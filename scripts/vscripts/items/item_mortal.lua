item_mortal = class({})

-- Modifier Linkers
LinkLuaModifier("item_mortal_modifier", "items/item_mortal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sepsis", "modifiers/sepsis", LUA_MODIFIER_MOTION_NONE)

function item_mortal:GetIntrinsicModifierName()
	return "item_mortal_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mortal_modifier = class({})

function item_mortal_modifier:IsHidden()
	return true
end

function item_mortal_modifier:IsPurgable()
	return false
end

function item_mortal_modifier:RemoveOnDeath()
	return false
end

function item_mortal_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_mortal_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "sepsis", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_mortal_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local sepsis = parent:FindModifierByName("sepsis")
	if sepsis then
		sepsis:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end

-- Stats
function item_mortal_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_mortal_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

function item_mortal_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end

function item_mortal_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end