item_horizon_focus = class({})

-- Modifier Linkers
LinkLuaModifier("item_horizon_focus_modifier", "items/item_horizon_focus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hyper", "modifiers/hyper", LUA_MODIFIER_MOTION_NONE)

function item_horizon_focus:GetIntrinsicModifierName()
	return "item_horizon_focus_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_horizon_focus_modifier = class({})

function item_horizon_focus_modifier:IsHidden()
	return true
end

function item_horizon_focus_modifier:IsPurgable()
	return false
end

function item_horizon_focus_modifier:RemoveOnDeath()
	return false
end

function item_horizon_focus_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_horizon_focus_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "hyper", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_horizon_focus_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local hyper = parent:FindModifierByName("hyper")
	if hyper then
		hyper:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_horizon_focus_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_horizon_focus_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end