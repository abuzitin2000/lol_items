item_bami = class({})

-- Modifier Linkers
LinkLuaModifier("item_bami_modifier", "items/item_bami", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("immolate", "modifiers/immolate", LUA_MODIFIER_MOTION_NONE)

function item_bami:GetIntrinsicModifierName()
	return "item_bami_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bami_modifier = class({})

function item_bami_modifier:IsHidden()
	return true
end

function item_bami_modifier:IsPurgable()
	return false
end

function item_bami_modifier:RemoveOnDeath()
	return false
end

function item_bami_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_bami_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "immolate", {})
end

-- Removing Unique Passives
function item_bami_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local immolate = parent:FindModifierByName("immolate")
	if immolate then
		immolate:Destroy()
	end
end

-- Stats
function item_bami_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_bami_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end