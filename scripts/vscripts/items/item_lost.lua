item_lost = class({})

-- Modifier Linkers
LinkLuaModifier("item_lost_modifier", "items/item_lost", LUA_MODIFIER_MOTION_NONE)

function item_lost:GetIntrinsicModifierName()
	return "item_lost_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_lost_modifier = class({})

function item_lost_modifier:IsHidden()
	return true
end

function item_lost_modifier:IsPurgable()
	return false
end

function item_lost_modifier:RemoveOnDeath()
	return false
end

function item_lost_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_lost_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_lost_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_lost_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS
	}
	return funcs
end

function item_lost_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end