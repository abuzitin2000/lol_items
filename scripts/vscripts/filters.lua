-- called from internal/filters

-- Filters allow you to do some code on specific events.
-- Whats special about it: you can manipulate some values here.

Filters = class({})


function Filters:AbilityTuningValueFilter(event)
	-- called on most abilities for each value
	-- PrintTable(event)
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local valueName = event.value_name_const -- e.g. duration or area_of_affect
	local value = event.value -- can not get modified with local

	-- Shield Power
	local unique = casterUnit:FindModifierByName("unique_mechanics")

	if not unique then
		return true
	end

	-- Aphotic Shield
	if ability:GetAbilityName() == "abaddon_aphotic_shield" and valueName == "damage_absorb" then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	-- Flame Guard
	if ability:GetAbilityName() == "ember_spirit_flame_guard" and valueName == "absorb_amount" then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	-- Refraction
	if ability:GetAbilityName() == "templar_assassin_refraction" and valueName == "instances" then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	-- Fireshield
	if ability:GetAbilityName() == "ogre_magi_smash" and valueName == "attacks" then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	-- Defense Matrix
	if ability:GetAbilityName() == "tinker_defense_matrix" and valueName == "damage_absorb" then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	-- Resonant Pulse
	if ability:GetAbilityName() == "void_spirit_resonant_pulse" and (valueName == "base_absorb_amount" or valueName == "absorb_per_hero_hit") then
		event.value = value + value * unique.heal_power / 100
		return true
	end

	return true
end

function Filters:HealingFilter(event)
	-- PrintTable(event)
	local casterUnit = event.entindex_healer_const and EntIndexToHScript(event.entindex_healer_const)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local heal = event.heal -- can not get modified with local

	if not casterUnit or not targetUnit then
		return true
	end

	-- Ardent Censer
	if casterUnit:HasModifier("sanctify") and casterUnit ~= targetUnit then
		local item = casterUnit:FindItemInInventory("item_ardent")
		casterUnit:AddNewModifier(targetUnit, item, "sanctify_buff", { duration = item:GetSpecialValueFor("sanctify_duration") })
		targetUnit:AddNewModifier(targetUnit, item, "sanctify_buff", { duration = item:GetSpecialValueFor("sanctify_duration") })
	end

	-- Chemtech Putrifier
	if casterUnit:HasModifier("puffcap") and casterUnit ~= targetUnit then
		local item = casterUnit:FindItemInInventory("item_chemtech")
		casterUnit:AddNewModifier(targetUnit, item, "puffcap_buff", { duration = 5 })
		targetUnit:AddNewModifier(targetUnit, item, "puffcap_buff", { duration = 5 })
	end

	return true
end

function Filters:ModifierGainedFilter(event)
	-- PrintTable(event)
	local name = event.name_const
	local duration = event.duration -- can not get modified with local
	local casterUnit = event.entindex_caster_const and EntIndexToHScript(event.entindex_caster_const)
	local parentUnit = event.entindex_parent_const and EntIndexToHScript(event.entindex_parent_const)

	if not casterUnit or not parentUnit then
		return true
	end

	-- Ardent Censer
	if casterUnit:HasModifier("sanctify") and casterUnit ~= parentUnit and (name == "modifier_abaddon_aphotic_shield" or name == "modifier_tinker_defense_matrix") then
		local item = casterUnit:FindItemInInventory("item_ardent")
		casterUnit:AddNewModifier(parentUnit, item, "sanctify_buff", { duration = item:GetSpecialValueFor("sanctify_duration") })
		parentUnit:AddNewModifier(parentUnit, item, "sanctify_buff", { duration = item:GetSpecialValueFor("sanctify_duration") })
	end

	-- Chemtech Putrifier
	if casterUnit:HasModifier("puffcap") and casterUnit ~= parentUnit and (name == "modifier_abaddon_aphotic_shield" or name == "modifier_tinker_defense_matrix") then
		local item = casterUnit:FindItemInInventory("item_chemtech")
		casterUnit:AddNewModifier(parentUnit, item, "puffcap_buff", { duration = 5 })
		parentUnit:AddNewModifier(parentUnit, item, "puffcap_buff", { duration = 5 })
	end

	-- OnStunned Event
	if casterUnit ~= parentUnit and casterUnit:GetTeam() ~= parentUnit:GetTeam() and casterUnit:IsHero() and parentUnit:IsHero() then
		parentUnit:AddNewModifier(casterUnit, nil, "onstunned", {})
	end
	
	return true
