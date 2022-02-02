ixtal = class({})

-- Modifier Linkers
LinkLuaModifier("ixtal_damage", "modifiers/ixtal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ixtal_health", "modifiers/ixtal", LUA_MODIFIER_MOTION_NONE)

function ixtal:IsHidden()
	return true
end

function ixtal:IsPurgable()
	return false
end

function ixtal:RemoveOnDeath()
	return false
end

function ixtal:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(1)
end

function ixtal:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function ixtal:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	parent:AddNewModifier(parent, ability, "ixtal_damage", { duration = 1 })
	parent:AddNewModifier(parent, ability, "ixtal_health", { duration = 1 })
end

ixtal_damage = class({})

function ixtal_damage:IsHidden()
	return true
end

function ixtal_damage:IsPurgable()
	return false
end

function ixtal_damage:RemoveOnDeath()
	return false
end

function ixtal_damage:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	self:SetStackCount(math.abs(parent:GetAverageTrueAttackDamage(nil) - parent:GetAttackDamage()))
end

function ixtal_damage:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function ixtal_damage:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return self:GetStackCount() * (ability:GetSpecialValueFor("ixtal") / 100)
end

ixtal_health = class({})

function ixtal_health:IsHidden()
	return true
end

function ixtal_health:IsPurgable()
	return false
end

function ixtal_health:RemoveOnDeath()
	return false
end

function ixtal_health:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	self:SetStackCount(math.abs(parent:GetMaxHealth() - parent:GetStrength() * 20))
end

function ixtal_health:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function ixtal_health:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return self:GetStackCount() * (ability:GetSpecialValueFor("ixtal") / 100)
end