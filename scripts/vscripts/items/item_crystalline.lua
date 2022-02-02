item_crystalline = class({})

-- Modifier Linkers
LinkLuaModifier("item_crystalline_modifier", "items/item_crystalline", LUA_MODIFIER_MOTION_NONE)

function item_crystalline:GetIntrinsicModifierName()
	return "item_crystalline_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_crystalline_modifier = class({})

function item_crystalline_modifier:IsHidden()
	return true
end

function item_crystalline_modifier:IsPurgable()
	return false
end

function item_crystalline_modifier:RemoveOnDeath()
	return false
end

function item_crystalline_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_crystalline_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
end

-- Removing Unique Passives
function item_crystalline_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
end

-- Stats
function item_crystalline_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_crystalline_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end