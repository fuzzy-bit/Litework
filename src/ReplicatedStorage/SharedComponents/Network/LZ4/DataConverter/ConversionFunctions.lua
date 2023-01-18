--DEFINE MODULE--
local ConversionFunctions = {}



--PUBLIC FUNCTIONS--
ConversionFunctions["string"] = function(Data: string)
	return string.byte(Data, 1, #Data)
end

ConversionFunctions["number"] = function(Data: number)
	return Data -- welp
end



--RETURN MODULE--
return ConversionFunctions