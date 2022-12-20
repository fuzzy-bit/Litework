--DEFINE MODULE--
--[=[
	Functions accessed via the `shared` global.
	@class Globals
]=]
local SharedFunctions = {}



--SERVICES--
local RunService = game:GetService("RunService")



--PRIVATE FUNCTIONS--
local function GetContext()
	return RunService:IsServer() and "Server" or RunService:IsClient() and "Client"
end



--PUBLIC FUNCTIONS--
--[=[
	Returns a module loaded with [Litework:Load()]. Used instead of `require` for your preloaded modules.
	For example:
	```lua
	local MyModule = shared.GetModule("MyModule")
	MyModule:MyMethod()
	```

	@within Globals
	@param ModuleName string
	@return {}
]=]
function SharedFunctions.GetModule(ModuleName: string)
	if shared.Modules then
		if shared.Modules[ModuleName] then
			return shared.Modules[ModuleName]
		end
	end

	error(string.format(
		"Unable to load module: Could not find %s module named \"%s\"!",
		string.lower(GetContext()),
		ModuleName
	))
end

--[=[
	Returns a built-in [Litework] component, for example:
	```lua
	local Util = shared.GetComponent("Util")
	Util.Math.Median({1, 2, 3}})
	```

	@within Globals
	@param ComponentName string
	@return {}
]=]
function SharedFunctions.GetComponent(ComponentName)
	if shared.Components then
		if shared.Components[ComponentName] then
			return shared.Components[ComponentName]
		end
	end

	error(string.format(
		"Unable to load component: Could not find component named \"%s\"! %s",
		ComponentName,
		RunService:IsClient() and "Is it a server-only component?" or ""
	))
end

--[=[
	Returns a third-party component, for example:
	```lua
	local Signal = shared.GetComponent("Signal")
	local NewSignal = Signal.new()
	```

	@within Globals
	@param VendorComponentName string
	@return {}
]=]
function SharedFunctions.GetVendorComponent(VendorComponentName)
	if shared.VendorComponents then
		if shared.VendorComponents[VendorComponentName] then
			return shared.VendorComponents[VendorComponentName]
		end
	end

	error(string.format(
		"Unable to load vendor component: Could not find component named \"%s\"! %s",
		VendorComponentName,
		RunService:IsClient() and "Is it a server-only vendor component?" or ""
	))
end



--RETURN MODULE--
return SharedFunctions