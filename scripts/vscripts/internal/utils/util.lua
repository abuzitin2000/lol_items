
function _G.softRequire(file)
	_G.dummyEnt = dummyEnt or Entities:CreateByClassname("info_target")
	local happy,msg = pcall(require,file)
	if not happy then
		dummyEnt:SetThink(function()
			error(msg,2)
		end)
	end
end

-------------------------- MATH FUNCTIONS -----------------------------

function math.clamp(val,min,max)
	if "number"~=type(val) or "number"~=type(min) or "number"~=type(max) then error("math.clamp:  args #1, #2 #3 must be numbers",2) end
	if min>max then min,max = max,min end
	if val>=max then return max end
	if val<=min then return min end
	return val
end

-------------------------- TABLE FUNCTIONS -----------------------------

function table.compare(table1, table2)
	if "table"~=type(table1) then error("1st argument of table.compare() is not a table",2) end
	if "table"~=type(table2) then error("2nd argument of table.compare() is not a table",2) end

	for k, v1 in pairs(table1) do
		local v2 = table2[k]
		if "table"==type(v1) and "table"==type(v2) then
			if not table.compare(v1,v2) then return false end
		else
			if v1~=v2 then return false end
		end
	end
	for k, _ in pairs(table2) do
		local v1 = table1[k]
		if v1==nil then return false end
	end

	return true
end

_G.TABLE_COMPARE_STRICT = 0
_G.TABLE_COMPARE_IGNORE_KEYS = 1
_G.TABLE_COMPARE_IGNORE_KEYS_AND_DUPLICATES = 2

-- not tested yet. careful.

function table.compare_dev(table1, table2, flags)
	if "table"~=type(table1) then error("1st argument of table.compare() is not a table",2) end
	if "table"~=type(table2) then error("2nd argument of table.compare() is not a table",2) end
	if nil==flags or TABLE_COMPARE_STRICT==flags then
		for k, v1 in pairs(table1) do
			local v2 = table2[k]
			if "table"==type(v1) and "table"==type(v2) then
				if not table.compare(v1,v2) then return false end
			else
				if v1~=v2 then return false end
			end
		end
		for k, _ in pairs(table2) do
			local v1 = table1[k]
			if v1==nil then return false end
		end
	elseif TABLE_COMPARE_IGNORE_KEYS==flags then
		local arr1 = {}
		for _, v1 in pairs(table1) do
			table.insert(arr1,v1)
		end
		-- arr1 is array with all table1 values
		for _, v2 in pairs(table2) do
			--checking every table2 value
			local foundV1 = false
			for k1, v1 in pairs(arr1) do
				if v2==v1
				or "table"==type(v1) and "table"==type(v2) and table.compare(v1,v2, flags)
				then
					-- found the counterpart in arr1
					foundV1 = true
					arr1[k1] = nil
					break
				end
			end
			if not foundV1 then
				-- no arr1 counterpart found
				return false
			end
		end
		for _ in pairs(arr1) do
			--  arr1 value is left with no table2 counterpart
			return false
		end
	elseif TABLE_COMPARE_IGNORE_KEYS_AND_DUPLICATES==flags then
		local values = {}
		local tabValues1 = {}
		for _, v1 in pairs(table1) do
			if "table"==type(v1) then
				-- v1 is a table
				local tableAlreadyListed = false
				for v0 in pairs(tabValues1) do
					if table.compare(v1,v0,flags) then
						tableAlreadyListed = true
						break
					end
				end
				if not tableAlreadyListed then
					tabValues1[v1] = v1
					values[v1] = 1
				end
			else
				-- v1 is a normal value, not table
				values[v1] = 1
			end
		end
		-- so now all table1 values are stored as keys in values	{12 = 1, "1a5" = 1,...}
		-- also tabValues1 contains all different tables 			{table51 = table51, table32 = table32, ...}
		-- for every tabValue1 there is an entry in values 			{..., "1a5" = 1, table51 = 1, ...}
		for k2, v2 in pairs(table2) do
			if "table"==type(v2) then
				local foundV1 = false
				for v1 in pairs(tabValues1) do
					if table.compare(v1,v2,flags) then
						foundV1 = true
						values[v1] = 2
						break
					end
				end
				if not foundV1 then return false end
			else
				-- v2 is a normal value, not table
				if nil==values[v2] then
					-- lonely value2
					return false
				end
				values[v2] = 2
			end
		end
		-- now all 1 inside values should have turned into 2
		-- values[normal values] == 2 now if they appeared in the 2nd table
		-- values[tables] == 2 if there was a similar (sub)table in table2
		for k,v in pairs(values) do
			if 1==v then
				-- lonely value1
				return false
			end
		end
	end
	return true
