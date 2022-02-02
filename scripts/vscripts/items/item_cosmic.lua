item_cosmic = class({})

-- Modifier Linkers
LinkLuaModifier("item_cosmic_modifier", "items/item_cosmic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spelldance", "modifiers/spelldance", LUA_MODIFIER_MOTION_NONE)

function item_cosmic:GetIntrinsicModifierName()
	return "item_cosmic_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_cosmic_modifier = class({})

function item_cosmic_modifier:IsHidden()
	return true
end

function item_cosmic_modifier:IsPurgable()
	return false
end

function item_cosmic_modifier:RemoveOnDeath()
	return false
end

function item_cosmic_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_cosmic_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spelldance", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_cosmic_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local spelldance = parent:FindModifierByName("spelldance")
	if spelldance then
		spelldance:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_cosmic_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_cosmic_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end

function item_cosmic_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end