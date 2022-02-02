item_archangel = class({})

-- Modifier Linkers
LinkLuaModifier("item_archangel_modifier", "items/item_archangel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("awe", "modifiers/awe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mana_charge", "modifiers/mana_charge", LUA_MODIFIER_MOTION_NONE)

function item_archangel:GetIntrinsicModifierName()
	return "item_archangel_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_archangel_modifier = class({})

function item_archangel_modifier:IsHidden()
	return true
end

function item_archangel_modifier:IsPurgable()
	return false
end

function item_archangel_modifier:RemoveOnDeath()
	return false
end

function item_archangel_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_archangel_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "awe", {})
	parent:AddNewModifier(parent, ability, "mana_charge", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_archangel_modifier:OnDestroy()
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
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_archangel_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_archangel_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end

function item_archangel_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end