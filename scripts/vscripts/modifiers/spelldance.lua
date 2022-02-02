spelldance = class({})

-- Modifier Linkers
LinkLuaModifier("spelldance_buff", "modifiers/spelldance", LUA_MODIFIER_MOTION_NONE)

function spelldance:IsHidden()
	return true
end

function spelldance:IsPurgable()
	return false
end

function spelldance:RemoveOnDeath()
	return false
end

function spelldance:OnCreated()
	if not IsServer() then
		return
	end

	self.timer = 0
	self.count = 0
	self.seperate = {}

	self:StartIntervalThink(1)
end

function spelldance:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function spelldance:OnIntervalThink()
	if not IsServer() then
		return
	end

	if self.timer > 0 then
		self.timer = self.timer - 1
	else
		self.count = 0
		self.seperate = {}
	end
end

function spelldance:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function spelldance:OnTakeDamageKillCredit( event )
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

	-- Check if target is a hero
	if not target:IsHero() then
		return
	end

	-- Don't work when denying
	if parent:GetTeam() == target:GetTeam() then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
    
	-- Don't count if already proc'd
	if parent:HasModifier("spelldance_buff") then
		return
	end

	self.timer = ability:GetSpecialValueFor("spelldance_stack")

	-- Count seperate attacks
	local inflictor = event.inflictor
	if inflictor == nil then
		inflictor = "auto_attack"
	end

	for k,v in pairs(self.seperate) do
		if v == true and k == inflictor then
			return
		end
	end

	self.seperate[inflictor] = true

	if self.count < ability:GetSpecialValueFor("spelldance_stack") - 1 then
		self.count = self.count + 1

		return
	end

	self.timer = 0
	self.count = 0

	parent:AddNewModifier(parent, ability, "spelldance_buff", {})

	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)

	EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", parent)
end

spelldance_buff = class({})

function spelldance_buff:IsHidden()
	return false
end

function spelldance_buff:IsPurgable()
	return false
end

function spelldance_buff:RemoveOnDeath()
	return false
end

function spelldance_buff:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + ability:GetSpecialValueFor("spelldance_ap")

	self.timer = 5

	self:StartIntervalThink(1)
end

function spelldance_buff:OnDestroy()
	if not IsServer() then
		return
	end
	
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end

	local unique = parent:FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - ability:GetSpecialValueFor("spelldance_ap")
end

function spelldance_buff:OnIntervalThink()
	if not IsServer() then
		return
	end

	if self.timer > 0 then
		self.timer = self.timer - 1
	end

	if self.timer <= 0 then
		self:Destroy()
	end
end

function spelldance_buff:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
	return funcs
end

function spelldance_buff:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end
	
	local time = self:GetElapsedTime()

	if time < 2 then
		return ability:GetSpecialValueFor("spelldance_speed") + (time / 2) * (ability:GetSpecialValueFor("spelldance_decay") - ability:GetSpecialValueFor("spelldance_speed"))
	end

	return ability:GetSpecialValueFor("spelldance_decay")
end

function spelldance_buff:OnTakeDamageKillCredit( event )
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

	-- Check if attacker or target is parent
	if attacker ~= parent and target ~= parent then
		return
	end
    
	self.timer = 5
end