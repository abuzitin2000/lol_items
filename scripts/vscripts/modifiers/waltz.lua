waltz = class ({})

-- Modifier Linkers
LinkLuaModifier("waltz_buff", "modifiers/waltz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("waltz_active", "modifiers/waltz", LUA_MODIFIER_MOTION_NONE)

function waltz:IsHidden()
	return true
end

function waltz:IsPurgable()
	return false
end

function waltz:RemoveOnDeath()
	return false
end

function waltz:OnCreated()
	if not IsServer() then
		return
	end

	self.stack = 0
end

function waltz:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function waltz:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function waltz:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

    local mod = parent:AddNewModifier(parent, ability, "waltz_buff", { duration = ability:GetSpecialValueFor("waltz_duration") })

    self.stack = self.stack + 1

    if self.stack >= ability:GetSpecialValueFor("waltz_stack") then
    	parent:AddNewModifier(parent, ability, "waltz_active", { duration = ability:GetSpecialValueFor("waltz_duration") })
    end

    if mod:GetStackCount() < ability:GetSpecialValueFor("waltz_stack") then
    	mod:SetStackCount(self.stack)
    else
    	mod:SetStackCount(ability:GetSpecialValueFor("waltz_stack"))
    end
end

waltz_buff = class ({})

function waltz_buff:IsHidden()
	return false
end

function waltz_buff:IsPurgable()
	return false
end

function waltz_buff:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local mod = parent:FindModifierByName("waltz")

	if mod then
		mod.stack = 0
	end
end

function waltz_buff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
	return state
end

function waltz_buff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function waltz_buff:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

    return ability:GetSpecialValueFor("waltz_speed")
end

waltz_active = class ({})

function waltz_active:IsHidden()
	return false
end

function waltz_active:IsPurgable()
	return false
end

function waltz_active:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function waltz_active:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

    return ability:GetSpecialValueFor("waltz_attack_speed")
end