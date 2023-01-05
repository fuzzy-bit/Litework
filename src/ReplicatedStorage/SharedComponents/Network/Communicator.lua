--DEFINE MODULE--
local Communicator = {}
Communicator.__index = Communicator



--SERVICES--
local RunService = game:GetService("RunService")
local JointsService = game:GetService("JointsService")
local ServerStorage = game:GetService("ServerStorage")



--MODULES--
local Signal = shared.GetVendorComponent("Signal")



--PRIVATE VARIABLES--
local InstanceLocation = game.ReplicatedStorage
local ServerBindableLocation = ServerStorage

local Randomizer = Random.new(tick())

local Modes = {
    ["Remote"] = "Remote",
    ["Bindable"] = "Bindable"
}
local ChannelTypes = {
    ["Event"] = "Event",
    ["Function"] = "Function"
}

local FireFunctionNames = {
    ["Remote"] = {
        ["Event"] = "FireServer",
        ["Function"] = "InvokeServer"
    },
    ["Bindable"] = {
        ["Event"] = "Fire",
        ["Function"] = "Invoke"
    }
}
local EventNames = {
    ["Remote"] = {
        ["Event"] = "On%sEvent",
        ["Function"] = "On%sInvoke"
    },
    ["Bindable"] = {
        ["Event"] = "Event",
        ["Function"] = "OnInvoke"
    }
}



--PUBLIC FUNCTIONS--
function Communicator.new(Name: string, Mode: string, ChannelType: string, ChannelAmount: number?)
    local self = setmetatable({
        Name = Name,
        Mode = Mode,
        Type = ChannelType,

        Channels = {},
        OnEvent = Signal.new(),

        RootFolder = nil
    }, Communicator)

    local ContextString = RunService:IsServer() and "Server" or "Client"

    local ChannelAmount = ChannelAmount or 1
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

    self:SetupChannels(ChannelAmount, ModeFolder)

    for i, ChannelObject in pairs(self.RootFolder:GetChildren()) do
        local EventName = EventNames[Mode][self.Type]
        local ContextualizedEventName = EventName

        if Mode == "Remote" then
            ContextualizedEventName = string.format(EventName, ContextString)
        end

        ChannelObject[ContextualizedEventName]:Connect(function(...)
            self.OnEvent:Fire(...)
        end)
    end

    return self
end

function Communicator:FireServer(...)
    local ChannelId = Randomizer:NextInteger(1, #self.Channels)
    self.Channels[ChannelId]:FireServer(...)
end

function Communicator:SetupChannels(ChannelAmount: number, ModeFolder: Instance)
    if not ModeFolder:FindFirstChild(self.Name) then
        self.RootFolder = Instance.new("Folder")
        self.RootFolder.Name = self.Name
        self.RootFolder.Parent = ModeFolder

        if not ChannelTypes[self.Type] then
            error(string.format(
                "Invalid channel type \"%s\"!",
                string.lower(self.Type)
            ))
        end

        for i = 1, ChannelAmount do
            local ChannelObject = Instance.new(self.Mode .. self.Type)
            ChannelObject.Name = string.format("%s-Channel", self.Type)
            ChannelObject.Parent = self.RootFolder

            table.insert(self.Channels, ChannelObject)
        end
    else
        self.RootFolder = ModeFolder:FindFirstChild(self.Name)

        for i, ChannelObject in pairs(self.RootFolder:GetChildren()) do
            local SplitName = string.split(ChannelObject.Name, "-")
            self.Type = SplitName[1]

            if not ChannelTypes[self.Type] then
                error(string.format(
                    "Invalid channel type \"%s\"!",
                    string.lower(self.Type)
                ))
            end

            table.insert(self.Channels, ChannelObject)
        end
    end
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