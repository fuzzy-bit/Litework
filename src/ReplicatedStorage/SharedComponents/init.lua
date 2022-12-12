--DEFINE MODULE--
local SharedComponents = {}



--INIT--
for i, Component in pairs(script:GetChildren()) do
	SharedComponents[Component.Name] = require(Component)
end



--RETURN MODULE--
return SharedComponents