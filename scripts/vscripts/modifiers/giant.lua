giant = class ({})

function giant:IsHidden()
	return true
end

function giant:IsPurgable()
	return false
end

function giant:RemoveOnDeath()
	return false
end

function giant:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function giant:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

-- Bonus Damage
function giant:GetModifierDamageOutgoing_Percentage( event )
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Only work on champions
	if (not target) or not target:IsHero() then
		return 0
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return 0
	end

	-- Don't work when enemy has less health
	if parent:GetMaxHealth() > target:GetMaxHealth() then
		return 0
	end

	local damage = 0.75 * ((parent:GetMaxHealth() - target:GetMaxHealth()) / 100)

	if damage > ability:GetSpecialValueFor("giant_damage") then
		damage = ability:GetSpecialValueFor("giant_damage")
	end

	return damage
end