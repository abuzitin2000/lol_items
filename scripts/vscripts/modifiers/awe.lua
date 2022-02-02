awe = class({})

function awe:IsHidden()
	return true
end

function awe:IsPurgable()
	return false
end

function awe:RemoveOnDeath()
	return false
end

function awe:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")

	if ability:GetAbilityName() == "item_archangel" or ability:GetAbilityName() == "item_seraph" then
		self.haste = (parent:GetMaxMana() - parent:GetIntellect() * 12) * ability:GetSpecialValueFor("awe") / 100
		unique.haste = unique.haste + self.haste
	end

	self:StartIntervalThink(1)
end

function awe:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")

	if ability:GetAbilityName() == "item_archangel" or ability:GetAbilityName() == "item_seraph" then
		unique.haste = unique.haste - self.haste
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function awe:OnIntervalThink()
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

	if ability:GetAbilityName() == "item_archangel" or ability:GetAbilityName() == "item_seraph" then
		unique.haste = unique.haste - self.haste
		self.haste = (parent:GetMaxMana() - parent:GetIntellect() * 12) * ability:GetSpecialValueFor("awe") / 100
		unique.haste = unique.haste + self.haste
	end
end

-- Stats
function awe:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function awe:GetModifierHealthBonus()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if ability:GetAbilityName() == "item_winter" or ability:GetAbilityName() == "item_fimbul" then
		return parent:GetMaxMana() * (ability:GetSpecialValueFor("awe") / 100)
	end

	return 0
end

function awe:GetModifierPreAttack_BonusDamage()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if ability:GetAbilityName() == "item_manamune" or ability:GetAbilityName() == "item_muramana" then
		return parent:GetMaxMana() * (ability:GetSpecialValueFor("awe") / 100)
	end

	return 0
end