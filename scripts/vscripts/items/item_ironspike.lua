item_ironspike = class({})

-- Modifier Linkers
LinkLuaModifier("item_ironspike_modifier", "items/item_ironspike", LUA_MODIFIER_MOTION_NONE)

function item_ironspike:GetIntrinsicModifierName()
	return "item_ironspike_modifier"
end

function item_ironspike:OnAbilityPhaseStart()
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
	EmitSoundOn("n_creep_Heavy.PreAttack", self:GetCaster())
	
	return true
end

function item_ironspike:OnSpellStart()
	local caster = self:GetCaster()

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), caster, 450, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
	for k, enemy in pairs(enemies) do
  		-- Deal Damage
		local damageTable = {
		  victim = enemy,
		  attacker = caster,
		  damage = caster:GetAttackDamage() * (self:GetSpecialValueFor("crescent_damage") / 100),
		  damage_type = DAMAGE_TYPE_PHYSICAL,
		  damage_flags = DOTA_DAMAGE_FLAG_NONE
		}
		ApplyDamage(damageTable)

		local vfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControl(vfx, 0, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControl(vfx, 1, Vector(1, 0, 0))
		ParticleManager:SetParticleControl(vfx, 2, Vector(1, 1, 1))
		ParticleManager:ReleaseParticleIndex(vfx)

		EmitSoundOn("Hero_Shredder.TimberChain.Damage", enemy)
	end

	if table.getn(enemies) > 1 then
		EmitSoundOn("Hero_Shredder.TimberChain.Damage", enemies[1])
	end

	local vfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(vfx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("Hero_Shredder.TimberChain.Cast", caster)
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_ironspike_modifier = class({})

function item_ironspike_modifier:IsHidden()
	return true
end

function item_ironspike_modifier:IsPurgable()
	return false
end

function item_ironspike_modifier:RemoveOnDeath()
	return false
end

function item_ironspike_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Stats
function item_ironspike_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_ironspike_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end