item_elixir_iron = class({})

-- Modifier Linkers
LinkLuaModifier("item_elixir_iron_modifier", "items/item_elixir_iron", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_elixir_iron_speed_modifier", "items/item_elixir_iron", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_elixir_iron:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	-- Remove other elixirs
	local sorcery = caster:FindModifierByName("item_elixir_sorcery_modifier")
	local wrath = caster:FindModifierByName("item_elixir_wrath_modifier")
	local iron = caster:FindModifierByName("item_elixir_iron_modifier")
	if sorcery then
		caster:RemoveModifierByName("item_elixir_sorcery_modifier")
	end
	if wrath then
		caster:RemoveModifierByName("item_elixir_wrath_modifier")
	end	
	if iron then
		caster:RemoveModifierByName("item_elixir_iron_modifier")
	end
	
	-- Add the elixir effect
	caster:AddNewModifier(caster, self, "item_elixir_iron_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")

	self:SpendCharge()
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_elixir_iron_modifier = class({})

function item_elixir_iron_modifier:IsHidden()
	return false
end

function item_elixir_iron_modifier:IsPurgable()
	return false
end

function item_elixir_iron_modifier:GetTexture()
	return "item_elixir_iron"
end

function item_elixir_iron_modifier:GetEffectName()
	return "particles/dev/library/base_smoke_trail.vpcf"
end

function item_elixir_iron_modifier:OnCreated()
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.tenacity = self:GetAbility():GetSpecialValueFor("tenacity")
	self.bonus_speed = self:GetAbility():GetSpecialValueFor("bonus_speed")

	if not IsServer() then
		return
	end

	self.locations = {self:GetParent():GetOrigin(), self:GetParent():GetOrigin(), self:GetParent():GetOrigin(), self:GetParent():GetOrigin(), self:GetParent():GetOrigin()}
	self.index = 0

	-- Add Tenacity
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.tenacityB["elixir_iron"] = self.tenacity

	self:StartIntervalThink(1)
end

function item_elixir_iron_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	-- Subtract Tenacity
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.tenacityB["elixir_iron"] = 0
end

function item_elixir_iron_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_PROPERTY_MODEL_SCALE
	}
	return funcs
end

-- Bonus Health
function item_elixir_iron_modifier:GetModifierHealthBonus() 
	return self.bonus_health
end

function item_elixir_iron_modifier:GetModifierModelScale()
	return self.tenacity
end

-- Damage on hit
function item_elixir_iron_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	for i=1, 5, 1 do
		-- Find and give speed to allies standing in the trail
		local allies = FindUnitsInRadius(parent:GetTeam(), self.locations[i], parent, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		for i,v in ipairs(allies) do
			if v ~= parent then
				local mod = v:AddNewModifier(parent, self:GetAbility(), "item_elixir_iron_speed_modifier", {
				duration = 1.0
				})
				mod:SetStackCount(self.bonus_speed)
			end
		end
	end

	-- Create the trail
	self.locations[self.index] = parent:GetOrigin()
	if self.index == 4 then
		self.index = 0
	else
		self.index = self.index + 1
	end
end

item_elixir_iron_speed_modifier = class ({})

function item_elixir_iron_speed_modifier:IsHidden()
	return true
end

function item_elixir_iron_speed_modifier:IsPurgable()
	return false
end

function item_elixir_iron_speed_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function item_elixir_iron_speed_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end