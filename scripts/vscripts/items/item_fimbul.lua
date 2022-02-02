item_fimbul = class({})

-- Modifier Linkers
LinkLuaModifier("item_fimbul_modifier", "items/item_fimbul", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("awe", "modifiers/awe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("everlast", "modifiers/everlast", LUA_MODIFIER_MOTION_NONE)

function item_fimbul:GetIntrinsicModifierName()
	return "item_fimbul_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_fimbul_modifier = class({})

function item_fimbul_modifier:IsHidden()
	return true
end

function item_fimbul_modifier:IsPurgable()
	return false
end

function item_fimbul_modifier:RemoveOnDeath()
	return false
end

function item_fimbul_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_fimbul_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "awe", {})
	parent:AddNewModifier(parent, ability, "everlast", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_fimbul_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local awe = parent:FindModifierByName("awe")
	if awe then
		awe:Destroy()
	end

	local everlast = parent:FindModifierByName("everlast")
	if everlast then
		everlast:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_fimbul_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_fimbul_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end

function item_fimbul_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end