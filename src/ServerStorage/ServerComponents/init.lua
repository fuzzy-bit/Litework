--DEFINE MODULE--
local ServerComponents = {}



--INIT--
for i, Component in pairs(script:GetChildren()) do
	ServerComponents[Component.Name] = require(Component)
end



--RETURN MODULE--
return ServerComponents