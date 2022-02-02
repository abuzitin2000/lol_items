item_ruby = class({})

-- Modifier Linkers
LinkLuaModifier("item_ruby_modifier", "items/item_ruby", LUA_MODIFIER_MOTION_NONE)

function item_ruby:GetIntrinsicModifierName()
	return "item_ruby_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_ruby_modifier = class({})

function item_ruby_modifier:IsHidden()
	return true
end

function item_ruby_modifier:IsPurgable()
	return false
end

function item_ruby_modifier:RemoveOnDeath()
	return false
end

function item_ruby_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_ruby_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_ruby_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end