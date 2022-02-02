item_dorans_ring = class({})

-- Modifier Linkers
LinkLuaModifier("item_dorans_ring_modifier", "items/item_dorans_ring", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("focus", "modifiers/focus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("drain", "modifiers/drain", LUA_MODIFIER_MOTION_NONE)

function item_dorans_ring:GetIntrinsicModifierName()
	return "item_dorans_ring_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dorans_ring_modifier = class({})

function item_dorans_ring_modifier:IsHidden()
	return true
end

function item_dorans_ring_modifier:IsPurgable()
	return false
end

function item_dorans_ring_modifier:RemoveOnDeath()
	return false
end

function item_dorans_ring_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dorans_ring_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "focus", {})
	parent:AddNewModifier(parent, ability, "drain", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_dorans_ring_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local focus = parent:FindModifierByName("focus")
	if focus then
		focus:Destroy()
	end

	local drain = parent:FindModifierByName("drain")
	if drain then
		drain:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_dorans_ring_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_dorans_ring_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end