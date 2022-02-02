item_bulwark = class({})

-- Modifier Linkers
LinkLuaModifier("item_bulwark_modifier", "items/item_bulwark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("support_ward_stack_modifier", "modifiers/support_ward_stack_modifier", LUA_MODIFIER_MOTION_NONE)

function item_bulwark:GetIntrinsicModifierName()
	return "item_bulwark_modifier"
end

function item_bulwark:OnSpellStart()
	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("support_ward_stack_modifier")

	if mod and mod.charge > 0 then
		-- Spend Charge
		mod.charge = mod.charge - 1

		-- Summon the ward
		local ward = CreateUnitByName("npc_dota_observer_wards", caster:GetCursorPosition(), true, caster, caster, caster:GetTeam())
		ward:AddNewModifier(caster, self, "modifier_kill", {
			duration = 150
		})
		ward:AddNewModifier(caster, nil, "support_ward_modifier", {})
		ward:SetMaximumGoldBounty(30)
		ward:SetMinimumGoldBounty(30)
		ward:SetDeathXP(40)
	end

	self:SpendCharge()
	EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "DOTA_Item.ObserverWard.Activate", caster)
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bulwark_modifier = class({})

function item_bulwark_modifier:IsHidden()
	return true
end

function item_bulwark_modifier:IsPurgable()
	return false
end

function item_bulwark_modifier:RemoveOnDeath()
	return false
end

function item_bulwark_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_bulwark_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "support_ward_stack_modifier", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_bulwark_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_bulwark_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_bulwark_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end