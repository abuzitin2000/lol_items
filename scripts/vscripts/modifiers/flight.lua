flight = class({})

function flight:IsHidden()
	return true
end

function flight:IsPurgable()
	return false
end

function flight:RemoveOnDeath()
	return false
end

function flight:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function flight:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function flight:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end