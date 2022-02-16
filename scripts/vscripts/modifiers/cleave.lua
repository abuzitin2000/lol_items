cleave = class ({})

function cleave:IsHidden()
	return true
end

function cleave:IsPurgable()
	return false
end

function cleave:RemoveOnDeath()
	return false
end

function cleave:OnCreated()
	if not IsServer() then
		return
	end

	self.seperate = {}
	self.dot = {}
	self.counter = 4

	self:StartIntervalThink(1)
end

function cleave:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function cleave:OnIntervalThink()
	if not IsServer() then
		return
	end

	self.seperate = {}

	if self.counter < 0 then
		self.dot = {}
		self.counter = 4
	end

	self.counter = self.counter - 1
end

function cleave:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }
    return funcs
end

function cleave:OnTakeDamageKillCredit( event )
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

	-- Check if target is a tower
	if target:IsTower() then
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

	-- Level 1
	if ability:GetAbilityName() == "item_tiamat" then
		-- Check if attack is an auto attack
		if event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
			return
		end
	end

	-- Level 2
	if ability:GetAbilityName() == "item_hydra" then
		-- Count damage over time
		local inflictor = event.inflictor

		-- Don't count auto attacks
		if inflictor then
			for k,v in pairs(self.dot) do
				if k == tostring(target) .. tostring(inflictor) and v == true then
					return
				end
			end

			self.dot[tostring(target) .. tostring(inflictor)] = true
		end
	end

	-- Cleave around target
	local enemies = FindUnitsInRadius(parent:GetTeam(), target:GetOrigin(), parent, 350, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
	for k, enemy in pairs(enemies) do
  		-- Don't deal cleave damage to target
  		if enemy ~= target then
  			local distance = CalcDistanceBetweenEntityOBB(target, enemy)
  			local distance_multiplier = ability:GetSpecialValueFor("cleave_max") - ability:GetSpecialValueFor("cleave_min") * (distance / 87.5)
  			local damage = parent:GetAverageTrueAttackDamage(nil) * (distance_multiplier / 100)

  			-- Level 2
			if ability:GetAbilityName() == "item_hydra" then
				-- Count seperate abilities
				local inflictor = event.inflictor

				-- Don't count auto attacks
				if inflictor then
					for k,v in pairs(self.seperate) do
						if k == enemy and v == inflictor then
							goto continue
						end
					end

					self.seperate[enemy] = inflictor
				end
			end

	  		-- Deal Damage
			local damageTable = {
			  victim = enemy,
			  attacker = parent,
			  damage = damage,
			  damage_type = DAMAGE_TYPE_PHYSICAL,
			  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
			}
			ApplyDamage(damageTable)

			local vfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(vfx, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(vfx, 1, Vector(0, 0, 0))
			ParticleManager:SetParticleControl(vfx, 2, Vector(1, 1, 1))
			ParticleManager:ReleaseParticleIndex(vfx)

			::continue::
		end
	end

	local vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(vfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(vfx)

	EmitSoundOn("DOTA_Item.BattleFury", target)
end