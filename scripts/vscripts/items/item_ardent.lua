item_ardent = class({})

-- Modifier Linkers
LinkLuaModifier("item_ardent_modifier", "items/item_ardent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sanctify", "modifiers/sanctify", LUA_MODIFIER_MOTION_NONE)

function item_ardent:GetIntrinsicModifierName()
	return "item_ardent_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_ardent_modifier = class({})

function item_ardent_modifier:IsHidden()
	return true
end

function item_ardent_modifier:IsPurgable()
	return false
end

function item_ardent_modifier:RemoveOnDeath()
	return false
end

function item_ardent_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_ardent_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "sanctify", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power + ability:GetSpecialValueFor("bonus_heal_power")
end

-- Removing Unique Passives
function item_ardent_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local sanctify = parent:FindModifierByName("sanctify")
	if sanctify then
		sanctify:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power - ability:GetSpecialValueFor("bonus_heal_power")
end