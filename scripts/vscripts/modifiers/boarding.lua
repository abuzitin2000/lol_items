boarding = class({})

-- Modifier Linkers
LinkLuaModifier("boarding_buff", "modifiers/boarding", LUA_MODIFIER_MOTION_NONE)

function boarding:IsHidden()
	return true
end

function boarding:IsPurgable()
	return false
end

function boarding:RemoveOnDeath()
	return false
end

function boarding:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(1)
end

function boarding:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function boarding:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Check if item is destroyed
	if not ability then
		return
	end

	-- Check if near an ally
	local allies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 1400, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, true)
	if table.getn(allies) > 1 then
		return
	end

	parent:AddNewModifier(parent, ability, "boarding_buff", { duration = 3 })

	local minions = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 1400, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)
	for _, minion in pairs(minions) do
		if minion:GetUnitName() == "npc_dota_goodguys_siege" or minion:GetUnitName() == "npc_dota_goodguys_siege_upgraded" or minion:GetUnitName() == "npc_dota_goodguys_siege_upgraded_mega" or minion:GetUnitName() == "npc_dota_badguys_siege" or minion:GetUnitName() == "npc_dota_badguys_siege_upgraded" or minion:GetUnitName() == "npc_dota_badguys_siege_upgraded_mega" then
			minion:AddNewModifier(parent, ability, "boarding_buff", { duration = 3 })
		end
	end
end

boarding_buff = class({})

function boarding_buff:IsHidden()
	return false
end

function boarding_buff:IsPurgable()
	return false
end

function boarding_buff:GetEffectName()
	return "particles/items_fx/armlet.vpcf"
end

function boarding_buff:OnCreated()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	self.multiplier = caster:GetLevel() / 18

	if parent:IsHero() then
		local armor = ability:GetSpecialValueFor("boarding_armor_min") + (ability:GetSpecialValueFor("boarding_armor_max") - ability:GetSpecialValueFor("boarding_armor_min")) * self.multiplier

		local unique = parent:FindModifierByName("unique_mechanics")
		unique.armor = unique.armor + armor
		unique.mr = unique.mr + armor
	end
end

function boarding_buff:OnDestroy()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:IsHero() then
		local armor = ability:GetSpecialValueFor("boarding_armor_min") + (ability:GetSpecialValueFor("boarding_armor_max") - ability:GetSpecialValueFor("boarding_armor_min")) * self.multiplier

		local unique = parent:FindModifierByName("unique_mechanics")
		unique.armor = unique.armor - armor
		unique.mr = unique.mr - armor
	end
end

-- Stats
function boarding_buff:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    	MODIFIER_PROPERTY_MODEL_SCALE,
    	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

-- Bonus Damage
function boarding_buff:GetModifierDamageOutgoing_Percentage( event )
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Only work on towers
	if (not target) or not target:IsTower() then
		return
	end

	if parent:IsHero() then
		return ability:GetSpecialValueFor("boarding_damage")
	end

	return ability:GetSpecialValueFor("boarding_minion_damage")
end

-- Bonus size
function boarding_buff:GetModifierModelScale()
	local parent = self:GetParent()

	if parent:IsHero() then
		return 0
	end

	return 10
end

-- Bonus Armor
function boarding_buff:GetModifierPhysicalArmorBonus()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if parent:IsHero() then
		return 0
	end

	local multiplier = caster:GetLevel() / 18
	local armor = ability:GetSpecialValueFor("boarding_minion_armor_min") + (ability:GetSpecialValueFor("boarding_minion_armor_max") - ability:GetSpecialValueFor("boarding_minion_armor_min")) * multiplier

	return armor / 6
end

-- Bonus MR
function boarding_buff:GetModifierMagicalResistanceBonus()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if parent:IsHero() then
		return 0
	end

	local multiplier = caster:GetLevel() / 18
	local armor = ability:GetSpecialValueFor("boarding_minion_armor_min") + (ability:GetSpecialValueFor("boarding_minion_armor_max") - ability:GetSpecialValueFor("boarding_minion_armor_min")) * multiplier

	-- Turn base dota mr into lol mr value
	local converted_mr = 100 / (1 - self:GetParent():GetBaseMagicalResistanceValue() / 100) - 100

	converted_mr = converted_mr + armor

	-- Turn back into dota mr value
	local mr_damage_multiplier = 100 / (100 + converted_mr)

	-- Subtitute for multiplicative stacking
	local final_mr = mr_damage_multiplier / 0.75

	return 100 * (1 - final_mr)
end