end


function table.merge(weak, strong)
	if (type(weak) ~= "table") then error("1st argument of table.merge() is not a table",2) end
	if (type(strong) == "table") then
		for k,v in pairs(strong) do
			if type(v)=="table" then
				if (type(weak[k])~="table") then weak[k] = {} end
				table.merge(weak[k],v)
				if next(weak[k])==nil then weak[k] = nil end
			else
				weak[k] = v
			end
		end
	end
	return weak
end

function table.copy(tabel)
	if ("table"~=type(tabel)) then error("Argument of table.copy() is not a table",2) end
	local out = {}
	for k,v in pairs(tabel) do
		out[k]=v
	end
	return out
end

function table.length(t)
	if ("table"~=type(t)) then error("Argument of table.length() is not a table",2) end
	local len = 0
	for _,_ in pairs(t) do
		len = len + 1
	end
	return len
end

function table.contains(t, v)
	if ("table"~=type(t)) then error("1st argument of table.contains() is not a table",2) end
	for _,v2 in pairs(t) do
		if v==v2 then
			return true
		end
	end
	return false
end

-------------------------- FILE COPY FUNCTIONS -------------------------

function copyFile(fromFile, toFile)
	if not io then return false end
	local replacingFile = io.open(toFile, "rb")
	if replacingFile then
		local replacingSize = replacingFile:seek("end")
		replacingFile:close()
	end

	local infile = io.open(fromFile, "rb")
	local fromSize = infile:seek("end")
	if replacingSize==fromSize then infile:close() return false end
	instr = infile:read("*a")
	infile:close()

	local outfile = io.open(toFile, "wb")
	outfile:write(instr)
	outfile:close()
	return true
end

function strToFile(str, filename)
	if not io then return false end
	local file = io.open(filename,"w")
	file:write(str)
	io.close(file)
	return true
end

function kvToFile(kv, filename)
	strToFile(kvToString(kv,""),filename)
end

function fileToString(filename)
	if not io then return nil end
	local file = io.open(filename, "r")
	local out = file:read("*all")
	io.close(file)
	return out
end

function kvToString(kv,prefix)
	local out = ""
	if type(kv)=="table" then
		for k,v in opairs(kv) do
			if type(v)=="table" then
				out = ("%s%s\"%s\"\n%s{\n%s%s}\n"):format(out,prefix,k,prefix,kvToString(v,prefix.."\t"),prefix)
				-- out = out .. prefix .. "\"" .. k .. "\" " .. "\n".. prefix .."{\n" .. kvToString(v,prefix.."\t") .. prefix .. "}\n"
			else
				local val = (type(v)=="string" or type(v)=="number") and v or "ERR"
				out = ("%s%s\"%-32s \"%s\"\n"):format(out,prefix,(k .. "\""),val)
			end
		end
	end
	return out
end

function fileToTable(filename)
	return fixParsedTable(LoadKeyValues(filename))
end

function fixParsedTable( tabl )
	if "table"~=type(tabl) then return tabl end
	for k,v in pairs(tabl) do
		if "number"==type(v) then
			tabl[k] = 0.001 * math.floor(v*1000+0.5)
		else tabl[k] = fixParsedTable(tabl[k]) end
	end
	return tabl
end

function globalsToString()
	local out = ""
	for k,v in pairs(_G) do
		if type(v)=="function" then v = "f()" end
		if type(v)=="table" then v = "{}" end
		if type(v)=="userdata" then v = "udat" end
		if type(v)=="boolean" then v = V and "true" or "false" end
		out = out .. k .. ": " .. v .. "\n"
	end
	return out
end

-------------------------- BAREBONES STUFF -------------------------

