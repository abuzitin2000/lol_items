vengeance = class({})

function vengeance:IsHidden()
	return false
end

function vengeance:IsPurgable()
	return false
end

function vengeance:RemoveOnDeath()
	return false
end

function vengeance:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }
    return funcs
end

function vengeance:GetModifierStatusResistanceStacking()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	-- Check if in range
	if CalcDistanceBetweenEntityOBB(parent, caster) > 700 then
		return 0
	end

	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return -1 * ability:GetSpecialValueFor("vengeance_tenacity")
end