item_dancer = class({})

-- Modifier Linkers
LinkLuaModifier("item_dancer_modifier", "items/item_dancer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("waltz", "modifiers/waltz", LUA_MODIFIER_MOTION_NONE)

function item_dancer:GetIntrinsicModifierName()
	return "item_dancer_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dancer_modifier = class({})

function item_dancer_modifier:IsHidden()
	return true
end

function item_dancer_modifier:IsPurgable()
	return false
end

function item_dancer_modifier:RemoveOnDeath()
	return false
end

function item_dancer_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dancer_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "waltz", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_dancer_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local waltz = parent:FindModifierByName("waltz")
	if waltz then
		waltz:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end

-- Stats
function item_dancer_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_dancer_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

function item_dancer_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end

function item_dancer_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end