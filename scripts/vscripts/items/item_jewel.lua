item_jewel = class({})

-- Modifier Linkers
LinkLuaModifier("item_jewel_modifier", "items/item_jewel", LUA_MODIFIER_MOTION_NONE)

function item_jewel:GetIntrinsicModifierName()
	return "item_jewel_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_jewel_modifier = class({})

function item_jewel_modifier:IsHidden()
	return true
end

function item_jewel_modifier:IsPurgable()
	return false
end

function item_jewel_modifier:RemoveOnDeath()
	return false
end

function item_jewel_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_jewel_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.percentage_magic_pen["jewel"] = ability:GetSpecialValueFor("bonus_magic_pen")
end

-- Removing Unique Passives
function item_jewel_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.percentage_magic_pen["jewel"] = 0
end