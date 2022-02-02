item_caulfield = class({})

-- Modifier Linkers
LinkLuaModifier("item_caulfield_modifier", "items/item_caulfield", LUA_MODIFIER_MOTION_NONE)

function item_caulfield:GetIntrinsicModifierName()
	return "item_caulfield_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_caulfield_modifier = class({})

function item_caulfield_modifier:IsHidden()
	return true
end

function item_caulfield_modifier:IsPurgable()
	return false
end

function item_caulfield_modifier:RemoveOnDeath()
	return false
end

function item_caulfield_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_caulfield_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_caulfield_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_caulfield_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_caulfield_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end