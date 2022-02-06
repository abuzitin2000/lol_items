_G.ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)
_G.PUBLISH_DATA = LoadKeyValues(ADDON_FOLDER:sub(5,-16).."publish_data.txt") or {}
_G.WORKSHOP_TITLE = PUBLISH_DATA.title or "Dota 2 but..."-- LoadKeyValues(debug.getinfo(1,"S").source:sub(7,-53).."publish_data.txt").title 
_G.MAX_LEVEL = 30

_G.GameMode = _G.GameMode or class({})

require("internal/utils/util")
require("internal/init")

require("internal/courier") -- EditFilterToCourier called from internal/filters

require("internal/utils/butt_api")
require("internal/utils/custom_gameevents")
require("internal/utils/particles")
require("internal/utils/timers")
-- require("internal/utils/notifications") -- will test it tomorrow 

require("internal/events")
require("internal/filters")
require("internal/panorama")
require("internal/shortcuts")
require("internal/talents")
require("internal/thinker")
require("internal/xp_modifier")

softRequire("events")
softRequire("filters")
softRequire("settings_butt")
softRequire("settings_misc")
softRequire("startitems")
softRequire("thinker")
softRequire("damn_particles_lua")

LinkLuaModifier("unique_mechanics", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_fixer", "modifiers/item_fixer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("onstunned", "modifiers/onstunned", LUA_MODIFIER_MOTION_NONE)

function Precache( context )
	FireGameEvent("addon_game_mode_precache",nil)
	PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_visage/visage_grave_chill_cast_beams.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_heal.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context)
	PrecacheResource("particle", "particles/items4_fx/spirit_vessel_damage_spirit.vpcf", context)
	PrecacheResource("particle", "particles/econ/events/ti7/shivas_guard_slow.vpcf", context)
	PrecacheResource("particle", "particles/items3_fx/lotus_orb_shield.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_staff_lvlup_globe.vpcf", context)
	PrecacheResource("particle", "particles/items_fx/aegis_timer.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_landing_rings.vpcf", context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Spawn()
	FireGameEvent("addon_game_mode_spawn",nil)
	local gmE = GameRules:GetGameModeEntity()

	gmE:SetUseDefaultDOTARuneSpawnLogic(true)
	gmE:SetTowerBackdoorProtectionEnabled(true)
	GameRules:SetShowcaseTime(0)

	FireGameEvent("created_game_mode_entity",{gameModeEntity = gmE})
end

function Activate()
	FireGameEvent("addon_game_mode_activate",nil)
	-- GameRules.GameMode = GameMode()
	-- FireGameEvent("init_game_mode",{})
end

ListenToGameEvent("addon_game_mode_activate", function()
	print( "Dota Butt Template is loaded." )
end, nil)

ListenToGameEvent("dota_item_purchased", function(keys)
	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname 
	-- The cost of the item purchased
	local itemcost = keys.itemcost
	local Player = PlayerResource:GetPlayer(plyID)
	local hero = Player:GetAssignedHero()

	-- Counters
	local control = 0
	local controlStack = 0
	local trinket = 0
	local potion = 0
	local jungle = 0
	local dark_seal = 0
	local tear = 0
	local boots = 0

	-- Count
	for itemSlot = 0, 14, 1 do
        local Item = hero:GetItemInSlot(itemSlot)

        if Item ~= nil and itemName ~= nil then
	        -- Control Ward
	        if hero:HasItemInInventory("item_wardstone") then
	        	if itemName == "item_control" and Item:GetAbilityName() == "item_control" then
		        	if hero:FindItemInInventory("item_wardstone"):GetCurrentCharges() > 2 then
		        		hero:RemoveItem(Item)
		    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
		    			-- Error
		    			HUDError("Can't have more than 3 control wards!", plyID)
		   				EmitSoundOnClient("General.CastFail_Silenced", Player)
		   				return
		   			else
		   				hero:RemoveItem(Item)
		    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
		    			hero:FindItemInInventory("item_wardstone"):SetCurrentCharges(hero:FindItemInInventory("item_wardstone"):GetCurrentCharges() + 1)
		    			return
		        	end
		        end
		    elseif hero:HasItemInInventory("item_vigilant") then
	        	if itemName == "item_control" and Item:GetAbilityName() == "item_control" then
		        	if hero:FindItemInInventory("item_vigilant"):GetCurrentCharges() > 2 then
		        		hero:RemoveItem(Item)
		    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
		    			-- Error
		    			HUDError("Can't have more than 3 control wards!", plyID)
		   				EmitSoundOnClient("General.CastFail_Silenced", Player)
		   				return
		   			else
		   				hero:RemoveItem(Item)
		    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
		    			hero:FindItemInInventory("item_vigilant"):SetCurrentCharges(hero:FindItemInInventory("item_vigilant"):GetCurrentCharges() + 1)
		    			return
		        	end
		        end
	        else
		        if Item:GetAbilityName() == "item_control" then
		        	if itemName == "item_control" and control > 0 and controlStack > 1 then
		    			hero:RemoveItem(Item)
		    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
		    			-- Error
		    			HUDError("Can't have more than 2 control wards!", plyID)
		   				EmitSoundOnClient("General.CastFail_Silenced", Player)
		   				return
		    		else
			        	control = control + 1
			        	controlStack = Item:GetCurrentCharges()
		        	end
		        end
		    end

	        -- Potion
	        if Item:GetAbilityName() == "item_potion" or Item:GetAbilityName() == "item_refill" or Item:GetAbilityName() == "item_recipe_corrupt" or Item:GetAbilityName() == "item_corrupt" then
	        	if (itemName == "item_potion" or itemName == "item_refill" or itemName == "item_recipe_corrupt") and potion > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Potion limit exceeded!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	potion = potion + 1
	        	end
	        end

	        -- Jungle and Support
	        if Item:GetAbilityName() == "item_emberknife" or Item:GetAbilityName() == "item_hailblade" or Item:GetAbilityName() == "item_spellthief" or Item:GetAbilityName() == "item_spectral" or Item:GetAbilityName() == "item_shoulder" or Item:GetAbilityName() == "item_relicshield" then
	        	if (itemName == "item_emberknife" or itemName == "item_hailblade" or itemName == "item_spellthief" or itemName == "item_spectral" or itemName == "item_shoulder" or itemName == "item_relicshield") and jungle > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Can't have multiple gold items!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	jungle = jungle + 1
	        	end
	        end

	        -- Dark Seal
	        if Item:GetAbilityName() == "item_dark_seal" then
	        	if itemName == "item_dark_seal" and dark_seal > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Can't have multiple seals!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	dark_seal = dark_seal + 1
	        	end
	        end

	        -- Tear
	        if Item:GetAbilityName() == "item_tear" then
	        	if itemName == "item_tear" and tear > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Can't have multiple tears!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	tear = tear + 1
	        	end
	        end

	        -- Elixirs
	        if hero:GetLevel() < 9 then
	        	if itemName == "item_elixir_sorcery" or itemName == "item_elixir_wrath" or itemName == "item_elixir_iron" then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Level 9 required!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	        	end
	        end

	        -- Boots
	        if Item:GetAbilityName() == "item_boot" or Item:GetAbilityName() == "item_sorcerer_boot" or Item:GetAbilityName() == "item_berserker_boot" or Item:GetAbilityName() == "item_swiftness_boot" or Item:GetAbilityName() == "item_ionia_boot" or Item:GetAbilityName() == "item_mercury_boot" or Item:GetAbilityName() == "item_mobility_boot" or Item:GetAbilityName() == "item_plated_boot" or Item:GetAbilityName() == "item_recipe_sorcerer_boot" or Item:GetAbilityName() == "item_recipe_berserker_boot" or Item:GetAbilityName() == "item_recipe_swiftness_boot" or Item:GetAbilityName() == "item_recipe_ionia_boot" or Item:GetAbilityName() == "item_recipe_mercury_boot" or Item:GetAbilityName() == "item_recipe_mobility_boot" or Item:GetAbilityName() == "item_recipe_plated_boot" then
	        	if (itemName == "item_boot" or itemName == "item_recipe_sorcerer_boot" or itemName == "item_recipe_berserker_boot" or itemName == "item_recipe_swiftness_boot" or itemName == "item_recipe_ionia_boot" or itemName == "item_recipe_mercury_boot" or itemName == "item_recipe_mobility_boot" or itemName == "item_recipe_plated_boot") and boots > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Can't have multiple boots!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	boots = boots + 1
	        	end
	        end

	        -- Stop Watch
	        if Item:GetAbilityName() == "item_stopwatch" then
	        	if hero:HasModifier("item_stopwatch_broken_modifier") then
	    			hero:RemoveItem(Item)
	    			hero:AddItemByName("item_broken_stopwatch")
	   				return
	        	end
	        end


	    end
    end

    -- Count for Jungle Item Slot
	for itemSlot = 16, 9, -1 do
        local Item = hero:GetItemInSlot(itemSlot)

        if Item ~= nil and itemName ~= nil then
	        -- Trinket
	        if Item:GetAbilityName() == "item_sward" or Item:GetAbilityName() == "item_oracle" or Item:GetAbilityName() == "item_far" then
	        	if (itemName == "item_sward" or itemName == "item_oracle" or itemName == "item_far") and trinket > 0 then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Trinket slot is not empty!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	    		else
		        	trinket = trinket + 1
	        	end
	        end

	        -- Far sight
	        if hero:GetLevel() < 9 then
	        	if itemName == "item_far" then
	    			hero:RemoveItem(Item)
	    			hero:ModifyGold(itemcost, true, DOTA_ModifyGold_SellItem)
	    			-- Error
	    			HUDError("Level 9 required!", plyID)
	   				EmitSoundOnClient("General.CastFail_Silenced", Player)
	   				return
	        	end
	        end


	    end
    end
end, nil)

ListenToGameEvent("dota_tutorial_shop_toggled", function(keys)
	Timers:CreateTimer( 0, function ()
		CustomGameEventManager:Send_ServerToAllClients("rotate_shop", {})
		return 0.1
	end)
end, nil)