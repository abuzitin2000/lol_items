wrath = class({})

function wrath:IsHidden()
	return true
end

function wrath:IsPurgable()
	return false
end

function wrath:RemoveOnDeath()
	return false
end

function wrath:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function wrath:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }
    return funcs
end

function wrath:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if target is a tower
	if target:IsTower() then
		return 0
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return 0
	end

	local crit = unique.crit
	if crit > 100 then
		crit = 100
	end

	local damage = ability:GetSpecialValueFor("wrath_damage") * (crit / ability:GetSpecialValueFor("wrath_crit"))

	return damage * (1 + (unique.crit_dmg - 175) / 100)
end