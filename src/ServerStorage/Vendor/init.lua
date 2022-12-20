--DEFINE MODULE--
--[=[
	Third-party libraries included in Litework, exclusive to the server. To require these in your code, use the `shared.GetVendorComponent()` function.
	Here's a list of currently available third-party server-only libraries:

	|Name|Author|
	|--------------|-------|
	|ProfileService|loleris|
	
	@server
	@class VendorServer
]=]
local VendorServer = {}



--INIT--
for i, Library in pairs(script:GetChildren()) do
	VendorServer[Library.Name] = require(Library)
end



--RETURN MODULE--
return VendorServer