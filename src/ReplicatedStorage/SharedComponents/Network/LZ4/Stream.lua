--DEFINE MODULE--
local Stream = {} -- TODO: use tables rather than strings



--SUBMODULES--
Stream.DataConverter = require(script.Parent.DataConverter)



--PUBLIC FUNCTIONS--
function Stream.new(Source: {})
    local self = setmetatable({
        Offset = 0,
        Source = Source,
        Length = #Source,

        Finished = false,
        LastUnreadBytes = 0
    }, Stream)

    return self
end

function Stream:Read(Length: number?, Shift: boolean?): string
    local Length = Length or 1
    local Shift = if Shift ~= nil then Shift else true

    local Data = string.sub(self.Source, self.Offset + 1, self.Offset + Length)
    local DataLength = #Data
    local UnreadBytes = Length - DataLength

    if Shift then
        self:Seek(Length)
    end

    self.LastUnreadBytes = UnreadBytes
    return Data
end

function Stream:Seek(Length: number?)
    local Length = Length or 1

    self.Offset = math.clamp(self.Offset + Length, 0, self.Length)
    self.Finished = self.Offset >= self.Length
end

function Stream:Append(NewData: any)
    local Converted = Stream.DataConverter:Convert(NewData)

    for i, Byte in pairs(Converted) do
        if Byte > 0xFF and type(NewData) ~= "number" then
            error("Stream recieved non-byte data!")
        end

        table.insert(self.Source, Byte)
    end

    self.Length = #self.Source
    self:Seek(0)
end

function Stream:ToEnd()
    self:Seek(self.Length)
end



--RETURN MODULE--
return Stream