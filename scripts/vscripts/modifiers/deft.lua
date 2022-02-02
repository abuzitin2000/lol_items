deft = class({})

function deft:IsHidden()
	return true
end

function deft:IsPurgable()
	return false
end

function deft:RemoveOnDeath()
	return false
end

function deft:OnCreated()
	if not IsServer() then
		return
	end

	self.ready = false
end

function deft:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function deft:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function deft:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Check if crit
	if not self.ready then
		return
	end

	for i = 0, 4 do
		local skill = self:GetParent():GetAbilityByIndex(i)

		if skill and not skill:IsCooldownReady() then
			local remaining = skill:GetCooldownTimeRemaining()
			skill:EndCooldown()
			skill:StartCooldown(remaining - remaining * (ability:GetSpecialValueFor("deft_crit") / 100))
		end
	end
end