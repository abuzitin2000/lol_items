vendetta = class({})

function vendetta:IsHidden()
	return false
end

function vendetta:IsPurgable()
	return false
end

function vendetta:RemoveOnDeath()
	return false
end

function vendetta:OnCreated( params )
	if not IsServer() then
		return
	end

	self.target = EntIndexToHScript(params.target)

	local ability = self:GetAbility()

	self:StartIntervalThink(ability:GetSpecialValueFor("vendetta_duration") / ability:GetSpecialValueFor("vendetta_max"))
end

function vendetta:OnDestroy()
	if not IsServer() then
		return
	end

	local vengeance = self.target:FindModifierByName("vengeance")
	if vengeance then
		vengeance:Destroy()
	end
end

function vendetta:OnIntervalThink()
	if not IsServer() then
		return
	end

	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	self:SetStackCount(self:GetStackCount() + ability:GetSpecialValueFor("vendetta_stack"))

	if self:GetStackCount() > ability:GetSpecialValueFor("vendetta_max") then
		self:SetStackCount(ability:GetSpecialValueFor("vendetta_max"))
	end
end

function vendetta:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function vendetta:GetModifierIncomingDamage_Percentage( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	-- Only reduce from target
	if attacker ~= self.target then
		return 0
	end

	-- Don't reduce pure damage
	if event.damage_type == DAMAGE_TYPE_PURE then
		return 0
	end

	return -1 * self:GetStackCount()
end