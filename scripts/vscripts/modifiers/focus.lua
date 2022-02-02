focus = class({})

function focus:IsHidden()
	return true
end

function focus:IsPurgable()
	return false
end

function focus:RemoveOnDeath()
	return false
end

function focus:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function focus:DeclareFunctions()
	local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

-- Deal damage when hitting lane creeps
function focus:OnAttackLanded( event )
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

	-- Check if attacker is self and stop infinite loops
	if parent == attacker and event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		-- Get proc damage value
		local finaldamage = ability:GetSpecialValueFor("focus_proc")

		-- Check if target is a lane creep
		if target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege" then
			-- Deal Damage
			local damageTable = {
			  victim = target,
			  attacker = attacker,
			  damage = finaldamage,
			  damage_type = DAMAGE_TYPE_PHYSICAL,
			  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			}
			ApplyDamage(damageTable)
		end
	end
end