item_mikael = class({})

-- Modifier Linkers
LinkLuaModifier("item_mikael_modifier", "items/item_mikael", LUA_MODIFIER_MOTION_NONE)

function item_mikael:GetIntrinsicModifierName()
	return "item_mikael_modifier"
end

function item_mikael:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetCursorCastTarget()

	if target:IsCurrentlyVerticalMotionControlled() then
		-- Error
		HUDError("Can't cast on Airborne!", caster:GetPlayerOwnerID())
		EmitSoundOnClient("General.CastFail_Silenced", caster:GetPlayerOwner())
		return	
	end

	target:Purge(false, true, false, true, false)

	target:Heal(100 + 100 / 17 * (target:GetLevel() - 1), self)

	local vfx = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_spell.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(vfx, 0, target:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(vfx, 1, target:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("DOTA_Item.MinotaurHorn.Cast", target)

	self:StartCooldown(self:GetSpecialValueFor("quicksilver_cooldown"))
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mikael_modifier = class({})

function item_mikael_modifier:IsHidden()
	return true
end

function item_mikael_modifier:IsPurgable()
	return false
end

function item_mikael_modifier:RemoveOnDeath()
	return false
end

function item_mikael_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_mikael_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power + ability:GetSpecialValueFor("bonus_heal_power")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

function item_mikael_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.heal_power = unique.heal_power - ability:GetSpecialValueFor("bonus_heal_power")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end