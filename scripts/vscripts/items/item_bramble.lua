item_bramble = class({})

-- Modifier Linkers
LinkLuaModifier("item_bramble_modifier", "items/item_bramble", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("thorns", "modifiers/thorns", LUA_MODIFIER_MOTION_NONE)

function item_bramble:GetIntrinsicModifierName()
	return "item_bramble_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_bramble_modifier = class({})

function item_bramble_modifier:IsHidden()
	return true
end

function item_bramble_modifier:IsPurgable()
	return false
end

function item_bramble_modifier:RemoveOnDeath()
	return false
end

function item_bramble_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_bramble_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "thorns", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
end

function item_bramble_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local thorns = parent:FindModifierByName("thorns")
	if thorns then
		thorns:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
end