--DEFINE MODULE--
local Stream = {} -- TODO: use tables rather than strings



--PUBLIC FUNCTIONS--
function Stream.new(Source: string)
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

function Stream:Append(NewData: string)
    self.Source ..= NewData
    self.Length = #self.Source
    self:Seek(0)
end

function Stream:ToEnd()
    self:Seek(self.Length)
end



--RETURN MODULE--
return Stream