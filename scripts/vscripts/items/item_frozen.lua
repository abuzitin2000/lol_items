item_frozen = class({})

-- Modifier Linkers
LinkLuaModifier("item_frozen_modifier", "items/item_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("rock_solid", "modifiers/rock_solid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("winter", "modifiers/winter", LUA_MODIFIER_MOTION_NONE)

function item_frozen:GetIntrinsicModifierName()
	return "item_frozen_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_frozen_modifier = class({})

function item_frozen_modifier:IsHidden()
	return true
end

function item_frozen_modifier:IsPurgable()
	return false
end

function item_frozen_modifier:RemoveOnDeath()
	return false
end

function item_frozen_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_frozen_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "rock_solid", {})
	parent:AddNewModifier(parent, ability, "winter", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_frozen_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local rock_solid = parent:FindModifierByName("rock_solid")
	if rock_solid then
		rock_solid:Destroy()
	end

	local winter = parent:FindModifierByName("winter")
	if winter then
		winter:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_frozen_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS
	}
	return funcs
end

function item_frozen_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end