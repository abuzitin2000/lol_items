huntsman = class ({})

-- Modifier Linkers
LinkLuaModifier("huntsman_first", "modifiers/huntsman", LUA_MODIFIER_MOTION_NONE)

function huntsman:IsHidden()
	return true
end

function huntsman:IsPurgable()
	return false
end

function huntsman:RemoveOnDeath()
	return false
end

function huntsman:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function huntsman:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

-- Give bonus exprience on large jungle creeps and less on lane creeps
function huntsman:OnDeath( event )
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

	-- Check if attacker is parent
	if parent == attacker and parent:GetTeam() ~= target:GetTeam() then
		-- If target is a large jungle creep
		if target:GetUnitName() == "npc_dota_neutral_alpha_wolf" or target:GetUnitName() == "npc_dota_neutral_centaur_khan" or target:GetUnitName() == "npc_dota_neutral_dark_troll_warlord" or target:GetUnitName() == "npc_dota_neutral_enraged_wildkin" or target:GetUnitName() == "npc_dota_neutral_forest_troll_high_priest" or target:GetUnitName() == "npc_dota_neutral_ghost" or target:GetUnitName() == "npc_dota_neutral_mud_golem" or target:GetUnitName() == "npc_dota_neutral_harpy_storm" or target:GetUnitName() == "npc_dota_neutral_kobold_taskmaster" or target:GetUnitName() == "npc_dota_neutral_ogre_magi" or target:GetUnitName() == "npc_dota_neutral_polar_furbolg_ursa_warrior" or target:GetUnitName() == "npc_dota_neutral_satyr_hellcaller" or target:GetUnitName() == "npc_dota_neutral_black_dragon" or target:GetUnitName() == "npc_dota_neutral_granite_golem" or target:GetUnitName() == "npc_dota_neutral_big_thunder_lizard" then
			-- If it is the first time, give more xp
			if parent:FindModifierByName("huntsman_first") then
				parent:AddExperience(ability:GetSpecialValueFor("huntsman_xp_low"), DOTA_ModifyXP_CreepKill, false, false)
				-- Catch-up xp
				local heroes = HeroList:GetAllHeroes()
				local totalLevel = 0
				local count = 0
				for h,hero in pairs(heroes) do
					totalLevel = totalLevel + hero:GetLevel()
					count = count + 1
				end
				if parent:GetLevel() < (totalLevel / count) - 2 then
					parent:AddExperience(50 * ((totalLevel / count) - parent:GetLevel()), DOTA_ModifyXP_CreepKill, false, false)
				end
			else
				-- First kill xp
				parent:AddExperience(ability:GetSpecialValueFor("huntsman_xp_high"), DOTA_ModifyXP_CreepKill, false, false)
				parent:AddNewModifier(parent, ability, "huntsman_first", {})
			end
		end

		-- If target is a lane creep
		if target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege" then
			local mod = parent:FindModifierByName("huntsman_first")
			if mod then
				local minion = mod.minion
				local jungle = mod.jungle
				-- If penalty is active reduce gold and xp
				if minion > jungle * 0.4 and GameRules:GetDOTATime(false, false) < 1200 then
					parent:ModifyGold(-13, true, DOTA_ModifyGold_CreepKill)
					parent:AddExperience(-1 * target:GetDeathXP() * 0.5, DOTA_ModifyXP_CreepKill, false, true)
				end
			end
		end
	end
end

huntsman_first = class ({})

function huntsman_first:IsHidden()
	return true
end

function huntsman_first:IsPurgable()
	return false
end

function huntsman_first:IsPermanent()
	return true
end

-- Used to handle lane creep penalty
function huntsman_first:OnCreated()
	self.minion = 0
	self.jungle = 0
end