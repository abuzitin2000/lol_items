item_vow = class({})

-- Modifier Linkers
LinkLuaModifier("item_vow_modifier", "items/item_vow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sacrifice_caster", "modifiers/sacrifice", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sacrifice_target", "modifiers/sacrifice", LUA_MODIFIER_MOTION_NONE)

function item_vow:GetIntrinsicModifierName()
	return "item_vow_modifier"
end

function item_vow:CastFilterResultTarget(target)
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	
	if caster == target then
		return UF_FAIL_OTHER 
	end

	return UF_SUCCESS
end

function item_vow:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetCursorCastTarget()

	if target:HasModifier("sacrifice_target") then
		self:StartCooldown(10)
		return
	end

	if caster:HasModifier("sacrifice_caster") then
		caster:FindModifierByName("sacrifice_caster"):Destroy()
	end

	caster:AddNewModifier(caster, self, "sacrifice_caster", { target = target:entindex() })
	target:AddNewModifier(caster, self, "sacrifice_target", {})

	self:StartCooldown(self:GetSpecialValueFor("pledge_cooldown"))

	caster:EmitSound("DOTA_Item.Buckler.Activate")
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_vow_modifier = class({})

function item_vow_modifier:IsHidden()
	return true
end

function item_vow_modifier:IsPurgable()
	return false
end

function item_vow_modifier:RemoveOnDeath()
	return false
end

function item_vow_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_vow_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
end

-- Removing Unique Passives
function item_vow_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local sacrifice_caster = parent:FindModifierByName("sacrifice_caster")
	if sacrifice_caster then
		sacrifice_caster:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
end

-- Stats
function item_vow_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_vow_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end