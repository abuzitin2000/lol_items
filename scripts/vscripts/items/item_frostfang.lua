item_frostfang = class({})

-- Modifier Linkers
LinkLuaModifier("item_frostfang_modifier", "items/item_frostfang", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("tribute", "modifiers/tribute", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("support_ward_stack_modifier", "modifiers/support_ward_stack_modifier", LUA_MODIFIER_MOTION_NONE)

function item_frostfang:GetIntrinsicModifierName()
	return "item_frostfang_modifier"
end

function item_frostfang:OnSpellStart()
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
item_frostfang_modifier = class({})

function item_frostfang_modifier:IsHidden()
	return true
end

function item_frostfang_modifier:IsPurgable()
	return false
end

function item_frostfang_modifier:RemoveOnDeath()
	return false
end

function item_frostfang_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_frostfang_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "tribute", {})
	parent:AddNewModifier(parent, ability, "support_ward_stack_modifier", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_frostfang_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local tribute = parent:FindModifierByName("tribute")
	if tribute then
		tribute:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_frostfang_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_frostfang_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end