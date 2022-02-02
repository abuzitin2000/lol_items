item_faerie = class({})

-- Modifier Linkers
LinkLuaModifier("item_faerie_modifier", "items/item_faerie", LUA_MODIFIER_MOTION_NONE)

function item_faerie:GetIntrinsicModifierName()
	return "item_faerie_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_faerie_modifier = class({})

function item_faerie_modifier:IsHidden()
	return true
end

function item_faerie_modifier:IsPurgable()
	return false
end

function item_faerie_modifier:RemoveOnDeath()
	return false
end

function item_faerie_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_faerie_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
end

-- Removing Unique Passives
function item_faerie_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
end