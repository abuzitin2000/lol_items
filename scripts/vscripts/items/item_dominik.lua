item_dominik = class({})

-- Modifier Linkers
LinkLuaModifier("item_dominik_modifier", "items/item_dominik", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("giant", "modifiers/giant", LUA_MODIFIER_MOTION_NONE)

function item_dominik:GetIntrinsicModifierName()
	return "item_dominik_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dominik_modifier = class({})

function item_dominik_modifier:IsHidden()
	return true
end

function item_dominik_modifier:IsPurgable()
	return false
end

function item_dominik_modifier:RemoveOnDeath()
	return false
end

function item_dominik_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dominik_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "giant", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
	unique.percentage_pen["whisper"] = ability:GetSpecialValueFor("bonus_pen")
end

-- Removing Unique Passives
function item_dominik_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local giant = parent:FindModifierByName("giant")
	if giant then
		giant:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
	unique.percentage_pen["whisper"] = 0
end

-- Stats
function item_dominik_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_dominik_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end