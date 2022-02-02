revved = class ({})

function revved:IsHidden()
	return true
end

function revved:IsPurgable()
	return false
end

function revved:RemoveOnDeath()
	return false
end

function revved:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function revved:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function revved:OnTakeDamageKillCredit( event )
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

	-- Check if not on cooldown
	if not ability:IsCooldownReady() then
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

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
    
	-- Deal Damage
	local damageTable = {
  		victim = target,
  		attacker = parent,
  		damage = 50 + 75 / 17 * (parent:GetLevel() - 1),
  		damage_type = DAMAGE_TYPE_MAGICAL,
  		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)

	local manaburn_pfx = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(manaburn_pfx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(manaburn_pfx, 2, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", target)

	ability:StartCooldown(ability:GetSpecialValueFor("revved_cooldown"))
end