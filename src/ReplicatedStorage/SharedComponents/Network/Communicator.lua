--DEFINE MODULE--
local Communicator = {}
Communicator.__index = Communicator



--SERVICES--
local RunService = game:GetService("RunService")
local JointsService = game:GetService("JointsService")
local ServerStorage = game:GetService("ServerStorage")



--PRIVATE VARIABLES--
local InstanceLocation = game.ReplicatedStorage
local ServerBindableLocation = ServerStorage

local Modes = {
    ["Remote"] = "Remote",
    ["Bindable"] = "Bindable"
}
local ChannelTypes = {
    ["Event"] = "Event",
    ["Function"] = "Function"
}



--PUBLIC FUNCTIONS--
function Communicator.new(Name: string, Mode: string, Channels: {}?)
    local self = setmetatable({
        Name = Name,
        Channels = {},

        RootFolder = nil
    }, Communicator)

    local ModeFolder = InstanceLocation.Communicators:FindFirstChild(Mode)

    if Mode == "Bindable" and RunService:IsServer() then
        ModeFolder = ServerBindableLocation.BindableCommunicators
    end

    if not ModeFolder then
        error(string.format(
            "Invalid mode \"%s\"!",
            string.lower(Mode)
        ))
    end

    if not ModeFolder:FindFirstChild(Name) then
        self.RootFolder = Instance.new("Folder")
        self.RootFolder.Name = Name
        self.RootFolder.Parent = ModeFolder

        Channels = Channels or {
            ["Event"] = 1,
            ["Function"] = 1
        }

        for ChannelType, Amount in pairs(Channels) do
            if not ChannelTypes[ChannelType] then
                error(string.format(
                    "Invalid channel type \"%s\"!",
                    string.lower(ChannelType)
                ))
            end

            if not self.Channels[ChannelType] then
                self.Channels[ChannelType] = {}
            end

            for i = 1, Amount do
                local ChannelObject = Instance.new(Mode .. ChannelType)
                ChannelObject.Name = string.format("%s-Channel", ChannelType)
                ChannelObject.Parent = self.RootFolder

                table.insert(self.Channels[ChannelType], ChannelObject)
            end
        end
    else
        self.RootFolder = ModeFolder:FindFirstChild(Name)

        for i, ChannelObject in pairs(self.RootFolder:GetChildren()) do
            local SplitName = string.split(ChannelObject.Name, "-")
            local ChannelType = SplitName[1]

            if not ChannelTypes[ChannelType] then
                error(string.format(
                    "Invalid channel type \"%s\"!",
                    string.lower(ChannelType)
                ))
            end

            if not self.Channels[ChannelType] then
                self.Channels[ChannelType] = {}
            end

            table.insert(self.Channels[ChannelType], ChannelObject)
        end
    end

    return self
end



--INIT--
if not InstanceLocation:FindFirstChild("Communicators") then
    local CommunicatorsFolder = Instance.new("Folder", InstanceLocation)
    CommunicatorsFolder.Name = "Communicators"

    for i, Mode in pairs(Modes) do
        local ModeFolder = Instance.new("Folder", CommunicatorsFolder)
        ModeFolder.Name = Mode
    end
end

if not ServerStorage:FindFirstChild("BindableCommunicators") then
    local CommunicatorsFolder = Instance.new("Folder", ServerBindableLocation)
    CommunicatorsFolder.Name = "BindableCommunicators"
end



--RETURN MODULE--
return Communicator