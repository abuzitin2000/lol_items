item_sapphire = class({})

-- Modifier Linkers
LinkLuaModifier("item_sapphire_modifier", "items/item_sapphire", LUA_MODIFIER_MOTION_NONE)

function item_sapphire:GetIntrinsicModifierName()
	return "item_sapphire_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_sapphire_modifier = class({})

function item_sapphire_modifier:IsHidden()
	return true
end

function item_sapphire_modifier:IsPurgable()
	return false
end

function item_sapphire_modifier:RemoveOnDeath()
	return false
end

function item_sapphire_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_sapphire_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS
	}
	return funcs
end

function item_sapphire_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end