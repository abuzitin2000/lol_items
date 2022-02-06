sharpshooter = class({})

function sharpshooter:IsHidden()
	return true
end

function sharpshooter:IsPurgable()
	return false
end

function sharpshooter:RemoveOnDeath()
	return false
end

function sharpshooter:OnCreated()
	if not IsServer() then
		return
	end

	self.particle = nil

	self:StartIntervalThink(0.1)
end

function sharpshooter:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function sharpshooter:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local mod = parent:FindModifierByName("energized")

	if not mod then
		return
	end

	-- Check if there is enough stack
	if mod:GetStackCount() < 100 then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, false)
			self.particle = nil
		end
	else
		if not self.particle then
			self.particle = ParticleManager:CreateParticle("particles/ui_mouseactions/range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(self.particle, 0, Vector(parent:GetOrigin().x, parent:GetOrigin().y, 450))
			--ParticleManager:SetParticleControl(self.particle, 1, Vector(255, 0, 0))
			ParticleManager:SetParticleControl(self.particle, 1, Vector(parent:Script_GetAttackRange(), 0, 0))
			--ParticleManager:SetParticleControl(self.particle, 4, Vector(parent:GetOrigin().x, parent:GetOrigin().y, 450))
		end
	end
end

function sharpshooter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
    return funcs
end

function sharpshooter:GetModifierProcAttack_BonusDamage_Magical( event )
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

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return 0
	end

	local mkb_vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(mkb_vfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(mkb_vfx)

	target:EmitSound("DOTA_Item.MKB.melee")

	mod:SetStackCount(0)

	return ability:GetSpecialValueFor("sharpshooter_damage")
end

function sharpshooter:GetModifierAttackRangeBonus()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local mod = parent:FindModifierByName("energized")

	if not ability then
		return 0
	end

	-- Check if there is enough stack
	if not mod or mod:GetStackCount() < 100 then
		return 0
	end

	local range = parent:GetBaseAttackRange() * (ability:GetSpecialValueFor("sharpshooter_range") / 100)

	if range > 150 then
		range = 150
	end

	return range
end