item_spectral = class({})

-- Modifier Linkers
LinkLuaModifier("item_spectral_modifier", "items/item_spectral", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("tribute", "modifiers/tribute", LUA_MODIFIER_MOTION_NONE)

function item_spectral:GetIntrinsicModifierName()
	return "item_spectral_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_spectral_modifier = class({})

function item_spectral_modifier:IsHidden()
	return true
end

function item_spectral_modifier:IsPurgable()
	return false
end

function item_spectral_modifier:RemoveOnDeath()
	return false
end

function item_spectral_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_spectral_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "tribute", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana + ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm + ability:GetSpecialValueFor("gpm")
end

-- Removing Unique Passives
function item_spectral_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local tribute = parent:FindModifierByName("tribute")
	if tribute then
		tribute:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.base_mana = unique.base_mana - ability:GetSpecialValueFor("bonus_mana_regen")
	unique.gpm = unique.gpm - ability:GetSpecialValueFor("gpm")
end

-- Stats
function item_spectral_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_spectral_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_ad")
end

function item_spectral_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end