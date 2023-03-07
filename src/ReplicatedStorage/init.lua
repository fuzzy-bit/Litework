--DEFINE MODULE--
--[=[
	The framework's main module, located in `ReplicatedStorage.Framework`.
	@class Litework
]=]
local Litework = {}



--SERVICES--
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")



--MODULES--
local SharedFunctions = require(script.SharedFunctions)
local SharedComponents = require(script.SharedComponents)
local SharedVendorComponents = require(script.Vendor)
local LiteworkServer = require(script.LoadServer)



--PUBLIC VARIABLES--
Litework.Version = "0.1.3-alpha" -- FOLLOWS SEMVER



--PRIVATE FUNCTIONS--
local function MergeDictionaries(...)
	local Result = {}

	for i, Dictionary in pairs({...}) do
		for Index, Value in pairs(Dictionary) do
			Result[Index] = Value
		end
	end

	return Result
end

local function GetFromServer(Index)
	if LiteworkServer then
		return LiteworkServer[Index]
	end

	return {}
end

local function LockMetatable(Index: {}, RealTable)
	return setmetatable(RealTable or {}, {
		__metatable = "This metatable is locked",
		__index = Index
	})
end

local function InitializeModule(Module)
	if Module["Init"] then
		if type(Module["Init"]) == "function" then
			task.spawn(function()
				Module:Init()
			end)
		end
	end
end

local function GetModules(ModuleContainer: Instance): {}
	local AllModules = {}

	for X, Child in pairs(ModuleContainer:GetChildren()) do
		if Child:IsA("Folder") then
			for Y, FolderChild in pairs(GetModules(Child)) do
				table.insert(AllModules, FolderChild)
			end
		elseif Child:IsA("ModuleScript") then
			table.insert(AllModules, Child)
		end
	end

	return AllModules
end

local function LoadOrderedModules(Modules: {}, PriorityList: {}): {}
	local OrderedModules = Modules
	
	for i, Module in pairs(OrderedModules) do
		local PrioritySearchResult = table.find(PriorityList, Module.Name)

		if PrioritySearchResult then
			OrderedModules[i], OrderedModules[PrioritySearchResult] = OrderedModules[PrioritySearchResult], OrderedModules[i]
		end
	end

	return OrderedModules
end

local function LoadModules(ModuleContainer: Instance, PriorityList: {}?): {}
	local LoadedModules = {}
	local AllModules = GetModules(ModuleContainer)

	if PriorityList then
		AllModules = LoadOrderedModules(AllModules, PriorityList)
	end

	for i, ModulePointer in pairs(AllModules) do
		LoadedModules[ModulePointer.Name] = require(ModulePointer)
		InitializeModule(LoadedModules[ModulePointer.Name])
	end

	return LoadedModules
end



--PUBLIC FUNCTIONS--
--[=[
	:::danger Only run this function once!
	This function should only be run on both the server and client once, not doing so will most likely cause errors.
	:::

	Loads the framework with an instance containing modules, and folders to group them. Each module is required in the order of the PriorityList, and runs an :Init() function given the module contains one. 
	Run on the server first, then the client.

	@yields
	@param ModuleContainer Instance -- An object which contains modules for the framework to load.
	@param PriorityList {}? -- A table containing names (strings) of modules to load in order.
]=]
function Litework:Load(ModuleContainer: Instance, PriorityList: {}?)
	local LoadedModules
	local LoadedComponents

	shared.GetModule = SharedFunctions.GetModule
	shared.GetComponent = SharedFunctions.GetComponent
	shared.GetVendorComponent = SharedFunctions.GetVendorComponent
	shared.VendorComponents = LockMetatable(MergeDictionaries(
		SharedVendorComponents,
		GetFromServer("Vendor")
	))

	LoadedComponents = SharedComponents:Load()

	shared.Components = LockMetatable(MergeDictionaries(
		LoadedComponents,
		GetFromServer("Components")
	))

	LoadedModules = LoadModules(ModuleContainer, PriorityList)
	shared.Modules = LockMetatable(LoadedModules)
end



--RETURN MODULE--
return Litework