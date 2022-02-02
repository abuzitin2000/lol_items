item_vampiric = class({})

-- Modifier Linkers
LinkLuaModifier("item_vampiric_modifier", "items/item_vampiric", LUA_MODIFIER_MOTION_NONE)

function item_vampiric:GetIntrinsicModifierName()
	return "item_vampiric_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_vampiric_modifier = class({})

function item_vampiric_modifier:IsHidden()
	return true
end

function item_vampiric_modifier:IsPurgable()
	return false
end

function item_vampiric_modifier:RemoveOnDeath()
	return false
end

function item_vampiric_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_vampiric_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.lifesteal = unique.lifesteal + ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Removing Unique Passives
function item_vampiric_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.lifesteal = unique.lifesteal - ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Stats
function item_vampiric_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_vampiric_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end