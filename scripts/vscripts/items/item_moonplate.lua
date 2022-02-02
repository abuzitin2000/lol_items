item_moonplate = class({})

-- Modifier Linkers
LinkLuaModifier("item_moonplate_modifier", "items/item_moonplate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flight", "modifiers/flight", LUA_MODIFIER_MOTION_NONE)

function item_moonplate:GetIntrinsicModifierName()
	return "item_moonplate_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_moonplate_modifier = class({})

function item_moonplate_modifier:IsHidden()
	return true
end

function item_moonplate_modifier:IsPurgable()
	return false
end

function item_moonplate_modifier:RemoveOnDeath()
	return false
end

function item_moonplate_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_moonplate_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "flight", {})
end

-- Removing Unique Passives
function item_moonplate_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local flight = parent:FindModifierByName("flight")
	if flight then
		flight:Destroy()
	end
end

-- Stats
function item_moonplate_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function item_moonplate_modifier:GetModifierHealthBonus()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	return ability:GetSpecialValueFor("bonus_health")
end