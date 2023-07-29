--DEFINE MODULE--
local Table = {}



--PUBLIC FUNCTIONS--
function Table.Shuffle(Input)
	local Output = {}

	for Key = #Input, 1, -1 do
		local RandomPosition = math.random(1, Key)

		Input[Key], Input[RandomPosition] = Input[RandomPosition], Input[Key]
		table.insert(Output, Input[Key])
	end

	return Output
end

function Table.DeepCopy(Input)
	local Output = {}

	for Key, Value in pairs(Input) do
		if type(Value) == "table" then
			Output[Key] = Table.DeepCopy(Value)
		else
			Output[Key] = Value
		end
	end

	return Output
end

function Table.Reverse(Input)
	local Output = {}

	for Key = #Input, 1, -1 do
		Output[#Input - Key + 1] = Input[Key]
	end

	return Output
end

function Table.Reconcile(Target, Template)
	for Key, Value in pairs(Template) do
		if type(Key) == "string" then -- Only string keys will be reconciled
			if Target[Key] == nil then
				if type(Value) == "table" then
					Target[Key] = Table.DeepCopy(Value)
				else
					Target[Key] = Value
				end
			elseif type(Target[Key]) == "table" and type(Value) == "table" then
				Table.Reconcile(Target[Key], Value)
			end
		end
	end
end

function Table.Merge(...)
	local Output = {}

	for i, TableToMerge in ipairs({...}) do
		if type(TableToMerge) == "table" then
			for Key, Value in pairs(TableToMerge) do
				Output[Key] = Value
			end
		end
	end

	return Output
end

function Table.MergeDictionaries(...)
	local Output = {}

	for i, Dictionary in pairs({...}) do
		for Index, Value in pairs(Dictionary) do
			Output[Index] = Value
		end
	end

	return Output
end



--RETURN MODULE--
return Table