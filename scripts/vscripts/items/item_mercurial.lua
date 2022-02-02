item_mercurial = class({})

-- Modifier Linkers
LinkLuaModifier("item_mercurial_modifier", "items/item_mercurial", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mercurial_buff", "items/item_mercurial", LUA_MODIFIER_MOTION_NONE)

function item_mercurial:GetIntrinsicModifierName()
	return "item_mercurial_modifier"
end

function item_mercurial:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsCurrentlyVerticalMotionControlled() then
		-- Error
		HUDError("Can't cast while Airborne!", caster:GetPlayerOwnerID())
		EmitSoundOnClient("General.CastFail_Silenced", caster:GetPlayerOwner())
		return	
	end

	caster:Purge(false, true, false, true, true)

	caster:AddNewModifier(caster, self, "mercurial_buff", { duration = self:GetSpecialValueFor("quicksilver_duration") })

	local vfx = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_spell.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(vfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(vfx, 1, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("DOTA_Item.MinotaurHorn.Cast", caster)

	self:StartCooldown(self:GetSpecialValueFor("quicksilver_cooldown"))
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mercurial_modifier = class({})

function item_mercurial_modifier:IsHidden()
	return true
end

function item_mercurial_modifier:IsPurgable()
	return false
end

function item_mercurial_modifier:RemoveOnDeath()
	return false
end

function item_mercurial_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_mercurial_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit + ability:GetSpecialValueFor("bonus_crit")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_mercurial_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.crit = unique.crit - ability:GetSpecialValueFor("bonus_crit")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end

-- Stats
function item_mercurial_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_mercurial_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end

mercurial_buff = class({})

function mercurial_buff:IsHidden()
	return false
end

function mercurial_buff:IsPurgable()
	return false
end

function mercurial_buff:RemoveOnDeath()
	return false
end

function mercurial_buff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
	return state
end

function mercurial_buff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function mercurial_buff:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("quicksilver_speed")
end