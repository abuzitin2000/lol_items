mana_charge = class ({})

-- Modifier Linkers
LinkLuaModifier("mana_chargestack", "modifiers/mana_charge", LUA_MODIFIER_MOTION_NONE)

function mana_charge:IsHidden()
	return false
end

function mana_charge:IsPurgable()
	return false
end

function mana_charge:RemoveOnDeath()
	return false
end

function mana_charge:OnCreated()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	parent:AddNewModifier(parent, ability, "mana_chargestack", {})

	self:StartIntervalThink(8)
end

function mana_charge:OnDestroy()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	-- Fix for selling items that you have a duplicate of
	ItemFixer(parent, self:GetName(), ability:GetAbilityName())
end

function mana_charge:OnIntervalThink()
	if not IsServer() then
		return
	end
	
	if self:GetStackCount() < 4 then
		self:IncrementStackCount()
	end
end

function mana_charge:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MANA_BONUS,
    	MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
    }
    return funcs
end

function mana_charge:GetModifierManaBonus()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability then
		return 0
	end

	return parent:GetModifierStackCount("mana_chargestack", parent)
end

function mana_charge:OnTakeDamageKillCredit( event )
	if not IsServer() then
		return
	end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local attacker = event.attacker
	local target = event.target
	local mod = parent:FindModifierByName("mana_chargestack")

	if not ability then
		return
	end

	-- Check damage type
	if event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not (ability:GetAbilityName() == "item_winter" or ability:GetAbilityName() == "item_manamune") then
		return
	end

	-- Check if attacker is parent and target is alive
	if attacker ~= parent or not target:IsAlive() then
		return
	end

	-- Check if ready
	if self:GetStackCount() <= 0 then
		return
	end

	-- Stops infinite loops
	if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end

	-- Increase stack
	if target:IsHero() then
		mod:SetStackCount(mod:GetStackCount() + ability:GetSpecialValueFor("proc_mana") * 2)
	else
		mod:SetStackCount(mod:GetStackCount() + ability:GetSpecialValueFor("proc_mana"))
	end

	-- Effect
	if mod:GetStackCount() > ability:GetSpecialValueFor("proc_max") then
		mod:SetStackCount(ability:GetSpecialValueFor("proc_max"))
	else
		local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControl(manaburn_pfx, 0, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(manaburn_pfx)
	end

	-- Set Item Stack
	local item = parent:FindItemInInventory("item_manamune") or parent:FindItemInInventory("item_winter") or parent:FindItemInInventory("item_archangel") or parent:FindItemInInventory("item_tear")
	item:SetCurrentCharges(mod:GetStackCount())
	self:DecrementStackCount()
end

mana_chargestack = class ({})

function mana_chargestack:IsHidden()
	return true
end

function mana_chargestack:IsPurgable()
	return false
end

function mana_chargestack:IsPermanent()
	return true
end

function mana_chargestack:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(1)
end

function mana_chargestack:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	-- Transform only when above threshold
	if self:GetStackCount() < 360 then
		return
	end

	local item = parent:FindItemInInventory("item_manamune") or parent:FindItemInInventory("item_winter") or parent:FindItemInInventory("item_archangel") or parent:FindItemInInventory("item_tear")
	
	if item then
		if item:GetAbilityName() == "item_archangel" then
			parent:RemoveItem(item)
			parent:AddItemByName("item_seraph")
		elseif item:GetAbilityName() == "item_winter" then
			parent:RemoveItem(item)
			parent:AddItemByName("item_fimbul")
		elseif item:GetAbilityName() == "item_manamune" then
			parent:RemoveItem(item)
			parent:AddItemByName("item_muramana")
		end
	end
end