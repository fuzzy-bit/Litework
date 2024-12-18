--DEFINE MODULE--
local Object = {}



--PUBLIC FUNCTIONS--
function Object.new(InstanceName: string, Properties: {[any]: any})
	local Object = Instance.new(InstanceName)

	for Property, Value in pairs(Properties) do
		Object[Property] = Value
	end

	return Object
end



--RETURN MODULE--
return Object