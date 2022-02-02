item_negatron = class({})

-- Modifier Linkers
LinkLuaModifier("item_negatron_modifier", "items/item_negatron", LUA_MODIFIER_MOTION_NONE)

function item_negatron:GetIntrinsicModifierName()
	return "item_negatron_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_negatron_modifier = class({})

function item_negatron_modifier:IsHidden()
	return true
end

function item_negatron_modifier:IsPurgable()
	return false
end

function item_negatron_modifier:RemoveOnDeath()
	return false
end

function item_negatron_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_negatron_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_negatron_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end