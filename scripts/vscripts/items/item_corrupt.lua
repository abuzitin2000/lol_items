item_corrupt = class({})

-- Modifier Linkers
LinkLuaModifier("item_corrupt_modifier", "items/item_corrupt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_corrupt_heal_modifier", "items/item_corrupt", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_corrupt_burn_modifier", "items/item_corrupt", LUA_MODIFIER_MOTION_NONE)

function item_corrupt:GetIntrinsicModifierName()
	return "item_corrupt_modifier"
end

-- Ability
function item_corrupt:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, self, "item_corrupt_heal_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.HealingSalve.Activate")

	self:SpendCharge()
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_corrupt_modifier = class ({})

function item_corrupt_modifier:IsHidden()
	return true
end

function item_corrupt_modifier:IsPurgable()
	return false
end

function item_corrupt_modifier:OnCreated()
	self:StartIntervalThink(1)
end

function item_corrupt_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	-- Refill when in fountain
	if parent:FindModifierByName("modifier_fountain_aura_buff") then
		local item = parent:FindItemInInventory("item_corrupt")
		if item then
			item:SetCurrentCharges(3)
		end
	end
end

-- Modifiers
-------------------------------------------------------------------------------------------------------------
item_corrupt_heal_modifier = class({})

function item_corrupt_heal_modifier:IsHidden()
	return false
end

function item_corrupt_heal_modifier:IsPurgable()
	return false
end

function item_corrupt_heal_modifier:GetTexture()
	return "item_corrupt"
end

function item_corrupt_heal_modifier:GetEffectName()
	return "particles/items_fx/bottle.vpcf"
end

function item_corrupt_heal_modifier:OnCreated()
	self.heal = self:GetAbility():GetSpecialValueFor("heal")
	self.mana = self:GetAbility():GetSpecialValueFor("mana")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end

function item_corrupt_heal_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
	return funcs
end

-- Bonus Health Regen
function item_corrupt_heal_modifier:GetModifierConstantHealthRegen() 
	return self.heal / self.duration
end

-- Bonus Mana Regen
function item_corrupt_heal_modifier:GetModifierConstantManaRegen() 
	return self.mana / self.duration
end

function item_corrupt_heal_modifier:OnTakeDamageKillCredit( event )
	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = event.inflictor

	if attacker == parent and target:IsAlive() and target:IsHero() and parent:GetTeam() ~= target:GetTeam() then
		-- Stops infinite loops
		if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
			local damage = self:GetAbility():GetSpecialValueFor("burn")
			-- Check if hero can't gain mana
			if parent:GetManaPercent() == 100 or parent:GetMaxMana() == 0 then
				damage = self:GetAbility():GetSpecialValueFor("burn_manaless")
			end

			-- Check if the damage came from AOE or Duration ability
			if ability then
				if ability:GetAOERadius() > 0 then
					damage = damage * 0.5
				elseif ability:GetDuration() > 0 then
					damage = damage * 0.5
				end
			end

			target:AddNewModifier(parent, self:GetAbility(), "item_corrupt_burn_modifier", { duration = 3, damage = damage })
		end
	end
end

item_corrupt_burn_modifier = class ({})

function item_corrupt_burn_modifier:IsHidden()
	return false
end

function item_corrupt_burn_modifier:IsPurgable()
	return true
end

function item_corrupt_burn_modifier:IsDebuff()
	return true
end

function item_corrupt_burn_modifier:GetTexture()
	return "item_corrupt"
end

function item_corrupt_burn_modifier:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function item_corrupt_burn_modifier:OnCreated( params )
	self.damage = params.damage
	self:StartIntervalThink(1)
end

function item_corrupt_burn_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end
	
	local caster = self:GetCaster()
	local target = self:GetParent()

	-- Deal Damage
	local damageTable = {
	  victim = target,
	  attacker = caster,
	  damage = self.damage,
	  damage_type = DAMAGE_TYPE_MAGICAL,
	  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)
end