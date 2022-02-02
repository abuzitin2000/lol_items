item_hull = class({})

-- Modifier Linkers
LinkLuaModifier("item_hull_modifier", "items/item_hull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("boarding", "modifiers/boarding", LUA_MODIFIER_MOTION_NONE)

function item_hull:GetIntrinsicModifierName()
	return "item_hull_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_hull_modifier = class({})

function item_hull_modifier:IsHidden()
	return true
end

function item_hull_modifier:IsPurgable()
	return false
end

function item_hull_modifier:RemoveOnDeath()
	return false
end

function item_hull_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_hull_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "boarding", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
end

-- Removing Unique Passives
function item_hull_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local boarding = parent:FindModifierByName("boarding")
	if boarding then
		boarding:Destroy()
	end

	local boarding_buff = parent:FindModifierByName("boarding_buff")
	if boarding_buff then
		boarding_buff:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
end

-- Stats
function item_hull_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_hull_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_hull_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end