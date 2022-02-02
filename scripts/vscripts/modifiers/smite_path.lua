smite_path = class ({})

function smite_path:IsHidden()
	return true
end

function smite_path:IsPurgable()
	return false
end

function smite_path:IsPermanent()
	return true
end

function smite_path:RemoveOnDeath()
	return false
end