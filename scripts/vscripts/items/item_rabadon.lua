item_rabadon = class({})

-- Modifier Linkers
LinkLuaModifier("item_rabadon_modifier", "items/item_rabadon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("opus", "modifiers/opus", LUA_MODIFIER_MOTION_NONE)

function item_rabadon:GetIntrinsicModifierName()
	return "item_rabadon_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_rabadon_modifier = class({})

function item_rabadon_modifier:IsHidden()
	return true
end

function item_rabadon_modifier:IsPurgable()
	return false
end

function item_rabadon_modifier:RemoveOnDeath()
	return false
end

function item_rabadon_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_rabadon_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "opus", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_rabadon_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local opus = parent:FindModifierByName("opus")
	if opus then
		opus:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end