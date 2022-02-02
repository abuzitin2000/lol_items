tribute = class ({})

-- Modifier Linkers
LinkLuaModifier("quest", "modifiers/quest", LUA_MODIFIER_MOTION_NONE)

function tribute:IsHidden()
	return false
end

function tribute:IsPurgable()
	return false
end

function tribute:RemoveOnDeath()
	return false
end

function tribute:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "quest", {})

	if not ability then
		return
	end

	self:StartIntervalThink(ability:GetSpecialValueFor("second") / ability:GetSpecialValueFor("stack"))
end

function tribute:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function tribute:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	if self:GetStackCount() < ability:GetSpecialValueFor("stack") then
		self:IncrementStackCount()
	end

	-- Set Item Stack
	--local item = parent:FindItemInInventory("item_spellthief") or parent:FindItemInInventory("item_spectral")
	--item:SetCurrentCharges(self:GetStackCount())
end

function tribute:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
    	MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function tribute:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local attacker = event.attacker
	local target = event.target
	local mod = parent:FindModifierByName("quest")

	if not ability then
		return
	end

	if attacker == parent and target:IsAlive() and self:GetStackCount() > 0 and (target:IsHero() or target:IsTower()) and event.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		-- Check if near an ally
		local allies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 2000, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		if table.getn(allies) > 1 then
			-- Give gold
			parent:ModifyGold(ability:GetSpecialValueFor("gold"), true, DOTA_ModifyGold_AbilityGold)
			self:DecrementStackCount()
			PopupGoldGain(target, ability:GetSpecialValueFor("gold"))
			target:EmitSound("General.Coins")

			-- Quest
			mod:SetStackCount(mod:GetStackCount() + ability:GetSpecialValueFor("gold"))
			if mod:GetStackCount() > ability:GetSpecialValueFor("max_gold") then
				mod:SetStackCount(ability:GetSpecialValueFor("max_gold"))
			end
		
			-- Set Item Stack
			--local item = parent:FindItemInInventory("item_spellthief") or parent:FindItemInInventory("item_spectral")
			--item:SetCurrentCharges(self:GetStackCount())
		end
	end
end

-- Reduce last hit gold when over farmed
function tribute:OnDeath( event )
	if IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit

	if target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege" then
		if parent == attacker and parent:GetTeam() ~= target:GetTeam() and parent:GetLastHits() > 20 * GameRules:GetDOTATime(false, false) / 300 then
			local per = 0.5 + (parent:GetLastHits() * 0.01)
			if per > 0.8 then
				parent:ModifyGold(-1 * target:GetGoldBounty() * 0.8, true, DOTA_ModifyGold_CreepKill)
			else
				parent:ModifyGold(-1 * target:GetGoldBounty() * per, true, DOTA_ModifyGold_CreepKill)
			end
		end
	end
end