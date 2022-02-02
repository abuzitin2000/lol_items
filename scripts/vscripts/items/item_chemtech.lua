item_chemtech = class({})

-- Modifier Linkers
LinkLuaModifier("item_chemtech_modifier", "items/item_chemtech", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("puffcap", "modifiers/puffcap", LUA_MODIFIER_MOTION_NONE)

function item_chemtech:GetIntrinsicModifierName()
	return "item_chemtech_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_chemtech_modifier = class({})

function item_chemtech_modifier:IsHidden()
	return true
end

function item_chemtech_modifier:IsPurgable()
	return false
end

function item_chemtech_modifier:RemoveOnDeath()
	return false
end

function item_chemtech_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_chemtech_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "puffcap", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
end

-- Removing Unique Passives
function item_chemtech_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local puffcap = parent:FindModifierByName("puffcap")
	if puffcap then
		puffcap:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
end