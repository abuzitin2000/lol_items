item_zeal = class({})

-- Modifier Linkers
LinkLuaModifier("item_zeal_modifier", "items/item_zeal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("zealous", "modifiers/zealous", LUA_MODIFIER_MOTION_NONE)

function item_zeal:GetIntrinsicModifierName()
	return "item_zeal_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_zeal_modifier = class({})

function item_zeal_modifier:IsHidden()
	return true
end

function item_zeal_modifier:IsPurgable()
	return false
end

function item_zeal_modifier:RemoveOnDeath()
	return false
end

function item_zeal_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_zeal_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "zealous", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_zeal_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local zealous = parent:FindModifierByName("zealous")
	if zealous then
		zealous:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end

-- Stats
function item_zeal_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_zeal_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end