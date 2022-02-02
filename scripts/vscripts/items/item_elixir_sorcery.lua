item_elixir_sorcery = class({})

-- Modifier Linkers
LinkLuaModifier("item_elixir_sorcery_modifier", "items/item_elixir_sorcery", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_elixir_sorcery:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	-- Remove other elixirs
	local sorcery = caster:FindModifierByName("item_elixir_sorcery_modifier")
	local wrath = caster:FindModifierByName("item_elixir_wrath_modifier")
	local iron = caster:FindModifierByName("item_elixir_iron_modifier")
	if sorcery then
		caster:RemoveModifierByName("item_elixir_sorcery_modifier")
	end
	if wrath then
		caster:RemoveModifierByName("item_elixir_wrath_modifier")
	end	
	if iron then
		caster:RemoveModifierByName("item_elixir_iron_modifier")
	end
	
	-- Add the elixir effect
	caster:AddNewModifier(caster, self, "item_elixir_sorcery_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")

	self:SpendCharge()
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_elixir_sorcery_modifier = class({})

function item_elixir_sorcery_modifier:IsHidden()
	return false
end

function item_elixir_sorcery_modifier:IsPurgable()
	return false
end

function item_elixir_sorcery_modifier:GetTexture()
	return "item_elixir_sorcery"
end

function item_elixir_sorcery_modifier:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function item_elixir_sorcery_modifier:OnCreated()
	self.bonus_ap = self:GetAbility():GetSpecialValueFor("bonus_ap")
	self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.true_damage = self:GetAbility():GetSpecialValueFor("true")

	self.heroids = {-1, -1, -1, -1, -1}
	self.herocools = {0, 0, 0, 0, 0}

	if not IsServer() then
		return
	end

	-- Add Ability Power
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.ap = unique.ap + self.bonus_ap

	self:StartIntervalThink(1)
end

function item_elixir_sorcery_modifier:OnDestroy()
	if not IsServer() then
		return
	end

	-- Subtract Ability Power
	local unique = self:GetParent():FindModifierByName("unique_mechanics")
	unique.ap = unique.ap - self.bonus_ap
end

function item_elixir_sorcery_modifier:DeclareFunctions()
	local funcs = {
    	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
	return funcs
end

-- Bonus Mana Regen
function item_elixir_sorcery_modifier:GetModifierConstantManaRegen() 
	return self.bonus_mana_regen
end

-- Damage on hit
function item_elixir_sorcery_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	for i=1, 5, 1 do
		if self.herocools[i] > 0 then
			self.herocools[i] = self.herocools[i] - 1
		end
	end
end

function item_elixir_sorcery_modifier:OnTakeDamageKillCredit( keys )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local target = keys.target

    if keys.attacker == parent and parent:GetTeam() ~= target:GetTeam() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
    	if target:IsTower() then
    		-- Deal Damage
			local damageTable = {
			  victim = target,
			  attacker = parent,
			  damage = self.true_damage,
			  damage_type = DAMAGE_TYPE_PURE,
			  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			}
			ApplyDamage(damageTable)
		end

		if target:IsHero() then
			local heroid = target:GetHeroID()

			-- Go through each enemy hero
			for i=1, 6, 1 do
				if self.heroids[i] == heroid then
					-- Deal damage if found and has no cooldown
					if self.herocools[i] == 0 then
						-- Deal Damage
						local damageTable = {
						  victim = target,
						  attacker = parent,
						  damage = self.true_damage,
						  damage_type = DAMAGE_TYPE_PURE,
						  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
						}
						ApplyDamage(damageTable)

						self.herocools[i] = 5
					end

					return
				elseif self.heroids[i] == -1 then
					-- Add to the list if not found
					self.heroids[i] = heroid

					-- Deal Damage
					local damageTable = {
					  victim = target,
					  attacker = parent,
					  damage = self.true_damage,
					  damage_type = DAMAGE_TYPE_PURE,
					  damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
					}
					ApplyDamage(damageTable)

					self.herocools[i] = 5

					return
				end
			end
		end
    end
end