item_wardstone = class({})

-- Modifier Linkers
LinkLuaModifier("item_wardstone_modifier", "items/item_wardstone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("control_modifier", "items/item_control", LUA_MODIFIER_MOTION_NONE)

function item_wardstone:GetIntrinsicModifierName()
	return "item_wardstone_modifier"
end

-- Ability
function item_wardstone:OnSpellStart()
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

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_wardstone_modifier = class({})

function item_wardstone_modifier:IsHidden()
	return true
end

function item_wardstone_modifier:IsPurgable()
	return false
end

function item_wardstone_modifier:RemoveOnDeath()
	return false
end

-- Remove Control Wards
function item_wardstone_modifier:OnCreated()
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

    local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")

	self:StartIntervalThink(1)
end

-- Add Control Wards
function item_wardstone_modifier:OnDestroy()
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

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

function item_wardstone_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local mod = parent:FindModifierByName("quest")

	if mod and mod:GetStackCount() >= 1000 and parent:GetLevel() >= 13 then
		local item = parent:FindItemInInventory("item_wardstone")
		if item then
			local charges = item:GetCurrentCharges()
			parent:RemoveItem(item)
			parent:AddItemByName("item_vigilant"):SetCurrentCharges(charges)
		end
	end
end

-- Stats
function item_wardstone_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_wardstone_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end