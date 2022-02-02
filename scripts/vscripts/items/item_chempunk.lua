item_chempunk = class({})

-- Modifier Linkers
LinkLuaModifier("item_chempunk_modifier", "items/item_chempunk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hackshorn", "modifiers/hackshorn", LUA_MODIFIER_MOTION_NONE)

function item_chempunk:GetIntrinsicModifierName()
	return "item_chempunk_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_chempunk_modifier = class({})

function item_chempunk_modifier:IsHidden()
	return true
end

function item_chempunk_modifier:IsPurgable()
	return false
end

function item_chempunk_modifier:RemoveOnDeath()
	return false
end

function item_chempunk_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_chempunk_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "hackshorn", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

-- Removing Unique Passives
function item_chempunk_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local hackshorn = parent:FindModifierByName("hackshorn")
	if hackshorn then
		hackshorn:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end

-- Stats
function item_chempunk_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    	MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function item_chempunk_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_damage")
end

function item_chempunk_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end