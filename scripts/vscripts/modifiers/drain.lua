drain = class({})

-- Modifier Linkers
LinkLuaModifier("drain_buff", "modifiers/drain", LUA_MODIFIER_MOTION_NONE)

function drain:IsHidden()
	return true
end

function drain:IsPurgable()
	return false
end

function drain:RemoveOnDeath()
	return false
end

function drain:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function drain:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

-- Bonus Health Regen
function drain:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	-- Check if parent can gain mana otherwise heal
	if parent:GetMana() / parent:GetMaxMana() == 1 or parent:GetMaxMana() == 0 then
		return ability:GetSpecialValueFor("drain_mana") / 2
	end
	
	return 0
end

-- Bonus Mana Regen
function drain:GetModifierConstantManaRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	-- Check if parent can gain mana otherwise heal
	if parent:GetMana() / parent:GetMaxMana() == 1 or parent:GetMaxMana() == 0 then
		return 0
	end
	
	return ability:GetSpecialValueFor("drain_mana")
end

function drain:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is parent
	if attacker ~= parent then
		return
	end

	-- Check if target is a hero
	if not target:IsHero() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
    
	parent:AddNewModifier(parent, ability, "drain_buff", { duration = ability:GetSpecialValueFor("drain_duration") })
end

drain_buff = class({})

function drain_buff:IsHidden()
	return true
end

function drain_buff:IsPurgable()
	return false
end

function drain_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
	return funcs
end

-- Bonus Health Regen
function drain_buff:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	-- Check if parent can gain mana otherwise heal
	if parent:GetMana() / parent:GetMaxMana() == 1 or parent:GetMaxMana() == 0 then
		return (ability:GetSpecialValueFor("drain_damage") - ability:GetSpecialValueFor("drain_mana")) / 2
	end
	
	return 0
end

-- Bonus Mana Regen
function drain_buff:GetModifierConstantManaRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	-- Check if parent can gain mana otherwise heal
	if parent:GetMana() / parent:GetMaxMana() == 1 or parent:GetMaxMana() == 0 then
		return 0
	end

	return ability:GetSpecialValueFor("drain_damage") - ability:GetSpecialValueFor("drain_mana")
end