function DebugPrint(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		print(...)
	end
end

function DebugPrintTable(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		PrintTable(...)
	end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]

			if type(value) == "table" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..":")
				PrintTable (value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


--[[Author: Noya
	Date: 09.08.2015.
	Hides all dem hats
	]]
	function HideWearables( event )
		local hero = event.caster
		local ability = event.ability

		hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
		local model = hero:FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() == "dota_item_wearable" then
				model:AddEffects(EF_NODRAW) -- Set model hidden
				table.insert(hero.hiddenWearables, model)
			end
			model = model:NextMovePeer()
		end
	end

	function ShowWearables( event )
		local hero = event.caster

		for i,v in pairs(hero.hiddenWearables) do
			v:RemoveEffects(EF_NODRAW)
		end
	end
	
function opairs(t)
	function orderedNext(t, state)
		function __genOrderedIndex( t )
		    local orderedIndex = {}
		    for key in pairs(t) do
		        table.insert( orderedIndex, key )
		    end
		    table.sort( orderedIndex )
		    return orderedIndex
		end

	    -- Equivalent of the next function, but returns the keys in the alphabetic
	    -- order. We use a temporary ordered key table that is stored in the
	    -- table being iterated.

	    local key = nil
	    --print("orderedNext: state = "..tostring(state) )
	    if state == nil then
	        -- the first time, generate the index
	        t.__orderedIndex = __genOrderedIndex( t )
	        key = t.__orderedIndex[1]
	    else
	        -- fetch the next value
	        for i = 1,table.getn(t.__orderedIndex) do
	            if t.__orderedIndex[i] == state then
	                key = t.__orderedIndex[i+1]
	            end
	        end
	    end

	    if key then
	        return key, t[key]
	    end

	    -- no more value to return, cleanup
	    t.__orderedIndex = nil
	    return
	end
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function RollPseudoRandom(base_chance, entity)
	local chances_table = {
		{1, 0.015604},
		{2, 0.062009},
		{3, 0.138618},
		{4, 0.244856},
		{5, 0.380166},
		{6, 0.544011},
		{7, 0.735871},
		{8, 0.955242},
		{9, 1.201637},
		{10, 1.474584},
		{11, 1.773627},
		{12, 2.098323},
		{13, 2.448241},
		{14, 2.822965},
		{15, 3.222091},
		{16, 3.645227},
		{17, 4.091991},
		{18, 4.562014},
		{19, 5.054934},
		{20, 5.570404},
		{21, 6.108083},
		{22, 6.667640},
		{23, 7.248754},
		{24, 7.851112},
		{25, 8.474409},
		{26, 9.118346},
		{27, 9.782638},
		{28, 10.467023},
		{29, 11.171176},
		{30, 11.894919},
		{31, 12.637932},
		{32, 13.400086},
		{33, 14.180520},
		{34, 14.981009},
		{35, 15.798310},
		{36, 16.632878},
		{37, 17.490924},
		{38, 18.362465},
		{39, 19.248596},
		{40, 20.154741},
		{41, 21.092003},
		{42, 22.036458},
		{43, 22.989868},
		{44, 23.954015},
		{45, 24.930700},
		{46, 25.987235},
		{47, 27.045294},
		{48, 28.100764},
		{49, 29.155227},
		{50, 30.210303},
		{51, 31.267664},
		{52, 32.329055},
		{53, 33.411996},
		{54, 34.736999},
		{55, 36.039785},
		{56, 37.321683},
		{57, 38.583961},
		{58, 39.827833},
		{59, 41.054464},
		{60, 42.264973},
		{61, 43.460445},
		{62, 44.641928},
		{63, 45.810444},
		{64, 46.966991},
		{65, 48.112548},
		{66, 49.248078},
		{67, 50.746269},
		{68, 52.941176},
		{69, 55.072464},
		{70, 57.142857},
		{71, 59.154930},
		{72, 61.111111},
		{73, 63.013699},
		{74, 64.864865},
		{75, 66.666667},
		{76, 68.421053},
		{77, 70.129870},
		{78, 71.794872},
		{79, 73.417722},
		{80, 75.000000},
		{81, 76.543210},
		{82, 78.048780},
		{83, 79.518072},
		{84, 80.952381},
		{85, 82.352941},
		{86, 83.720930},
		{87, 85.057471},
		{88, 86.363636},
		{89, 87.640449},
		{90, 88.888889},
		{91, 90.109890},
		{92, 91.304348},
		{93, 92.473118},
		{94, 93.617021},
		{95, 94.736842},
		{96, 95.833333},
		{97, 96.907216},
		{98, 97.959184},
		{99, 98.989899},	
		{100, 100}
	}

	entity.pseudoRandomModifier = entity.pseudoRandomModifier or 0
	local prngBase
	for i = 1, #chances_table do
		if base_chance == chances_table[i][1] then		  
			prngBase = chances_table[i][2]
		end	 
	end

	if not prngBase then
--		print("The chance was not found! Make sure to add it to the table or change the value.")
		return false
	end
	
	if RollPercentage( prngBase + entity.pseudoRandomModifier ) then
		entity.pseudoRandomModifier = 0
		return true
	else
		entity.pseudoRandomModifier = entity.pseudoRandomModifier + prngBase		
		return false
	end
end

function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function ItemFixer(hero, modifierName, itemName)
	hero:AddNewModifier(hero, nil, "item_fixer", {
		hero = hero:entindex(),
		modifierName = modifierName,
		itemName = itemName
	})
end
