item_bead = class({})

-- Modifier Linkers
LinkLuaModifier("item_bead_modifier", "items/item_bead", LUA_MODIFIER_MOTION_NONE)

function item_bead:GetIntrinsicModifierName()
	return "item_bead_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bead_modifier = class({})

function item_bead_modifier:IsHidden()
	return true
end

function item_bead_modifier:IsPurgable()
	return false
end

function item_bead_modifier:RemoveOnDeath()
	return false
end

function item_bead_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_bead_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
end

-- Removing Unique Passives
function item_bead_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
end