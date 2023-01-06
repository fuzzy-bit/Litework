--DEFINE MODULE--
local SharedComponents = {}



--PUBLIC FUNCTIONS--
function SharedComponents:Load()
	local LoadedComponents = {}

	for i, Component in pairs(script:GetChildren()) do
		LoadedComponents[Component.Name] = require(Component)
	end

	SharedComponents.Load = nil
	return LoadedComponents
end



--RETURN MODULE--
return SharedComponents