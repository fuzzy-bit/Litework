--DEFINE MODULE--
local Network = {}



--SUBMODULES--
Network.Communicator = require(script.Communicator)



--PRIVATE VARIABLES--
local Communicators = {
    ["Remote"] = {},
    ["Bindable"] = {}
}



--PUBLIC FUNCTIONS--
function Network:GetCommunicator(Name: string, Mode: string, ChannelType: string, ChannelAmount: number?)
    return Network.Communicator.new(Name, Mode, ChannelType, ChannelAmount)
end



--RETURN MODULE--
return Network