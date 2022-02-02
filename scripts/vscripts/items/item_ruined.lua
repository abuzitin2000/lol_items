item_ruined = class({})

-- Modifier Linkers
LinkLuaModifier("item_ruined_modifier", "items/item_ruined", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mist", "modifiers/mist", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("siphon", "modifiers/siphon", LUA_MODIFIER_MOTION_NONE)

function item_ruined:GetIntrinsicModifierName()
	return "item_ruined_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_ruined_modifier = class({})

function item_ruined_modifier:IsHidden()
	return true
end

function item_ruined_modifier:IsPurgable()
	return false
end

function item_ruined_modifier:RemoveOnDeath()
	return false
end

function item_ruined_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_ruined_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "mist", {})
	parent:AddNewModifier(parent, ability, "siphon", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.lifesteal = unique.lifesteal + ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Removing Unique Passives
function item_ruined_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local mist = parent:FindModifierByName("mist")
	if mist then
		mist:Destroy()
	end

	local siphon = parent:FindModifierByName("siphon")
	if siphon then
		siphon:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.lifesteal = unique.lifesteal - ability:GetSpecialValueFor("bonus_lifesteal")
end

-- Stats
function item_ruined_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_ruined_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_ruined_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end