item_lich = class({})

-- Modifier Linkers
LinkLuaModifier("item_lich_modifier", "items/item_lich", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spellblade", "modifiers/spellblade", LUA_MODIFIER_MOTION_NONE)

function item_lich:GetIntrinsicModifierName()
	return "item_lich_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_lich_modifier = class({})

function item_lich_modifier:IsHidden()
	return true
end

function item_lich_modifier:IsPurgable()
	return false
end

function item_lich_modifier:RemoveOnDeath()
	return false
end

function item_lich_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_lich_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spellblade", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_lich_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local spellblade = parent:FindModifierByName("spellblade")
	if spellblade then
		spellblade:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_lich_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_lich_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end