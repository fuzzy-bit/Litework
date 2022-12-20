--DEFINE MODULE--
local ServerVendor = {}



--INIT--
for i, Library in pairs(script:GetChildren()) do
	ServerVendor[Library.Name] = require(Library)
end



--RETURN MODULE--
return ServerVendor