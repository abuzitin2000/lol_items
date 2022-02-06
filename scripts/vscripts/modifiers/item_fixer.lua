item_fixer = class({})

function item_fixer:IsHidden()
	return true
end

function item_fixer:IsPurgable()
	return false
end

function item_fixer:RemoveOnDeath()
	return false
end

function item_fixer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_fixer:OnCreated( params )
	if not IsServer() then
		return
	end

	self.hero = EntIndexToHScript(params.hero)
	self.modifierName = params.modifierName
	self.itemName = params.itemName

	self:StartIntervalThink(0.1)
end

-- Need to wait for a sec because putting items in your backpack calls destroy before changing the item slot
function item_fixer:OnIntervalThink()
	if not IsServer() then
		return
	end

	local hero = self.hero
	local modifierName = self.modifierName
	local itemName = self.itemName

	local item = nil

	-- Cleave
	if modifierName == "cleave" then
		item = hero:FindItemInInventory("item_tiamat")
	end

	-- Cursed
	if modifierName == "cursed" then
		item = hero:FindItemInInventory("item_oblivion_orb")
	end

	-- Drain
	if modifierName == "drain" then
		item = hero:FindItemInInventory("item_dorans_ring")
	end

	-- Endure
	if modifierName == "endure" then
		item = hero:FindItemInInventory("item_dorans_shield")
	end

	-- Energized
	if modifierName == "energized" then
		item = hero:FindItemInInventory("item_rapid") or hero:FindItemInInventory("item_kircheis")
	end

	-- Focus
	if modifierName == "focus" then
		item = hero:FindItemInInventory("item_dorans_shield") or hero:FindItemInInventory("item_dorans_ring")
	end

	-- Glide
	if modifierName == "glide" then
		item = hero:FindItemInInventory("item_wisp")
	end

	-- Glory
	if modifierName == "glory" then
		item = hero:FindItemInInventory("item_mejai") or hero:FindItemInInventory("item_dark_seal")
	end

	-- Gouge
	if modifierName == "gouge" then
		item = hero:FindItemInInventory("item_dirk")
	end

	-- Huntsman
	if modifierName == "huntsman" then
		item = hero:FindItemInInventory("item_emberknife") or hero:FindItemInInventory("item_hailblade")
	end

	-- Immolate
	if modifierName == "immolate" then
		item = hero:FindItemInInventory("item_bami")
	end

	-- Incorporeal
	if modifierName == "incorporeal" then
		item = hero:FindItemInInventory("item_cowl")
	end

	-- Jolt
	if modifierName == "jolt" then
		item = hero:FindItemInInventory("item_kircheis")
	end

	-- Lifeline
	if modifierName == "lifeline" then
		item = hero:FindItemInInventory("item_maw") or hero:FindItemInInventory("item_hexdrinker")
	end

	-- Mana Charge
	if modifierName == "mana_charge" then
		item = hero:FindItemInInventory("item_tear") or hero:FindItemInInventory("item_archangel") or hero:FindItemInInventory("item_winter") or hero:FindItemInInventory("item_manamune")
	end

	-- Nimble
	if modifierName == "nimble" then
		item = hero:FindItemInInventory("item_hearthbound")
	end

	-- Precision
	if modifierName == "precision" then
		item = hero:FindItemInInventory("item_noonquiver")
	end

	-- Reap
	if modifierName == "reap" then
		item = hero:FindItemInInventory("item_cull")
	end

	-- Recoup
	if modifierName == "recoup" then
		item = hero:FindItemInInventory("item_emberknife") or hero:FindItemInInventory("item_hailblade")
	end

	-- Recovery
	if modifierName == "recovery" then
		item = hero:FindItemInInventory("item_dorans_shield")
	end

	-- Rend
	if modifierName == "rend" then
		item = hero:FindItemInInventory("item_executioner")
	end

	-- Revved
	if modifierName == "revved" then
		item = hero:FindItemInInventory("item_alternator")
	end

	-- Sear
	if modifierName == "sear" then
		item = hero:FindItemInInventory("item_emberknife") or hero:FindItemInInventory("item_hailblade")
	end

	-- Spellblade
	if modifierName == "spellblade" then
		item = hero:FindItemInInventory("item_lich") or hero:FindItemInInventory("item_essence_reaver") or hero:FindItemInInventory("item_sheen")
	end

	-- Spoils
	if modifierName == "spoils" then
		item = hero:FindItemInInventory("item_runesteel") or hero:FindItemInInventory("item_targon") or hero:FindItemInInventory("item_shoulder") or hero:FindItemInInventory("item_relicshield")
	end

	-- Steeltipped
	if modifierName == "steeltipped" then
		item = hero:FindItemInInventory("item_recurve")
	end

	-- Sturdy
	if modifierName == "sturdy" then
		item = hero:FindItemInInventory("item_phage")
	end

	-- Thorns
	if modifierName == "thorns" then
		item = hero:FindItemInInventory("item_bramble")
	end

	-- Tribute
	if modifierName == "tribute" then
		item = hero:FindItemInInventory("item_frostfang") or hero:FindItemInInventory("item_harrow") or hero:FindItemInInventory("item_spellthief") or hero:FindItemInInventory("item_spectral")
	end

	-- Warmonger
	if modifierName == "warmonger" then
		item = hero:FindItemInInventory("item_dorans_blade")
	end

	-- Witchs Path
	if modifierName == "witchs_path" then
		item = hero:FindItemInInventory("item_seekers")
	end

	-- Wrath
	if modifierName == "wrath" then
		item = hero:FindItemInInventory("item_rageblade") or hero:FindItemInInventory("item_rageknife")
	end

	-- Adaptive
	if modifierName == "adaptive" then
		item = hero:FindItemInInventory("item_verdant")
	end

	-- Rock Solid
	if modifierName == "rock_solid" then
		item = hero:FindItemInInventory("item_randuin") or hero:FindItemInInventory("item_frozen") or hero:FindItemInInventory("item_warden")
	end

	-- Flight
	if modifierName == "flight" then
		item = hero:FindItemInInventory("item_moonplate")
	end

	-- Zealous
	if modifierName == "zealous" then
		item = hero:FindItemInInventory("item_zeal")
	end

	-- Unmake
	if modifierName == "unmake" then
		item = hero:FindItemInInventory("item_abyssal")
	end

	-- Awe
	if modifierName == "awe" then
		item = hero:FindItemInInventory("item_seraph") or hero:FindItemInInventory("item_archangel") or hero:FindItemInInventory("item_fimbul") or hero:FindItemInInventory("item_winter") or hero:FindItemInInventory("item_muramana") or hero:FindItemInInventory("item_manamune")
	end

	-- Empyrean
	if modifierName == "empyrean" then
		item = hero:FindItemInInventory("item_seraph")
	end

	-- Sanctify
	if modifierName == "sanctify" then
		item = hero:FindItemInInventory("item_ardent")
	end

	-- Annul
	if modifierName == "annul" then
		item = hero:FindItemInInventory("item_banshee") or hero:FindItemInInventory("item_night")
	end

	-- Carve
	if modifierName == "carve" then
		item = hero:FindItemInInventory("item_cleaver")
	end

	-- Rage
	if modifierName == "rage" then
		item = hero:FindItemInInventory("item_cleaver")
	end

	-- Behold
	if modifierName == "behold" then
		item = hero:FindItemInInventory("item_vigilant")
	end

	-- Ixtal
	if modifierName == "ixtal" then
		item = hero:FindItemInInventory("item_vigilant")
	end

	-- Mist
	if modifierName == "mist" then
		item = hero:FindItemInInventory("item_ruined")
	end

	-- Siphon
	if modifierName == "siphon" then
		item = hero:FindItemInInventory("item_ruined")
	end

	-- Ichor
	if modifierName == "ichor" then
		item = hero:FindItemInInventory("item_bloodthirster")
	end

	-- Hackshorn
	if modifierName == "hackshorn" then
		item = hero:FindItemInInventory("item_chempunk")
	end

	-- Puffcap
	if modifierName == "puffcap" then
		item = hero:FindItemInInventory("item_chemtech")
	end

	-- Spelldance
	if modifierName == "spelldance" then
		item = hero:FindItemInInventory("item_cosmic")
	end

	-- Shipwrecker
	if modifierName == "shipwrecker" then
		item = hero:FindItemInInventory("item_deadman")
	end

	-- Ignore Pain
	if modifierName == "ignore_pain" then
		item = hero:FindItemInInventory("item_dance")
	end

	-- Defy
	if modifierName == "defy" then
		item = hero:FindItemInInventory("item_dance")
	end

	-- Azakana
	if modifierName == "azakana" then
		item = hero:FindItemInInventory("item_embrace")
	end

	-- Dark Pact
	if modifierName == "dark_pact" then
		item = hero:FindItemInInventory("item_embrace")
	end

	-- Winter
	if modifierName == "winter" then
		item = hero:FindItemInInventory("item_frozen")
	end

	-- Fortify
	if modifierName == "fortify" then
		item = hero:FindItemInInventory("item_gargoyle")
	end

	-- Absorb
	if modifierName == "absorb" then
		item = hero:FindItemInInventory("item_nature")
	end

	-- Flux
	if modifierName == "flux" then
		item = hero:FindItemInInventory("item_axiom")
	end

	-- Everlasting
	if modifierName == "everlast" then
		item = hero:FindItemInInventory("item_fimbul")
	end

	-- Grace
	if modifierName == "grace" then
		item = hero:FindItemInInventory("item_angel")
	end

	-- Seeth
	if modifierName == "seeth" then
		item = hero:FindItemInInventory("item_rageblade")
	end

	-- Hyper
	if modifierName == "hyper" then
		item = hero:FindItemInInventory("item_horizon_focus")
	end

	-- Boarding
	if modifierName == "boarding" then
		item = hero:FindItemInInventory("item_hull")
	end

	-- Perfection
	if modifierName == "perfection" then
		item = hero:FindItemInInventory("item_infinity")
	end

	-- Giant
	if modifierName == "giant" then
		item = hero:FindItemInInventory("item_dominik")
	end

	-- Shock
	if modifierName == "shock" then
		item = hero:FindItemInInventory("item_muramana")
	end

	-- Affliction
	if modifierName == "affliction" then
		item = hero:FindItemInInventory("item_morello")
	end

	-- Sepsis
	if modifierName == "sepsis" then
		item = hero:FindItemInInventory("item_mortal")
	end

	-- Icathian
	if modifierName == "icathian" then
		item = hero:FindItemInInventory("item_nashor")
	end

	-- Deft
	if modifierName == "deft" then
		item = hero:FindItemInInventory("item_navori")
	end

	-- Waltz
	if modifierName == "waltz" then
		item = hero:FindItemInInventory("item_dancer")
	end

	-- Opus
	if modifierName == "opus" then
		item = hero:FindItemInInventory("item_rabadon")
	end

	-- Sharpshooter
	if modifierName == "sharpshooter" then
		item = hero:FindItemInInventory("item_rapid")
	end

	if item and item:GetItemSlot() < 6 then
		hero:AddNewModifier(hero, item, modifierName, {})
	end

	self:Destroy()
end