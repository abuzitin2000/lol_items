sacrifice_caster = class({})

function sacrifice_caster:IsHidden()
	return false
end

function sacrifice_caster:IsPurgable()
	return false
end

function sacrifice_caster:RemoveOnDeath()
	return false
end

function sacrifice_caster:GetEffectName()
	return "particles/items_fx/aura_assault.vpcf"
end

function sacrifice_caster:OnCreated( params )
	if not IsServer() then
		return
	end

	self.target = EntIndexToHScript(params.target)
end

function sacrifice_caster:OnDestroy()
	if not IsServer() then
		return
	end

	local sacrifice = self.target:FindModifierByName("sacrifice_target")
	if sacrifice then
		sacrifice:Destroy()
	end
end

sacrifice_target = class({})

function sacrifice_target:IsHidden()
	return false
end

function sacrifice_target:IsPurgable()
	return false
end

function sacrifice_target:RemoveOnDeath()
	return false
end

function sacrifice_target:GetEffectName()
	return "particles/items_fx/aura_assault.vpcf"
end

function sacrifice_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function sacrifice_target:GetModifierIncomingDamage_Percentage( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local caster = self:GetCaster()
	local target = event.target
	local attacker = event.attacker
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	-- Don't reduce pure damage
	if event.damage_type == DAMAGE_TYPE_PURE then
		return 0
	end

	-- Only reduce when ally has health
	if caster:GetHealthPercent() < ability:GetSpecialValueFor("sacrifice_health") then
		return 0
	end

	-- Only reduce when ally nearby
	if CalcDistanceBetweenEntityOBB(parent, caster) > 1200 then
		return 0
	end

	local reduction = ability:GetSpecialValueFor("sacrifice_redirect")

	if parent:GetHealthPercent() < ability:GetSpecialValueFor("sacrifice_health") then
		reduction = ability:GetSpecialValueFor("sacrifice_increase")
	end

	-- Deal Damage
	local damageTable = {
	  victim = caster,
	  attacker = attacker,
	  damage = event.damage * (reduction / 100),
	  damage_type = DAMAGE_TYPE_PURE,
	  damage_flags = DOTA_DAMAGE_FLAG_NONE
	}
	ApplyDamage(damageTable)

	return -1 * reduction
end

function sacrifice_target:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local caster = self:GetCaster()
	local attacker = event.attacker
	local target = event.target
	local ability = self:GetAbility()

	if not ability then
		return
	end

	-- Check if attacker is parent
    if attacker ~= parent then
    	return
    end

    -- Check if target is hero
    if not target:IsHero() then
    	return
    end

    -- Check if ally is alive
	if not caster:IsAlive() then
		return
	end

	caster:Heal(event.damage * (ability:GetSpecialValueFor("sacrifice_heal") / 100), ability)
end