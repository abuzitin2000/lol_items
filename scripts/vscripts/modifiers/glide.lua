glide = class({})

function glide:IsHidden()
	return true
end

function glide:IsPurgable()
	return false
end

function glide:RemoveOnDeath()
	return false
end

function glide:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function glide:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function glide:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return ability:GetSpecialValueFor("bonus_speed")
end