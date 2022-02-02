monolith = class ({})

function monolith:IsHidden()
	return false
end

function monolith:IsPurgable()
	return false
end

function monolith:OnCreated()
	local parent = self:GetParent()

    self.vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.vfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	self:AddParticle(self.vfx, false, false, -1, false, false)

	EmitSoundOn("DOTA_Item.MedallionOfCourage.Activate", parent)

	self:StartIntervalThink(0.25)
end

function monolith:OnDestroy()
    if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function monolith:OnIntervalThink()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	self:SetStackCount(self:GetStackCount() - math.ceil(self:GetStackCount() / 5))
end

function monolith:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
    return funcs
end

-- Shield
function monolith:GetModifierTotal_ConstantBlock( event )
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

function monolith:GetModifierModelScale()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("monolith_size")
end