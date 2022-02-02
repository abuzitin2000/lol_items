shipwrecker = class({})

-- Modifier Linkers
LinkLuaModifier("shipwrecker_slow", "modifiers/shipwrecker", LUA_MODIFIER_MOTION_NONE)

function shipwrecker:IsHidden()
	return true
end

function shipwrecker:IsPurgable()
	return false
end

function shipwrecker:RemoveOnDeath()
	return false
end

function shipwrecker:OnCreated()
	if not IsServer() then
		return
	end

	self.previous_location = self:GetParent():GetAbsOrigin()

	self:StartIntervalThink(0.25)
end

function shipwrecker:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function shipwrecker:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	
	-- Increase stack while moving
	if self:GetStackCount() < 100 then
		local distance = CalculateDistance(self.previous_location, parent)

		if distance > 24 then
			self:SetStackCount(self:GetStackCount() + 7)
		end
	end

	if self:GetStackCount() > 100 then
		self:SetStackCount(100)
	end

	-- Decrease stack if immobilized
	if parent:IsStunned() or parent:IsNightmared() or parent:IsRooted() then
		self:SetStackCount(self:GetStackCount() - 15)
	end

	if self.pfx then
		if self:GetStackCount() < 100 then
			ParticleManager:DestroyParticle(self.pfx, false)
			ParticleManager:ReleaseParticleIndex(self.pfx)
			self.pfx = nil
		end
	else
		if self:GetStackCount() == 100 then
			self.pfx = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(self.pfx, 0, parent:GetAbsOrigin())
		end 
	end

	self.previous_location = self:GetParent():GetAbsOrigin()

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_deadman")
	item:SetCurrentCharges(self:GetStackCount())
end

function shipwrecker:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }
    return funcs
end

function shipwrecker:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("shipwrecker_speed") * (self:GetStackCount() / 100)
end

function shipwrecker:GetModifierProcAttack_BonusDamage_Physical( event )
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	local damage = ability:GetSpecialValueFor("shipwrecker_damage") * (self:GetStackCount() / 100) + (parent:GetBaseDamageMax() + parent:GetBaseDamageMin()) / 2 * (self:GetStackCount() / 100)

	if self:GetStackCount() == 100 then
		if not parent:IsRangedAttacker() then
			target:AddNewModifier(parent, ability, "shipwrecker_slow", { duration = ability:GetSpecialValueFor("shipwrecker_duration") })
		end

		local pfx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 2, Vector(1, 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)

		EmitSoundOn("DOTA_Item.HavocHammer.Cast", target)
	end

	self:SetStackCount(0)

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_deadman")
	item:SetCurrentCharges(self:GetStackCount())

	return damage
end

shipwrecker_slow = class({})

function shipwrecker_slow:IsHidden()
	return false
end

function shipwrecker_slow:IsPurgable()
	return false
end

function shipwrecker_slow:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function shipwrecker_slow:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return -1 * ability:GetSpecialValueFor("shipwrecker_slow")
end