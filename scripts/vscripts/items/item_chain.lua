item_chain = class({})

-- Modifier Linkers
LinkLuaModifier("item_chain_modifier", "items/item_chain", LUA_MODIFIER_MOTION_NONE)

function item_chain:GetIntrinsicModifierName()
	return "item_chain_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_chain_modifier = class({})

function item_chain_modifier:IsHidden()
	return true
end

function item_chain_modifier:IsPurgable()
	return false
end

function item_chain_modifier:RemoveOnDeath()
	return false
end

function item_chain_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_chain_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

function item_chain_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end