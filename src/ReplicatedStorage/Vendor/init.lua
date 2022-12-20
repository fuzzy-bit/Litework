--DEFINE MODULE--
local Vendor = {}



--INIT--
for i, Library in pairs(script:GetChildren()) do
	Vendor[Library.Name] = require(Library)
end



--RETURN MODULE--
return Vendor