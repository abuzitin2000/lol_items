precision = class({})

function precision:IsHidden()
	return true
end

function precision:IsPurgable()
	return false
end

function precision:RemoveOnDeath()
	return false
end

function precision:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function precision:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
	return funcs
end

-- Deal damage when hitting lane creeps
function precision:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if target is a creep
	if not target:IsCreep() then
		return 0
	end

	return ability:GetSpecialValueFor("precision")
end