item_blast_wand = class({})

-- Modifier Linkers
LinkLuaModifier("item_blast_wand_modifier", "items/item_blast_wand", LUA_MODIFIER_MOTION_NONE)

function item_blast_wand:GetIntrinsicModifierName()
	return "item_blast_wand_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_blast_wand_modifier = class({})

function item_blast_wand_modifier:IsHidden()
	return true
end

function item_blast_wand_modifier:IsPurgable()
	return false
end

function item_blast_wand_modifier:RemoveOnDeath()
	return false
end

function item_blast_wand_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_blast_wand_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_blast_wand_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end