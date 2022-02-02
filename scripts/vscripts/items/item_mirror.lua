item_mirror = class({})

-- Modifier Linkers
LinkLuaModifier("item_mirror_modifier", "items/item_mirror", LUA_MODIFIER_MOTION_NONE)

function item_mirror:GetIntrinsicModifierName()
	return "item_mirror_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mirror_modifier = class({})

function item_mirror_modifier:IsHidden()
	return true
end

function item_mirror_modifier:IsPurgable()
	return false
end

function item_mirror_modifier:RemoveOnDeath()
	return false
end

function item_mirror_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_mirror_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
end

-- Removing Unique Passives
function item_mirror_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
end