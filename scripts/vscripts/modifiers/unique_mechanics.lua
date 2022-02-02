unique_mechanics = class({})

-- Modifier Linkers
LinkLuaModifier("tracker_refresher", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ability_power_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ability_haste_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mr_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("armor_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("tenacity_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_mana_regen_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_health_regen_tracker", "modifiers/unique_mechanics", LUA_MODIFIER_MOTION_NONE)

function unique_mechanics:IsHidden()
	return true
end

function unique_mechanics:IsPurgable()
	return false
end

function unique_mechanics:IsPermanent()
	return true
end

function unique_mechanics:RemoveOnDeath()
	return false
end

function unique_mechanics:OnCreated()
	if not IsServer() then
		return
	end

	self.ap = 0
	self.haste = 0
	self.gpm = 0
	self.armor = 0
	self.mr = 0
	self.base_hp = 0
	self.base_mana = 0
	self.crit = 0
	self.crit_dmg = 175
	self.heal_power = 0
	self.lifesteal = 0
	self.omnivamp = {}
	self.jungle_omnivamp = {}
	self.physvamp = {}
	self.tenacityA = {}
	self.tenacityB = {}
	self.percentage_pen = {}
	self.flat_pen = {}
	self.percentage_magic_pen = {}
	self.flat_magic_pen = {}

	-- Stat trackers for client to see
	self:GetParent():AddNewModifier(self:GetParent(), nil, "tracker_refresher", {})
	self.ap_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "ability_power_tracker", {})
	self.haste_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "ability_haste_tracker", {})
	self.mr_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "mr_tracker", {})
	self.armor_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "armor_tracker", {})
	self.base_mana_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "base_mana_regen_tracker", {})
	self.base_hp_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "base_health_regen_tracker", {})
	self.tenacity_tracker = self:GetParent():AddNewModifier(self:GetParent(), nil, "tenacity_tracker", {})

	self:StartIntervalThink(10)
end

-- Subscribed Interval Mechanics
function unique_mechanics:OnIntervalThink()
	if not IsServer() then
		return
	end
	
	self:GPM()
end

function unique_mechanics:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    	MODIFIER_EVENT_ON_TAKEDAMAGE,
    	MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
    	MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE
    }
    return funcs
end

-- Ability Power
function unique_mechanics:GetModifierSpellAmplify_Percentage()
	if not IsServer() then
		return
	end

	-- Calculate AP
	local ap = self:AbilityPower()

	-- Multiplies for balance reasons
	local multiplier = 0.25

	-- Stat tracker for client to see
	self.ap_tracker:SetStackCount(ap * multiplier)

	return ap * multiplier
end

-- Ability Haste
function unique_mechanics:GetModifierPercentageCooldown()
	if not IsServer() then
		return
	end

	-- Calculate how to convert Haste into CDR
	local haste = self:AbilityHaste()
	
	-- Stat tracker for client to see
	self.haste_tracker:SetStackCount(haste)

	return haste
end

-- Armor
function unique_mechanics:GetModifierPhysicalArmorBonus()
	if not IsServer() then
		return
	end

	-- Calculate armor
	local armor = self:Armor()

	-- Stat tracker for client to see
	self.armor_tracker:SetStackCount(armor * 100)

	return armor
end

-- Magic Resistance
function unique_mechanics:GetModifierMagicalResistanceBonus()
	if not IsServer() then
		return
	end

	-- Calculate magic resistance
	local mr = self:MagicResistance()

	-- Stat tracker for client to see
	self.mr_tracker:SetStackCount(mr)

	return mr
end

-- Health Regen
function unique_mechanics:GetModifierConstantHealthRegen()
	if not IsServer() then
		return
	end

	-- Calculate hp regen
	local base_hp = self:BaseHealthRegen()

	-- Stat tracker for client to see
	self.base_hp_tracker:SetStackCount(base_hp * 100)

	return base_hp
end

-- Mana Regen
function unique_mechanics:GetModifierConstantManaRegen()
	if not IsServer() then
		return
	end

	-- Calculate mana regen
	local base_mana = self:BaseManaRegen()

	-- Stat tracker for client to see
	self.base_mana_tracker:SetStackCount(base_mana * 100)

	return base_mana
end

-- Heal Power
function unique_mechanics:GetModifierHealAmplify_PercentageSource()
	if not IsServer() then
		return
	end

	-- Calculate heal power
	local heal_power = self:HealPower()

	return heal_power
end

