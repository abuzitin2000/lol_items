item_executioner = class({})

-- Modifier Linkers
LinkLuaModifier("item_executioner_modifier", "items/item_executioner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("rend", "modifiers/rend", LUA_MODIFIER_MOTION_NONE)

function item_executioner:GetIntrinsicModifierName()
	return "item_executioner_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_executioner_modifier = class({})

function item_executioner_modifier:IsHidden()
	return true
end

function item_executioner_modifier:IsPurgable()
	return false
end

function item_executioner_modifier:RemoveOnDeath()
	return false
end

function item_executioner_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_executioner_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "rend", {})
end

-- Removing Unique Passives
function item_executioner_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local rend = parent:FindModifierByName("rend")
	if rend then
		rend:Destroy()
	end
end

-- Stats
function item_executioner_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_executioner_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end