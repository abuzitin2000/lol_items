flux = class ({})

-- Modifier Linkers
LinkLuaModifier("flux_debuff", "modifiers/flux", LUA_MODIFIER_MOTION_NONE)

function flux:IsHidden()
	return true
end

function flux:IsPurgable()
	return false
end

function flux:RemoveOnDeath()
	return false
end

function flux:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function flux:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function flux:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Check if target is a hero
	if not target:IsRealHero() then
		return
	end

	target:AddNewModifier(parent, ability, "flux_debuff", { duration = ability:GetSpecialValueFor("flux_duration") })
end

flux_debuff = class({})

function flux_debuff:IsHidden()
	return true
end

function flux_debuff:IsPurgable()
	return false
end

function flux_debuff:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function flux_debuff:OnDeath( event )
    if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local caster = self:GetCaster()
	local target = event.unit
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if death is parent
	if parent ~= target then
		return
	end

	local ulti = caster:GetAbilityByIndex(5)

	-- Check if on cooldown
	if ulti:IsCooldownReady() then
		return
	end

	local cd = ulti:GetCooldownTimeRemaining() - ulti:GetCooldown(-1) * (ability:GetSpecialValueFor("flux_cdr") / 100)

	if cd < 0.5 then
		cd = 0.5
	end

	ulti:EndCooldown()
	ulti:StartCooldown(cd)
end