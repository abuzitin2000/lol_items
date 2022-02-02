item_large = class({})

-- Modifier Linkers
LinkLuaModifier("item_large_modifier", "items/item_large", LUA_MODIFIER_MOTION_NONE)

function item_large:GetIntrinsicModifierName()
	return "item_large_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_large_modifier = class({})

function item_large_modifier:IsHidden()
	return true
end

function item_large_modifier:IsPurgable()
	return false
end

function item_large_modifier:RemoveOnDeath()
	return false
end

function item_large_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_large_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_large_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end