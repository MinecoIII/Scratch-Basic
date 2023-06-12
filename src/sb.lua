--!nonstrict

local SB = {}
local QC = require("qc")
local stringify = require("stringify")

--

local PARAMS = {
	MaxParameters = 15
}

local TYPES = {
	["nil"] = "nil";
	number = "number";
	["string"] = "string";
}

--

local memory = {
	var = {
	
	};
	func = {
		
	};
}

local func = nil
local returnTable = {
	triggered = false;
	endSkip = 0;
	value = nil;
}

local endTriggers = {
	"if", "function", "unless"
}

local FUNCTIONTYPES = {
	["if"] = "if";
	["unless"] = "unless";
	["normal"] = "normal"
}
--

local FunctionBehaviour = {}
local Commands = {}

--

function FunctionBehaviour.__if(name, args)
	local a, b = memory:GetVariable(args[1]), memory:GetVariable(args[2])
	
	if a == b then
		Commands.run(nil, name)
	end
end

function FunctionBehaviour.__unless(name, args)
	local a, b = memory:GetVariable(args[1]), memory:GetVariable(args[2])

	if a ~= b then
		Commands.run(nil, name)
	end
end

--

function SB:ObjectifyString(var)
	if tonumber(var) then
		var = tonumber(var)
	end

	if var == "nil" then
		var = nil
	end

	if var == "true" then
		var = true
	elseif var == "false" then
		var = false
	end

	return var, type(var)
end

function SB:IsType(var, TYPE, INDEX)
	local CURRENTTYPE = type(var)
	
	if CURRENTTYPE == TYPE then
		return true
	else
		QC:Error("Expected "..TYPE.." got "..CURRENTTYPE.." at line "..(INDEX or "(NO LINE GIVEN)"))
		
		return false
	end
end

--

function memory:GetVariable(NAME)
	local var = memory.var[NAME]
	
	if var == nil then
		if NAME == "time" then
			var = os.time()
			
		elseif NAME == "clock" then
			var = os.clock()
		end
	end
	
	var = SB:ObjectifyString(var)
	
	return var
end

function memory:GetFunction(NAME)
	local f = memory.func[NAME]
	
	return f
end

function memory:SaveFunction()
	
	if func == nil then return end
	
	local name = func.name
	local TYPE = func["type"]
	local args = func.args
	
	memory.func[func.name] = {
		code = func.code
	}
	
	func = nil
	
	local BEHAVIOUR = FunctionBehaviour["__"..TYPE]
	
	if BEHAVIOUR ~= nil then
		local t = {BEHAVIOUR}
		
		t[1](name, args)
	end
end

function memory:CreateFunction(Name, Type, Args)
	func = {
		name = Name;
		endSkip = 0;
		code = "";
		["type"] = Type or "normal";
		args = Args;
	}
end

--

Commands["function"] = function (INDEX, a, ...)
	local args = {...}
	
	memory:CreateFunction(a, nil, args)
end

function Commands.run(INDEX, b, a, ...)
	local args = {...}
	
	for i, v in pairs(args) do
		args[i] = memory:GetVariable(v)
	end
	
	local localfunc = memory:GetFunction(a)
	
	for i, v in pairs(localfunc.args) do
		memory[v] = args[i]
	end
	
	if localfunc ~= nil then
		SB:Run(localfunc.code)
	end
	
	memory[b] = returnTable.value
end

function Commands.require(INDEX, a, b)
	
end

function Commands.unless(INDEX, a, b) -- no special syntax
	memory:CreateFunction(math.random() .. "_UNLESS_STATEMENT", FUNCTIONTYPES["unless"], {a, b})
end

Commands["if"] = function (INDEX, a, b) -- special syntax since i cant put if as the function na,e
	memory:CreateFunction(math.random() .. "_IF_STATEMENT", FUNCTIONTYPES["if"], {a, b})
end

Commands["return"] = function (INDEX, a, b, c, d, e, f, g)
    local t = {a,b,c,d,e,f,g}
    
	returnTable.triggered = true
	returnTable.endSkip = 0
	returnTable.value = table.concat(t, " ") or "nil"
end

function Commands.print(INDEX, a, b, c, d, e,f ,g)
	local r = ""
	
	local t = {a,b,c,d,e,f,g}
	
	for i, v in pairs(t) do
		t[i] = tostring(memory:GetVariable(v) or v)
	end

	local var = table.concat(t, " ")
	
	QC:Print(var)
