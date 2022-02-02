spoils = class ({})

-- Modifier Linkers
LinkLuaModifier("quest", "modifiers/quest", LUA_MODIFIER_MOTION_NONE)

function spoils:IsHidden()
	return false
end

function spoils:IsPurgable()
	return false
end

function spoils:RemoveOnDeath()
	return false
end

function spoils:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "quest", {})

	self:StartIntervalThink(ability:GetSpecialValueFor("duration"))
end

function spoils:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function spoils:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return
	end
	
	if self:GetStackCount() < ability:GetSpecialValueFor("max_stack") then
		self:IncrementStackCount()
	end

	-- Set Item Stack
	--local item = parent:FindItemInInventory("item_shoulder") or parent:FindItemInInventory("item_relicshield")
	--item:SetCurrentCharges(self:GetStackCount())
end

function spoils:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
    	MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function spoils:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local attacker = event.attacker
	local target = event.target
	local mod = parent:FindModifierByName("quest")

	if not ability then
		return
	end

	if attacker == parent and target:IsAlive() and attacker:GetTeam() ~= target:GetTeam() and self:GetStackCount() > 0 and (target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege") then
		-- Check if near an ally
		local allies = FindUnitsInRadius(parent:GetTeam(), parent:GetOrigin(), parent, 1050, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		if table.getn(allies) > 1 then
			if (parent:IsRangedAttacker() and target:GetHealthPercent() < ability:GetSpecialValueFor("range")) or ((not parent:IsRangedAttacker()) and target:GetHealthPercent() < ability:GetSpecialValueFor("melee")) then
				-- Give gold
				allies[2]:ModifyGold(target:GetGoldBounty(), false, DOTA_ModifyGold_CreepKill)
				self:DecrementStackCount()
				PopupGoldGain(allies[2], target:GetGoldBounty())

				-- Launch a creep soul to the ally
				local soul_projectile = {
					Target = allies[2],
				 	Source = target,
				 	Ability = event.ability,
					EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					iMoveSpeed = 1000,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile(soul_projectile)

				target:EmitSound("UI.Deny.Ranged")
				target:EmitSound("UI.Deny.Melee")
				target:Kill(event.ability, parent)

				-- Quest
				mod:SetStackCount(mod:GetStackCount() + target:GetGoldBounty())
				if mod:GetStackCount() > ability:GetSpecialValueFor("max_gold") then
					mod:SetStackCount(ability:GetSpecialValueFor("max_gold"))
				end
			
				-- Set Item Stack
				--local item = parent:FindItemInInventory("item_shoulder") or parent:FindItemInInventory("item_relicshield")
				--item:SetCurrentCharges(self:GetStackCount())
			end
		end
	end
end

-- Reduce last hit gold when over farmed
function spoils:OnDeath( event )
	if IsServer() then
		return
	end

	local parent = self:GetParent()
	local attacker = event.attacker
	local target = event.unit

	if target:GetUnitName() == "npc_dota_creep_goodguys_melee" or target:GetUnitName() == "npc_dota_creep_goodguys_ranged" or target:GetUnitName() == "npc_dota_creep_badguys_melee" or target:GetUnitName() == "npc_dota_creep_badguys_ranged" or target:GetUnitName() == "npc_dota_goodguys_siege" or target:GetUnitName() == "npc_dota_badguys_siege" then
		if parent == attacker and parent:GetTeam() ~= target:GetTeam() and parent:GetLastHits() > 20 * GameRules:GetDOTATime(false, false) / 300 then
			local per = 0.5 + (parent:GetLastHits() * 0.01)
			if per > 0.8 then
				parent:ModifyGold(-1 * target:GetGoldBounty() * 0.8, true, DOTA_ModifyGold_CreepKill)
			else
				parent:ModifyGold(-1 * target:GetGoldBounty() * per, true, DOTA_ModifyGold_CreepKill)
			end
		end
	end
end