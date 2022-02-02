item_dark_seal = class({})

-- Modifier Linkers
LinkLuaModifier("item_dark_seal_modifier", "items/item_dark_seal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("glory", "modifiers/glory", LUA_MODIFIER_MOTION_NONE)

function item_dark_seal:GetIntrinsicModifierName()
	return "item_dark_seal_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dark_seal_modifier = class({})

function item_dark_seal_modifier:IsHidden()
	return true
end

function item_dark_seal_modifier:IsPurgable()
	return false
end

function item_dark_seal_modifier:RemoveOnDeath()
	return false
end

function item_dark_seal_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dark_seal_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "glory", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

-- Removing Unique Passives
function item_dark_seal_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local glory = parent:FindModifierByName("glory")
	if glory then
		glory:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end

-- Stats
function item_dark_seal_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_dark_seal_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end