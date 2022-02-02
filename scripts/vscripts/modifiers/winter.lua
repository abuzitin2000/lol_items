winter = class({})

-- Modifier Linkers
LinkLuaModifier("winter_debuff", "modifiers/winter", LUA_MODIFIER_MOTION_NONE)

function winter:IsHidden()
	return true
end

function winter:IsPurgable()
	return false
end

function winter:RemoveOnDeath()
	return false
end

function winter:IsAura()
	return true
end

function winter:GetModifierAura()
	return "winter_debuff"
end

function winter:GetAuraRadius()
	return 700
end

function winter:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function winter:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function winter:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function winter:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

winter_debuff = class({})

function winter_debuff:IsHidden()
	return false
end

function winter_debuff:IsPurgable()
	return false
end

function winter_debuff:GetEffectName()
	return "particles/econ/events/ti7/shivas_guard_slow.vpcf"
end

function winter_debuff:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
    return funcs
end

function winter_debuff:GetModifierAttackSpeedPercentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return -1 * ability:GetSpecialValueFor("winter")
end