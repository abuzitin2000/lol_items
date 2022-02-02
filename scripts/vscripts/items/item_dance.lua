item_dance = class({})

-- Modifier Linkers
LinkLuaModifier("item_dance_modifier", "items/item_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ignore_pain", "modifiers/ignore_pain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("defy", "modifiers/defy", LUA_MODIFIER_MOTION_NONE)

function item_dance:GetIntrinsicModifierName()
	return "item_dance_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dance_modifier = class({})

function item_dance_modifier:IsHidden()
	return true
end

function item_dance_modifier:IsPurgable()
	return false
end

function item_dance_modifier:RemoveOnDeath()
	return false
end

function item_dance_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dance_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "ignore_pain", {})
	parent:AddNewModifier(parent, ability, "defy", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_dance_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local ignore_pain = parent:FindModifierByName("ignore_pain")
	if ignore_pain then
		ignore_pain:Destroy()
	end

	local defy = parent:FindModifierByName("defy")
	if defy then
		defy:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_dance_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_dance_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end