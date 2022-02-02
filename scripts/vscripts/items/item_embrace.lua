item_embrace = class({})

-- Modifier Linkers
LinkLuaModifier("item_embrace_modifier", "items/item_embrace", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("azakana", "modifiers/azakana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dark_pact", "modifiers/dark_pact", LUA_MODIFIER_MOTION_NONE)

function item_embrace:GetIntrinsicModifierName()
	return "item_embrace_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_embrace_modifier = class({})

function item_embrace_modifier:IsHidden()
	return true
end

function item_embrace_modifier:IsPurgable()
	return false
end

function item_embrace_modifier:RemoveOnDeath()
	return false
end

function item_embrace_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_embrace_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "azakana", {})
	parent:AddNewModifier(parent, ability, "dark_pact", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_embrace_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local azakana = parent:FindModifierByName("azakana")
	if azakana then
		azakana:Destroy()
	end

	local dark_pact = parent:FindModifierByName("dark_pact")
	if dark_pact then
		dark_pact:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_embrace_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_embrace_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end