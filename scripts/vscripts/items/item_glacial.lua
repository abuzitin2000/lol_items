item_glacial = class({})

-- Modifier Linkers
LinkLuaModifier("item_glacial_modifier", "items/item_glacial", LUA_MODIFIER_MOTION_NONE)

function item_glacial:GetIntrinsicModifierName()
	return "item_glacial_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_glacial_modifier = class({})

function item_glacial_modifier:IsHidden()
	return true
end

function item_glacial_modifier:IsPurgable()
	return false
end

function item_glacial_modifier:RemoveOnDeath()
	return false
end

function item_glacial_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_glacial_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_glacial_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_glacial_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS
	}
	return funcs
end

function item_glacial_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end