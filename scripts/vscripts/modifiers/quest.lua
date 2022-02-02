quest = class ({})

function quest:IsHidden()
	local parent = self:GetParent()
	
	if parent:HasItemInInventory("item_true_ice") or parent:HasItemInInventory("item_black_mist") or parent:HasItemInInventory("item_whiterock") or parent:HasItemInInventory("item_bulwark") then
		return true
	end

	if self:GetStackCount() >= 1000 then
		return true
	end

	return false
end

function quest:IsPurgable()
	return false
end

function quest:IsPermanent()
	return true
end

function quest:RemoveOnDeath()
	return false
end

function quest:GetTexture()
	return "item_quest"
end

function quest:OnCreated()
	if not IsServer() then
		return
	end

	self:StartIntervalThink(1)
end

function quest:OnIntervalThink()
	if not IsServer() then
		return
	end

	local parent = self:GetParent()

	if self:GetStackCount() >= 500 then
		local item = parent:FindItemInInventory("item_spellthief")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_frostfang")
		end

		item = parent:FindItemInInventory("item_spectral")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_harrow")
		end

		item = parent:FindItemInInventory("item_shoulder")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_runesteel")
		end

		item = parent:FindItemInInventory("item_relicshield")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_targon")
		end
	end

	if self:GetStackCount() >= 1000 then
		local item = parent:FindItemInInventory("item_frostfang")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_true_ice")
		end

		item = parent:FindItemInInventory("item_harrow")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_black_mist")
		end

		item = parent:FindItemInInventory("item_runesteel")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_whiterock")
		end

		item = parent:FindItemInInventory("item_targon")
		if item then
			parent:RemoveItem(item)
			parent:AddItemByName("item_bulwark")
		end
	end
end