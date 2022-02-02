siphon = class ({})

-- Modifier Linkers
LinkLuaModifier("siphon_stack", "modifiers/siphon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("siphon_speed", "modifiers/siphon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("siphon_slow", "modifiers/siphon", LUA_MODIFIER_MOTION_NONE)

function siphon:IsHidden()
	return true
end

function siphon:IsPurgable()
	return false
end

function siphon:RemoveOnDeath()
	return false
end

function siphon:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function siphon:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function siphon:OnTakeDamageKillCredit( event )
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

	-- Check if target is a hero
	if not target:IsHero() then
		return
	end

	-- Check if auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL and event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
    
	local mod = target:AddNewModifier(parent, ability, "siphon_stack", { duration = 6 })

	if not ability:IsCooldownReady() then
		if mod:GetStackCount() == 0 then
			mod:SetStackCount(1)
		end
	else
		if mod:GetStackCount() < 2 then
			mod:SetStackCount(mod:GetStackCount() + 1)
		else
			-- Deal Damage
			local damageTable = {
		  		victim = target,
		  		attacker = parent,
		  		damage = 40 + 110 / 17 * (parent:GetLevel() - 1),
		  		damage_type = DAMAGE_TYPE_MAGICAL,
		  		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			}
			ApplyDamage(damageTable)

			local chill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_cast_beams.vpcf", PATTACH_POINT_FOLLOW, parent)
			ParticleManager:SetParticleControlEnt(chill_particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(chill_particle, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(chill_particle)

			EmitSoundOn("DOTA_Item.Butterfly", target)

			ability:StartCooldown(ability:GetSpecialValueFor("siphon_cooldown"))

			target:RemoveModifierByName("siphon_stack")

			parent:AddNewModifier(parent, ability, "siphon_speed", { duration = ability:GetSpecialValueFor("siphon_duration") })
			target:AddNewModifier(parent, ability, "siphon_slow", { duration = ability:GetSpecialValueFor("siphon_duration") })
		end
	end
end

siphon_stack = class({})

function siphon_stack:IsHidden()
	return false
end

function siphon_stack:IsPurgable()
	return false
end

function siphon_stack:RemoveOnDeath()
	return false
end

siphon_speed = class({})

function siphon_speed:IsHidden()
	return false
end

function siphon_speed:IsPurgable()
	return false
end

function siphon_speed:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function siphon_speed:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("siphon_speed")
end

siphon_slow = class({})

function siphon_slow:IsHidden()
	return false
end

function siphon_slow:IsPurgable()
	return false
end

function siphon_slow:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function siphon_slow:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return -1 * ability:GetSpecialValueFor("siphon_speed")
end