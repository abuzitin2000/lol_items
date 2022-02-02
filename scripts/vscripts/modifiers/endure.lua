endure = class({})

-- Modifier Linkers
LinkLuaModifier("endure_regen", "modifiers/endure", LUA_MODIFIER_MOTION_NONE)

function endure:IsHidden()
	return true
end

function endure:IsPurgable()
	return false
end

function endure:RemoveOnDeath()
	return false
end

-- Removing Regen Passive
function endure:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local modifier = parent:FindModifierByName("endure_regen")
	if modifier then
		modifier:Destroy()
	end

	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function endure:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

-- Get Bonus Health Regen when hit
function endure:OnTakeDamage( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit
	local ability = event.inflictor

	-- Check if parent is the target
	if parent == target then
		-- Check if attacker is a hero or is a neutral creep or Roshan
		if attacker:IsHero() or attacker:IsNeutralUnitType() or attacker:GetUnitName() == "npc_dota_roshan" then
			-- Multiplier used to determine regen power
			self:SetStackCount(0)
			-- Reduce regen if parent is ranged
			if parent:IsRangedAttacker() then
				self:SetStackCount(1)
			end
			-- Reduce regen if hit by an aoe or dot ability
			if ability then
				if ability:GetAOERadius() > 0 then
					self:SetStackCount(1)
				elseif ability:GetDuration() > 0 then
					self:SetStackCount(1)
				end
			end
			-- Reduce regen if damage is done through proc
			if parent:IsRangedAttacker() then
				self:SetStackCount(1)
			end
			-- Add regen modifier
			parent:AddNewModifier(parent, self:GetAbility(), "endure_regen", {
				duration = self:GetAbility():GetSpecialValueFor("endure_duration")
			})
		end 
	end
end

endure_regen = class({})

function endure_regen:IsPurgable()
	return false
end

function endure_regen:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-- Bonus Health Regen
function endure_regen:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local duration = self:GetDuration()
	local regen = (100 - parent:GetHealthPercent()) * 0.53 / duration
	local multiplier = 1
	if parent:GetModifierStackCount("endure", parent) > 0 then
		multiplier = self:GetAbility():GetSpecialValueFor("endure_reduce")
	end
	-- Check if going over max regen
	if regen > self:GetAbility():GetSpecialValueFor("endure_regen") / duration then
    	return (self:GetAbility():GetSpecialValueFor("endure_regen") / duration) * multiplier
    else
    	return regen * multiplier
    end
end