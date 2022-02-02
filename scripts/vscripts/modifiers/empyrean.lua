empyrean = class({})

function empyrean:IsHidden()
	return true
end

function empyrean:IsPurgable()
	return false
end

function empyrean:RemoveOnDeath()
	return false
end

function empyrean:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function empyrean:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_SPENT_MANA
    }
    return funcs
end

function empyrean:OnSpentMana( event )
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local casted_ability = event.ability

	if not ability then
		return
	end

	if not casted_ability then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")

	if not unique then
		return
	end

	local heal = casted_ability:GetManaCost(-1) * (ability:GetSpecialValueFor("empyrean_heal") / 100)
	local max = (25 + 25 / 17 * (parent:GetLevel() - 1)) + (unique.ap * (ability:GetSpecialValueFor("empyrean_ap") / 100))

	if heal > max then
		heal = max
	end

	-- Heal
	parent:Heal(heal, ability)

	-- Effect
	if heal > 0 and parent:GetHealthPercent() ~= 100 then
		local lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
	end
end