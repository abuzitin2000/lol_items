recovery = class({})

function recovery:IsHidden()
	return true
end

function recovery:IsPurgable()
	return false
end

function recovery:RemoveOnDeath()
	return false
end

function recovery:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function recovery:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-- Bonus Health Regen
function recovery:GetModifierConstantHealthRegen()
	local ability = self:GetAbility()

	if not ability then
		return
	end
				
	return ability:GetSpecialValueFor("recovery_health_regen")
end