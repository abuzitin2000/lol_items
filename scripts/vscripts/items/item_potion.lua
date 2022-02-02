item_potion = class({})

-- Modifier Linkers
LinkLuaModifier("item_potion_modifier", "items/item_potion", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_potion:OnSpellStart()
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, self, "item_potion_modifier", { duration = duration })
	caster:EmitSound("Bottle.Drink")

	self:SpendCharge()
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_potion_modifier = class({})

function item_potion_modifier:IsHidden()
	return false
end

function item_potion_modifier:IsPurgable()
	return false
end

function item_potion_modifier:GetTexture()
	return "item_potion"
end

function item_potion_modifier:GetEffectName()
	return "particles/items_fx/healing_flask.vpcf"
end

function item_potion_modifier:OnCreated()
	self.heal = self:GetAbility():GetSpecialValueFor("heal")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end

function item_potion_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-- Bonus Health Regen
function item_potion_modifier:GetModifierConstantHealthRegen() 
	return self.heal / self.duration
end