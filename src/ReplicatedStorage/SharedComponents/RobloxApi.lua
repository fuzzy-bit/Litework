--DEFINE MODULE--
local RobloxApi = {}
RobloxApi.__index = RobloxApi
RobloxApi.__type = "RobloxApi"



--SERVICES--
local HttpService = game:GetService("HttpService")



--PUBLIC VARAIBLES--
export type RobloxClassMember = {
	Category: string,
	MemberType: string,
	Name: string,
	Security: {},
	Serialization: {},
	Tags: {},
	ThreadSafety: string,
	ValueType: {},
}

export type RobloxClass = {
	Members: { RobloxClassMember },
	MemoryCategory: string,
	Name: string,
	Superclass: string,
}

export type RobloxApi = typeof(RobloxApi)



--PRIVATE VARIABLES--
local Cache = {
	Classes = {},
	Members = {},
}



--PUBLIC FUNCTIONS--
function RobloxApi.new(ApiDump: string | {}, UseCache: boolean)
	local self = setmetatable({
		ApiDump = ApiDump,
		UseCache = UseCache,

		Data = {},
		Classes = {},
		Enums = {},

		Version = 1,
	}, RobloxApi)

	if type(ApiDump) == "string" then
		local Success, Error = pcall(function()
			self.Data = HttpService:JSONDecode(HttpService:GetAsync(ApiDump))
		end)

		assert(Success, "Could not get Api data! Please double-check if the URL is valid or returns JSON.")
	else
		self.Data = ApiDump -- Assume we are a table, since it is the other accepted type
	end

	self:GenerateDictionaries()
	self.Version = self.Data.Version

	return self
end

function RobloxApi:GenerateDictionaries()
	for i, Class in pairs(self.Data.Classes) do
		self.Classes[Class.Name] = Class
	end

	for i, Class in pairs(self.Data.Enums) do
		self.Enums[Class.Name] = Class
	end
end

function RobloxApi:GetClassMembers(ClassName: string): { RobloxClassMember }
	if self.Classes[ClassName] then
		local ClassData: RobloxClass = self.Classes[ClassName]
		local ClassMembers: { RobloxClassMember } = ClassData.Members

		if self.Classes[ClassData.Superclass] then
			for i, ClassMember in pairs(self:GetClassMembers(ClassData.Superclass)) do
				table.insert(ClassMembers, ClassMember)
			end
		else
			return ClassMembers
		end

		return ClassMembers
	end

	error(string.format('"%s" is not a valid class name!', ClassName))
end

function RobloxApi:GetClass(ClassName: string): RobloxClass
	if Cache.Classes[ClassName] then
		return Cache.Classes[ClassName]
	end

	if self.Classes[ClassName] then
		local ClassData: RobloxClass = self.Classes[ClassName]

		for i, ClassMember in pairs(self:GetClassMembers(ClassData.Superclass)) do -- zOMG HAX
			table.insert(ClassData.Members, ClassMember)
		end

		Cache.Classes[ClassName] = ClassData
		return ClassData
	end

	error(string.format('"%s" is not a valid class name!', ClassName))
end

function RobloxApi:GetMember(ClassName: string, MemberName: string): RobloxClassMember | nil
	local Class: RobloxClass -- This is defined later so we don't waste time at the beginning, since it might be cached

	if Cache.Members[ClassName] then
		if Cache.Members[ClassName][MemberName] then
			return Cache.Members[ClassName][MemberName]
		end
	end

	Class = self:GetClass(ClassName) -- Looks ugly, saves cycles

	for i, Member: RobloxClassMember in pairs(Class.Members) do
		if Member.Name == MemberName then
			if self.UseCache then
				if not Cache.Members[ClassName] then
					Cache.Members[ClassName] = {}
				end

				Cache.Members[ClassName][MemberName] = Member
			end

			return Member
		end
	end

	return
end



--RETURN MODULE--
return RobloxApi