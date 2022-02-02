item_rageknife = class({})

-- Modifier Linkers
LinkLuaModifier("item_rageknife_modifier", "items/item_rageknife", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("wrath", "modifiers/wrath", LUA_MODIFIER_MOTION_NONE)

function item_rageknife:GetIntrinsicModifierName()
	return "item_rageknife_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_rageknife_modifier = class({})

function item_rageknife_modifier:IsHidden()
	return true
end

function item_rageknife_modifier:IsPurgable()
	return false
end

function item_rageknife_modifier:RemoveOnDeath()
	return false
end

function item_rageknife_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_rageknife_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "wrath", {})
end

-- Removing Unique Passives
function item_rageknife_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local wrath = parent:FindModifierByName("wrath")
	if wrath then
		wrath:Destroy()
	end
end

-- Stats
function item_rageknife_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_rageknife_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end