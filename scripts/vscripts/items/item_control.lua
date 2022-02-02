item_control = class({})

-- Modifier Linkers
LinkLuaModifier("item_control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_control:OnSpellStart()
	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("item_control_modifier")

	if not mod then
		mod = caster:AddNewModifier(caster, self, "item_control_modifier", {})
	end

	if mod then
		-- Summon the ward
		local ward = CreateUnitByName("npc_dota_observer_wards", caster:GetCursorPosition(), true, caster, caster, caster:GetTeam())
		ward:AddNewModifier(caster, self, "control_modifier", {})
		ward:SetMaximumGoldBounty(30)
		ward:SetMinimumGoldBounty(30)
		ward:SetDeathXP(40)

		-- Kill the other ward
		if mod.ward then
			mod.ward:ForceKill(false)
		end
		mod.ward = ward
	end

	self:SpendCharge()
	EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "DOTA_Item.ObserverWard.Activate", caster)
end

-- Modifiers
-------------------------------------------------------------------------------------------------------------
item_control_modifier = class({})

function item_control_modifier:IsHidden()
	return true
end

function item_control_modifier:IsPurgable()
	return false
end

function item_control_modifier:IsPermanent()
	return true
end

function item_control_modifier:OnCreated()
	self.ward = nil
	self.ward_other = nil
end

control_modifier = class ({})

function control_modifier:IsHidden()
	return true
end

function control_modifier:IsPurgable()
	return false
end

function control_modifier:GetTexture()
	return "item_control"
end

function control_modifier:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function control_modifier:OnCreated( event )
	self.heal = 0

	self:StartIntervalThink(0.1)
end

function control_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("item_control_modifier")
	if mod then
		if mod.ward_other == self:GetParent() then
			mod.ward_other = nil
		end
		
		if mod.ward == self:GetParent() then
			mod.ward = nil
		end
	end
end

function control_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, true)
	for i,v in ipairs(enemies) do
		v:AddNewModifier(parent, nil, "modifier_truesight", {
		duration = 1.0
	})
	end

	-- Heal after not taking damage for 6 seconds
	if self.heal > 0 then
		self.heal = self.heal - 0.1
	end

	if self.heal <= 0 then
		parent:Heal(1.5, self:GetAbility())
	end
end

function control_modifier:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_FIXED_DAY_VISION,
    	MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
    	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function control_modifier:GetFixedDayVision()
	return 900
end

function control_modifier:GetFixedNightVision()
	return 900
end

function control_modifier:GetModifierExtraHealthBonus()
	return 100
end

function control_modifier:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

-- Set all damage taken to 0
function control_modifier:GetModifierIncomingDamage_Percentage()
	return -100
end

function control_modifier:OnAttackLanded( params ) -- health handling
	if not IsServer() then
		return
	end

	if params.target == self:GetParent() then
		local damage = 50
		if params.attacker:IsRealHero() then -- Non Heroes should deal less damage
		else
			damage = 5
		end

		self.heal = 6

		if self:GetParent():GetHealth() > damage then
			self:GetParent():SetHealth( self:GetParent():GetHealth() - damage)
		else
			self:GetParent():Kill(nil, params.attacker)
		end
	end
end