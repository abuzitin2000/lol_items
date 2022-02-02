item_codex = class({})

-- Modifier Linkers
LinkLuaModifier("item_codex_modifier", "items/item_codex", LUA_MODIFIER_MOTION_NONE)

function item_codex:GetIntrinsicModifierName()
	return "item_codex_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_codex_modifier = class({})

function item_codex_modifier:IsHidden()
	return true
end

function item_codex_modifier:IsPurgable()
	return false
end

function item_codex_modifier:RemoveOnDeath()
	return false
end

function item_codex_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_codex_modifier:OnCreated()
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
function item_codex_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end