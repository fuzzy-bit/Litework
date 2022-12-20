--DEFINE MODULE--
--[=[
	Third-party libraries included in Litework. To require these in your code, use the `shared.GetVendorComponent()` function.
	Here's a list of currently available third-party libraries:

	|Name|Author|
	|------|----------|
	|Signal|sleitnick|
	
	@private
	@class VendorShared
]=]
local Vendor = {}



--INIT--
for i, Library in pairs(script:GetChildren()) do
	Vendor[Library.Name] = require(Library)
end



--RETURN MODULE--
return Vendor