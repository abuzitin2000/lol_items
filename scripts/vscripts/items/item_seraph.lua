item_seraph = class({})

-- Modifier Linkers
LinkLuaModifier("item_seraph_modifier", "items/item_seraph", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("awe", "modifiers/awe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("empyrean", "modifiers/empyrean", LUA_MODIFIER_MOTION_NONE)

function item_seraph:GetIntrinsicModifierName()
	return "item_seraph_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_seraph_modifier = class({})

function item_seraph_modifier:IsHidden()
	return true
end

function item_seraph_modifier:IsPurgable()
	return false
end

function item_seraph_modifier:RemoveOnDeath()
	return false
end

function item_seraph_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_seraph_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "awe", {})
	parent:AddNewModifier(parent, ability, "empyrean", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_seraph_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local awe = parent:FindModifierByName("awe")
	if awe then
		awe:Destroy()
	end

	local empyrean = parent:FindModifierByName("empyrean")
	if empyrean then
		empyrean:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_seraph_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_seraph_modifier:GetModifierManaBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_mana")
end

function item_seraph_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end