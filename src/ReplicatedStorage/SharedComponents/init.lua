--DEFINE MODULE--
local SharedComponents = {}



--PUBLIC FUNCTIONS--
function SharedComponents:Load()
	for i, Component in pairs(script:GetChildren()) do
		SharedComponents[Component.Name] = require(Component)
	end

	SharedComponents.Load = nil
end



--RETURN MODULE--
return SharedComponents