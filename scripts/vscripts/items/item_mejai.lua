item_mejai = class({})

-- Modifier Linkers
LinkLuaModifier("item_mejai_modifier", "items/item_mejai", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("glory", "modifiers/glory", LUA_MODIFIER_MOTION_NONE)

function item_mejai:GetIntrinsicModifierName()
	return "item_mejai_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mejai_modifier = class({})

function item_mejai_modifier:IsHidden()
	return true
end

function item_mejai_modifier:IsPurgable()
	return false
end

function item_mejai_modifier:RemoveOnDeath()
	return false
end

function item_mejai_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_mejai_modifier:OnCreated()
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
function item_mejai_modifier:OnDestroy()
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
function item_mejai_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_mejai_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end