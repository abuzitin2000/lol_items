item_shoulder = class({})

-- Modifier Linkers
LinkLuaModifier("item_shoulder_modifier", "items/item_shoulder", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spoils", "modifiers/spoils", LUA_MODIFIER_MOTION_NONE)

function item_shoulder:GetIntrinsicModifierName()
	return "item_shoulder_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_shoulder_modifier = class({})

function item_shoulder_modifier:IsHidden()
	return true
end

function item_shoulder_modifier:IsPurgable()
	return false
end

function item_shoulder_modifier:RemoveOnDeath()
	return false
end

function item_shoulder_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_shoulder_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spoils", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_shoulder_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local spoils = parent:FindModifierByName("spoils")
	if spoils then
		spoils:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_shoulder_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_shoulder_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_ad")
end

function item_shoulder_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end