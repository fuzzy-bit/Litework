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
	PlayerHandler:SetFlag("CharacterAutoLoads", true) -- Default: false. Disables custom RespawnTime and character handling
	PlayerHandler:SetFlag("RespawnTime", 1) -- Default: 5
	PlayerHandler:BindToCharacterDeath("KillEffect", function()
		-- stuff
	end)
	```
]]--
--DEFINE MODULE--
local PlayerHandler = {}



--RETURN MODULE--
return PlayerHandler