item_dorans_blade = class({})

-- Modifier Linkers
LinkLuaModifier("item_dorans_blade_modifier", "items/item_dorans_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("warmonger", "modifiers/warmonger", LUA_MODIFIER_MOTION_NONE)

function item_dorans_blade:GetIntrinsicModifierName()
	return "item_dorans_blade_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dorans_blade_modifier = class({})

function item_dorans_blade_modifier:IsHidden()
	return true
end

function item_dorans_blade_modifier:IsPurgable()
	return false
end

function item_dorans_blade_modifier:RemoveOnDeath()
	return false
end

function item_dorans_blade_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dorans_blade_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "warmonger", {})
end

-- Removing Unique Passives
function item_dorans_blade_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local warmonger = parent:FindModifierByName("warmonger")
	if warmonger then
		warmonger:Destroy()
	end
end

-- Stats
function item_dorans_blade_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_dorans_blade_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_dorans_blade_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end