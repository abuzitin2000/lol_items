jolt = class({})

function jolt:IsHidden()
	return true
end

function jolt:IsPurgable()
	return false
end

function jolt:RemoveOnDeath()
	return false
end

function jolt:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function jolt:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
    }
    return funcs
end

function jolt:GetModifierProcAttack_BonusDamage_Magical( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()
	local mod = parent:FindModifierByName("energized")

	if not ability then
		return 0
	end

	-- Check if there is enough stack
	if not mod or mod:GetStackCount() < 100 then
		return 0
	end

	-- Doesn't work on towers
	if target:IsTower() then
		return 0
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return 0
	end

	local mkb_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(mkb_vfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(mkb_vfx)

	parent:EmitSound("DOTA_Item.MKB.melee")

	mod:SetStackCount(0)

	return ability:GetSpecialValueFor("jolt")
end