end

function Commands.var(INDEX, a, b, c, d, e, f, g, h)
	memory.var[a] = table.concat({b,c,d,e,f,g, h}, " ") or "nil"
	
	return memory.var[a]
end

function Commands.wait(INDEX, a)
	__love.timer.sleep(a or 0.001)
end

function Commands.add(INDEX, a, b, c)
	b = memory:GetVariable(b)
	c = memory:GetVariable(c)
	
	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end
	
	memory.var[a] = (b + c)
	
	return memory.var[a]
end

function Commands.pow(INDEX, a, b, c)
	b = memory:GetVariable(b)
	c = memory:GetVariable(c)

	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end

	memory.var[a] = (b ^ c)

	return memory.var[a]
end

function Commands.sub(INDEX, a, b, c)
	b = memory:GetVariable(a)
	c = memory:GetVariable(b)

	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end

	memory.var[a] = (b - c)

	return memory.var[a]
end

function Commands.mul(INDEX, a, b, c)
	b = memory:GetVariable(a)
	c = memory:GetVariable(b)

	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end

	memory.var[a] = (b * c)

	return memory.var[a]
end

function Commands.div(INDEX, a, b, c)
	b = memory:GetVariable(a)
	c = memory:GetVariable(b)

	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end

	memory.var[a] = (b / c)

	return memory.var[a]
end

function Commands.mod(INDEX, a, b, c)
	b = memory:GetVariable(a)
	c = memory:GetVariable(b)

	if SB:IsType(b, TYPES.number, INDEX) == false then return end
	if SB:IsType(c, TYPES.number, INDEX) == false then return end

	memory.var[a] = (b % c)

	return memory.var[a]
end

--

function SB:initRunLine()
	
end

function SB:HandleEnd(Command, endSkip)
	local n = 0
	
	for i, v in pairs(endTriggers) do
		if Command == v then

			n = n + 1
		end
	end

	if Command == "end" then
		if endSkip <= 0 then			
			return n, true
		else
			n = n - 1
		end
	end
	
	return n, false
end

function SB:RegisterLine(Line, Command, INDEX)
	if returnTable.triggered == true then
		local number, finished = SB:HandleEnd(Command, returnTable.endSkip)
		
		returnTable.endSkip = returnTable.endSkip + number
		
		if finished == true then
			returnTable.triggered = false
			
			return false 
		end
		
		return false
		
	elseif func ~= nil then
		local number, finished = SB:HandleEnd(Command, func.endSkip)

		func.endSkip = func.endSkip + number

		if finished == true then
			memory:SaveFunction()

			return false 
		end
		
		func.code = func.code .. Line .. "\n"

		return false
	else
		return true
	end
end

function SB:RunLine(Line, INDEX)
	SB:initRunLine()
	
	local Words = stringify.split(Line, " ")
	
	if #Words == 0 then return end
	
	for i, Word in pairs(Words) do
		if Word == "" then
			table.remove(Words, i)
		end
	end
	
	local Command = Words[1]
	local FUNCTION = Commands[tostring(Command):lower()]
	
	if FUNCTION ~= nil or (Command == "end") then
		local shouldExecute = SB:RegisterLine(Line, Command, INDEX)
		
		if shouldExecute == true and (Command ~= "end") then
			local t = {FUNCTION}

			t[1](INDEX, Words[2], Words[3], Words[4], Words[5], Words[6], Words[7], Words[8], Words[9], Words[10]) -- run the function
		else
			
		end
	else
		Line = Line:gsub("%s", "")
		
		if Line ~= "" then
			if Command ~= "end" then
				
				print(Command, Words)
				QC:Warn("UNKNOWN COMMAND AT LINE " .. (INDEX or "NO INDEX GIVEN"))
			end
		end
	end
	
	return
end

function SB:Run(Code)
	if Code == nil then QC:Error("Code is nothing") return end
	
	local Lines = stringify.split(Code, "\n")
	
	for INDEX, Line in pairs(Lines) do
		Line = Line:gsub("[%s]+", " "):gsub("\t", "") -- remove extra spaces and tabs
		
		SB:RunLine(Line, INDEX)
	end
	
	return
end

return SB
