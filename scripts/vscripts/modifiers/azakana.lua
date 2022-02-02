azakana = class ({})

-- Modifier Linkers
LinkLuaModifier("azakana_burn", "modifiers/azakana", LUA_MODIFIER_MOTION_NONE)

function azakana:IsHidden()
	return true
end

function azakana:IsPurgable()
	return false
end

function azakana:RemoveOnDeath()
	return false
end

function azakana:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function azakana:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function azakana:OnTakeDamageKillCredit( event )
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
    if attacker ~= parent or not target:IsAlive() then
    	return
    end

    -- Check if target is hero
    if not target:IsHero() then
    	return
    end

    -- Check if damage is ability
    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then
    	return
    end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
    	return
    end

    target:AddNewModifier(parent, ability, "azakana_burn", { duration = ability:GetSpecialValueFor("azakana_duration") })
end

azakana_burn = class ({})

function azakana_burn:IsHidden()
	return false
end

function azakana_burn:IsPurgable()
	return false
end

function azakana_burn:GetEffectName()
	return "particles/items4_fx/spirit_vessel_damage_spirit.vpcf"
end

function azakana_burn:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(1)
end

-- Burn the afflicted
function azakana_burn:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local damage = ability:GetSpecialValueFor("azakana_melee") / 100

	if caster:IsRangedAttacker() then
		damage = ability:GetSpecialValueFor("azakana_ranged") / 100
	end

	-- Deal Damage
	local damageTable = {
	  victim = parent,
	  attacker = caster,
	  damage = parent:GetMaxHealth() * damage,
	  damage_type = DAMAGE_TYPE_MAGICAL,
	  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)
end