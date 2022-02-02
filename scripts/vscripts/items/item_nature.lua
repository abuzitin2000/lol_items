item_nature = class({})

-- Modifier Linkers
LinkLuaModifier("item_nature_modifier", "items/item_nature", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("absorb", "modifiers/absorb", LUA_MODIFIER_MOTION_NONE)

function item_nature:GetIntrinsicModifierName()
	return "item_nature_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_nature_modifier = class({})

function item_nature_modifier:IsHidden()
	return true
end

function item_nature_modifier:IsPurgable()
	return false
end

function item_nature_modifier:RemoveOnDeath()
	return false
end

function item_nature_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_nature_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "absorb", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_nature_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local absorb = parent:FindModifierByName("absorb")
	if absorb then
		absorb:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end

-- Stats
function item_nature_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function item_nature_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end

function item_nature_modifier:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end