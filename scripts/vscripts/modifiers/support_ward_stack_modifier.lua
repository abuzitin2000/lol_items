support_ward_stack_modifier = class({})

-- Modifier Linkers
LinkLuaModifier("support_ward_modifier", "modifiers/support_ward_stack_modifier", LUA_MODIFIER_MOTION_NONE)

function support_ward_stack_modifier:IsHidden()
	return true
end

function support_ward_stack_modifier:IsPurgable()
	return false
end

function support_ward_stack_modifier:IsPermanent()
	return true
end

function support_ward_stack_modifier:RemoveOnDeath()
	return false
end

function support_ward_stack_modifier:OnCreated()
	if not IsServer() then
		return
	end

	self.charge = 1
	self.ward_count = 0
	self.wards = {0, 0, 0, 0}

	local mod = self:GetParent():FindModifierByName("item_sward_modifier")
	if mod then
		self.wards[0] = mod.wards[0]
		self.wards[1] = mod.wards[1]
		self.wards[2] = mod.wards[2]
		self.wards[3] = mod.wards[3]
		self.ward_count = mod.ward_count
	end

	self:StartIntervalThink(1)
end

function support_ward_stack_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:FindModifierByName("modifier_fountain_aura_buff") then
		if ability then
			self.charge = ability:GetSpecialValueFor("ward_stack")
		end
	end

	-- Set Item Stacks
	local item = parent:FindItemInInventory("item_true_ice") or parent:FindItemInInventory("item_black_mist") or parent:FindItemInInventory("item_whiterock") or parent:FindItemInInventory("item_bulwark") or parent:FindItemInInventory("item_frostfang") or parent:FindItemInInventory("item_harrow") or parent:FindItemInInventory("item_runesteel") or parent:FindItemInInventory("item_targon")
	if item then
		item:SetCurrentCharges(self.charge)
	end
end

support_ward_modifier = class ({})

function support_ward_modifier:IsHidden()
	return false
end

function support_ward_modifier:IsPurgable()
	return false
end

function support_ward_modifier:GetTexture()
	return "item_sward"
end

function support_ward_modifier:OnCreated( event )
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("support_ward_stack_modifier")
	local ward_mod = caster:FindModifierByName("item_sward_modifier")

	-- Check if ward limit is reached
	local limit = 2
	if caster:HasModifier("behold") then
		limit = 3
	end

	if mod.ward_count > limit then
		mod.wards[0]:ForceKill(false)
	end
	mod.wards[mod.ward_count] = self:GetParent()
	mod.ward_count = mod.ward_count + 1
	
	if ward_mod then
		ward_mod.wards[0] = mod.wards[0]
		ward_mod.wards[1] = mod.wards[1]
		ward_mod.wards[2] = mod.wards[2]
		ward_mod.wards[3] = mod.wards[3]
		ward_mod.ward_count = mod.ward_count
	end

	self:StartIntervalThink(0.1)
end

function support_ward_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	local caster = self:GetCaster()
	local mod = caster:FindModifierByName("support_ward_stack_modifier")
	local ward_mod = caster:FindModifierByName("item_sward_modifier")

	if mod then
		for i=0, 4, 1 do
  			if mod.wards[i] == self:GetParent() then
  				if i == 0 then
  					mod.wards[0] = mod.wards[1]
  					mod.wards[1] = mod.wards[2]
  					mod.wards[2] = mod.wards[3]
  					mod.wards[3] = 0
  				elseif i == 1 then
  					mod.wards[1] = mod.wards[2]
  					mod.wards[2] = mod.wards[3]
  					mod.wards[3] = 0
  				elseif i == 2 then
  					mod.wards[2] = mod.wards[3]
  					mod.wards[3] = 0
  				elseif i == 3 then
  					mod.wards[3] = 0
  				end
  				mod.ward_count = mod.ward_count - 1
  			end
		end
	end

	if ward_mod then
		ward_mod.wards[0] = mod.wards[0]
		ward_mod.wards[1] = mod.wards[1]
		ward_mod.wards[2] = mod.wards[2]
		ward_mod.wards[3] = mod.wards[3]
		ward_mod.ward_count = mod.ward_count
	end
end

function support_ward_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	if not parent:HasModifier("modifier_truesight") then
		AddFOWViewer(parent:GetTeam(), parent:GetOrigin(), 900, 0.2, true)
	end
end

function support_ward_modifier:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_FIXED_DAY_VISION,
    	MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
    	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function support_ward_modifier:GetFixedDayVision()
	return 1
end

function support_ward_modifier:GetFixedNightVision()
	return 1
end

function support_ward_modifier:GetModifierExtraHealthBonus()
	return 50
end

function support_ward_modifier:CheckState()
	local b = false
	if self:GetElapsedTime() > 1 then
		b = true
	end
	local state = {

		[MODIFIER_STATE_INVISIBLE] = b,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end

-- Set all damage taken to 0
function support_ward_modifier:GetModifierIncomingDamage_Percentage()
	return -100
end

function support_ward_modifier:OnAttackLanded( params ) -- health handling
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