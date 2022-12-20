--DEFINE MODULE--
local SharedFunctions = {}



--SERVICES--
local RunService = game:GetService("RunService")



--PRIVATE FUNCTIONS--
local function GetContext()
	return RunService:IsServer() and "Server" or RunService:IsClient() and "Client"
end



--PUBLIC FUNCTIONS--
function SharedFunctions.GetModule(ModuleName)
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