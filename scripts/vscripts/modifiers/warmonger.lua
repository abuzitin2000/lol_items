warmonger = class({})

function warmonger:IsHidden()
	return true
end

function warmonger:IsPurgable()
	return false
end

function warmonger:RemoveOnDeath()
	return false
end

-- Adding Omnivamp on Equip
function warmonger:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.omnivamp["warmonger"] = ability:GetSpecialValueFor("warmonger_omnivamp")
end

-- Removing Omnivamp on Unequip
function warmonger:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.omnivamp["warmonger"] = 0

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end