item_spellthief = class({})

-- Modifier Linkers
LinkLuaModifier("item_spellthief_modifier", "items/item_spellthief", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("tribute", "modifiers/tribute", LUA_MODIFIER_MOTION_NONE)

function item_spellthief:GetIntrinsicModifierName()
	return "item_spellthief_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_spellthief_modifier = class({})

function item_spellthief_modifier:IsHidden()
	return true
end

function item_spellthief_modifier:IsPurgable()
	return false
end

function item_spellthief_modifier:RemoveOnDeath()
	return false
end

function item_spellthief_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_spellthief_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "tribute", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_spellthief_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local tribute = parent:FindModifierByName("tribute")
	if tribute then
		tribute:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_spellthief_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_spellthief_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end