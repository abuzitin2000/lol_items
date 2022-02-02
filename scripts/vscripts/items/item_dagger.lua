item_dagger = class({})

-- Modifier Linkers
LinkLuaModifier("item_dagger_modifier", "items/item_dagger", LUA_MODIFIER_MOTION_NONE)

function item_dagger:GetIntrinsicModifierName()
	return "item_dagger_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dagger_modifier = class({})

function item_dagger_modifier:IsHidden()
	return true
end

function item_dagger_modifier:IsPurgable()
	return false
end

function item_dagger_modifier:RemoveOnDeath()
	return false
end

function item_dagger_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_dagger_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_dagger_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end