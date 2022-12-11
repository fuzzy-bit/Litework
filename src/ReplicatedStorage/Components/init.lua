--DEFINE MODULE--
local Components = {}



--INIT--
for i, Component in pairs(script:GetChildren()) do
	Components[Component.Name] = require(Component)
end



--RETURN MODULE--
return Components