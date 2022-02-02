lifeline = class ({})

-- Modifier Linkers
LinkLuaModifier("lifeline_shield", "modifiers/lifeline", LUA_MODIFIER_MOTION_NONE)

function lifeline:IsHidden()
	return true
end

function lifeline:IsPurgable()
	return false
end

function lifeline:RemoveOnDeath()
	return false
end

function lifeline:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function lifeline:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

-- Check if below health and give shield if so
function lifeline:GetModifierTotal_ConstantBlock( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Check if not on cooldown
	if not ability:IsCooldownReady() then
		return 0
	end

	-- Don't work when self damage
	if parent:GetTeam() == attacker:GetTeam() then
		return 0
	end

	-- Check if below health percentage
	if (parent:GetHealth() - event.damage) / parent:GetMaxHealth() * 100 > ability:GetSpecialValueFor("lifeline_health") then
		return 0
	end

	local shield = 0

	-- Level 1
	if ability:GetAbilityName() == "item_hexdrinker" then
		-- Check if damage is magic
		if event.damage_type ~= DAMAGE_TYPE_MAGICAL then
			return 0
		end

		shield = 100 + 10 * parent:GetLevel()

		local unique = parent:FindModifierByName("unique_mechanics")

		if unique then
			shield = shield * (1 + unique.heal_power / 100)
		end
	end

	-- Level 2
	if ability:GetAbilityName() == "item_maw" then
		-- Check if damage is magic
		if event.damage_type ~= DAMAGE_TYPE_MAGICAL then
			return 0
		end

		shield = ability:GetSpecialValueFor("lifeline_base") + parent:GetMaxHealth() * (ability:GetSpecialValueFor("lifeline_max_health") / 100)

		local unique = parent:FindModifierByName("unique_mechanics")

		if unique then
			shield = shield * (1 + unique.heal_power / 100)
		end
	end

	-- Apply Shield
	local lifeline_shield = parent:AddNewModifier(parent, ability, "lifeline_shield", { duration = ability:GetSpecialValueFor("lifeline_duration") })
	lifeline_shield:SetStackCount(shield)

	ability:StartCooldown(ability:GetSpecialValueFor("lifeline_cooldown"))

	-- Reduce from shield
	if lifeline_shield:GetStackCount() > event.damage then
		lifeline_shield:SetStackCount(lifeline_shield:GetStackCount() - event.damage)
		return event.damage
	else
		local block = lifeline_shield:GetStackCount()
		lifeline_shield:SetStackCount(0)
		lifeline_shield:SetDuration(0.2, true)
		return block
	end
end

lifeline_shield = class ({})

function lifeline_shield:IsHidden()
	return false
end

function lifeline_shield:IsPurgable()
	return false
end

function lifeline_shield:OnCreated()
	local parent = self:GetParent()

    self.pfx = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

	EmitSoundOn("Item.LotusOrb.Target", self:GetParent())
end

function lifeline_shield:OnDestroy()
	EmitSoundOn("Item.LotusOrb.Destroy", self:GetParent())

    if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function lifeline_shield:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

-- Shield
function lifeline_shield:GetModifierTotal_ConstantBlock( event )
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Level 1 and Level 2
	if ability:GetAbilityName() == "item_hexdrinker" or ability:GetAbilityName() == "item_maw" then
		-- Check if damage is magic
		if event.damage_type ~= DAMAGE_TYPE_MAGICAL then
			return 0
		end
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