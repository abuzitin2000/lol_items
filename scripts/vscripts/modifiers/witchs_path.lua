witchs_path = class({})

-- Modifier Linkers
LinkLuaModifier("witchs_path_stack", "modifiers/witchs_path", LUA_MODIFIER_MOTION_NONE)

function witchs_path:IsHidden()
	return true
end

function witchs_path:IsPurgable()
	return false
end

function witchs_path:RemoveOnDeath()
	return false
end

-- Adding Armor on Equip
function witchs_path:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	local mod = parent:FindModifierByName("witchs_path_stack")

	if mod then
		unique.armor = unique.armor + mod:GetStackCount() * ability:GetSpecialValueFor("witchs_armor")
	else
		parent:AddNewModifier(parent, ability, "witchs_path_stack", {})
	end
end

-- Removing Armor on Unequip
function witchs_path:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local unique = parent:FindModifierByName("unique_mechanics")
	local mod = parent:FindModifierByName("witchs_path_stack")

	if mod then
		unique.armor = unique.armor - mod:GetStackCount() * ability:GetSpecialValueFor("witchs_armor")
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function witchs_path:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function witchs_path:OnDeath( event )
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

	local mod = parent:FindModifierByName("witchs_path_stack")

	if not mod then
		return
	end

	-- Check if over max stacks
	if mod:GetStackCount() >= ability:GetSpecialValueFor("witchs_max") / ability:GetSpecialValueFor("witchs_armor") then
		return
	end

	mod:SetStackCount(mod:GetStackCount() + 1)

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return
	end

	unique.armor = unique.armor + ability:GetSpecialValueFor("witchs_armor")
end

witchs_path_stack = class ({})

function witchs_path_stack:IsHidden()
	return true
end

function witchs_path_stack:IsPurgable()
	return false
end

function witchs_path_stack:IsPermanent()
	return true
end