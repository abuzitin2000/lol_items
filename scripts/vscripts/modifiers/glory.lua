glory = class ({})

-- Modifier Linkers
LinkLuaModifier("glorystack", "modifiers/glory", LUA_MODIFIER_MOTION_NONE)

function glory:IsHidden()
	return true
end

function glory:IsPurgable()
	return false
end

function glory:RemoveOnDeath()
	return false
end

-- Adding Stack modifier
function glory:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "glorystack", {})
	local stack = parent:GetModifierStackCount("glorystack", parent)
	
	-- Add Ability Power
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + stack * ability:GetSpecialValueFor("glory")
end

-- Remove Ability Power
function glory:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local stack = parent:GetModifierStackCount("glorystack", parent)
	
	-- Remove Ability Power
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - stack * ability:GetSpecialValueFor("glory")

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function glory:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_DEATH,
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function glory:OnDeath( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.unit
	local attacker = event.attacker
	local mod = parent:FindModifierByName("glorystack")
	local unique = parent:FindModifierByName("unique_mechanics")
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() and parent ~= target then
		return
	end
	
	local stack_max = ability:GetSpecialValueFor("stack_max")
	local stack_kill = ability:GetSpecialValueFor("stack_kill")
	local stack_assist = ability:GetSpecialValueFor("stack_assist")
	local stack_lose = ability:GetSpecialValueFor("stack_lose")
	local glory_AP = ability:GetSpecialValueFor("glory")
	
	if target == parent then
		-- Lose Glory stacks
		mod:SetStackCount(mod:GetStackCount() - stack_lose)
		if mod:GetStackCount() < 0 then
			mod:SetStackCount(0)
		end
		-- Subtract Ability Power
		unique.ap = unique.ap - stack_lose * glory_AP
	elseif target:IsRealHero() then
		-- Gain Glory stacks
		if attacker == parent then
			-- Kill
			mod:SetStackCount(mod:GetStackCount() + stack_kill)
			if mod:GetStackCount() > stack_max then
				mod:SetStackCount(stack_max)
			end
			-- Add Ability Power
			unique.ap = unique.ap + stack_kill * glory_AP
		elseif CalcDistanceBetweenEntityOBB(target, parent) < 1300 then
			-- Assist
			mod:SetStackCount(mod:GetStackCount() + stack_assist)
			if mod:GetStackCount() > stack_max then
				mod:SetStackCount(stack_max)
			end
			-- Add Ability Power
			unique.ap = unique.ap + stack_assist * glory_AP
		end
	end

	-- Set stacks on item
	local item = parent:FindItemInInventory("item_mejai") or parent:FindItemInInventory("item_dark_seal")
	if item then
		item:SetCurrentCharges(mod:GetStackCount())
	end

	self:SetStackCount(mod:GetStackCount())
end

function glory:GetModifierMoveSpeedBonus_Percentage()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if self:GetStackCount() < ability:GetSpecialValueFor("glory_limit") then
		return 0
	end

    return ability:GetSpecialValueFor("glory_speed")
end

glorystack = class ({})

function glorystack:IsHidden()
	return true
end

function glorystack:IsPurgable()
	return false
end

function glorystack:IsPermanent()
	return true
end