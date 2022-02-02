item_infinity = class({})

-- Modifier Linkers
LinkLuaModifier("item_infinity_modifier", "items/item_infinity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("perfection", "modifiers/perfection", LUA_MODIFIER_MOTION_NONE)

function item_infinity:GetIntrinsicModifierName()
	return "item_infinity_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_infinity_modifier = class({})

function item_infinity_modifier:IsHidden()
	return true
end

function item_infinity_modifier:IsPurgable()
	return false
end

function item_infinity_modifier:RemoveOnDeath()
	return false
end

function item_infinity_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_infinity_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "perfection", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
end

-- Removing Unique Passives
function item_infinity_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local perfection = parent:FindModifierByName("perfection")
	if perfection then
		perfection:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
end

-- Stats
function item_infinity_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_infinity_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end