-- Tenacity
function unique_mechanics:GetModifierStatusResistanceStacking()
	if not IsServer() then
		return
	end

	-- Calculate tenacity
	local tenacity = self:Tenacity()

	-- Stat tracker for client to see
	self.tenacity_tracker:SetStackCount(tenacity)

	return tenacity
end

-- Crit
function unique_mechanics:GetModifierPreAttack_CriticalStrike( event )
	if not IsServer() then
		return
	end

	-- Calculate crit
	local crit = self:Crit(event.target)

	if RollPseudoRandom(crit, self) then
		self.b_crit = true

		local damage = self.crit_dmg

		if self:GetParent():HasModifier("perfection") then
			damage = damage + self:GetParent():FindModifierByName("perfection"):GetAbility():GetSpecialValueFor("perfection_crit")
		end

		if self:GetParent():HasModifier("deft") then
			self:GetParent():FindModifierByName("deft").ready = true
		end

		return damage
	end

	if self:GetParent():HasModifier("deft") then
		self:GetParent():FindModifierByName("deft").ready = false
	end

	self.b_crit = false
	return 100
end

-- Subscribed Damage Mechanics
function unique_mechanics:OnTakeDamage( event )
	if not IsServer() then
		return
	end

	if event.attacker == self:GetParent() and event.attacker:IsAlive() then
		self:Lifesteal(event.attacker, event.unit, event.damage, event.damage_category)
		self:Omnivamp(event.attacker, event.unit, event.damage, event.inflictor)
		self:JungleOmnivamp(event.attacker, event.unit, event.damage, event.inflictor)
		self:Physvamp(event.attacker, event.unit, event.damage, event.inflictor, event.damage_type)
		self:Pen(event.attacker, event.unit, event.damage, event.inflictor, event.damage_type, event.damage_flags)
		self:MagicPen(event.attacker, event.unit, event.damage, event.inflictor, event.damage_type, event.damage_flags)
		self:CritSfx(event.unit, event.damage_type, event.damage_category)
	end
end

-- Unique Mechanics
-------------------------------------------------------------------------------------------------------------
function unique_mechanics:AbilityPower()
	if not IsServer() then
		return
	end

	local ap = self.ap

	if self:GetParent():HasModifier("ixtal") then
		ap = ap + self.ap * (self:GetParent():FindModifierByName("ixtal"):GetAbility():GetSpecialValueFor("ixtal") / 100)
	end

	if self:GetParent():HasModifier("opus") then
		ap = ap + self.ap * (self:GetParent():FindModifierByName("opus"):GetAbility():GetSpecialValueFor("opus") / 100)
	end

	return ap
end

function unique_mechanics:AbilityHaste()
	if not IsServer() then
		return
	end

	local haste = self.haste

	if self:GetParent():HasModifier("ixtal") then
		haste = haste * (1 + (self:GetParent():FindModifierByName("ixtal"):GetAbility():GetSpecialValueFor("ixtal") / 100))
	end

	return haste / (100 + haste) * 100
end

function unique_mechanics:Armor()
	if not IsServer() then
		return
	end

	-- Turn base dota armor into lol armor value
	--local base_multiplier = 0.06 * self:GetParent():GetPhysicalArmorBaseValue() / (1 + 0.06 * self:GetParent():GetPhysicalArmorBaseValue())
	--local converted_armor = 100 / (1 - base_multiplier) - 100

	--converted_armor = converted_armor + self.armor

	-- Calculate damage multiplier
	--local armor_damage_multiplier = 1 - (100 / (100 + converted_armor))

	-- Turn back into dota armor value
	--local final_armor = -1 * armor_damage_multiplier / (armor_damage_multiplier - 1) / 0.06

	-- TURN OUT IT'S JUST ARMOR DIVIDED BY 6
	local final_armor = self.armor / 6

	return final_armor
end

function unique_mechanics:MagicResistance()
	if not IsServer() then
		return
	end

	-- Turn base dota mr into lol mr value
	local converted_mr = 100 / (1 - self:GetParent():GetBaseMagicalResistanceValue() / 100) - 100

	converted_mr = converted_mr + self.mr

	-- Turn back into dota mr value
	local mr_damage_multiplier = 100 / (100 + converted_mr)

	-- Subtitute for multiplicative stacking
	local final_mr = mr_damage_multiplier / 0.75

	return 100 * (1 - final_mr)
end

function unique_mechanics:BaseHealthRegen()
	if not IsServer() then
		return
	end

	return self:GetParent():GetBaseHealthRegen() * (self.base_hp / 100)
