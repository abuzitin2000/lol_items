sepsis = class ({})

-- Modifier Linkers
LinkLuaModifier("grievous", "modifiers/grievous", LUA_MODIFIER_MOTION_NONE)

function sepsis:IsHidden()
	return true
end

function sepsis:IsPurgable()
	return false
end

function sepsis:RemoveOnDeath()
	return false
end

function sepsis:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function sepsis:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

-- Apply Grivious Wounds
function sepsis:OnTakeDamageKillCredit( event )
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

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Check if target is a hero
	if not target:IsHero() then
		return
	end

	-- Check if attack is an auto attack
	if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
		return
	end

	-- Apply Grievous Wounds
	local grievous = target:AddNewModifier(parent, ability, "grievous", { duration = ability:GetSpecialValueFor("grievous_duration") })

	grievous.count = grievous.count + 1

	if grievous.count > ability:GetSpecialValueFor("grievous_attacks") and grievous:GetStackCount() <= ability:GetSpecialValueFor("grievous_max") then
		grievous:SetStackCount(ability:GetSpecialValueFor("grievous_max"))
	else
		grievous:SetStackCount(ability:GetSpecialValueFor("grievous"))
	end
end