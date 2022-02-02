item_kircheis = class({})

-- Modifier Linkers
LinkLuaModifier("item_kircheis_modifier", "items/item_kircheis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("energized", "modifiers/energized", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("jolt", "modifiers/jolt", LUA_MODIFIER_MOTION_NONE)

function item_kircheis:GetIntrinsicModifierName()
	return "item_kircheis_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_kircheis_modifier = class({})

function item_kircheis_modifier:IsHidden()
	return true
end

function item_kircheis_modifier:IsPurgable()
	return false
end

function item_kircheis_modifier:RemoveOnDeath()
	return false
end

function item_kircheis_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_kircheis_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "energized", {})
	parent:AddNewModifier(parent, ability, "jolt", {})
end

-- Removing Unique Passives
function item_kircheis_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local energized = parent:FindModifierByName("energized")
	if energized then
		energized:Destroy()
	end

	local jolt = parent:FindModifierByName("jolt")
	if jolt then
		jolt:Destroy()
	end
end

-- Stats
function item_kircheis_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function item_kircheis_modifier:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_attack_speed")
end