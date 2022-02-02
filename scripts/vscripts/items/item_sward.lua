item_sward = class({})

-- Modifier Linkers
LinkLuaModifier("item_sward_modifier", "items/item_sward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sward_modifier", "items/item_sward", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_sward:OnSpellStart()
	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("item_sward_modifier")

	if not mod then
		mod = caster:AddNewModifier(caster, self, "item_sward_modifier", {})
	end

	if mod and mod.charge > 0 then
		-- Spend Charge and set charge timer
		mod.charge = mod.charge - 1
		local heroes = HeroList:GetAllHeroes()
		local totalLevel = 0
		local count = 0
		for h,hero in pairs(heroes) do
			totalLevel = totalLevel + hero:GetLevel()
			count = count + 1
		end
		local charge_timer = 240 - 120 / 17 * (totalLevel / count - 1)
		if charge_timer < mod.charge_timer or mod.charge_timer == 0 then
			mod.charge_timer = charge_timer
		end

		-- Summon the ward
		local ward = CreateUnitByName("npc_dota_observer_wards", caster:GetCursorPosition(), true, caster, caster, caster:GetTeam())
		ward:AddNewModifier(caster, self, "modifier_kill", {
			duration = 90 + 30 / 17 * (totalLevel / count - 1)
		})
		ward:AddNewModifier(caster, nil, "sward_modifier", {})
		ward:SetMaximumGoldBounty(10)
		ward:SetMinimumGoldBounty(10)
		ward:SetDeathXP(40)
	end

	self:SpendCharge()
	EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "DOTA_Item.ObserverWard.Activate", caster)
end

-- Modifiers
-------------------------------------------------------------------------------------------------------------
item_sward_modifier = class({})

function item_sward_modifier:IsHidden()
	return true
end

function item_sward_modifier:IsPurgable()
	return false
end

function item_sward_modifier:IsPermanent()
	return true
end

function item_sward_modifier:RemoveOnDeath()
	return false
end

function item_sward_modifier:OnCreated()
	if not IsServer() then
		return
	end

	self.charge = 2
	self.charge_timer = 0
	self.ward_count = 0
	self.wards = {0, 0, 0, 0}

	local mod = self:GetParent():FindModifierByName("support_ward_stack_modifier")
	if mod then
		self.wards[0] = mod.wards[0]
		self.wards[1] = mod.wards[1]
		self.wards[2] = mod.wards[2]
		self.wards[3] = mod.wards[3]
		self.ward_count = mod.ward_count
	end

	self:StartIntervalThink(1)
end

function item_sward_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	if self.charge_timer > 0 then
		-- Reduce charge timer every second
		if self.charge < 2 then
			self.charge_timer = self.charge_timer - 1
		end
	elseif self.charge < 2 then
		-- Increase ward charge and set charge timer
		self.charge = self.charge + 1

		local heroes = HeroList:GetAllHeroes()
		local totalLevel = 0
		local count = 0
		for h,hero in pairs(heroes) do
			totalLevel = totalLevel + hero:GetLevel()
			count = count + 1
		end
		self.charge_timer = 240 - 120 / 17 * (totalLevel / count - 1)
	end

	-- Set Item Stacks
	local item = self:GetParent():FindItemInInventory("item_sward")
	if item then
		item:SetCurrentCharges(self.charge)
	end
end

sward_modifier = class ({})

function sward_modifier:IsHidden()
	return false
end

function sward_modifier:IsPurgable()
	return false
end

function sward_modifier:GetTexture()
	return "item_sward"
end

function sward_modifier:OnCreated( event )
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("item_sward_modifier")
	local support_mod = caster:FindModifierByName("support_ward_stack_modifier")

	-- Check if ward limit is reached
	if mod.ward_count > 2 then
		mod.wards[0]:ForceKill(false)
	end
	mod.wards[mod.ward_count] = self:GetParent()
	mod.ward_count = mod.ward_count + 1
	
	if support_mod then
		support_mod.wards[0] = mod.wards[0]
		support_mod.wards[1] = mod.wards[1]
		support_mod.wards[2] = mod.wards[2]
		support_mod.wards[3] = mod.wards[3]
		support_mod.ward_count = mod.ward_count
	end

	self:StartIntervalThink(0.1)
end

function sward_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("item_sward_modifier")
	local support_mod = caster:FindModifierByName("support_ward_stack_modifier")

	if mod then
		for i=0, 3, 1 do
  			if mod.wards[i] == self:GetParent() then
  				if i == 0 then
  					mod.wards[0] = mod.wards[1]
  					mod.wards[1] = mod.wards[2]
  					mod.wards[2] = 0
  				elseif i == 1 then
  					mod.wards[1] = mod.wards[2]
  					mod.wards[2] = 0
  				elseif i == 2 then
  					mod.wards[2] = 0
  				end
  				mod.ward_count = mod.ward_count - 1
  			end
		end
	end

	if support_mod then
		support_mod.wards[0] = mod.wards[0]
		support_mod.wards[1] = mod.wards[1]
		support_mod.wards[2] = mod.wards[2]
		support_mod.wards[3] = mod.wards[3]
		support_mod.ward_count = mod.ward_count
	end
end

function sward_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	if not parent:HasModifier("modifier_truesight") then
		AddFOWViewer(parent:GetTeam(), parent:GetOrigin(), 900, 0.2, true)
	end
end

function sward_modifier:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_FIXED_DAY_VISION,
    	MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
    	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function sward_modifier:GetFixedDayVision()
	return 1
end

function sward_modifier:GetFixedNightVision()
	return 1
end

function sward_modifier:GetModifierExtraHealthBonus()
	return 50
end

function sward_modifier:CheckState()
	local b = false
	if self:GetElapsedTime() > 2 then
		b = true
	end
	local state = {

		[MODIFIER_STATE_INVISIBLE] = b,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end

-- Set all damage taken to 0
function sward_modifier:GetModifierIncomingDamage_Percentage()
	return -100
end

function sward_modifier:OnAttackLanded( params ) -- health handling
	if not IsServer() then
		return
	end

	if params.target == self:GetParent() then
		local damage = 50
		if not params.attacker:IsRealHero() then -- Non Heroes should deal less damage
			damage = 5
		end

		if self:GetParent():GetHealth() > damage then
			self:GetParent():SetHealth( self:GetParent():GetHealth() - damage)
		else
			self:GetParent():Kill(nil, params.attacker)
		end
	end
end