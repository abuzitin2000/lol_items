perfection = class({})

function perfection:IsHidden()
	return true
end

function perfection:IsPurgable()
	return false
end

function perfection:RemoveOnDeath()
	return false
end

function perfection:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end