item_randuin = class({})

-- Modifier Linkers
LinkLuaModifier("item_randuin_modifier", "items/item_randuin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("rock_solid", "modifiers/rock_solid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("humility_debuff", "items/item_randuin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("humility_helper", "items/item_randuin", LUA_MODIFIER_MOTION_NONE)

function item_randuin:GetIntrinsicModifierName()
	return "item_randuin_modifier"
end

function item_randuin:OnSpellStart()
	local caster = self:GetCaster()

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), caster, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
	for k, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "humility_debuff", { duration = self:GetSpecialValueFor("humility_duration") })
	end

	local vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_landing_rings.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(vfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(vfx, 1, caster:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("DOTA_Item.MedallionOfCourage.Activate", caster)

	self:StartCooldown(self:GetSpecialValueFor("humility_cooldown"))
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_randuin_modifier = class({})

function item_randuin_modifier:IsHidden()
	return true
end

function item_randuin_modifier:IsPurgable()
	return false
end

function item_randuin_modifier:RemoveOnDeath()
	return false
end

function item_randuin_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_randuin_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "rock_solid", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_randuin_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local rock_solid = parent:FindModifierByName("rock_solid")
	if rock_solid then
		rock_solid:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_randuin_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_randuin_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end

-- Humility
humility_debuff = class ({})

function humility_debuff:IsHidden()
	return false
end

function humility_debuff:IsPurgable()
	return false
end

function humility_debuff:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local damage = parent:GetAverageTrueAttackDamage(nil) * (ability:GetSpecialValueFor("humility_damage") / 100)
	local mod = parent:AddNewModifier(self:GetCaster(), ability, "humility_helper", { duration = ability:GetSpecialValueFor("humility_duration") })
	mod:SetStackCount(damage)

	local unique = parent:FindModifierByName("unique_mechanics")

	if unique then
		self.crit_dmg = unique.crit_dmg
		unique.crit_dmg = unique.crit_dmg * ((100 - ability:GetSpecialValueFor("humility_crit")) / 100)
	end
end

function humility_debuff:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if unique then
		unique.crit_dmg = self.crit_dmg
	end
end

humility_helper = class ({})

function humility_helper:IsHidden()
	return true
end

function humility_helper:IsPurgable()
	return false
end

function humility_helper:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function humility_helper:GetModifierPreAttack_BonusDamage()
	return -1 * self:GetStackCount()
end