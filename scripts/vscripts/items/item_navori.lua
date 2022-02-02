item_navori = class({})

-- Modifier Linkers
LinkLuaModifier("item_navori_modifier", "items/item_navori", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("deft", "modifiers/deft", LUA_MODIFIER_MOTION_NONE)

function item_navori:GetIntrinsicModifierName()
	return "item_navori_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_navori_modifier = class({})

function item_navori_modifier:IsHidden()
	return true
end

function item_navori_modifier:IsPurgable()
	return false
end

function item_navori_modifier:RemoveOnDeath()
	return false
end

function item_navori_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_navori_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "deft", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_navori_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local deft = parent:FindModifierByName("deft")
	if deft then
		deft:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_navori_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_navori_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end