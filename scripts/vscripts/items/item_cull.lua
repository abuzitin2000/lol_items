item_cull = class({})

-- Modifier Linkers
LinkLuaModifier("item_cull_modifier", "items/item_cull", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("reap", "modifiers/reap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("reap_stack", "modifiers/reap_stack", LUA_MODIFIER_MOTION_NONE)

function item_cull:GetIntrinsicModifierName()
	return "item_cull_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_cull_modifier = class({})

function item_cull_modifier:IsHidden()
	return true
end

function item_cull_modifier:IsPurgable()
	return false
end

function item_cull_modifier:RemoveOnDeath()
	return false
end

function item_cull_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_cull_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "reap", {})
end

-- Removing Unique Passives
function item_cull_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local reap = parent:FindModifierByName("reap")
	if reap then
		reap:Destroy()
	end
end

-- Stats
function item_cull_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function item_cull_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

-- Heal when auto attacking
function item_cull_modifier:OnAttackLanded( event )
	local parent = self:GetParent()
	local attacker = event.attacker
	local ability = self:GetAbility()
	if parent == attacker and event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		parent:Heal(ability:GetSpecialValueFor("cull_heal"), parent)
	end
end