mist = class({})

function mist:IsHidden()
	return true
end

function mist:IsPurgable()
	return false
end

function mist:RemoveOnDeath()
	return false
end

function mist:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function mist:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
	return funcs
end

-- Deal damage when hitting
function mist:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if not target:IsAlive() then
		return 0
	end

	-- Doesn't work on towers
	if target:IsTower() then
		return 0
	end

	local damage = target:GetHealth()

	if parent:IsRangedAttacker() then
		damage = damage * (ability:GetSpecialValueFor("mist_range") / 100)
	else
		damage = damage * (ability:GetSpecialValueFor("mist_melee") / 100)
	end

	-- Minimum damage
	if damage < 15 then
		damage = 15
	end

	-- Maximum damage against creeps
	if target:IsCreep() and damage > 60 then
		damage = 60
	end

	return damage
end