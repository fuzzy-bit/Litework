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
function Network:GetCommunicator(Name: string, Mode: string, Channels: {}?)
    return Network.Communicator.new(Name, Mode, Channels)
end



--RETURN MODULE--
return Network