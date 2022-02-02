item_cloth = class({})

-- Modifier Linkers
LinkLuaModifier("item_cloth_modifier", "items/item_cloth", LUA_MODIFIER_MOTION_NONE)

function item_cloth:GetIntrinsicModifierName()
	return "item_cloth_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_cloth_modifier = class({})

function item_cloth_modifier:IsHidden()
	return true
end

function item_cloth_modifier:IsPurgable()
	return false
end

function item_cloth_modifier:RemoveOnDeath()
	return false
end

function item_cloth_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_cloth_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

function item_cloth_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end