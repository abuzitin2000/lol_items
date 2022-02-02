item_noonquiver = class({})

-- Modifier Linkers
LinkLuaModifier("item_noonquiver_modifier", "items/item_noonquiver", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("precision", "modifiers/precision", LUA_MODIFIER_MOTION_NONE)

function item_noonquiver:GetIntrinsicModifierName()
	return "item_noonquiver_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_noonquiver_modifier = class({})

function item_noonquiver_modifier:IsHidden()
	return true
end

function item_noonquiver_modifier:IsPurgable()
	return false
end

function item_noonquiver_modifier:RemoveOnDeath()
	return false
end

function item_noonquiver_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_noonquiver_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "precision", {})
end

-- Removing Unique Passives
function item_noonquiver_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local precision = parent:FindModifierByName("precision")
	if precision then
		precision:Destroy()
	end
end

-- Stats
function item_noonquiver_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_noonquiver_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_noonquiver_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end