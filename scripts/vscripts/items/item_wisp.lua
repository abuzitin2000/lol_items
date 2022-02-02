item_wisp = class({})

-- Modifier Linkers
LinkLuaModifier("item_wisp_modifier", "items/item_wisp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("glide", "modifiers/glide", LUA_MODIFIER_MOTION_NONE)

function item_wisp:GetIntrinsicModifierName()
	return "item_wisp_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_wisp_modifier = class({})

function item_wisp_modifier:IsHidden()
	return true
end

function item_wisp_modifier:IsPurgable()
	return false
end

function item_wisp_modifier:RemoveOnDeath()
	return false
end

function item_wisp_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_wisp_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "glide", {})
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("bonus_ap")
end

function item_wisp_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local glide = parent:FindModifierByName("glide")
	if glide then
		glide:Destroy()
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("bonus_ap")
end