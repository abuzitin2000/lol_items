item_anathema = class({})

-- Modifier Linkers
LinkLuaModifier("item_anathema_modifier", "items/item_anathema", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("vendetta", "modifiers/vendetta", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("vengeance", "modifiers/vengeance", LUA_MODIFIER_MOTION_NONE)

function item_anathema:GetIntrinsicModifierName()
	return "item_anathema_modifier"
end

function item_anathema:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetCursorCastTarget()

	if caster:HasModifier("vendetta") then
		caster:FindModifierByName("vendetta"):Destroy()
	end

	caster:AddNewModifier(caster, self, "vendetta", { target = target:entindex() })
	target:AddNewModifier(caster, self, "vengeance", {})

	self:StartCooldown(self:GetSpecialValueFor("vow_cooldown"))

	caster:EmitSound("DOTA_Item.Buckler.Activate")
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_anathema_modifier = class({})

function item_anathema_modifier:IsHidden()
	return true
end

function item_anathema_modifier:IsPurgable()
	return false
end

function item_anathema_modifier:RemoveOnDeath()
	return false
end

function item_anathema_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_anathema_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_anathema_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local vendetta = parent:FindModifierByName("vendetta")
	if vendetta then
		vendetta:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_anathema_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
	return funcs
end

function item_anathema_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end

function item_anathema_modifier:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	-- Cooldown when in combat
	if parent == attacker or parent == target then
		if parent:HasModifier("vendetta") and ability:GetCooldownTimeRemaining() < 15 then
			ability:StartCooldown(15)
		end
	end
end