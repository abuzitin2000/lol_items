item_whisper = class({})

-- Modifier Linkers
LinkLuaModifier("item_whisper_modifier", "items/item_whisper", LUA_MODIFIER_MOTION_NONE)

function item_whisper:GetIntrinsicModifierName()
	return "item_whisper_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_whisper_modifier = class({})

function item_whisper_modifier:IsHidden()
	return true
end

function item_whisper_modifier:IsPurgable()
	return false
end

function item_whisper_modifier:RemoveOnDeath()
	return false
end

function item_whisper_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_whisper_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.percentage_pen["whisper"] = ability:GetSpecialValueFor("bonus_pen")
end

-- Removing Unique Passives
function item_whisper_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.percentage_pen["whisper"] = 0
end

-- Stats
function item_whisper_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_whisper_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end