item_legion = class({})

-- Modifier Linkers
LinkLuaModifier("item_legion_modifier", "items/item_legion", LUA_MODIFIER_MOTION_NONE)

function item_legion:GetIntrinsicModifierName()
	return "item_legion_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_legion_modifier = class({})

function item_legion_modifier:IsHidden()
	return true
end

function item_legion_modifier:IsPurgable()
	return false
end

function item_legion_modifier:RemoveOnDeath()
	return false
end

function item_legion_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_legion_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

function item_legion_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end