end

function unique_mechanics:BaseManaRegen()
	if not IsServer() then
		return
	end

	return self:GetParent():GetBaseManaRegen() * (self.base_mana / 100)
end

function unique_mechanics:HealPower()
	if not IsServer() then
		return
	end

	return self.heal_power
end

function unique_mechanics:Crit(target)
	if not IsServer() then
		return
	end

	-- Doesn't work on towers
	if target:IsTower() then
		return 0
	end

	-- Doesn't work with wrath
	if self:GetParent():HasModifier("wrath") then
		return 0
	end

	local crit = self.crit

	if crit > 100 then
		return 100
	else
		return crit
	end
end

function unique_mechanics:CritSfx(target, type, category)
	if not IsServer() then
		return
	end

	-- Crit sound effect
	if type == DAMAGE_TYPE_PHYSICAL and category == DOTA_DAMAGE_CATEGORY_ATTACK and self.b_crit then
		target:EmitSound("DOTA_Item.Daedelus.Crit")
	end
end

function unique_mechanics:BaseManaRegen()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	return parent:GetBaseManaRegen() * (self.base_mana / 100)
end

function unique_mechanics:GPM()
	local parent = self:GetParent()

	if not parent:IsRealHero() then
		return
	end

	parent:ModifyGold(self.gpm, true, DOTA_ModifyGold_GameTick)
	
	-- Increase Quest Stack
	local quest_mod = self:GetParent():FindModifierByName("quest")
	if quest_mod then
		quest_mod:SetStackCount(quest_mod:GetStackCount() + self.gpm)
	end
end

