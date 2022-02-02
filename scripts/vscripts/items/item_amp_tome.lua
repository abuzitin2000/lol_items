item_amp_tome = class({})

-- Modifier Linkers
LinkLuaModifier("item_amp_tome_modifier", "items/item_amp_tome", LUA_MODIFIER_MOTION_NONE)

function item_amp_tome:GetIntrinsicModifierName()
	return "item_amp_tome_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_amp_tome_modifier = class({})

function item_amp_tome_modifier:IsHidden()
	return true
end

function item_amp_tome_modifier:IsPurgable()
	return false
end

function item_amp_tome_modifier:RemoveOnDeath()
	return false
end

function item_amp_tome_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_amp_tome_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_amp_tome_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end