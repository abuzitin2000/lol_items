item_long = class({})

-- Modifier Linkers
LinkLuaModifier("item_long_modifier", "items/item_long", LUA_MODIFIER_MOTION_NONE)

function item_long:GetIntrinsicModifierName()
	return "item_long_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_long_modifier = class({})

function item_long_modifier:IsHidden()
	return true
end

function item_long_modifier:IsPurgable()
	return false
end

function item_long_modifier:RemoveOnDeath()
	return false
end

function item_long_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_long_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_long_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end