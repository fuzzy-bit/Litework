--DEFINE MODULE--
local Table = {}



--PUBLIC FUNCTIONS--
function Table:Shuffle(InputTable)
	local OutputTable = {}

	for Key = #InputTable, 1, -1 do
		local RandomPosition = math.random(1, Key)

		InputTable[Key], InputTable[RandomPosition] = InputTable[RandomPosition], InputTable[Key]
		table.insert(OutputTable, InputTable[Key])
	end

	return OutputTable
end

function Table:DeepCopy(Input)
	local Copy = {}
	
	for Key, Value in pairs(Input) do
		if type(Value) == "table" then
			Copy[Key] = Table:DeepCopy(Value)
		else
			Copy[Key] = Value
		end
	end
	
	return Copy
end

function Table:Reconcile(Target, Template)
	for Key, Value in pairs(Template) do
		if type(Key) == "string" then -- Only string keys will be reconciled
			if Target[Key] == nil then
				if type(Value) == "table" then
					Target[Key] = Table:DeepCopy(Value)
				else
					Target[Key] = Value
				end
			elseif type(Target[Key]) == "table" and type(Value) == "table" then
				Table:Reconcile(Target[Key], Value)
			end
		end
	end
end

function Table:Merge(...)
	local Result = {}
	
	for i, TableToMerge in ipairs({...}) do
		if type(TableToMerge) == "table" then
			for Key, Value in pairs(TableToMerge) do
				Result[Key] = Value
			end
		end
	end
	
	return Result
end



--RETURN MODULE--
return Table