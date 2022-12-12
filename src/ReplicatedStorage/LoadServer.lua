--SERVICES--
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")



--RETURN MODULE--
return RunService:IsServer() and require(ServerStorage.Framework) -- Loaded only on the server, as it's in ServerStorage