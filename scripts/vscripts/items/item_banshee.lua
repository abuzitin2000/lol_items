item_banshee = class({})

-- Modifier Linkers
LinkLuaModifier("item_banshee_modifier", "items/item_banshee", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("annul", "modifiers/annul", LUA_MODIFIER_MOTION_NONE)

function item_banshee:GetIntrinsicModifierName()
	return "item_banshee_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_banshee_modifier = class({})

function item_banshee_modifier:IsHidden()
	return true
end

function item_banshee_modifier:IsPurgable()
	return false
end

function item_banshee_modifier:RemoveOnDeath()
	return false
end

function item_banshee_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_banshee_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "annul", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_banshee_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local annul = parent:FindModifierByName("annul")
	if annul then
		annul:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end