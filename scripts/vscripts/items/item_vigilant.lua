item_vigilant = class({})

-- Modifier Linkers
LinkLuaModifier("item_vigilant_modifier", "items/item_vigilant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("behold", "modifiers/behold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ixtal", "modifiers/ixtal", LUA_MODIFIER_MOTION_NONE)

function item_vigilant:GetIntrinsicModifierName()
	return "item_vigilant_modifier"
end

-- Ability
function item_vigilant:OnSpellStart()
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
			if mod.ward_other then
				mod.ward_other:ForceKill(false)
			end
			mod.ward_other = mod.ward
		end
		mod.ward = ward
	end

	self:SpendCharge()
	EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "DOTA_Item.ObserverWard.Activate", caster)
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_vigilant_modifier = class({})

function item_vigilant_modifier:IsHidden()
	return true
end

function item_vigilant_modifier:IsPurgable()
	return false
end

function item_vigilant_modifier:RemoveOnDeath()
	return false
end

-- Remove Control Wards
function item_vigilant_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local control = parent:FindItemInInventory("item_control")
    if control then
		ability:SetCurrentCharges(control:GetCurrentCharges())
		parent:RemoveItem(control)
    end

    parent:AddNewModifier(parent, ability, "behold", {})
	parent:AddNewModifier(parent, ability, "ixtal", {})

    local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Add Control Wards
function item_vigilant_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	--[[
	if ability:GetCurrentCharges() == 3 then
		ability:SetCurrentCharges(2)
	end

	for i = 1, ability:GetCurrentCharges(), 1 do
		parent:AddItemByName("item_control")
	end
	]]--

	local behold = parent:FindModifierByName("behold")
	if behold then
		behold:Destroy()
	end

	local ixtal = parent:FindModifierByName("ixtal")
	if ixtal then
		ixtal:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_vigilant_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_vigilant_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end