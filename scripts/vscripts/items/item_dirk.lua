item_dirk = class({})

-- Modifier Linkers
LinkLuaModifier("item_dirk_modifier", "items/item_dirk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("gouge", "modifiers/gouge", LUA_MODIFIER_MOTION_NONE)

function item_dirk:GetIntrinsicModifierName()
	return "item_dirk_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_dirk_modifier = class({})

function item_dirk_modifier:IsHidden()
	return true
end

function item_dirk_modifier:IsPurgable()
	return false
end

function item_dirk_modifier:RemoveOnDeath()
	return false
end

function item_dirk_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_dirk_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "gouge", {})
end

-- Removing Unique Passives
function item_dirk_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local gouge = parent:FindModifierByName("gouge")
	if gouge then
		gouge:Destroy()
	end
end

-- Stats
function item_dirk_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_dirk_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end