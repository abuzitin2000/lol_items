grace = class ({})

-- Modifier Linkers
LinkLuaModifier("grace_buff", "modifiers/grace", LUA_MODIFIER_MOTION_NONE)

function grace:IsHidden()
	return true
end

function grace:IsPurgable()
	return false
end

function grace:RemoveOnDeath()
	return false
end

function grace:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function grace:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
        MODIFIER_PROPERTY_MIN_HEALTH
    }
    return funcs
end

function grace:GetMinHealth()
	local ability = self:GetAbility()

	if ability:IsCooldownReady() then
		return 1
	end

	return 0
end

function grace:OnTakeDamageKillCredit( event )
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

	-- Check if target is parent
	if target ~= parent or not attacker then
		return
	end

	-- Check if on cooldown
	if not ability:IsCooldownReady() then
		return
	end

	-- Check if low health
	if parent:GetHealth() > 10 then
		return
	end

	parent:AddNewModifier(parent, ability, "grace_buff", { duration = ability:GetSpecialValueFor("grace_duration") })
	parent:StartGestureWithPlaybackRate(ACT_DOTA_DIE, 0.5)

	-- Start cooldown
	ability:StartCooldown(ability:GetSpecialValueFor("grace_cooldown"))

	parent:EmitSound("Aegis.Timer")
end

grace_buff = class ({})

function grace_buff:IsHidden()
	return false
end

function grace_buff:IsPurgable()
	return false
end

function grace_buff:GetEffectName()
	return "particles/items_fx/aegis_timer.vpcf"
end

function grace_buff:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")

	local heal = (parent:GetStrength() * 20) * (ability:GetSpecialValueFor("grace_health") / 100)
	local mana = parent:GetMaxMana() * (ability:GetSpecialValueFor("grace_mana") / 100)
	
	parent:Heal(heal * (1 + unique.heal_power / 100), ability)
	parent:GiveMana(mana)

	parent:RemoveGesture(ACT_DOTA_DIE)

	parent:EmitSound("Hero_Omniknight.Purification")

	-- Effect
	local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(lifesteal_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(lifesteal_pfx)

	local heal_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(heal_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(heal_pfx)
end

function grace_buff:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_PROVIDES_VISION] = false
	}
	return state
end