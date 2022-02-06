item_rapid = class({})

-- Modifier Linkers
LinkLuaModifier("item_rapid_modifier", "items/item_rapid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("energized", "modifiers/energized", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sharpshooter", "modifiers/sharpshooter", LUA_MODIFIER_MOTION_NONE)

function item_rapid:GetIntrinsicModifierName()
	return "item_rapid_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_rapid_modifier = class({})

function item_rapid_modifier:IsHidden()
	return true
end

function item_rapid_modifier:IsPurgable()
	return false
end

function item_rapid_modifier:RemoveOnDeath()
	return false
end

function item_rapid_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_rapid_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "energized", {})
	parent:AddNewModifier(parent, ability, "sharpshooter", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_rapid_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local energized = parent:FindModifierByName("energized")
	if energized then
		energized:Destroy()
	end

	local sharpshooter = parent:FindModifierByName("sharpshooter")
	if sharpshooter then
		sharpshooter:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end

-- Stats
function item_rapid_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_rapid_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end

function item_rapid_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end