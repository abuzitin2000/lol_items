recoup = class ({})

function recoup:IsHidden()
	return true
end

function recoup:IsPurgable()
	return false
end

function recoup:RemoveOnDeath()
	return false
end

function recoup:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function recoup:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end

-- Give mana regen when on jungle or river
function recoup:GetModifierConstantManaRegen()
	local parent = self:GetParent()
	local z = parent:GetAbsOrigin().z
	-- Check if on jungle or river
	if z == 256 or z == 0 then
		local percent = 1 - (parent:GetMana() / parent:GetMaxMana())
		if percent > 0.8 then
			return (7.4117647058824 + (0.58823529411765 * parent:GetLevel())) * 0.8
		else
			return (7.4117647058824 + (0.58823529411765 * parent:GetLevel())) * percent
		end
	end
end