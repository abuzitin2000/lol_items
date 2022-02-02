immolate = class({})

-- Modifier Linkers
LinkLuaModifier("immolate_active", "modifiers/immolate", LUA_MODIFIER_MOTION_NONE)

function immolate:IsHidden()
	return true
end

function immolate:IsPurgable()
	return false
end

function immolate:RemoveOnDeath()
	return false
end

function immolate:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local immolate_active = parent:FindModifierByName("immolate_active")
	if immolate_active then
		immolate_active:Destroy()
	end

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function immolate:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function immolate:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	-- Start dealing damage when in combat
	if parent == attacker or parent == target then
		parent:AddNewModifier(parent, self:GetAbility(), "immolate_active", {
		duration = self:GetAbility():GetSpecialValueFor("immolate_duration")
	})
	end
end

immolate_active = class({})

function immolate_active:IsHidden()
	return false
end

function immolate_active:IsPurgable()
	return false
end

function immolate_active:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function immolate_active:OnCreated( params )
	if not IsServer() then
		return
	end

	self:GetParent():EmitSound("DOTA_Item.Radiance.Target.Loop")

	self:StartIntervalThink(1)
end

function immolate_active:OnDestroy()
	if not IsServer() then
		return
	end

	self:GetParent():StopSound("DOTA_Item.Radiance.Target.Loop")
end

-- Burn enemies
function immolate_active:OnIntervalThink()
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

	local damage = 0
	local size = 350

	-- Increase area with size
	if parent:GetModelScale() > 1 then
		size = size * parent:GetModelScale()
	end

	-- Level 1
	if ability:GetAbilityName() == "item_bami" then
		damage = ability:GetSpecialValueFor("immolate_damage") + ((parent:GetMaxHealth() - parent:GetStrength() * 20) * ability:GetSpecialValueFor("immolate_health") / 100)
	end

	-- Don't deal damage if illusion and real hero is nearby
	if not parent:IsRealHero() and CalcDistanceBetweenEntityOBB(parent, parent:GetPlayerOwner():GetAssignedHero()) < size then
		return
	end

	local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, size, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
	for k, enemy in pairs(enemies) do
		local multiplier = 1

		-- Increase damage for creeps
		if enemy:GetUnitName() == "npc_dota_creep_goodguys_melee" or enemy:GetUnitName() == "npc_dota_creep_goodguys_ranged" or enemy:GetUnitName() == "npc_dota_creep_badguys_melee" or enemy:GetUnitName() == "npc_dota_creep_badguys_ranged" or enemy:GetUnitName() == "npc_dota_goodguys_siege" or enemy:GetUnitName() == "npc_dota_badguys_siege" then
  			multiplier = multiplier + ability:GetSpecialValueFor("immolate_minion") / 100
  		end

  		-- Increase damage for jungle
		if enemy:IsNeutralUnitType() then
  			multiplier = multiplier + ability:GetSpecialValueFor("immolate_monster") / 100
  		end

  		-- Deal Damage
		local damageTable = {
		  victim = enemy,
		  attacker = parent,
		  damage = damage * multiplier,
		  damage_type = DAMAGE_TYPE_MAGICAL,
		  damage_flags = DOTA_DAMAGE_FLAG_NONE
		}
		ApplyDamage(damageTable)

		-- Execute minion if below health threshold
		if enemy:GetUnitName() == "npc_dota_creep_goodguys_melee" or enemy:GetUnitName() == "npc_dota_creep_goodguys_ranged" or enemy:GetUnitName() == "npc_dota_creep_badguys_melee" or enemy:GetUnitName() == "npc_dota_creep_badguys_ranged" or enemy:GetUnitName() == "npc_dota_goodguys_siege" or enemy:GetUnitName() == "npc_dota_badguys_siege" then
			if damage * multiplier > enemy:GetHealth() then
				-- Deal Damage
				local damageTable = {
				  victim = enemy,
				  attacker = parent,
				  damage = damage * multiplier,
				  damage_type = DAMAGE_TYPE_MAGICAL,
				  damage_flags = DOTA_DAMAGE_FLAG_NONE
				}
				ApplyDamage(damageTable)
			end
		end
	end
end