item_bloodthirster = class({})

-- Modifier Linkers
LinkLuaModifier("item_bloodthirster_modifier", "items/item_bloodthirster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ichor", "modifiers/ichor", LUA_MODIFIER_MOTION_NONE)

function item_bloodthirster:GetIntrinsicModifierName()
	return "item_bloodthirster_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bloodthirster_modifier = class({})

function item_bloodthirster_modifier:IsHidden()
	return true
end

function item_bloodthirster_modifier:IsPurgable()
	return false
end

function item_bloodthirster_modifier:RemoveOnDeath()
	return false
end

function item_bloodthirster_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_bloodthirster_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "ichor", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
	unique.lifesteal = unique.lifesteal + ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Removing Unique Passives
function item_bloodthirster_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local ichor = parent:FindModifierByName("ichor")
	if ichor then
		ichor:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
	unique.lifesteal = unique.lifesteal - ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Stats
function item_bloodthirster_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_bloodthirster_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end