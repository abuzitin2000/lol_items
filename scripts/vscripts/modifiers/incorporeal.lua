incorporeal = class({})

-- Modifier Linkers
LinkLuaModifier("incorporeal_regen", "modifiers/incorporeal", LUA_MODIFIER_MOTION_NONE)

function incorporeal:IsHidden()
	return true
end

function incorporeal:IsPurgable()
	return false
end

function incorporeal:RemoveOnDeath()
	return false
end

-- Removing Regen Passive
function incorporeal:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local modifier = parent:FindModifierByName("incorporeal_regen")
	if modifier then
		modifier:Destroy()
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function incorporeal:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

-- Get Bonus Health Regen when hit
function incorporeal:OnTakeDamage( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit
	local ability = event.inflictor

	-- Check if parent is the target
	if parent ~= target then
		return	
	end

	-- Check if attacker is a hero
	if not attacker:IsHero() then
		return	
	end

	-- Add regen modifier
	parent:AddNewModifier(parent, self:GetAbility(), "incorporeal_regen", {
		duration = self:GetAbility():GetSpecialValueFor("incorporeal_duration")
	})
end

incorporeal_regen = class({})

function incorporeal_regen:IsPurgable()
	return false
end

function incorporeal_regen:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("incorporeal_regen")
end

function incorporeal_regen:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("incorporeal_regen")
end