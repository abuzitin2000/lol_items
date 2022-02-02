reap = class ({})

-- Modifier Linkers
LinkLuaModifier("reap_stack", "modifiers/reap", LUA_MODIFIER_MOTION_NONE)

function reap:IsHidden()
	return true
end

function reap:IsPurgable()
	return false
end

function reap:RemoveOnDeath()
	return false
end

function reap:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "reap_stack", {})
end

function reap:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function reap:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

-- Gain Gold on Death
function reap:OnDeath( event )
	if IsServer() then
		local parent = self:GetParent()
		local attacker = event.attacker
		local target = event.unit

		-- Check if attacker is parent
		if parent == attacker then
			-- Check if target is lane creep
			if target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege" then
				-- Using another modifier to not lose stacks when losing modifier
				local mod = parent:FindModifierByName("reap_stack")
				mod:IncrementStackCount()

				-- Get data
				local ability = self:GetAbility()

				if not ability then
					return
				end
	
				local maxstack = ability:GetSpecialValueFor("reap_max_stack")
				local gold = ability:GetSpecialValueFor("reap_gold")
				local maxgold = ability:GetSpecialValueFor("reap_max_gold")

				-- Give gold
				if mod:GetStackCount() < maxstack then
					-- Give gold if stack is less than max
					parent:ModifyGold(gold, false, DOTA_ModifyGold_CreepKill)
					-- Set item stack
					for itemSlot = 0, 14, 1 do
        				local Item = parent:GetItemInSlot(itemSlot)
        				if Item ~= nil then
	        				if Item:GetAbilityName() == "item_cull" then
								Item:SetCurrentCharges(maxstack - mod:GetStackCount())
							end
						end
					end
				elseif mod:GetStackCount() == maxstack then
					-- Give max gold if stack is max and then stop giving gold
					parent:ModifyGold(maxgold, false, DOTA_ModifyGold_CreepKill)
					-- Set item stack
					for itemSlot = 0, 14, 1 do
        				local Item = parent:GetItemInSlot(itemSlot)
        				if Item ~= nil then
	        				if Item:GetAbilityName() == "item_cull" then
								Item:SetCurrentCharges(maxstack - mod:GetStackCount())
							end
						end
					end
				end
			end
		end
	end
end

reap_stack = class ({})

function reap_stack:IsHidden()
	return true
end

function reap_stack:IsPurgable()
	return false
end

function reap_stack:IsPermanent()
	return true
end