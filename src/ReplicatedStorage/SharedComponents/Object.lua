--DEFINE MODULE--
local Object = {}



--PUBLIC FUNCTIONS--
function Object.new(InstanceName: string, Parent: Instance, Properties: {}?)
	local Object = Instance.new(InstanceName, Parent)

	for Property, Value in pairs(Properties) do
		Object[Property] = Value
	end
end



--RETURN MODULE--
return Object