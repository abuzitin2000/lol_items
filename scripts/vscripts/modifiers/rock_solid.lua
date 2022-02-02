rock_solid = class ({})

function rock_solid:IsHidden()
	return true
end

function rock_solid:IsPurgable()
	return false
end

function rock_solid:RemoveOnDeath()
	return false
end

function rock_solid:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function rock_solid:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function rock_solid:GetModifierTotal_ConstantBlock( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if attack is an auto attack
	if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return 0
	end

	local block = ability:GetSpecialValueFor("rock_base") + parent:GetMaxHealth() * ability:GetSpecialValueFor("rock_health") / 100

	-- Reduce block if going over max percent
	if block > event.damage * (ability:GetSpecialValueFor("rock_max") / 100) then
		block = event.damage * (ability:GetSpecialValueFor("rock_max") / 100)
	end

	return block
end