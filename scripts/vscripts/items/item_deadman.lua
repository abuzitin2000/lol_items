item_deadman = class({})

-- Modifier Linkers
LinkLuaModifier("item_deadman_modifier", "items/item_deadman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shipwrecker", "modifiers/shipwrecker", LUA_MODIFIER_MOTION_NONE)

function item_deadman:GetIntrinsicModifierName()
	return "item_deadman_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_deadman_modifier = class({})

function item_deadman_modifier:IsHidden()
	return true
end

function item_deadman_modifier:IsPurgable()
	return false
end

function item_deadman_modifier:RemoveOnDeath()
	return false
end

function item_deadman_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_deadman_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "shipwrecker", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

-- Removing Unique Passives
function item_deadman_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local shipwrecker = parent:FindModifierByName("shipwrecker")
	if shipwrecker then
		shipwrecker:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end

-- Stats
function item_deadman_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_deadman_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end

function item_deadman_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end