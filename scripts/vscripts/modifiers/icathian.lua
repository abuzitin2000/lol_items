icathian = class({})

function icathian:IsHidden()
	return true
end

function icathian:IsPurgable()
	return false
end

function icathian:RemoveOnDeath()
	return false
end

function icathian:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function icathian:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
    }
    return funcs
end

function icathian:GetModifierProcAttack_BonusDamage_Magical( event )
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

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return 0
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return 0
	end

	return ability:GetSpecialValueFor("icathian_base") + unique:AbilityPower() * (ability:GetSpecialValueFor("icathian_ap") / 100)
end