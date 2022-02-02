item_alternator = class({})

-- Modifier Linkers
LinkLuaModifier("item_alternator_modifier", "items/item_alternator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("revved", "modifiers/revved", LUA_MODIFIER_MOTION_NONE)

function item_alternator:GetIntrinsicModifierName()
	return "item_alternator_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_alternator_modifier = class({})

function item_alternator_modifier:IsHidden()
	return true
end

function item_alternator_modifier:IsPurgable()
	return false
end

function item_alternator_modifier:RemoveOnDeath()
	return false
end

function item_alternator_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_alternator_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "revved", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_alternator_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local revved = parent:FindModifierByName("revved")
	if revved then
		revved:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_alternator_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_alternator_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end