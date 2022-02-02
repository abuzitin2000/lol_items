item_angel = class({})

-- Modifier Linkers
LinkLuaModifier("item_angel_modifier", "items/item_angel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("grace", "modifiers/grace", LUA_MODIFIER_MOTION_NONE)

function item_angel:GetIntrinsicModifierName()
	return "item_angel_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_angel_modifier = class({})

function item_angel_modifier:IsHidden()
	return true
end

function item_angel_modifier:IsPurgable()
	return false
end

function item_angel_modifier:RemoveOnDeath()
	return false
end

function item_angel_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_angel_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "grace", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

-- Removing Unique Passives
function item_angel_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local grace = parent:FindModifierByName("grace")
	if grace then
		grace:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end

-- Stats
function item_angel_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_angel_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end