sanctify = class({})

-- Modifier Linkers
LinkLuaModifier("sanctify_buff", "modifiers/sanctify", LUA_MODIFIER_MOTION_NONE)

function sanctify:IsHidden()
	return true
end

function sanctify:IsPurgable()
	return false
end

function sanctify:RemoveOnDeath()
	return false
end

function sanctify:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

sanctify_buff = class({})

function sanctify_buff:IsHidden()
	return false
end

function sanctify_buff:IsPurgable()
	return false
end

function sanctify_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
	}
	return funcs
end

function sanctify_buff:GetModifierAttackSpeedBonus_Constant()
	local caster = self:GetCaster()
	
	return 10 + 20 / 17 * (caster:GetLevel() - 1)
end

function sanctify_buff:GetModifierProcAttack_BonusDamage_Magical( event )
	local caster = self:GetCaster()

	return 5 + 15 / 17 * (caster:GetLevel() - 1)
end