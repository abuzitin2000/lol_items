item_quicksilver = class({})

-- Modifier Linkers
LinkLuaModifier("item_quicksilver_modifier", "items/item_quicksilver", LUA_MODIFIER_MOTION_NONE)

function item_quicksilver:GetIntrinsicModifierName()
	return "item_quicksilver_modifier"
end

function item_quicksilver:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsCurrentlyVerticalMotionControlled() then
		-- Error
		HUDError("Can't cast while Airborne!", caster:GetPlayerOwnerID())
		EmitSoundOnClient("General.CastFail_Silenced", caster:GetPlayerOwner())
		return	
	end

	caster:Purge(false, true, false, true, true)

	local vfx = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_spell.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(vfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(vfx, 1, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("DOTA_Item.MinotaurHorn.Cast", caster)

	self:StartCooldown(self:GetSpecialValueFor("quicksilver_cooldown"))
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_quicksilver_modifier = class({})

function item_quicksilver_modifier:IsHidden()
	return true
end

function item_quicksilver_modifier:IsPurgable()
	return false
end

function item_quicksilver_modifier:RemoveOnDeath()
	return false
end

function item_quicksilver_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_quicksilver_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
end

function item_quicksilver_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
end