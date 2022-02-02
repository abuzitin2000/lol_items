item_refill = class({})

-- Modifier Linkers
LinkLuaModifier("item_refill_modifier", "items/item_refill", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_refill_heal_modifier", "items/item_refill", LUA_MODIFIER_MOTION_NONE)

function item_refill:GetIntrinsicModifierName()
	return "item_refill_modifier"
end

-- Ability
function item_refill:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, self, "item_refill_heal_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.HealingSalve.Activate")

	self:SpendCharge()
end

-- Intrinsic Modifier
-------------------------------------------------------------------------------------------------------------
item_refill_modifier = class ({})

function item_refill_modifier:IsHidden()
	return true
end

function item_refill_modifier:IsPurgable()
	return false
end

function item_refill_modifier:OnCreated()
	self:StartIntervalThink(1)
end

function item_refill_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	-- Refill when in fountain
	if parent:FindModifierByName("modifier_fountain_aura_buff") then
		local item = parent:FindItemInInventory("item_refill")
		if item then
			item:SetCurrentCharges(2)
		end
	end
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_refill_heal_modifier = class({})

function item_refill_heal_modifier:IsHidden()
	return false
end

function item_refill_heal_modifier:IsPurgable()
	return false
end

function item_refill_heal_modifier:GetTexture()
	return "item_refill"
end

function item_refill_heal_modifier:GetEffectName()
	return "particles/items_fx/bottle.vpcf"
end

function item_refill_heal_modifier:OnCreated()
	self.heal = self:GetAbility():GetSpecialValueFor("heal")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end

function item_refill_heal_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

-- Bonus Health Regen
function item_refill_heal_modifier:GetModifierConstantHealthRegen() 
	return self.heal / self.duration
end