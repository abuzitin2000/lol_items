item_null_magic = class({})

-- Modifier Linkers
LinkLuaModifier("item_null_magic_modifier", "items/item_null_magic", LUA_MODIFIER_MOTION_NONE)

function item_null_magic:GetIntrinsicModifierName()
	return "item_null_magic_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_null_magic_modifier = class({})

function item_null_magic_modifier:IsHidden()
	return true
end

function item_null_magic_modifier:IsPurgable()
	return false
end

function item_null_magic_modifier:RemoveOnDeath()
	return false
end

function item_null_magic_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_null_magic_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_null_magic_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end