item_manamune = class({})

-- Modifier Linkers
LinkLuaModifier("item_manamune_modifier", "items/item_manamune", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("awe", "modifiers/awe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mana_charge", "modifiers/mana_charge", LUA_MODIFIER_MOTION_NONE)

function item_manamune:GetIntrinsicModifierName()
	return "item_manamune_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_manamune_modifier = class({})

function item_manamune_modifier:IsHidden()
	return true
end

function item_manamune_modifier:IsPurgable()
	return false
end

function item_manamune_modifier:RemoveOnDeath()
	return false
end

function item_manamune_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_manamune_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "awe", {})
	parent:AddNewModifier(parent, ability, "mana_charge", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_manamune_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local awe = parent:FindModifierByName("awe")
	if awe then
		awe:Destroy()
	end

	local mana_charge = parent:FindModifierByName("mana_charge")
	if mana_charge then
		mana_charge:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_manamune_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_manamune_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end

function item_manamune_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end