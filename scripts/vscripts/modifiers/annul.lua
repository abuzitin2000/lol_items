annul = class({})

function annul:IsHidden()
	if self:GetStackCount() == 0 then
		return false
	end

	return true
end

function annul:IsPurgable()
	return false
end

function annul:RemoveOnDeath()
	return false
end

function annul:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	self.pfx = ParticleManager:CreateParticle("particles/items_fx/immunity_sphere_buff.vpcf", PATTACH_ROOTBONE_FOLLOW, parent)
	ParticleManager:SetParticleControl(self.pfx, 0, parent:GetAbsOrigin())

	parent:EmitSound("DOTA_Item.LinkensSphere.Target")

	self:StartIntervalThink(1)
end

function annul:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	ParticleManager:DestroyParticle(self.pfx, true)
	ParticleManager:ReleaseParticleIndex(self.pfx)

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function annul:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if ability:IsCooldownReady() and self:GetStackCount() > 0 then
		self:SetStackCount(0)

		self.pfx = ParticleManager:CreateParticle("particles/items_fx/immunity_sphere_buff.vpcf", PATTACH_ROOTBONE_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.pfx, 0, parent:GetAbsOrigin())

		parent:EmitSound("DOTA_Item.LinkensSphere.Target")
	end
end

function annul:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function annul:GetModifierTotal_ConstantBlock( event )
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

	-- Check cooldown
	if not ability:IsCooldownReady() then
		return 0
	end

	-- Check if attacker is self
	if attacker == parent then
		return 0
	end

	-- Check if attack is ability
	if event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		return 0
	end

	if event.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then
		return 0
	end

	ability:StartCooldown(ability:GetSpecialValueFor("annul_cooldown"))
	self:SetStackCount(1)

	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)

	parent:EmitSound("DOTA_Item.LinkensSphere.Activate")

	return event.damage
end

function annul:GetModifierStatusResistanceStacking()
	if self:GetStackCount() == 0 then
		return 100
	end

	return 0
end

function annul:OnDeath( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.unit
	local ability = self:GetAbility()

	if not ability then
		return
	end

	if parent ~= target then
		return
	end

	ability:StartCooldown(ability:GetSpecialValueFor("annul_cooldown"))

	ParticleManager:DestroyParticle(self.pfx, true)
	ParticleManager:ReleaseParticleIndex(self.pfx)
end

function annul:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	if parent ~= target then
		return
	end

	if ability:IsCooldownReady() then
		return
	end

	ability:StartCooldown(ability:GetSpecialValueFor("annul_cooldown"))
end