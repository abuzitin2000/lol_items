item_agility_cloak = class({})

-- Modifier Linkers
LinkLuaModifier("item_agility_cloak_modifier", "items/item_agility_cloak", LUA_MODIFIER_MOTION_NONE)

function item_agility_cloak:GetIntrinsicModifierName()
	return "item_agility_cloak_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_agility_cloak_modifier = class({})

function item_agility_cloak_modifier:IsHidden()
	return true
end

function item_agility_cloak_modifier:IsPurgable()
	return false
end

function item_agility_cloak_modifier:RemoveOnDeath()
	return false
end

function item_agility_cloak_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_agility_cloak_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_agility_cloak_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end