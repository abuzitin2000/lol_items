item_bf = class({})

-- Modifier Linkers
LinkLuaModifier("item_bf_modifier", "items/item_bf", LUA_MODIFIER_MOTION_NONE)

function item_bf:GetIntrinsicModifierName()
	return "item_bf_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bf_modifier = class({})

function item_bf_modifier:IsHidden()
	return true
end

function item_bf_modifier:IsPurgable()
	return false
end

function item_bf_modifier:RemoveOnDeath()
	return false
end

function item_bf_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_bf_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_bf_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end