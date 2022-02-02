grievous = class({})

function grievous:IsHidden()
	return false
end

function grievous:IsPurgable()
	return false
end

function grievous:OnCreated()
    if not IsServer() then
        return
    end

    self.count = 0
end

function grievous:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
    	MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    	MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
    	MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function grievous:GetModifierHealAmplify_PercentageTarget()
    return -1 * self:GetStackCount()
end

function grievous:GetModifierHPRegenAmplify_Percentage()
    return -1 * self:GetStackCount()
end

function grievous:GetModifierLifestealRegenAmplify_Percentage()
    return -1 * self:GetStackCount()
end

function grievous:GetModifierSpellLifestealRegenAmplify_Percentage()
    return -1 * self:GetStackCount()
end