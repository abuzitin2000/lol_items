item_nashor = class({})

-- Modifier Linkers
LinkLuaModifier("item_nashor_modifier", "items/item_nashor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icathian", "modifiers/icathian", LUA_MODIFIER_MOTION_NONE)

function item_nashor:GetIntrinsicModifierName()
	return "item_nashor_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_nashor_modifier = class({})

function item_nashor_modifier:IsHidden()
	return true
end

function item_nashor_modifier:IsPurgable()
	return false
end

function item_nashor_modifier:RemoveOnDeath()
	return false
end

function item_nashor_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_nashor_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "icathian", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_nashor_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local icathian = parent:FindModifierByName("icathian")
	if icathian then
		icathian:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_nashor_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_nashor_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end