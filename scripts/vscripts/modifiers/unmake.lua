unmake = class({})

-- Modifier Linkers
LinkLuaModifier("unmake_debuff", "modifiers/unmake", LUA_MODIFIER_MOTION_NONE)

function unmake:IsHidden()
	return true
end

function unmake:IsPurgable()
	return false
end

function unmake:RemoveOnDeath()
	return false
end

function unmake:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	self.mr = 0

	self:StartIntervalThink(1)
end

function unmake:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Curse enemies around the hero
	local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 550, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)
	for _,enemy in ipairs(enemies) do
		enemy:AddNewModifier(parent, ability, "unmake_debuff", {
		duration = 1.0
	})
	end

	local count = table.getn(enemies)
	
	if count > 5 then
		count = 5
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - self.mr
	self.mr = count * ability:GetSpecialValueFor("unmake_buff")
	unique.mr = unique.mr + self.mr
end

function unmake:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

unmake_debuff = class ({})

function unmake_debuff:IsHidden()
	return false
end

function unmake_debuff:IsPurgable()
	return false
end

function unmake_debuff:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	self.reduction = ability:GetSpecialValueFor("unmake_base") + (ability:GetSpecialValueFor("unmake_percentage") / 100) * caster:GetMaxHealth()

	if self.reduction > ability:GetSpecialValueFor("unmake_max") then
		self.reduction = ability:GetSpecialValueFor("unmake_max")
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr - self.reduction
end

function unmake_debuff:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.mr = unique.mr + self.reduction
end