function unique_mechanics:Lifesteal(attacker, target, damage, category)
	-- Doesn't work on towers
	if target:IsTower() then
		return
	end

	-- Check if attack is an auto attack
	if category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Heal
	attacker:Heal(damage * (self.lifesteal * 0.01), attacker)

	-- Bloodthirster
	if attacker:HasModifier("ichor") and attacker:GetHealthPercent() == 100 then
		local mod = attacker:FindModifierByName("ichor")
		mod:SetStackCount(mod:GetStackCount() + damage * (self.lifesteal * 0.01) * (1 + self.heal_power / 100))
		mod.decay = mod:GetAbility():GetSpecialValueFor("ichor_duration")

		local max = 50 + 300 / 17 * (attacker:GetLevel() - 1)

		if mod:GetStackCount() > max then
			mod:SetStackCount(max)
		end

		-- Effect
		if not mod.crimson_guard_pfx then
			mod.crimson_guard_pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active.vpcf", PATTACH_OVERHEAD_FOLLOW, attacker)
			ParticleManager:SetParticleControl(mod.crimson_guard_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(mod.crimson_guard_pfx, 1, attacker, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
		end
	end

	-- Effect
	if self.lifesteal > 0 and attacker:GetHealthPercent() ~= 100 then
		if self.lifesteal < 10 then
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal_lanecreeps.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		else
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		end
	end
end

function unique_mechanics:Omnivamp(attacker, target, damage, ability)
	-- Doesn't work on towers
	if target:IsTower() then
		return
	end

	-- Healing is reduced on AOE abilities
	local multiplier = 1
	if ability then
		if ability:GetAOERadius() ~= 0 then
			multiplier = 0.33
		end
	end

	-- Calculate Additive
	local totalomnivamp = 0
	for k, v in pairs(self.omnivamp) do
  		totalomnivamp = totalomnivamp + v
	end

	-- Heal
	attacker:Heal(damage * (totalomnivamp * 0.01) * multiplier, attacker)

	-- Effect
	if totalomnivamp > 0 and attacker:GetHealthPercent() ~= 100 then
		if totalomnivamp < 10 then
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal_lanecreeps.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		else
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		end
	end
end

function unique_mechanics:JungleOmnivamp(attacker, target, damage, ability)
	-- Only works on jungle creeps
	if not target:IsNeutralUnitType() then
		return
	end

	-- Calculate Additive
	local totalomnivamp = 0
	for k, v in pairs(self.jungle_omnivamp) do
  		totalomnivamp = totalomnivamp + v
	end

	-- Heal
	attacker:Heal(damage * (totalomnivamp * 0.01), attacker)

	-- Effect
	if totalomnivamp > 0 and attacker:GetHealthPercent() ~= 100 then
		local lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
	end
end

function unique_mechanics:Physvamp(attacker, target, damage, ability, damage_type)
	-- Doesn't work on towers
	if target:IsTower() then
		return
	end

	-- Only heal from physical damage
	if damage_type ~= DAMAGE_TYPE_PHYSICAL then
		return
	end

	-- Healing is reduced on AOE abilities
	local multiplier = 1
	if ability then
		if ability:GetAOERadius() ~= 0 then
			multiplier = 0.33
		end
	end

	-- Calculate Additive
	local totalphysvamp = 0
	for k, v in pairs(self.physvamp) do
		if not (k == "elixir_wrath" and (not target:IsHero())) then
  			totalphysvamp = totalphysvamp + v
  		end
	end

	-- Heal
	attacker:Heal(damage * (totalphysvamp * 0.01) * multiplier, attacker)

	-- Effect
	if totalphysvamp > 0 and attacker:GetHealthPercent() ~= 100 then
		if totalphysvamp < 10 then
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal_lanecreeps.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		else
			local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		end
	end
end

function unique_mechanics:Pen(attacker, target, damage, ability, damage_type, damage_flags)
	-- Only work on physical damage
	if damage_type ~= DAMAGE_TYPE_PHYSICAL then
		return
	end

	-- Check if target is alive
	if not target:IsAlive() then
		return
	end

	-- Stops infinite loops
	if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end

	-- Calculate Multiplicative
	local percentage_pen = 1
	for k, v in pairs(self.percentage_pen) do
  		percentage_pen = percentage_pen * ((100 - v) / 100)
	end

	-- Calculate Additive
	local flat_pen = 0
	for k, v in pairs(self.flat_pen) do
  		flat_pen = flat_pen + v
	end

	-- Lethality scales with level
	flat_pen = flat_pen * (0.6 + 0.4 * attacker:GetLevel() / 18)

	-- Calculate Damage
	local finaldamage = 0
	local armor = target:GetPhysicalArmorValue(false) * 6

    if armor > 0 then
    	local reduced_armor = armor * percentage_pen
    	reduced_armor = reduced_armor - flat_pen

    	if reduced_armor < 0 then
    		reduced_armor = 0
    	end

    	-- Turn Armor into damage multiplier
    	local reduced_armor_multiplier = 100 / (100 + reduced_armor)
    	local actual_armor_multiplier = 100 / (100 + target:GetPhysicalArmorValue(false) * 6)

    	local expected_damage = (damage / actual_armor_multiplier) * reduced_armor_multiplier
    	finaldamage = math.abs(expected_damage - damage)

    end

    -- Deal Damage
	local damageTable = {
		victim = target,
		attacker = attacker,
		damage = finaldamage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	}
	ApplyDamage(damageTable)
end

function unique_mechanics:MagicPen(attacker, target, damage, ability, damage_type, damage_flags)
	-- Only work on magical damage
	if damage_type ~= DAMAGE_TYPE_MAGICAL then
		return
	end

	-- Check if target is alive
	if not target:IsAlive() then
		return
	end

	-- Stops infinite loops
	if bit.band(damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end

	-- Calculate Multiplicative
	local percentage_magic_pen = 1
	for k, v in pairs(self.percentage_magic_pen) do
  		percentage_magic_pen = percentage_magic_pen * ((100 - v) / 100)
	end

	-- Calculate Additive
	local flat_magic_pen = 0
	for k, v in pairs(self.flat_magic_pen) do
  		flat_magic_pen = flat_magic_pen + v
	end

	-- Calculate Damage
	local finaldamage = 0
	local magic_resistance = math.abs(100 - 100 / (1 - target:GetMagicalArmorValue()))

    if magic_resistance > 0 then
    	local reduced_magic_resistance = magic_resistance * percentage_magic_pen
    	reduced_magic_resistance = reduced_magic_resistance - flat_magic_pen

    	if reduced_magic_resistance < 0 then
    		reduced_magic_resistance = 0
    	end

    	-- Turn Magic Resistance back to dota form
    	reduced_magic_resistance = 1 - 100 / (100 + reduced_magic_resistance)

    	local expected_damage = (damage / (1 - target:GetMagicalArmorValue())) * (1 - reduced_magic_resistance)
    	finaldamage = math.abs(expected_damage - damage)
    end

    -- Deal Damage
	local damageTable = {
		victim = target,
		attacker = attacker,
		damage = finaldamage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	}
	ApplyDamage(damageTable)
end

function unique_mechanics:Tenacity()
	if not IsServer() then
		return
	end

	-- Calculate Additive A
	local tenacityA = 0
	for k, v in pairs(self.tenacityA) do
  		tenacityA = tenacityA + v
	end

	-- Calculate Additive B
	local tenacityB = 0
	for k, v in pairs(self.tenacityB) do
  		tenacityB = tenacityB + v
	end

	return 100 * (1 - (1 - tenacityA / 100) * (1 - tenacityB / 100))
end

-- Trackers
-------------------------------------------------------------------------------------------------------------
tracker_refresher = class ({})

function tracker_refresher:IsHidden()
	return true
end

function tracker_refresher:IsPurgable()
	return false
end

function tracker_refresher:IsPermanent()
	return true
end

function tracker_refresher:RemoveOnDeath()
	return false
end

function tracker_refresher:OnCreated()
	if not IsServer() then
		return
	end

	self.unique = self:GetParent():FindModifierByName("unique_mechanics")

	self:StartIntervalThink(1)
end

function tracker_refresher:OnIntervalThink()
	if not IsServer() then
		return
	end
	
	self.unique:GetModifierSpellAmplify_Percentage()
	self.unique:GetModifierPercentageCooldown()
	self.unique:GetModifierPhysicalArmorBonus()
	self.unique:GetModifierMagicalResistanceBonus()
	self.unique:GetModifierConstantHealthRegen()
	self.unique:GetModifierConstantManaRegen()
	self.unique:GetModifierStatusResistanceStacking()
end

ability_power_tracker = class ({})

function ability_power_tracker:IsHidden()
	return true
end

function ability_power_tracker:IsPurgable()
	return false
end

function ability_power_tracker:IsPermanent()
	return true
end

function ability_power_tracker:RemoveOnDeath()
	return false
end

function ability_power_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function ability_power_tracker:GetModifierSpellAmplify_Percentage()
	if IsServer() then
		return
	end

	return self:GetStackCount()
end

ability_haste_tracker = class ({})

function ability_haste_tracker:IsHidden()
	return true
end

function ability_haste_tracker:IsPurgable()
	return false
end

function ability_haste_tracker:IsPermanent()
	return true
end

function ability_haste_tracker:RemoveOnDeath()
	return false
end

function ability_haste_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
    return funcs
end

function ability_haste_tracker:GetModifierPercentageCooldown()
	if IsServer() then
		return
	end

	return self:GetStackCount()
end

tenacity_tracker = class ({})

function tenacity_tracker:IsHidden()
	return true
end

function tenacity_tracker:IsPurgable()
	return false
end

function tenacity_tracker:IsPermanent()
	return true
end

function tenacity_tracker:RemoveOnDeath()
	return false
end

function tenacity_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }
    return funcs
end

function tenacity_tracker:GetModifierStatusResistanceStacking()
	if IsServer() then
		return
	end

	return self:GetStackCount()
end

armor_tracker = class ({})

function armor_tracker:IsHidden()
	return true
end

function armor_tracker:IsPurgable()
	return false
end

function armor_tracker:IsPermanent()
	return true
end

function armor_tracker:RemoveOnDeath()
	return false
end

function armor_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function armor_tracker:GetModifierPhysicalArmorBonus()
	if IsServer() then
		return
	end

	return self:GetStackCount() / 100
end

mr_tracker = class ({})

function mr_tracker:IsHidden()
	return true
end

function mr_tracker:IsPurgable()
	return false
end

function mr_tracker:IsPermanent()
	return true
end

function mr_tracker:RemoveOnDeath()
	return false
end

function mr_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function mr_tracker:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return
	end

	return self:GetStackCount()
end

base_health_regen_tracker = class ({})

function base_health_regen_tracker:IsHidden()
	return true
end

function base_health_regen_tracker:IsPurgable()
	return false
end

function base_health_regen_tracker:IsPermanent()
	return true
end

function base_health_regen_tracker:RemoveOnDeath()
	return false
end

function base_health_regen_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function base_health_regen_tracker:GetModifierConstantHealthRegen()
	if IsServer() then
		return
	end

	return self:GetStackCount() / 100
end

base_mana_regen_tracker = class ({})

function base_mana_regen_tracker:IsHidden()
	return true
end

function base_mana_regen_tracker:IsPurgable()
	return false
end

function base_mana_regen_tracker:IsPermanent()
	return true
end

function base_mana_regen_tracker:RemoveOnDeath()
	return false
end

function base_mana_regen_tracker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
    return funcs
end

function base_mana_regen_tracker:GetModifierConstantManaRegen()
	if IsServer() then
		return
	end

	return self:GetStackCount() / 100
end