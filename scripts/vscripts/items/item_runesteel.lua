item_runesteel = class({})

-- Modifier Linkers
LinkLuaModifier("item_runesteel_modifier", "items/item_runesteel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spoils", "modifiers/spoils", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("support_ward_stack_modifier", "modifiers/support_ward_stack_modifier", LUA_MODIFIER_MOTION_NONE)

function item_runesteel:GetIntrinsicModifierName()
	return "item_runesteel_modifier"
end

function item_runesteel:OnSpellStart()
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
item_runesteel_modifier = class({})

function item_runesteel_modifier:IsHidden()
	return true
end

function item_runesteel_modifier:IsPurgable()
	return false
end

function item_runesteel_modifier:RemoveOnDeath()
	return false
end

function item_runesteel_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_runesteel_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "spoils", {})
	parent:AddNewModifier(parent, ability, "support_ward_stack_modifier", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp + ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_runesteel_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local spoils = parent:FindModifierByName("spoils")
	if spoils then
		spoils:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_hp = unique.base_hp - ability:GetSpecialValueFor("bonus_health_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_runesteel_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_runesteel_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_ad")
end

function item_runesteel_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end