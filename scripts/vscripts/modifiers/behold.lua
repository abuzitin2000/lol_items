behold = class({})

function behold:IsHidden()
	return true
end

function behold:IsPurgable()
	return false
end

function behold:RemoveOnDeath()
	return false
end

function behold:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end