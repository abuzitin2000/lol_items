onstunned = class({})

function onstunned:IsHidden()
	return true
end

function onstunned:IsPurgable()
	return false
end

function onstunned:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(0.01)
end

function onstunned:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local caster = self:GetCaster()

	local forced = false

	for _,modifier in pairs(parent:FindAllModifiers()) do
		local states = {}

		if modifier ~= nil and modifier:IsNull() == false then
			modifier:CheckStateToTable( states )

			if states[tostring(MODIFIER_STATE_FEARED)] == true or states[tostring(MODIFIER_STATE_TAUNTED)] == true then
				forced = true
			end
		end
	end

	if parent:IsStunned() or parent:IsRooted() or parent:IsMovementImpaired() or parent:IsFrozen() or parent:IsHexed() or parent:IsNightmared() or forced then
		-- List of OnStunned Modifiers
		local list = { "everlast", "hyper" }

		for k,v in pairs(list) do
			local buff = caster:FindModifierByName(v)

			if buff then
				buff:OnStunned( parent:entindex() )
			end
		end
	end

	self:Destroy()
end