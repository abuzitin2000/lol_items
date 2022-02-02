sturdy = class({})

-- Modifier Linkers
LinkLuaModifier("sturdy_regen", "modifiers/sturdy", LUA_MODIFIER_MOTION_NONE)

function sturdy:IsHidden()
	return true
end

function sturdy:IsPurgable()
	return false
end

function sturdy:RemoveOnDeath()
	return false
end

-- Removing Regen Passive
function sturdy:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local modifier = parent:FindModifierByName("sturdy_regen")
	if modifier then
		modifier:Destroy()
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function sturdy:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

-- Get Bonus Health Regen on hit
function sturdy:OnTakeDamage( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit
	local ability = event.inflictor

	-- Check if parent is the attacker
	if not parent == attacker then
		return
	end

	-- Check if target is a hero
	if not target:IsHero() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Multiplier used to determine regen power
	self:SetStackCount(0)

	-- Reduce regen if parent is ranged
	if parent:IsRangedAttacker() then
		self:SetStackCount(1)
	end

	-- Add regen modifier
	parent:AddNewModifier(parent, self:GetAbility(), "sturdy_regen", {
		duration = self:GetAbility():GetSpecialValueFor("sturdy_duration")
	})
end

sturdy_regen = class({})

function sturdy_regen:IsPurgable()
	return false
end

function sturdy_regen:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-- Bonus Health Regen
function sturdy_regen:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local multiplier = 1

	if parent:GetModifierStackCount("sturdy", parent) > 0 then
		multiplier = 0.5
	end

    return parent:GetMaxHealth() * ability:GetSpecialValueFor("sturdy_heal") / 100 * multiplier / ability:GetSpecialValueFor("sturdy_duration")
end