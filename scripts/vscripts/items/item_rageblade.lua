item_rageblade = class({})

-- Modifier Linkers
LinkLuaModifier("item_rageblade_modifier", "items/item_rageblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("wrath", "modifiers/wrath", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("seeth", "modifiers/seeth", LUA_MODIFIER_MOTION_NONE)

function item_rageblade:GetIntrinsicModifierName()
	return "item_rageblade_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_rageblade_modifier = class({})

function item_rageblade_modifier:IsHidden()
	return true
end

function item_rageblade_modifier:IsPurgable()
	return false
end

function item_rageblade_modifier:RemoveOnDeath()
	return false
end

function item_rageblade_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_rageblade_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "wrath", {})
	parent:AddNewModifier(parent, ability, "seeth", {})
end

-- Removing Unique Passives
function item_rageblade_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local wrath = parent:FindModifierByName("wrath")
	if wrath then
		wrath:Destroy()
	end

	local seeth = parent:FindModifierByName("seeth")
	if seeth then
		seeth:Destroy()
	end
end

-- Stats
function item_rageblade_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_rageblade_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end