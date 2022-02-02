item_oblivion_orb = class({})

-- Modifier Linkers
LinkLuaModifier("item_oblivion_orb_modifier", "items/item_oblivion_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("cursed", "modifiers/cursed", LUA_MODIFIER_MOTION_NONE)

function item_oblivion_orb:GetIntrinsicModifierName()
	return "item_oblivion_orb_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_oblivion_orb_modifier = class({})

function item_oblivion_orb_modifier:IsHidden()
	return true
end

function item_oblivion_orb_modifier:IsPurgable()
	return false
end

function item_oblivion_orb_modifier:RemoveOnDeath()
	return false
end

function item_oblivion_orb_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_oblivion_orb_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "cursed", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_oblivion_orb_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local cursed = parent:FindModifierByName("cursed")
	if cursed then
		cursed:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end