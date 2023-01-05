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
local ContextString = RunService:IsServer() and "Server" or "Client"

local Errors = {
    InvalidMode = "Invalid mode \"%s\"!",
    InvalidChannel = "Invalid channel type \"%s\"!",
    ServerFromClient = "Attempt to call client-only method from server!",
    ClientFromServer = "Attempt to call server-only method from client!"
}

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

    local ChannelAmount = ChannelAmount or 1
    local ModeFolder = InstanceLocation.Communicators:FindFirstChild(Mode)

    if Mode == "Bindable" and RunService:IsServer() then
        ModeFolder = ServerBindableLocation.BindableCommunicators
    end

    if not ModeFolder then
        error(string.format(
            Errors.InvalidMode,
            string.lower(Mode)
        ))
    end

    self:SetupChannels(ChannelAmount, ModeFolder)
    self:UpdateChannels()

    return self
end

-- RemoteEvent
function Communicator:FireAllClients(...)
    if RunService:IsServer() then   
        local ChannelId = Randomizer:NextInteger(1, #self.Channels)
        self.Channels[ChannelId]:FireAllClients(...)
    else
        error(Errors.ServerFromClient)
    end
end

function Communicator:FireClient(Player: Player, ...)
    if RunService:IsServer() then   
        local ChannelId = Randomizer:NextInteger(1, #self.Channels)
        self.Channels[ChannelId]:FireClient(Player, ...)
    else
        error(Errors.ServerFromClient)
    end
end

function Communicator:FireServer(...)
    if RunService:IsClient() then   
        local ChannelId = Randomizer:NextInteger(1, #self.Channels)
        self.Channels[ChannelId]:FireServer(...)
    else
        error(Errors.ClientFromServer)
    end
end

-- BindableEvent
function Communicator:Fire(...)
    local ChannelId = Randomizer:NextInteger(1, #self.Channels)
    self.Channels[ChannelId]:Fire(...)
end

--RemoteFunction
function Communicator:InvokeServer(...)
    if RunService:IsClient() then
        local ChannelId = Randomizer:NextInteger(1, #self.Channels)
        return self.Channels[ChannelId]:InvokeServer(...)
    else
        error(Errors.ClientFromServer)
    end
end

function Communicator:InvokeClient(...)
    if RunService:IsServer() then
        local ChannelId = Randomizer:NextInteger(1, #self.Channels)
        return self.Channels[ChannelId]:InvokeClient(...)
    else
        error(Errors.ServerFromClient)
    end
end

-- BindableFunction
function Communicator:Invoke(...)
    local ChannelId = Randomizer:NextInteger(1, #self.Channels)
    return self.Channels[ChannelId]:Invoke(...)
end

function Communicator:OnInvoke(InvokeFunction)
    for i, ChannelObject in pairs(self.RootFolder:GetChildren()) do
        local EventName = EventNames[self.Mode][self.Type]
        local ContextualizedEventName = EventName

        if self.Mode == "Remote" then
            ContextualizedEventName = string.format(EventName, ContextString)
        end

        if self.Type == "Function" then
            ChannelObject[ContextualizedEventName] = InvokeFunction
        end
    end
end

function Communicator:SetupChannels(ChannelAmount: number, ModeFolder: Instance)
    if not ModeFolder:WaitForChild(self.Name, 3) then
        self.RootFolder = Instance.new("Folder")
        self.RootFolder.Name = self.Name
        self.RootFolder.Parent = ModeFolder

        if not ChannelTypes[self.Type] then
            error(string.format(
                Errors.InvalidChannel,
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
                    Errors.InvalidChannel,
                    string.lower(self.Type)
                ))
            end

            table.insert(self.Channels, ChannelObject)
        end
    end
end

function Communicator:UpdateChannels()
    for i, ChannelObject in pairs(self.RootFolder:GetChildren()) do
        local EventName = EventNames[self.Mode][self.Type]
        local ContextualizedEventName = EventName

        if self.Mode == "Remote" then
            ContextualizedEventName = string.format(EventName, ContextString)
        end

        if self.Type == "Event" then
            ChannelObject[ContextualizedEventName]:Connect(function(...)
                self.OnEvent:Fire(...)
            end)
        elseif self.Type == "Function" then
            ChannelObject[ContextualizedEventName] = self.OnEvent
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