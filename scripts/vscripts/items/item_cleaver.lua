item_cleaver = class({})

-- Modifier Linkers
LinkLuaModifier("item_cleaver_modifier", "items/item_cleaver", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("carve", "modifiers/carve", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("rage", "modifiers/rage", LUA_MODIFIER_MOTION_NONE)

function item_cleaver:GetIntrinsicModifierName()
	return "item_cleaver_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_cleaver_modifier = class({})

function item_cleaver_modifier:IsHidden()
	return true
end

function item_cleaver_modifier:IsPurgable()
	return false
end

function item_cleaver_modifier:RemoveOnDeath()
	return false
end

function item_cleaver_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_cleaver_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "carve", {})
	parent:AddNewModifier(parent, ability, "rage", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_cleaver_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local carve = parent:FindModifierByName("carve")
	if carve then
		carve:Destroy()
	end

	local rage = parent:FindModifierByName("rage")
	if rage then
		rage:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_cleaver_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_cleaver_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

function item_cleaver_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end