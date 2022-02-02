item_abyssal = class({})

-- Modifier Linkers
LinkLuaModifier("item_abyssal_modifier", "items/item_abyssal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("unmake", "modifiers/unmake", LUA_MODIFIER_MOTION_NONE)

function item_abyssal:GetIntrinsicModifierName()
	return "item_abyssal_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_abyssal_modifier = class({})

function item_abyssal_modifier:IsHidden()
	return true
end

function item_abyssal_modifier:IsPurgable()
	return false
end

function item_abyssal_modifier:RemoveOnDeath()
	return false
end

function item_abyssal_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_abyssal_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "unmake", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_abyssal_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unmake = parent:FindModifierByName("unmake")
	if unmake then
		unmake:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_abyssal_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_abyssal_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end