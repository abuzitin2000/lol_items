seeth = class ({})

-- Modifier Linkers
LinkLuaModifier("seeth_buff", "modifiers/seeth", LUA_MODIFIER_MOTION_NONE)

function seeth:IsHidden()
	return true
end

function seeth:IsPurgable()
	return false
end

function seeth:RemoveOnDeath()
	return false
end

function seeth:OnCreated()
	if not IsServer() then
		return
	end

	self.timer = 0

	self:StartIntervalThink(1)
end

function seeth:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function seeth:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	if self.timer > 1 then
		self.timer = self.timer - 1
	end

	if self.timer == 1 then
		self.timer = 0
		self:SetStackCount(0)

		-- Set Item Stack
		local item = parent:FindItemInInventory("item_rageblade")
		item:SetCurrentCharges(0)
	end
end

function seeth:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function seeth:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Check if attack is ghost
	if event.no_attack_cooldown then
		return
	end

	self:SetStackCount(self:GetStackCount() + 1)

	self.timer = 6

	if self:GetStackCount() == 3 then
		target:AddNewModifier(parent, ability, "seeth_buff", { duration = 0.15 })
		self:SetStackCount(0)
	end

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_rageblade")
	item:SetCurrentCharges(self:GetStackCount())
end

seeth_buff = class ({})

function seeth_buff:IsHidden()
	return true
end

function seeth_buff:IsPurgable()
	return false
end

function seeth_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function seeth_buff:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	caster:PerformAttack(parent, true, true, true, true, false, true, true)
end