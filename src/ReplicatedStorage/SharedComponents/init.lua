--DEFINE MODULE--
local SharedComponents = {}



--PRIVATE FUNCTIONS--
local function AfterLoad()
	return "This function can only be used once per require."
end



--PUBLIC FUNCTIONS--
function SharedComponents:Load()
	local LoadedComponents = {}

	for i, Component in pairs(script:GetChildren()) do
		LoadedComponents[Component.Name] = require(Component)
	end

	SharedComponents.Load = AfterLoad -- self-destruct for safety
	return LoadedComponents
end



--RETURN MODULE--
return SharedComponents