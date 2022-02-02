item_oracle = class({})

-- Modifier Linkers
LinkLuaModifier("item_oracle_modifier", "items/item_oracle", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_oracle:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "item_oracle_modifier", { duration = self:GetSpecialValueFor("duration") })

	-- Set item cooldown
	local item = caster:FindItemInInventory("item_oracle")
	local heroes = HeroList:GetAllHeroes()
	local totalLevel = 0
	local count = 0
	for h,hero in pairs(heroes) do
		totalLevel = totalLevel + hero:GetLevel()
		count = count + 1
	end
	item:StartCooldown(90 - 30 / 17 * (totalLevel / count - 1))

	caster:EmitSound("DOTA_Item.ClarityPotion.Activate")
end

-- Modifiers
-------------------------------------------------------------------------------------------------------------
item_oracle_modifier = class({})

function item_oracle_modifier:IsHidden()
	return false
end

function item_oracle_modifier:IsPurgable()
	return false
end

function item_oracle_modifier:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function item_oracle_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


function item_oracle_modifier:OnCreated()
	self:StartIntervalThink(0.1)
end

function item_oracle_modifier:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	AddFOWViewer(parent:GetTeam(), parent:GetOrigin(), 750, 1.0, false)

	-- Give True Sight around the hero
	local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 750, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, true)
	for _,enemy in ipairs(enemies) do
		enemy:AddNewModifier(parent, ability, "modifier_truesight", {
		duration = 1.0
	})
	end
end