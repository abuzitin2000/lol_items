item_tiamat = class({})

-- Modifier Linkers
LinkLuaModifier("item_tiamat_modifier", "items/item_tiamat", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("cleave", "modifiers/cleave", LUA_MODIFIER_MOTION_NONE)

function item_tiamat:GetIntrinsicModifierName()
	return "item_tiamat_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_tiamat_modifier = class({})

function item_tiamat_modifier:IsHidden()
	return true
end

function item_tiamat_modifier:IsPurgable()
	return false
end

function item_tiamat_modifier:RemoveOnDeath()
	return false
end

function item_tiamat_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_tiamat_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "cleave", {})
end

-- Removing Unique Passives
function item_tiamat_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local cleave = parent:FindModifierByName("cleave")
	if cleave then
		cleave:Destroy()
	end
end

-- Stats
function item_tiamat_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function item_tiamat_modifier:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return ability:GetSpecialValueFor("bonus_damage")
end