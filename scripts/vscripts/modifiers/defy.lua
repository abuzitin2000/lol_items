defy = class({})

-- Modifier Linkers
LinkLuaModifier("defy_buff", "modifiers/defy", LUA_MODIFIER_MOTION_NONE)

function defy:IsHidden()
	return true
end

function defy:IsPurgable()
	return false
end

function defy:RemoveOnDeath()
	return false
end

function defy:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function defy:DeclareFunctions()
	local funcs = {
    	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function defy:OnDeath( event )
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if target is hero
	if not target:IsRealHero() then
		return
	end

	-- Check if attacker got the kill or assist
	if not (parent == attacker or CalcDistanceBetweenEntityOBB(target, parent) < 1300) then
		return
	end

	local mods = parent:FindAllModifiersByName("ignore_pain_damage")

	if mods then
		for _,mod in pairs(mods) do
			mod:Destroy()
		end
	end

	parent:AddNewModifier(parent, ability, "defy_buff", { duration = ability:GetSpecialValueFor("defy_duration") })
end

defy_buff = class({})

function defy_buff:IsHidden()
	return false
end

function defy_buff:IsPurgable()
	return false
end

function defy_buff:RemoveOnDeath()
	return false
end

function defy_buff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function defy_buff:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
    return (parent:GetMaxHealth() * (ability:GetSpecialValueFor("defy_heal") / 100)) / ability:GetSpecialValueFor("defy_duration")
end