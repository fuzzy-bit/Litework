--[[
	HOW THIS SHOULD WORK, DOCUMENT IT LIKE THIS

	PlayerHandler must be initialized with `PlayerHandler:Init()` to register all connections.

	Events in the `Players` service can have functions bound to them with just one event receiver,
	while also having built-in behavior (like custom respawn time) that can be toggled.

	Functions can be bound with Bind/Unbind functions with a string as the identifier.
	Each event has a dictionary of functions with their identifier as the index.

	Example: `PlayerHandler:BindToPlayerAdded(Name, Function)`.
	To toggle built-in behavior, you can use `PlayerHandler:SetFlag(FlagName, Value)`.

	Some uses include:
	```lua
	PlayerHandler:Init() -- Running more than once does absolutely nothing
	PlayerHandler:SetFlag("CharacterAutoLoads", true) -- Default: true. Disables custom RespawnTime.
	PlayerHandler:SetFlag("RespawnTime", 1) -- Default: 5
	PlayerHandler:BindToCharacterDied("KillEffect", function(Player, Character)
		-- stuff
	end)
	```
]]--
--DEFINE MODULE--
local PlayerHandler = {}



--SERVICES--
local Players = game:GetService("Players")



--PRIVATE VARIABLES--
local Flags = {
	CharacterAutoLoads = true,
	RespawnTime = 5
}
local Bindings = {
	PlayerAdded = {},
	PlayerRemoving = {},
	CharacterAdded = {},
	CharacterDied = {}
}

local PlayerAddedConnection, PlayerRemovingConnection



--PRIVATE FUNCTIONS--
local function RunBindings(BindingTable: {}, ...)
	for i, Binding in pairs(BindingTable) do
		Binding(...)
	end
end

local function CharacterAdded(Player: Player, Character: any)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid")
	RunBindings(Bindings.CharacterAdded, Player, Character)

	Humanoid.Died:Connect(function()
		RunBindings(Bindings.CharacterDied, Player, Character)
	end)
end

local function PlayerAdded(Player: Player)
	RunBindings(Bindings.PlayerAdded, Player)

	Player.CharacterAdded:Connect(function(Character)
		CharacterAdded(Player, Character)
	end)
end



--PUBLIC FUNCTIONS--
function PlayerHandler:SetFlag(Name, Value)
	Flags[Name] = Value
	
	return PlayerHandler.SetFlag
end

function PlayerHandler:Init()
	Players.CharacterAutoLoads = Flags.CharacterAutoLoads
	Players.RespawnTime = Flags.RespawnTime
	
	if not PlayerAddedConnection then
		PlayerAddedConnection = Players.PlayerAdded:Connect(function(Player)
			PlayerAdded(Player)
		end)

		for i, Player in pairs(Players:GetPlayers()) do
			PlayerAdded(Player)
		end
	end

	if not PlayerRemovingConnection then
		PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(Player)
			RunBindings(Bindings.PlayerRemoving, Player)
		end)
	end
end

function PlayerHandler:BindToPlayerAdded(BindName, BindFunction)
	Bindings.PlayerAdded[BindName] = BindFunction
end

function PlayerHandler:BindToPlayerRemoving(BindName, BindFunction)
	Bindings.PlayerRemoving[BindName] = BindFunction
end

function PlayerHandler:BindToCharacterAdded(BindName, BindFunction)
	Bindings.CharacterAdded[BindName] = BindFunction
end

function PlayerHandler:BindToCharacterDied(BindName, BindFunction)
	Bindings.CharacterDied[BindName] = BindFunction
end



--RETURN MODULE--
return PlayerHandler