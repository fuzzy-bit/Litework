--DEFINE MODULE--
local Network = {}



--SUBMODULES--
Network.Communicator = require(script.Communicator)



--PRIVATE VARIABLES--
local Communicators = {
    ["Remote"] = {},
    ["Bindable"] = {}
}



--PRIVATE FUNCTIONS--
local function GetExistingCommunicators(Mode: string)
    
end



--PUBLIC FUNCTIONS--
function Network:GetCommunicator(Name: string, Mode: string, Channels: {}?)
    return Network.Communicator.new(Name, Mode, Channels)
end



--INIT--
GetExistingCommunicators("Remote")
GetExistingCommunicators("Bindable")



--RETURN MODULE--
return Network