ignore_pain = class ({})

-- Modifier Linkers
LinkLuaModifier("ignore_pain_damage", "modifiers/ignore_pain", LUA_MODIFIER_MOTION_NONE)

function ignore_pain:IsHidden()
	return true
end

function ignore_pain:IsPurgable()
	return false
end

function ignore_pain:RemoveOnDeath()
	return false
end

function ignore_pain:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function ignore_pain:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

function ignore_pain:GetModifierTotal_ConstantBlock( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if attack is physical
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL then
		return 0
	end

	local block = event.damage

	-- Reduced block on ranged heroes
	if parent:IsRangedAttacker() then
		block = block * (ability:GetSpecialValueFor("ignore_range") / 100)
	else
		block = block * (ability:GetSpecialValueFor("ignore_melee") / 100)
	end

	parent:AddNewModifier(attacker, ability, "ignore_pain_damage", {
		duration = ability:GetSpecialValueFor("ignore_duration"),
		damage = block
	})

	return block
end

ignore_pain_damage = class({})

function ignore_pain_damage:IsHidden()
	return true
end

function ignore_pain_damage:IsPurgable()
	return false
end

function ignore_pain_damage:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function ignore_pain_damage:OnCreated( params )
	if not IsServer() then
		return
	end

	self.damage = params.damage
	self.remaining = self.damage

	if self.damage <= 0 then
		self:Destroy()
	end

	self:StartIntervalThink(1)
end

function ignore_pain_damage:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Check if item is destroyed
	if not ability then
		return
	end

	-- Check if damage is depleted
	if self.remaining <= 0 then
		self:Destroy()
	end

	-- Deal Damage
	local damageTable = {
	  victim = parent,
	  attacker = caster,
	  damage = self.damage / 3,
	  damage_type = DAMAGE_TYPE_PURE,
	  damage_flags = DOTA_DAMAGE_FLAG_NONE
	}
	ApplyDamage(damageTable)

	self.remaining = self.remaining - (self.damage / 3)
end