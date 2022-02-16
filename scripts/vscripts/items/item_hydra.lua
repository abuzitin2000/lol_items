item_hydra = class({})

-- Modifier Linkers
LinkLuaModifier("item_hydra_modifier", "items/item_hydra", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("cleave", "modifiers/cleave", LUA_MODIFIER_MOTION_NONE)

function item_hydra:GetIntrinsicModifierName()
	return "item_hydra_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_hydra_modifier = class({})

function item_hydra_modifier:IsHidden()
	return true
end

function item_hydra_modifier:IsPurgable()
	return false
end

function item_hydra_modifier:RemoveOnDeath()
	return false
end

function item_hydra_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_hydra_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "cleave", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
	unique.omnivamp["hydra"] = ability:GetSpecialValueFor("omnivamp")
end

-- Removing Unique Passives
function item_hydra_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local cleave = parent:FindModifierByName("cleave")
	if cleave then
		cleave:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
	unique.omnivamp["hydra"] = 0
end

-- Stats
function item_hydra_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_hydra_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end