item_mobility_boot = class({})

-- Modifier Linkers
LinkLuaModifier("item_mobility_boot_modifier", "items/item_mobility_boot", LUA_MODIFIER_MOTION_NONE)

function item_mobility_boot:GetIntrinsicModifierName()
	return "item_mobility_boot_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_mobility_boot_modifier = class({})

function item_mobility_boot_modifier:IsHidden()
	return true
end

function item_mobility_boot_modifier:IsPurgable()
	return false
end

function item_mobility_boot_modifier:RemoveOnDeath()
	return false
end

-- Stats
function item_mobility_boot_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
	return funcs
end

function item_mobility_boot_modifier:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	if IsServer() then
		if ability:IsCooldownReady() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end

	if self:GetStackCount() == 1 then
		return ability:GetSpecialValueFor("increased_speed")
	else
		return ability:GetSpecialValueFor("bonus_speed")
	end
end

function item_mobility_boot_modifier:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	-- Check if attacker or target is parent
    if attacker == parent or target == parent then
    	self:GetAbility():StartCooldown(5)
    end
end