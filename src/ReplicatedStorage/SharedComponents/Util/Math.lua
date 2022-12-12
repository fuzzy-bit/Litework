--DEFINE MODULE--
local Math = {}



--PUBLIC FUNCTIONS--
function Math:Lerp(A, B, T) 
	return A * (1 - T) + B * T
end

function Math:Median(Numbers)
	if type(Numbers) ~= "table" then return Numbers end
	
	table.sort(Numbers)
	if #Numbers % 2 == 0 then
		return (Numbers[#Numbers / 2] + Numbers[#Numbers / 2 + 1]) / 2 
	end
	
	return Numbers[math.ceil(#Numbers / 2)]
end

function Math:SecondsToFrames(Seconds, FPS)
	if not FPS then
		FPS = 60
	end
	
	return Seconds * FPS
end



--RETURN MODULE--
return Math