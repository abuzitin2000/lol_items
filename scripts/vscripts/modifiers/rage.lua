rage = class ({})

-- Modifier Linkers
LinkLuaModifier("rage_buff", "modifiers/rage", LUA_MODIFIER_MOTION_NONE)

function rage:IsHidden()
	return true
end

function rage:IsPurgable()
	return false
end

function rage:RemoveOnDeath()
	return false
end

function rage:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function rage:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function rage:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent
    if attacker ~= parent or target == parent and target:IsAlive() then
    	return
    end

    -- Check if physical damage
    if event.damage_type ~= DAMAGE_TYPE_PHYSICAL then
    	return
    end

    parent:AddNewModifier(target, ability, "rage_buff", { duration = ability:GetSpecialValueFor("rage_duration") })
end

rage_buff = class ({})

function rage_buff:IsHidden()
	return false
end

function rage_buff:IsPurgable()
	return false
end

function rage_buff:IsDebuff()
	return false
end

function rage_buff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
    return funcs
end

function rage_buff:GetModifierMoveSpeedBonus_Constant()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

    return caster:GetModifierStackCount("carve_debuff", parent) * ability:GetSpecialValueFor("rage_speed")
end