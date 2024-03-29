--DEFINE MODULE--
--[=[
	The framework's main module, located in `ReplicatedStorage.Framework`.
	@class Litework
]=]
local Litework = {}



--PRIVATE VARIABLES--
local ComponentOrder = {
	"Signal",
	"Object",
	"Util",
	"PlayerHandler",
	"Network",
	"RobloxApi"
}



--PUBLIC VARIABLES--
Litework.Version = "0.2.0-alpha" -- FOLLOWS SEMVER

Litework.Loaded = false
Litework.Components = {}
Litework.Modules = {}



--PRIVATE FUNCTIONS--
local function InitializeModule(Module)
	if Module["Init"] then
		if type(Module["Init"]) == "function" then
			Module:Init()
		end
	end
end

local function GetModules(ModuleContainer: Instance): {}
	local AllModules = {}

	for X, Child in pairs(ModuleContainer:GetChildren()) do
		if Child:IsA("Folder") then
			for Y, FolderChild in pairs(GetModules(Child)) do
				AllModules[FolderChild.Name] = FolderChild
			end
		elseif Child:IsA("ModuleScript") then
			AllModules[Child.Name] = Child
		end
	end

	return AllModules
end

local function LoadOrderedModules(Modules: {}, PriorityList: {}): {}
	local OrderedModules = {}
	
	for i, ModuleName in pairs(PriorityList) do
		table.insert(OrderedModules, Modules[ModuleName])
	end

	return OrderedModules
end

local function LoadModules(ModuleContainer: Instance, PriorityList: {}?): {}
	local AllModules = GetModules(ModuleContainer)

	if PriorityList then
		AllModules = LoadOrderedModules(AllModules, PriorityList)
	end

	for i, ModulePointer in pairs(AllModules) do
		task.spawn(function()
			Litework.Modules[ModulePointer.Name] = require(ModulePointer)
			InitializeModule(Litework.Modules[ModulePointer.Name])
		end)
	end

	return Litework.Modules
end



--PUBLIC FUNCTIONS--
--[=[
	:::danger Only run this function once!
	This function should only be run on both the server and client once, not doing so will most likely cause errors.
	:::

	:::danger Only yield when you need to!
	The call to the initialization function will be delayed if you run anything that yields outside of your :Init().
	:::

	Loads the framework with an instance containing modules, and folders to group them. Each module is required in the order of the PriorityList, and runs an :Init() function given the module contains one. 
	Run on the server first, then the client.

	@yields
	@param ModuleContainer Instance -- An object which contains modules for the framework to load.
	@param PriorityList {}? -- A table containing names (strings) of modules to load in order.
]=]
function Litework:Load(ModuleContainer: Instance, PriorityList: {}?)
	if not Litework.Loaded then
		for i, ComponentName in pairs(ComponentOrder) do
			if script:FindFirstChild(ComponentName) then
				local ComponentModule = script:FindFirstChild(ComponentName)
				Litework.Components[ComponentName] = require(ComponentModule)
			else
				error(string.format("%s is not a valid component!", ComponentName))
			end
		end

		LoadModules(ModuleContainer, PriorityList)
		Litework.Loaded = true
	end
end



--RETURN MODULE--
return Litework