item_leer = class({})

-- Modifier Linkers
LinkLuaModifier("item_leer_modifier", "items/item_leer", LUA_MODIFIER_MOTION_NONE)

function item_leer:GetIntrinsicModifierName()
	return "item_leer_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_leer_modifier = class({})

function item_leer_modifier:IsHidden()
	return true
end

function item_leer_modifier:IsPurgable()
	return false
end

function item_leer_modifier:RemoveOnDeath()
	return false
end

function item_leer_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_leer_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.omnivamp["leer"] = ability:GetSpecialValueFor("omnivamp")
end

-- Removing Unique Passives
function item_leer_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.omnivamp["leer"] = 0
end

-- Stats
function item_leer_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_leer_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end