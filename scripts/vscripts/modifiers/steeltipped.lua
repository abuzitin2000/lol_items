steeltipped = class({})

function steeltipped:IsHidden()
	return true
end

function steeltipped:IsPurgable()
	return false
end

function steeltipped:RemoveOnDeath()
	return false
end

function steeltipped:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function steeltipped:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
	return funcs
end

-- Deal damage when hitting
function steeltipped:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Doesn't work on towers
	if target:IsTower() then
		return 0
	end

	return ability:GetSpecialValueFor("steeltipped_damage")
end