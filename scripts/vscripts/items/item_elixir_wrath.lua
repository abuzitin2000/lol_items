item_elixir_wrath = class({})

-- Modifier Linkers
LinkLuaModifier("item_elixir_wrath_modifier", "items/item_elixir_wrath", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_elixir_wrath:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	-- Remove other elixirs
	local sorcery = caster:FindModifierByName("item_elixir_sorcery_modifier")
	local wrath = caster:FindModifierByName("item_elixir_wrath_modifier")
	local iron = caster:FindModifierByName("item_elixir_iron_modifier")
	if sorcery then
		caster:RemoveModifierByName("item_elixir_sorcery_modifier")
	end
	if wrath then
		caster:RemoveModifierByName("item_elixir_wrath_modifier")
	end	
	if iron then
		caster:RemoveModifierByName("item_elixir_iron_modifier")
	end
	
	-- Add the elixir effect
	caster:AddNewModifier(caster, self, "item_elixir_wrath_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")

	self:SpendCharge()
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_elixir_wrath_modifier = class({})

function item_elixir_wrath_modifier:IsHidden()
	return false
end

function item_elixir_wrath_modifier:IsPurgable()
	return false
end

function item_elixir_wrath_modifier:GetTexture()
	return "item_elixir_wrath"
end

function item_elixir_wrath_modifier:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_style_ambient_flames.vpcf"
end

function item_elixir_wrath_modifier:OnCreated()
	self.bonus_ad = self:GetAbility():GetSpecialValueFor("bonus_ad")
	self.bonus_vamp = self:GetAbility():GetSpecialValueFor("bonus_vamp")

	if not IsServer() then
		return
	end

	-- Add Physical Vamp
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.physvamp["elixir_wrath"] = self.bonus_vamp
end

function item_elixir_wrath_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	-- Subtract Physical Vamp
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.physvamp["elixir_wrath"] = 0
end

function item_elixir_wrath_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

-- Bonus Damage
function item_elixir_wrath_modifier:GetModifierPreAttack_BonusDamage() 
	return self.bonus_ad
end