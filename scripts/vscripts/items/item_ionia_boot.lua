item_ionia_boot = class({})

-- Modifier Linkers
LinkLuaModifier("item_ionia_boot_modifier", "items/item_ionia_boot", LUA_MODIFIER_MOTION_NONE)

function item_ionia_boot:GetIntrinsicModifierName()
	return "item_ionia_boot_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_ionia_boot_modifier = class({})

function item_ionia_boot_modifier:IsHidden()
	return true
end

function item_ionia_boot_modifier:IsPurgable()
	return false
end

function item_ionia_boot_modifier:RemoveOnDeath()
	return false
end

-- Adding Unique Passives
function item_ionia_boot_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_ionia_boot_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_ionia_boot_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_ionia_boot_modifier:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_speed")
end