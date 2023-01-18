--DEFINE MODULE--
local DataConverter = {}



--MODULES--
local ConversionFunctions = require(script.ConversionFunctions)



--PUBLIC VARIABLES--
DataConverter.Header = {0x4C, 0x57, 0x4B, 0x00}
DataConverter.EndMarker = {0x45, 0x4E, 0x44, 0x00}
DataConverter.TypeBindings = {
	Id = {
		[0xA0] = "string",
		[0xA1] = "number"
	},

	Name = {
		["string"] = 0xA0,
		["number"] = 0xA1
	}
}



--PUBLIC FUNCTIONS--
function DataConverter:Convert(Data: any): {}
	local DataType = type(Data)

	if ConversionFunctions[DataType] then
		local ConvertedData = {
			DataConverter.Header,
			DataConverter.TypeBindings.Name[DataType],
			ConversionFunctions[DataType](Data),
			DataConverter.EndMarker
		}

		return ConvertedData
	else
		error(string.format("No converter for type %s!", DataType))
	end
end



--RETURN MODULE--
return DataConverter