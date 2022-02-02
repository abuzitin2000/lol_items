fortify = class({})

function fortify:IsHidden()
	return true
end

function fortify:IsPurgable()
	return false
end

function fortify:RemoveOnDeath()
	return false
end

function fortify:OnCreated()
	if not IsServer() then
		return
	end

	self.timer = 0
	self.armor = 0
	self.mr = 0
	self.enemies = {}

	self:StartIntervalThink(1)
end

function fortify:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function fortify:OnIntervalThink()
	if not IsServer() then
		return
	end

	self.timer = self.timer - 1

	if self.timer > 0 then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - self.armor * self:GetStackCount() * (ability:GetSpecialValueFor("fortify_armor") / 100)
	unique.mr = unique.mr - self.mr * self:GetStackCount() * (ability:GetSpecialValueFor("fortify_mr") / 100)

	self:SetStackCount(0)

	self.enemies = {}

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_gargoyle")
	item:SetCurrentCharges(0)
end

function fortify:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function fortify:OnTakeDamageKillCredit( event )
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

	-- Check if target is parent
	if target ~= parent then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if self:GetStackCount() == 0 then
		self.armor = unique.armor
		self.mr = unique.mr
	end

	self.timer = ability:GetSpecialValueFor("fortify_duration")

	if self:GetStackCount() >= 5 then
		return
	end

	if self.enemies and self.enemies[attacker:entindex()] then
		return
	end

	self.enemies[attacker:entindex()] = true

	self:SetStackCount(self:GetStackCount() + 1)
	
	unique.armor = unique.armor + self.armor * (ability:GetSpecialValueFor("fortify_armor") / 100)
	unique.mr = unique.mr + self.mr * (ability:GetSpecialValueFor("fortify_mr") / 100)

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_gargoyle")
	item:SetCurrentCharges(self:GetStackCount())
end