carve = class ({})

-- Modifier Linkers
LinkLuaModifier("carve_debuff", "modifiers/carve", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("carve_helper", "modifiers/carve", LUA_MODIFIER_MOTION_NONE)

function carve:IsHidden()
	return true
end

function carve:IsPurgable()
	return false
end

function carve:RemoveOnDeath()
	return false
end

function carve:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function carve:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function carve:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is parent
    if attacker ~= parent or target == parent and target:IsAlive() then
    	return
    end

    -- Check if physical damage
    if event.damage_type ~= DAMAGE_TYPE_PHYSICAL then
    	return
    end

    local mod = target:FindModifierByName("carve_debuff")

    if mod then
    	mod:SetStackCount(mod:GetStackCount() + 1)
    	-- Fix if going over max stacks
    	if mod:GetStackCount() > ability:GetSpecialValueFor("carve_max") / ability:GetSpecialValueFor("carve_stack") then
    		mod:SetStackCount(ability:GetSpecialValueFor("carve_max") / ability:GetSpecialValueFor("carve_stack"))
    	end
    end

    target:AddNewModifier(parent, ability, "carve_debuff", { duration = ability:GetSpecialValueFor("carve_duration") })
    target:AddNewModifier(parent, ability, "carve_helper", { duration = ability:GetSpecialValueFor("carve_duration") })
end

carve_debuff = class ({})

function carve_debuff:IsHidden()
	return false
end

function carve_debuff:IsPurgable()
	return false
end

function carve_debuff:OnCreated()
	if not IsServer() then
		return
	end

	self:SetStackCount(1)
end

function carve_debuff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function carve_debuff:GetModifierPhysicalArmorBonus()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

    return -1 * (parent:GetModifierStackCount("carve_helper", caster) / 100) * (ability:GetSpecialValueFor("carve_stack") * self:GetStackCount() / 100)
end

carve_helper = class ({})

function carve_helper:IsHidden()
	return true
end

function carve_helper:IsPurgable()
	return false
end

function carve_helper:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	self:SetStackCount(parent:GetPhysicalArmorValue(false) * 100)
end