item_essence_reaver = class({})

-- Modifier Linkers
LinkLuaModifier("item_essence_reaver_modifier", "items/item_essence_reaver", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spellblade", "modifiers/spellblade", LUA_MODIFIER_MOTION_NONE)

function item_essence_reaver:GetIntrinsicModifierName()
	return "item_essence_reaver_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_essence_reaver_modifier = class({})

function item_essence_reaver_modifier:IsHidden()
	return true
end

function item_essence_reaver_modifier:IsPurgable()
	return false
end

function item_essence_reaver_modifier:RemoveOnDeath()
	return false
end

function item_essence_reaver_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_essence_reaver_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spellblade", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_essence_reaver_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local spellblade = parent:FindModifierByName("spellblade")
	if spellblade then
		spellblade:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_essence_reaver_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_essence_reaver_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end