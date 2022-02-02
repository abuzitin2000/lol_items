energized = class({})

function energized:IsHidden()
	return false
end

function energized:IsPurgable()
	return false
end

function energized:RemoveOnDeath()
	return false
end

function energized:OnCreated()
	if not IsServer() then
		return
	end

	self.previous_location = self:GetParent():GetAbsOrigin()

	self:StartIntervalThink(0.1)
end

function energized:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function energized:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	
	-- Increase stack while moving
	if self:GetStackCount() < 100 then
		local distance = CalculateDistance(self.previous_location, parent)

		if distance > 24 then
			self:SetStackCount(self:GetStackCount() + math.ceil(distance / 24))
		end
	end

	if self:GetStackCount() > 100 then
		self:SetStackCount(100)
	end

	self.previous_location = self:GetParent():GetAbsOrigin()
end

function energized:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function energized:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Increase stacks
	self:SetStackCount(self:GetStackCount() + 6)
end