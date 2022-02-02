item_gargoyle = class({})

-- Modifier Linkers
LinkLuaModifier("item_gargoyle_modifier", "items/item_gargoyle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("monolith", "modifiers/monolith", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fortify", "modifiers/fortify", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_gargoyle:OnSpellStart()
	local caster = self:GetCaster()
	local unique = caster:FindModifierByName("unique_mechanics")

	local mod = caster:AddNewModifier(caster, self, "monolith", { duration = self:GetSpecialValueFor("monolith_duration") })
	local shield = self:GetSpecialValueFor("monolith_base") + (caster:GetMaxHealth() - caster:GetStrength() * 20) * (self:GetSpecialValueFor("monolith_health") / 100)
	mod:SetStackCount(shield * (1 + unique.heal_power / 100))

	self:StartCooldown(self:GetSpecialValueFor("monolith_cooldown"))
end

function item_gargoyle:GetIntrinsicModifierName()
	return "item_gargoyle_modifier"
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_gargoyle_modifier = class({})

function item_gargoyle_modifier:IsHidden()
	return true
end

function item_gargoyle_modifier:IsPurgable()
	return false
end

function item_gargoyle_modifier:RemoveOnDeath()
	return false
end

function item_gargoyle_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_gargoyle_modifier:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "fortify", {})

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor + ability:GetSpecialValueFor("bonus_armor")
	unique.mr = unique.mr + ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste + ability:GetSpecialValueFor("bonus_haste")
end

function item_gargoyle_modifier:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	local fortify = parent:FindModifierByName("fortify")
	if fortify then
		fortify:Destroy()
	end
	
	local unique = parent:FindModifierByName("unique_mechanics")
	unique.armor = unique.armor - ability:GetSpecialValueFor("bonus_armor")
	unique.mr = unique.mr - ability:GetSpecialValueFor("bonus_mr")
	unique.haste = unique.haste - ability:GetSpecialValueFor("bonus_haste")
end