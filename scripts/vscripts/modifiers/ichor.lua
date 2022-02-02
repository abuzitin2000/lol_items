ichor = class({})

function ichor:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	end

	return true
end

function ichor:IsPurgable()
	return false
end

function ichor:RemoveOnDeath()
	return false
end

function ichor:OnCreated()
	if not IsServer() then
		return
	end

	local ability = self:GetAbility()

	self.decay = ability:GetSpecialValueFor("ichor_duration")

	self:StartIntervalThink(1)
end

function ichor:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if self.crimson_guard_pfx then
		ParticleManager:DestroyParticle(self.crimson_guard_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.crimson_guard_pfx)
		self.crimson_guard_pfx = nil
	end
				
	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function ichor:OnIntervalThink()
	if not IsServer() then
		return
	end

	local ability = self:GetAbility()

	self.decay = self.decay - 1

	if self.decay < 0 then
		self:SetStackCount(self:GetStackCount() - math.ceil(self:GetStackCount() / ability:GetSpecialValueFor("ichor_duration")))

		if self:GetStackCount() <= 0 then
			-- Kill Effect
			if self.crimson_guard_pfx then
				ParticleManager:DestroyParticle(self.crimson_guard_pfx, false)
				ParticleManager:ReleaseParticleIndex(self.crimson_guard_pfx)
				self.crimson_guard_pfx = nil
			end
		end
	end
end

function ichor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
    }
    return funcs
end

-- Shield
function ichor:GetModifierTotal_ConstantBlock( event )
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	self.decay = ability:GetSpecialValueFor("ichor_duration")

	-- Reduce from shield
	if self:GetStackCount() > event.damage then
		self:SetStackCount(self:GetStackCount() - event.damage)
		return event.damage
	else
		local block = self:GetStackCount()
		self:SetStackCount(0)

		-- Kill Effect
		if self.crimson_guard_pfx then
			ParticleManager:DestroyParticle(self.crimson_guard_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.crimson_guard_pfx)
			self.crimson_guard_pfx = nil
		end

		return block
	end
end