shock = class({})

function shock:IsHidden()
	return true
end

function shock:IsPurgable()
	return false
end

function shock:RemoveOnDeath()
	return false
end

function shock:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function shock:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function shock:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Only work on heroes
	if not target:IsHero() then
		return 0
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return 0
	end

	return parent:GetMaxMana() * (ability:GetSpecialValueFor("shock_mana") / 100)
end

function shock:OnTakeDamageKillCredit( event )
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

    -- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
    
    local damage = parent:GetAverageTrueAttackDamage(nil) * (ability:GetSpecialValueFor("shock_ad") / 100)

    if parent:IsRangedAttacker() then
    	damage = damage + parent:GetMaxMana() * (ability:GetSpecialValueFor("shock_ranged") / 100)
    else
    	damage = damage + parent:GetMaxMana() * (ability:GetSpecialValueFor("shock_melee") / 100)
    end

	-- Deal Damage
	local damageTable = {
  		victim = target,
  		attacker = parent,
  		damage = damage,
  		damage_type = DAMAGE_TYPE_PHYSICAL,
  		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)
end