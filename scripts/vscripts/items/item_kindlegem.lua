item_kindlegem = class({})

-- Modifier Linkers
LinkLuaModifier("item_kindlegem_modifier", "items/item_kindlegem", LUA_MODIFIER_MOTION_NONE)

function item_kindlegem:GetIntrinsicModifierName()
	return "item_kindlegem_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_kindlegem_modifier = class({})

function item_kindlegem_modifier:IsHidden()
	return true
end

function item_kindlegem_modifier:IsPurgable()
	return false
end

function item_kindlegem_modifier:RemoveOnDeath()
	return false
end

function item_kindlegem_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_kindlegem_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_kindlegem_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_kindlegem_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_kindlegem_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end