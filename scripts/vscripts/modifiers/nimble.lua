nimble = class({})

-- Modifier Linkers
LinkLuaModifier("nimble_speed", "modifiers/nimble", LUA_MODIFIER_MOTION_NONE)

function nimble:IsHidden()
	return true
end

function nimble:IsPurgable()
	return false
end

function nimble:RemoveOnDeath()
	return false
end

function nimble:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function nimble:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

-- Gain Movement Speed on Hit
function nimble:OnAttackLanded( event )
	local parent = self:GetParent()
	local attacker = event.attacker
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is self
	if parent == attacker and event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		if parent:IsRangedAttacker() then
			parent:AddNewModifier(parent, ability, "nimble_speed", {
				duration = ability:GetSpecialValueFor("nimble_duration")
			})
		else
			parent:AddNewModifier(parent, ability, "nimble_speed", {
				duration = ability:GetSpecialValueFor("nimble_duration")
			})
		end
	end
end

nimble_speed = class({})

function nimble_speed:IsHidden()
	return false
end

function nimble_speed:IsPurgable()
	return false
end

function nimble_speed:OnCreated( params )
	self.bonus_speed = params.bonus_speed
end

function nimble_speed:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
    return funcs
end

function nimble_speed:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if self:GetParent():IsRangedAttacker() then
    	return self:GetAbility():GetSpecialValueFor("nimble_ranged")
    else
    	return self:GetAbility():GetSpecialValueFor("nimble_melee")
    end
end