item_hailblade = class({})

-- Modifier Linkers
LinkLuaModifier("item_hailblade_modifier", "items/item_hailblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("sear", "modifiers/sear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("smite_path", "modifiers/smite_path", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("huntsman", "modifiers/huntsman", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("recoup", "modifiers/recoup", LUA_MODIFIER_MOTION_NONE)

function item_hailblade:GetIntrinsicModifierName()
	return "item_hailblade_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_hailblade_modifier = class({})

function item_hailblade_modifier:IsHidden()
	return true
end

function item_hailblade_modifier:IsPurgable()
	return false
end

function item_hailblade_modifier:RemoveOnDeath()
	return false
end

function item_hailblade_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- Adding Unique Passives
function item_hailblade_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "sear", {})
	parent:AddNewModifier(parent, ability, "smite_path", {})
	parent:AddNewModifier(parent, ability, "huntsman", {})
	parent:AddNewModifier(parent, ability, "recoup", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.jungle_omnivamp["hailblade"] = ability:GetSpecialValueFor("jungle_omnivamp")
end

-- Removing Unique Passives
function item_hailblade_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local path = parent:FindModifierByName("smite_path")
	-- Don't destroy modifiers if item is consumed
	if path:GetStackCount() < ability:GetSpecialValueFor("smite_stack") then
		local sear = parent:FindModifierByName("sear")
		if sear then
			sear:Destroy()
		end

		local huntsman = parent:FindModifierByName("huntsman")
		if huntsman then
			huntsman:Destroy()
		end

		local recoup = parent:FindModifierByName("recoup")
		if recoup then
			recoup:Destroy()
		end

		local unique = parent:FindModifierByName("unique_mechanics")
		unique.jungle_omnivamp["hailblade"] = 0
	end
end