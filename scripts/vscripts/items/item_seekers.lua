item_seekers = class({})

-- Modifier Linkers
LinkLuaModifier("item_seekers_modifier", "items/item_seekers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("witchs_path", "modifiers/witchs_path", LUA_MODIFIER_MOTION_NONE)

function item_seekers:GetIntrinsicModifierName()
	return "item_seekers_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_seekers_modifier = class({})

function item_seekers_modifier:IsHidden()
	return true
end

function item_seekers_modifier:IsPurgable()
	return false
end

function item_seekers_modifier:RemoveOnDeath()
	return false
end

function item_seekers_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_seekers_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "witchs_path", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

-- Removing Unique Passives
function item_seekers_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local witchs_path = parent:FindModifierByName("witchs_path")
	if witchs_path then
		witchs_path:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end