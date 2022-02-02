item_tear = class({})

-- Modifier Linkers
LinkLuaModifier("item_tear_modifier", "items/item_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("focus", "modifiers/focus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mana_charge", "modifiers/mana_charge", LUA_MODIFIER_MOTION_NONE)

function item_tear:GetIntrinsicModifierName()
	return "item_tear_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_tear_modifier = class({})

function item_tear_modifier:IsHidden()
	return true
end

function item_tear_modifier:IsPurgable()
	return false
end

function item_tear_modifier:RemoveOnDeath()
	return false
end

function item_tear_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_tear_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "focus", {})
	parent:AddNewModifier(parent, ability, "mana_charge", {})
end

-- Removing Unique Passives
function item_tear_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local focus = parent:FindModifierByName("focus")
	if focus then
		focus:Destroy()
	end

	local mana_charge = parent:FindModifierByName("mana_charge")
	if mana_charge then
		mana_charge:Destroy()
	end
end

-- Stats
function item_tear_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS
	}
	return funcs
end

function item_tear_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end