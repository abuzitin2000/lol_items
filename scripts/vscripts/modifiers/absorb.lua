absorb = class ({})

-- Modifier Linkers
LinkLuaModifier("absorb_buff", "modifiers/absorb", LUA_MODIFIER_MOTION_NONE)

function absorb:IsHidden()
	return true
end

function absorb:IsPurgable()
	return false
end

function absorb:RemoveOnDeath()
	return false
end

function absorb:OnCreated()
	if not IsServer() then
		return
	end

	self.seperate = {}

	self:StartIntervalThink(1)
end

function absorb:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function absorb:OnIntervalThink()
	if not IsServer() then
		return
	end

	self.seperate = {}
end

function absorb:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function absorb:OnTakeDamageKillCredit( event )
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
	if target ~= parent or not attacker then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == attacker:GetTeam() then
		return
	end

	-- Check if damage is magic
	if event.damage_type ~= DAMAGE_TYPE_MAGICAL then
		return
	end

	-- Stops infinite loops
	--if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
	--	return
	--end

	-- Count seperate attacks
	local inflictor = event.inflictor
	if inflictor == nil then
		return
	end

	for k,v in pairs(self.seperate) do
		if v == true and k == inflictor then
			return
		end
	end

	self.seperate[inflictor] = true

	local absorb_buff = parent:AddNewModifier(parent, ability, "absorb_buff", { duration = ability:GetSpecialValueFor("absorb_duration") })

	absorb_buff:SetStackCount(absorb_buff:GetStackCount() + 1)

	-- Additional if disabled
	if target:IsStunned() or target:IsRooted() or target:IsNightmared() then
		absorb_buff:SetStackCount(absorb_buff:GetStackCount() + ability:GetSpecialValueFor("absorb_stun"))
	end

	if absorb_buff:GetStackCount() > ability:GetSpecialValueFor("absorb_stack") then
		absorb_buff:SetStackCount(ability:GetSpecialValueFor("absorb_stack"))
	end

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_nature")
	item:SetCurrentCharges(absorb_buff:GetStackCount())
end

absorb_buff = class ({})

function absorb_buff:IsHidden()
	return true
end

function absorb_buff:IsPurgable()
	return false
end

function absorb_buff:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_nature")
	item:SetCurrentCharges(0)
end

function absorb_buff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function absorb_buff:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if self:GetStackCount() < ability:GetSpecialValueFor("absorb_stack") then
		return 0
	end
	
    return ability:GetSpecialValueFor("absorb_speed")
end

function absorb_buff:GetModifierIncomingDamage_Percentage( event )
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if self:GetStackCount() < ability:GetSpecialValueFor("absorb_stack") then
		return 0
	end

	if event.damage_type ~= DAMAGE_TYPE_MAGICAL then
		return 0
	end
	
    return -1 * ability:GetSpecialValueFor("absorb_mr")
end