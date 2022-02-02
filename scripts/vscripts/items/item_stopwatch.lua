item_stopwatch = class({})

-- Modifier Linkers
LinkLuaModifier("item_stopwatch_modifier", "items/item_stopwatch", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_stopwatch_broken_modifier", "items/item_stopwatch", LUA_MODIFIER_MOTION_NONE)

-- Ability
function item_stopwatch:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, self, "item_stopwatch_modifier", { duration = duration })
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")

	if IsServer() then
		caster:RemoveItem(caster:FindItemInInventory("item_stopwatch"))
		caster:AddItemByName("item_broken_stopwatch")
		caster:AddNewModifier(caster, self, "item_stopwatch_broken_modifier", {})
	end
end

-- Modifier
-------------------------------------------------------------------------------------------------------------
item_stopwatch_modifier = class({})

function item_stopwatch_modifier:IsHidden()
	return false
end

function item_stopwatch_modifier:IsPurgable()
	return false
end

function item_stopwatch_modifier:GetTexture()
	return "item_stopwatch"
end

function item_stopwatch_modifier:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function item_stopwatch_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true
	}
	return state
end

item_stopwatch_broken_modifier = class ({})

function item_stopwatch_broken_modifier:IsHidden()
	return true
end

function item_stopwatch_broken_modifier:IsPurgable()
	return false
end

function item_stopwatch_broken_modifier:IsPermanent()
	return true
end