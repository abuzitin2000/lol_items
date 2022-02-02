sear = class ({})

-- Modifier Linkers
LinkLuaModifier("sear_burn", "modifiers/sear", LUA_MODIFIER_MOTION_NONE)

function sear:IsHidden()
	return true
end

function sear:IsPurgable()
	return false
end

function sear:RemoveOnDeath()
	return false
end

function sear:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function sear:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

-- Apply burn to jungle creeps
function sear:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent and target is neutral
    if attacker == parent and target:IsAlive() and target:IsNeutralUnitType() then
    	-- Stops infinite loops
    	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
	    	target:AddNewModifier(parent, ability, "sear_burn", {
				duration = ability:GetSpecialValueFor("sear_duration"),
				damage = ability:GetSpecialValueFor("sear_damage_base") + parent:FindModifierByName("unique_mechanics"):AbilityPower() * ability:GetSpecialValueFor("sear_damage_ap") / 100 + (parent:GetAverageTrueAttackDamage(nil) - (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2) * ability:GetSpecialValueFor("sear_damage_attack") / 100 + (parent:GetMaxHealth() - parent:GetStrength() * 20) * ability:GetSpecialValueFor("sear_damage_health") / 100
			})
	    end
    end
end

sear_burn = class ({})

function sear_burn:IsHidden()
	return false
end

function sear_burn:IsPurgable()
	return false
end

function sear_burn:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function sear_burn:OnCreated( params )
	self.damage = params.damage
	self:StartIntervalThink(1)
end

-- Burn the afflicted
function sear_burn:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()

	-- Deal Damage
	local damageTable = {
	  victim = parent,
	  attacker = caster,
	  damage = self.damage / self:GetDuration(),
	  damage_type = DAMAGE_TYPE_MAGICAL,
	  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)
end