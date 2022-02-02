item_swiftness_boot = class({})

-- Modifier Linkers
LinkLuaModifier("item_swiftness_boot_modifier", "items/item_swiftness_boot", LUA_MODIFIER_MOTION_NONE)

function item_swiftness_boot:GetIntrinsicModifierName()
	return "item_swiftness_boot_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_swiftness_boot_modifier = class({})

function item_swiftness_boot_modifier:IsHidden()
	return true
end

function item_swiftness_boot_modifier:IsPurgable()
	return false
end

function item_swiftness_boot_modifier:RemoveOnDeath()
	return false
end

-- Stats
function item_swiftness_boot_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE
	}
	return funcs
end

function item_swiftness_boot_modifier:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_speed")
end

function item_swiftness_boot_modifier:GetModifierMoveSpeedReductionPercentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return 100 - ability:GetSpecialValueFor("slow_resist")
end