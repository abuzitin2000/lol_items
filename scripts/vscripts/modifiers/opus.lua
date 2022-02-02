opus = class({})

function opus:IsHidden()
	return true
end

function opus:IsPurgable()
	return false
end

function opus:RemoveOnDeath()
	return false
end

function opus:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end