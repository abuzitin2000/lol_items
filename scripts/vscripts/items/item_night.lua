item_night = class({})

-- Modifier Linkers
LinkLuaModifier("item_night_modifier", "items/item_night", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("annul", "modifiers/annul", LUA_MODIFIER_MOTION_NONE)

function item_night:GetIntrinsicModifierName()
	return "item_night_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_night_modifier = class({})

function item_night_modifier:IsHidden()
	return true
end

function item_night_modifier:IsPurgable()
	return false
end

function item_night_modifier:RemoveOnDeath()
	return false
end

function item_night_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_night_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "annul", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.flat_pen["night"] = ability:GetSpecialValueFor("bonus_pen")
end

-- Removing Unique Passives
function item_night_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local annul = parent:FindModifierByName("annul")
	if annul then
		annul:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.flat_pen["night"] = 0
end

-- Stats
function item_night_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_night_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

function item_night_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end