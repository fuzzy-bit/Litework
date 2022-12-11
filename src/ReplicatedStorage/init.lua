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
local Components = require(script.Components)



--PRIVATE VARIABLES--
local ServerComponents



--PRIVATE FUNCTIONS--
local function LoadServerComponents()
	if RunService:IsServer() then
		if not ServerComponents then
			ServerComponents = require(ServerStorage.Framework)
		end

		return ServerComponents
	else
		return {}
	end
end

local function LockMetatable(Index: {}, RealTable: {}?)
	return setmetatable(RealTable or {}, {
		__metatable = "This metatable is locked",
		__index = Index
	})
end

local function InitializeModule(Module: {})
	if Module["Init"] then
		if type(Module["Init"]) == "function" then
			Module:Init()
		end
	end
end

local function LoadOrderedModules(Modules: {}, PriorityList: {}): {}
	local OrderedModules = {}

	for i, Module in pairs(Modules) do
		if PriorityList[Module.Name] then
			table.insert(OrderedModules, {
				Pointer = Module,
				LoadPriority = PriorityList[Module.Name]
			})
		else
			table.insert(OrderedModules, {
				Pointer = Module,
				LoadPriority = math.max
			})
		end
	end

	table.sort(OrderedModules, function(A, B)
		return A.LoadPriority > B.LoadPriority
	end)

	return OrderedModules
end

local function LoadModules(ModuleContainer: Instance, PriorityList: {}?): {}
	local LoadedModules = {}

	if PriorityList then
		local OrderedModules = LoadOrderedModules(ModuleContainer:GetChildren(), PriorityList)

		for i, OrderedModule in pairs(OrderedModules) do
			LoadedModules[OrderedModule.Pointer.Name] = require(OrderedModule.Pointer)
			InitializeModule(LoadedModules[OrderedModule.Pointer.Name])
		end
	else
		for i, ModulePointer in pairs(ModuleContainer:GetChildren()) do
			LoadedModules[ModulePointer.Name] = require(ModulePointer)
			InitializeModule(LoadedModules[ModulePointer.Name])
		end
	end

	return LoadedModules
end



--PUBLIC FUNCTIONS--
--[=[
	:::danger Do not run this function more than once!
	This function should only be ran on both the server and client once, not doing so will most likely cause errors.
	:::

	Loads the framework with an instance containing modules, and folders to group them. Each module is required in order, and runs an :Init() function given the module contains one. 
	Run on the server first, then the client.

	@yields
	@param ModuleContainer Instance -- An object which contains modules for the framework to load.
	@param PriorityList {}? -- A dictionary containing names of modules to load as the index, with the value being their priority.
]=]
function Litework:Load(ModuleContainer: Instance, PriorityList: {}?)
	local LoadedModules = LoadModules(ModuleContainer, PriorityList)

	shared.Modules = LockMetatable(LoadedModules)
	shared.Components = LockMetatable({
		unpack(Components),
		unpack(LoadServerComponents())
	})

	shared.GetModule = SharedFunctions.GetModule
	shared.GetComponent = SharedFunctions.GetComponent
end



--RETURN MODULE--
return Litework