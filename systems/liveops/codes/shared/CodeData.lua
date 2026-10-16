local CodesConfig = require(script.Parent:WaitForChild("CodesConfig"))

local CodeData = {}

CodeData.Codes = CodesConfig.CODES
CodeData.MAX_LENGTH = CodesConfig.MAX_LENGTH

function CodeData.Normalize(text)
	if type(text) ~= "string" then
		return nil
	end
	local trimmed = string.upper((string.gsub(text, "%s", "")))
	if trimmed == "" or #trimmed > CodeData.MAX_LENGTH then
		return nil
	end
	return trimmed
end

function CodeData.Lookup(text, now)
	local code = CodeData.Normalize(text)
	local def = code and CodeData.Codes[code]
	if not def or def.active == false then
		return nil, "invalid", code
	end
	if def.expires and now and now > def.expires then
		return nil, "expired", code
	end
	return def, nil, code
end

function CodeData.Reward(def, income)
	return math.max(def.min or 0, math.floor((income or 0) * (def.seconds or 0)))
end

return CodeData
