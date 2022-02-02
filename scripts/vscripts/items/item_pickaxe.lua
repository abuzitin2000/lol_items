item_pickaxe = class({})

-- Modifier Linkers
LinkLuaModifier("item_pickaxe_modifier", "items/item_pickaxe", LUA_MODIFIER_MOTION_NONE)

function item_pickaxe:GetIntrinsicModifierName()
	return "item_pickaxe_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_pickaxe_modifier = class({})

function item_pickaxe_modifier:IsHidden()
	return true
end

function item_pickaxe_modifier:IsPurgable()
	return false
end

function item_pickaxe_modifier:RemoveOnDeath()
	return false
end

function item_pickaxe_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_pickaxe_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_pickaxe_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end