item_phage = class({})

-- Modifier Linkers
LinkLuaModifier("item_phage_modifier", "items/item_phage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sturdy", "modifiers/sturdy", LUA_MODIFIER_MOTION_NONE)

function item_phage:GetIntrinsicModifierName()
	return "item_phage_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_phage_modifier = class({})

function item_phage_modifier:IsHidden()
	return true
end

function item_phage_modifier:IsPurgable()
	return false
end

function item_phage_modifier:RemoveOnDeath()
	return false
end

function item_phage_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_phage_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "sturdy", {})
end

-- Removing Unique Passives
function item_phage_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local sturdy = parent:FindModifierByName("sturdy")
	if sturdy then
		sturdy:Destroy()
	end
end

-- Stats
function item_phage_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_phage_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

function item_phage_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end