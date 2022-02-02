item_giant_belt = class({})

-- Modifier Linkers
LinkLuaModifier("item_giant_belt_modifier", "items/item_giant_belt", LUA_MODIFIER_MOTION_NONE)

function item_giant_belt:GetIntrinsicModifierName()
	return "item_giant_belt_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_giant_belt_modifier = class({})

function item_giant_belt_modifier:IsHidden()
	return true
end

function item_giant_belt_modifier:IsPurgable()
	return false
end

function item_giant_belt_modifier:RemoveOnDeath()
	return false
end

function item_giant_belt_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_giant_belt_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_giant_belt_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end