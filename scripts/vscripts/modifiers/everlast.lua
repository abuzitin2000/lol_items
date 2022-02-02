everlast = class ({})

-- Modifier Linkers
LinkLuaModifier("everlast_shield", "modifiers/everlast", LUA_MODIFIER_MOTION_NONE)

function everlast:IsHidden()
	return true
end

function everlast:IsPurgable()
	return false
end

function everlast:RemoveOnDeath()
	return false
end

function everlast:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function everlast:OnStunned( stunnedTarget )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Only work with melee
	if parent:IsRangedAttacker() then
		return
	end

	-- Don't work on cooldown
	if not ability:IsCooldownReady() then
		return
	end

	-- Don't work with low mana
	if parent:GetManaPercent() < 20 then
		return
	end

	parent:SpendMana(parent:GetMana() * (ability:GetSpecialValueFor("everlast_cost") / 100), ability)

	local shield = 100 + 100 / 17 * (parent:GetLevel() - 1)
	shield = shield + parent:GetMana() * (ability:GetSpecialValueFor("everlast_mana") / 100)

	local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 750, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)

	if table.getn(enemies) > 1 then
		shield = shield + shield * (ability:GetSpecialValueFor("everlast_increase") / 100)
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if unique then
		shield = shield * (1 + unique.heal_power / 100)
	end

	local buff = parent:AddNewModifier(parent, ability, "everlast_shield", { duration = ability:GetSpecialValueFor("everlast_duration") })
	buff:SetStackCount(shield)

	ability:StartCooldown(ability:GetSpecialValueFor("everlast_cooldown"))
end

everlast_shield = class ({})

function everlast_shield:IsHidden()
	return false
end

function everlast_shield:IsPurgable()
	return false
end

function everlast_shield:OnCreated()
	local parent = self:GetParent()

    self.pfx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_staff_lvlup_globe.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.pfx, 5, Vector(0.8, 0.8, 0.8))

	EmitSoundOn("Item.LotusOrb.Target", self:GetParent())
end

function everlast_shield:OnDestroy()
	EmitSoundOn("Item.LotusOrb.Destroy", self:GetParent())

    if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function everlast_shield:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

-- Shield
function everlast_shield:GetModifierTotal_ConstantBlock( event )
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Reduce from shield
	if self:GetStackCount() > event.damage then
		self:SetStackCount(self:GetStackCount() - event.damage)
		return event.damage
	else
		local block = self:GetStackCount()
		self:SetStackCount(0)
		self:SetDuration(0, true)
		return block
	end
end