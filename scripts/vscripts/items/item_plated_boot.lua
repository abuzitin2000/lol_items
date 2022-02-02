item_plated_boot = class({})

-- Modifier Linkers
LinkLuaModifier("item_plated_boot_modifier", "items/item_plated_boot", LUA_MODIFIER_MOTION_NONE)

function item_plated_boot:GetIntrinsicModifierName()
	return "item_plated_boot_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_plated_boot_modifier = class({})

function item_plated_boot_modifier:IsHidden()
	return true
end

function item_plated_boot_modifier:IsPurgable()
	return false
end

function item_plated_boot_modifier:RemoveOnDeath()
	return false
end

function item_plated_boot_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

function item_plated_boot_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end

-- Stats
function item_plated_boot_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    	MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
	}
	return funcs
end

function item_plated_boot_modifier:GetModifierMoveSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_speed")
end

function item_plated_boot_modifier:GetModifierIncomingPhysicalDamage_Percentage( event )
	if not IsServer() then
		return
	end

	-- Only work when taking damage
	if event.target ~= self:GetParent() then
		return 0
	end

	-- Doesn't work against towers
	if event.attacker:IsTower() then
		return 0
	end

	-- Doesn't work against abilities
	if event.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return 0
	end

	-- Doesn't work against on hit effects
	if event.inflictor then
		return 0
	end

	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return -1 * ability:GetSpecialValueFor("damage_reduction")
end