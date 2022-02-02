item_warden = class({})

-- Modifier Linkers
LinkLuaModifier("item_warden_modifier", "items/item_warden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("rock_solid", "modifiers/rock_solid", LUA_MODIFIER_MOTION_NONE)

function item_warden:GetIntrinsicModifierName()
	return "item_warden_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_warden_modifier = class({})

function item_warden_modifier:IsHidden()
	return true
end

function item_warden_modifier:IsPurgable()
	return false
end

function item_warden_modifier:RemoveOnDeath()
	return false
end

function item_warden_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_warden_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "rock_solid", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

-- Removing Unique Passives
function item_warden_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local rock_solid = parent:FindModifierByName("rock_solid")
	if rock_solid then
		rock_solid:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end