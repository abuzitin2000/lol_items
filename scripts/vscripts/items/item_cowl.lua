item_cowl = class({})

-- Modifier Linkers
LinkLuaModifier("item_cowl_modifier", "items/item_cowl", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("incorporeal", "modifiers/incorporeal", LUA_MODIFIER_MOTION_NONE)

function item_cowl:GetIntrinsicModifierName()
	return "item_cowl_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_cowl_modifier = class({})

function item_cowl_modifier:IsHidden()
	return true
end

function item_cowl_modifier:IsPurgable()
	return false
end

function item_cowl_modifier:RemoveOnDeath()
	return false
end

function item_cowl_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_cowl_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "incorporeal", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_cowl_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local incorporeal = parent:FindModifierByName("incorporeal")
	if incorporeal then
		incorporeal:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end

-- Stats
function item_cowl_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_cowl_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end