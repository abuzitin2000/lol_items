item_verdant = class({})

-- Modifier Linkers
LinkLuaModifier("item_verdant_modifier", "items/item_verdant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("adaptive", "modifiers/adaptive", LUA_MODIFIER_MOTION_NONE)

function item_verdant:GetIntrinsicModifierName()
	return "item_verdant_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_verdant_modifier = class({})

function item_verdant_modifier:IsHidden()
	return true
end

function item_verdant_modifier:IsPurgable()
	return false
end

function item_verdant_modifier:RemoveOnDeath()
	return false
end

function item_verdant_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_verdant_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "adaptive", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

-- Removing Unique Passives
function item_verdant_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local adaptive = parent:FindModifierByName("adaptive")
	if adaptive then
		adaptive:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end