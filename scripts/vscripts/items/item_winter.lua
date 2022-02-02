item_winter = class({})

-- Modifier Linkers
LinkLuaModifier("item_winter_modifier", "items/item_winter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("awe", "modifiers/awe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mana_charge", "modifiers/mana_charge", LUA_MODIFIER_MOTION_NONE)

function item_winter:GetIntrinsicModifierName()
	return "item_winter_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_winter_modifier = class({})

function item_winter_modifier:IsHidden()
	return true
end

function item_winter_modifier:IsPurgable()
	return false
end

function item_winter_modifier:RemoveOnDeath()
	return false
end

function item_winter_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_winter_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "awe", {})
	parent:AddNewModifier(parent, ability, "mana_charge", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_winter_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local awe = parent:FindModifierByName("awe")
	if awe then
		awe:Destroy()
	end

	local mana_charge = parent:FindModifierByName("mana_charge")
	if mana_charge then
		mana_charge:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_winter_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_winter_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end

function item_winter_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end