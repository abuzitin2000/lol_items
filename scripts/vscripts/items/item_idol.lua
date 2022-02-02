item_idol = class({})

-- Modifier Linkers
LinkLuaModifier("item_idol_modifier", "items/item_idol", LUA_MODIFIER_MOTION_NONE)

function item_idol:GetIntrinsicModifierName()
	return "item_idol_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_idol_modifier = class({})

function item_idol_modifier:IsHidden()
	return true
end

function item_idol_modifier:IsPurgable()
	return false
end

function item_idol_modifier:RemoveOnDeath()
	return false
end

function item_idol_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_idol_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power + ability:GetSpecialValueFor("bonus_heal_power")
end

-- Removing Unique Passives
function item_idol_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power - ability:GetSpecialValueFor("bonus_heal_power")
end