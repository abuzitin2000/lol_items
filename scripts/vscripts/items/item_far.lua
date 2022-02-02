item_far = class({})

-- Modifier Linkers
LinkLuaModifier("item_far_modifier", "items/item_far", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("far_vision_giver", "items/item_far", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_far:OnSpellStart()
	local caster = self:GetCaster()
	
	AddFOWViewer(caster:GetTeam(), caster:GetCursorPosition(), 900, 2.0, false)

	-- Summon ward
	local ward = CreateUnitByName("npc_dota_sentry_wards", caster:GetCursorPosition(), true, caster, caster, caster:GetTeam())
	ward:AddNewModifier(caster, self, "item_far_modifier", {})
	ward:SetMaximumGoldBounty(15)
	ward:SetMinimumGoldBounty(15)
	ward:SetDeathXP(15)

	-- Reveal enemies
	local enemies = FindUnitsInRadius(ward:GetTeam(), ward:GetOrigin(), ward, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)
	for e,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "far_vision_giver", { duration = 5 })
	end

	-- Set item cooldown
	local item = caster:FindItemInInventory("item_far")
	local heroes = HeroList:GetAllHeroes()
	local totalLevel = 0
	local count = 0
	for h,hero in pairs(heroes) do
		totalLevel = totalLevel + hero:GetLevel()
		count = count + 1
	end
	item:StartCooldown(198 - 99 / 17 * (totalLevel / count - 1))

	EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "DOTA_Item.SentryWard.Activate", caster)
end

-- Modifiers
-------------------------------------------------------------------------------------------------------------
item_far_modifier = class({})

function item_far_modifier:IsHidden()
	return true
end

function item_far_modifier:IsPurgable()
	return false
end

function item_far_modifier:GetTexture()
	return "item_far"
end

function item_far_modifier:OnCreated( event )
	local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(blast_pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(blast_pfx, 1, Vector(500, 2, 500))
	ParticleManager:ReleaseParticleIndex(blast_pfx)
	self:StartIntervalThink(1)
end

function item_far_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	AddFOWViewer(parent:GetTeam(), parent:GetOrigin(), 500, 1.0, true)
end

function item_far_modifier:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function item_far_modifier:GetModifierExtraHealthBonus()
	return -50
end

function item_far_modifier:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

-- Set all damage taken to 0
function item_far_modifier:GetModifierIncomingDamage_Percentage()
	return -100
end

function item_far_modifier:OnAttackLanded( params ) -- health handling
	if not IsServer() then
		return
	end

	if params.target == self:GetParent() then
		local damage = 50
		if not params.attacker:IsRealHero() then -- Non Heroes should deal less damage
			damage = 5
		end

		if self:GetParent():GetHealth() > damage then
			self:GetParent():SetHealth( self:GetParent():GetHealth() - damage)
		else
			self:GetParent():Kill(nil, params.attacker)
		end
	end
end

far_vision_giver = class({})

function far_vision_giver:IsHidden() 
	return true
end

function far_vision_giver:OnCreated()
	self:StartIntervalThink(0.1)
end

function far_vision_giver:OnIntervalThink()
	if not IsServer() then
		return
	end
	
	AddFOWViewer(self:GetCaster():GetTeam(), self:GetParent():GetOrigin(), 200, 0.2, true)
end