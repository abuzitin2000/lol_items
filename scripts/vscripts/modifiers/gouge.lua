gouge = class({})

function gouge:IsHidden()
	return true
end

function gouge:IsPurgable()
	return false
end

function gouge:RemoveOnDeath()
	return false
end

-- Adding Lethality on Equip
function gouge:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.flat_pen["gouge"] = ability:GetSpecialValueFor("gouge")
end

-- Removing Lethality on Unequip
function gouge:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.flat_pen["gouge"] = 0

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end