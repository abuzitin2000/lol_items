hyper = class ({})

-- Modifier Linkers
LinkLuaModifier("hyper_debuff", "modifiers/hyper", LUA_MODIFIER_MOTION_NONE)

function hyper:IsHidden()
	return true
end

function hyper:IsPurgable()
	return false
end

function hyper:RemoveOnDeath()
	return false
end

function hyper:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function hyper:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function hyper:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent
    if attacker ~= parent or not target:IsAlive() then
    	return
    end

    -- Check if target is hero
    if not target:IsHero() then
    	return
    end

    -- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

    -- Check if damage is ability
    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then
    	return
    end

    -- Check distance
    if CalcDistanceBetweenEntityOBB(parent, target) < ability:GetSpecialValueFor("hyper_range") then
    	return
    end

	-- Check if ability is skillshot
    if event.inflictor and bit.band(event.inflictor:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= DOTA_ABILITY_BEHAVIOR_POINT then
    	return
    end

    target:AddNewModifier(parent, ability, "hyper_debuff", { duration = ability:GetSpecialValueFor("hyper_duration") })
end

function hyper:OnStunned( stunnedTarget )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = EntIndexToHScript(stunnedTarget)
	local ability = self:GetAbility()

	if not ability then
		return
	end

    -- Check if target is hero
    if not target:IsHero() then
    	return
    end

    -- Check distance
    if CalcDistanceBetweenEntityOBB(parent, target) < ability:GetSpecialValueFor("hyper_range") then
    	return
    end

    target:AddNewModifier(parent, ability, "hyper_debuff", { duration = ability:GetSpecialValueFor("hyper_duration") })
end

hyper_debuff = class ({})

function hyper_debuff:IsHidden()
	return false
end

function hyper_debuff:IsPurgable()
	return false
end

function hyper_debuff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function hyper_debuff:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(0.1)
end

-- Give vision on enemy
function hyper_debuff:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	AddFOWViewer(caster:GetTeam(), parent:GetAbsOrigin(), 10, 0.2, true)
end

function hyper_debuff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function hyper_debuff:GetModifierIncomingDamage_Percentage( event )
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local attacker = event.attacker
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if attacker is caster
    if attacker ~= caster then
    	return
    end
	
    return ability:GetSpecialValueFor("hyper_damage")
end