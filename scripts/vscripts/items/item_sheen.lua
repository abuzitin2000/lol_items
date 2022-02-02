item_sheen = class({})

-- Modifier Linkers
LinkLuaModifier("item_sheen_modifier", "items/item_sheen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spellblade", "modifiers/spellblade", LUA_MODIFIER_MOTION_NONE)

function item_sheen:GetIntrinsicModifierName()
	return "item_sheen_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_sheen_modifier = class({})

function item_sheen_modifier:IsHidden()
	return true
end

function item_sheen_modifier:IsPurgable()
	return false
end

function item_sheen_modifier:RemoveOnDeath()
	return false
end

function item_sheen_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_sheen_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spellblade", {})
end

-- Removing Unique Passives
function item_sheen_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local spellblade = parent:FindModifierByName("spellblade")
	if spellblade then
		spellblade:Destroy()
	end
end