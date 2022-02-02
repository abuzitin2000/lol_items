spellblade = class ({})

-- Modifier Linkers
LinkLuaModifier("spellblade_empowered", "modifiers/spellblade", LUA_MODIFIER_MOTION_NONE)

function spellblade:IsHidden()
	return true
end

function spellblade:IsPurgable()
	return false
end

function spellblade:RemoveOnDeath()
	return false
end

function spellblade:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function spellblade:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
    return funcs
end

function spellblade:OnAbilityExecuted( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = event.ability

	-- Check if not on cooldown
	if not self:GetAbility():IsCooldownReady() then
		return
	end

	-- Check if capturing outpost
	if ability:GetName() == "ability_capture" then
		return
	end

	-- Check if ability is cast by parent
	if event.unit ~= parent then
		return
	end

	-- Check if ability is toggle or item
	if ability:IsItem() or ability:IsToggle() then
		return
	end

	parent:AddNewModifier(parent, self:GetAbility(), "spellblade_empowered", { duration = self:GetAbility():GetSpecialValueFor("duration") })
end

spellblade_empowered = class ({})

function spellblade_empowered:IsHidden()
	return false
end

function spellblade_empowered:IsPurgable()
	return false
end

function spellblade_empowered:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
    }
    return funcs
end

function spellblade_empowered:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	local damage = 0

	-- Level 1
	if ability:GetAbilityName() == "item_sheen" then
		damage = (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2 * (ability:GetSpecialValueFor("spellblade_damage") / 100)
	end

	-- Level 2
	if ability:GetAbilityName() == "item_essence_reaver" then
		damage = (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2 * (ability:GetSpecialValueFor("spellblade_damage") / 100) + (parent:GetAverageTrueAttackDamage(nil) - (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2) * (ability:GetSpecialValueFor("spellblade_bonus") / 100)
	
		parent:GiveMana((parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2 * (ability:GetSpecialValueFor("mana_base") / 100) + (parent:GetAverageTrueAttackDamage(nil) - (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2) * (ability:GetSpecialValueFor("mana_bonus") / 100))
	
		-- Effect
		local mana_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(mana_pfx, 0, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(mana_pfx)
	end

	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	ability:StartCooldown(ability:GetSpecialValueFor("cooldown"))
	self:SetDuration(0, true)

	return damage
end

function spellblade_empowered:GetModifierProcAttack_BonusDamage_Magical( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	local damage = 0

	-- Level 3
	if ability:GetAbilityName() == "item_lich" then
		damage = (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2 * (ability:GetSpecialValueFor("spellblade_damage") / 100)

		local unique = parent:FindModifierByName("unique_mechanics")
		
		if unique then
			damage = damage + unique:AbilityPower() * (ability:GetSpecialValueFor("spellblade_ap") / 100)
		end

		print(damage, unique:AbilityPower() * (ability:GetSpecialValueFor("spellblade_ap") / 100), unique:AbilityPower())
	end

	return damage
end