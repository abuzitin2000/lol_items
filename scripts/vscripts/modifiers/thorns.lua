thorns = class ({})

-- Modifier Linkers
LinkLuaModifier("grievous", "modifiers/grievous", LUA_MODIFIER_MOTION_NONE)

function thorns:IsHidden()
	return true
end

function thorns:IsPurgable()
	return false
end

function thorns:RemoveOnDeath()
	return false
end

function thorns:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function thorns:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

-- Reflect damage and apply Grivious Wounds
function thorns:OnTakeDamageKillCredit( event )
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

	-- Check if target is parent and attacker is alive
	if target ~= parent or not attacker or not attacker:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == attacker:GetTeam() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end

	local damage = 0

	-- Level 1
	if ability:GetAbilityName() == "item_bramble" then
		damage = ability:GetSpecialValueFor("thorns")
	end
    
	-- Deal Damage
	local damageTable = {
  		victim = attacker,
  		attacker = parent,
  		damage = damage,
  		damage_type = DAMAGE_TYPE_MAGICAL,
  		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	}
	ApplyDamage(damageTable)

	local vfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(vfx, 0, attacker:GetAbsOrigin())
	ParticleManager:SetParticleControl(vfx, 1, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(vfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(vfx)

	-- Check if attacker is a hero, only the damage is done to non heroes
	if not attacker:IsHero() then
		return
	end

	-- Apply Grievous Wounds
	local grievous = attacker:AddNewModifier(parent, ability, "grievous", { duration = 3 })
	if grievous:GetStackCount() < ability:GetSpecialValueFor("grievous") then
		grievous:SetStackCount(ability:GetSpecialValueFor("grievous"))
	end
end