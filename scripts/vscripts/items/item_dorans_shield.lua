item_dorans_shield = class({})

-- Modifier Linkers
LinkLuaModifier("item_dorans_shield_modifier", "items/item_dorans_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("focus", "modifiers/focus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("recovery", "modifiers/recovery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("endure", "modifiers/endure", LUA_MODIFIER_MOTION_NONE)

function item_dorans_shield:GetIntrinsicModifierName()
	return "item_dorans_shield_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dorans_shield_modifier = class({})

function item_dorans_shield_modifier:IsHidden()
	return true
end

function item_dorans_shield_modifier:IsPurgable()
	return false
end

function item_dorans_shield_modifier:RemoveOnDeath()
	return false
end

function item_dorans_shield_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dorans_shield_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "focus", {})
	parent:AddNewModifier(parent, ability, "recovery", {})
	parent:AddNewModifier(parent, ability, "endure", {})
end

-- Removing Unique Passives
function item_dorans_shield_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local focus = parent:FindModifierByName("focus")
	if focus then
		focus:Destroy()
	end

	local recovery = parent:FindModifierByName("recovery")
	if recovery then
		recovery:Destroy()
	end
	
	local endure = parent:FindModifierByName("endure")
	if endure then
		endure:Destroy()
	end
end

-- Stats
function item_dorans_shield_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_dorans_shield_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end