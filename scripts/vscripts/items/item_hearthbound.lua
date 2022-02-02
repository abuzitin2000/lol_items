item_hearthbound = class({})

-- Modifier Linkers
LinkLuaModifier("item_hearthbound_modifier", "items/item_hearthbound", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("nimble", "modifiers/nimble", LUA_MODIFIER_MOTION_NONE)

function item_hearthbound:GetIntrinsicModifierName()
	return "item_hearthbound_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_hearthbound_modifier = class({})

function item_hearthbound_modifier:IsHidden()
	return true
end

function item_hearthbound_modifier:IsPurgable()
	return false
end

function item_hearthbound_modifier:RemoveOnDeath()
	return false
end

function item_hearthbound_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_hearthbound_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "nimble", {})
end

-- Removing Unique Passives
function item_hearthbound_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local nimble = parent:FindModifierByName("nimble")
	if nimble then
		nimble:Destroy()
	end
end

-- Stats
function item_hearthbound_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_hearthbound_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_hearthbound_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end