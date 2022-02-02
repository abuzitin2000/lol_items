item_recurve = class({})

-- Modifier Linkers
LinkLuaModifier("item_recurve_modifier", "items/item_recurve", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("steeltipped", "modifiers/steeltipped", LUA_MODIFIER_MOTION_NONE)

function item_recurve:GetIntrinsicModifierName()
	return "item_recurve_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_recurve_modifier = class({})

function item_recurve_modifier:IsHidden()
	return true
end

function item_recurve_modifier:IsPurgable()
	return false
end

function item_recurve_modifier:RemoveOnDeath()
	return false
end

function item_recurve_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_recurve_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "steeltipped", {})
end

-- Removing Unique Passives
function item_recurve_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local steeltipped = parent:FindModifierByName("steeltipped")
	if steeltipped then
		steeltipped:Destroy()
	end
end

-- Stats
function item_recurve_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_recurve_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end