end

function Filters:BountyRunePickupFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local xp = event.xp_bounty -- can not get modified with local
	local gold = event.gold_bounty -- can not get modified with local

	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold_bounty = 10
		-- event.xp_bounty = 10

	return true
end

function Filters:DamageFilter(event)
	-- PrintTable(event)
	local attackerUnit = event.entindex_attacker_const and EntIndexToHScript(event.entindex_attacker_const)
	local victimUnit = event.entindex_victim_const and EntIndexToHScript(event.entindex_victim_const)
	local damageType = event.damagetype_const
	local damage = event.damage -- can not get modified with local

	-- --  example
		-- event.damage = 10

	return true
end

function Filters:ExecuteOrderFilter(event)
	-- PrintTable(event)
	local ability = event.entindex_ability and EntIndexToHScript(event.entindex_ability)
	local targetUnit = event.entindex_target and EntIndexToHScript(event.entindex_target)
	local playerID = event.issuer_player_id_const
	local orderType = event.order_type
	local pos = Vector(event.position_x,event.position_y,event.position_z)
	local queue = event.queue
	local seqNum = event.sequence_number_const
	local units = event.units
	local unit = units and units["0"] and EntIndexToHScript(units["0"])

	return true
end

function Filters:ItemAddedToInventoryFilter(event)
	-- PrintTable(event)
	local inventory = event.inventory_parent_entindex_const and EntIndexToHScript(event.inventory_parent_entindex_const)
	local item = event.item_entindex_const and EntIndexToHScript(event.item_entindex_const)
	local itemParent = event.item_parent_entindex_const and EntIndexToHScript(event.item_parent_entindex_const)
	local sugg = event.suggested_slot
	
	return true
end

function Filters:ModifyExperienceFilter(event)
	-- PrintTable(event)
	local playerID = event.player_id_const
	local reason = event.reason_const
	local xp = event.experience -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)
	
	-- --  example
		-- event.experience = xp*RandomFloat(0,2)

	return true
end

function Filters:ModifyGoldFilter(event)
	-- PrintTable(event) 
	local playerID = event.player_id_const
	local reason = event.reason_const
	local gold = event.gold -- can not get modified with local
	local reliable = event.reliable -- can not get modified with local
	local heroUnit = playerID and PlayerResource:GetSelectedHeroEntity(playerID)

	-- --  example
		-- event.gold = gold*RandomFloat(0,2)

	return true
end


function Filters:RuneSpawnFilter(event)
	-- PrintTable(event)
	-- maybe deprecated? 
	return true
end

function Filters:TrackingProjectileFilter(event)
	-- PrintTable(event)
	local dodgeable = event.dodgeable
	local ability = event.entindex_ability_const and EntIndexToHScript(event.entindex_ability_const)
	local attackerUnit = event.entindex_source_const and EntIndexToHScript(event.entindex_source_const)
	local targetUnit = event.entindex_target_const and EntIndexToHScript(event.entindex_target_const)
	local expireTime = event.expire_time
	local isAttack = (1==event.is_attack)
	local maxImpactTime = event.max_impact_time
	local moveSpeed = event.move_speed -- can not get modified with local

	-- --  example
		-- event.move_speed = moveSpeed*RandomFloat(0,2)

	return true
end
