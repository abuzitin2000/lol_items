dark_pact = class({})

function dark_pact:IsHidden()
	return true
end

function dark_pact:IsPurgable()
	return false
end

function dark_pact:RemoveOnDeath()
	return false
end

function dark_pact:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")

	self.ap = (parent:GetMaxHealth() - parent:GetStrength() * 20) * ability:GetSpecialValueFor("dark_pact") / 100
	unique.ap = unique.ap + self.ap

	self:StartIntervalThink(1)
end

function dark_pact:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - self.ap

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function dark_pact:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return
	end

	unique.ap = unique.ap - self.ap
	self.ap = (parent:GetMaxHealth() - parent:GetStrength() * 20) * ability:GetSpecialValueFor("dark_pact") / 100
	unique.ap = unique.ap + self.ap
end