adaptive = class({})

-- Modifier Linkers
LinkLuaModifier("adaptive_stack", "modifiers/adaptive", LUA_MODIFIER_MOTION_NONE)

function adaptive:IsHidden()
	return true
end

function adaptive:IsPurgable()
	return false
end

function adaptive:RemoveOnDeath()
	return false
end

-- Adding Magic Resistance on Equip
function adaptive:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	local mod = parent:FindModifierByName("adaptive_stack")

	if mod then
		unique.mr = unique.mr + mod:GetStackCount() * ability:GetSpecialValueFor("adaptive_mr")
	else
		parent:AddNewModifier(parent, ability, "adaptive_stack", {})
	end
end

-- Removing Magic Resistance on Unequip
function adaptive:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	local mod = parent:FindModifierByName("adaptive_stack")

	if mod then
		unique.mr = unique.mr - mod:GetStackCount() * ability:GetSpecialValueFor("adaptive_mr")
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function adaptive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function adaptive:OnDeath( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is self
	if attacker ~= parent then
		return
	end

	local mod = parent:FindModifierByName("adaptive_stack")

	if not mod then
		return
	end

	-- Check if over max stacks
	if mod:GetStackCount() >= ability:GetSpecialValueFor("adaptive_max") / ability:GetSpecialValueFor("adaptive_mr") then
		return
	end

	mod:SetStackCount(mod:GetStackCount() + 1)

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return
	end

	unique.mr = unique.mr + ability:GetSpecialValueFor("adaptive_mr")
end

adaptive_stack = class ({})

function adaptive_stack:IsHidden()
	return true
end

function adaptive_stack:IsPurgable()
	return false
end

function adaptive_stack:IsPermanent()
	return true
end