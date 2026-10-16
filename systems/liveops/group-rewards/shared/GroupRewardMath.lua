local GroupRewardsConfig = require(script.Parent:WaitForChild("GroupRewardsConfig"))

local GroupRewardMath = {}

function GroupRewardMath.JoinPayout(income, config)
	config = config or GroupRewardsConfig
	return math.max(config.JOIN_MIN, math.floor((income or 0) * config.JOIN_SECONDS))
end

function GroupRewardMath.IncomePayout(income, config)
	config = config or GroupRewardsConfig
	return math.max(config.INCOME_MIN, math.floor((income or 0) * config.INCOME_SECONDS))
end

function GroupRewardMath.InGroupList(groups, groupId)
	if type(groups) ~= "table" then
		return false
	end
	for _, group in ipairs(groups) do
		if type(group) == "table" and group.Id == groupId then
			return true
		end
	end
	return false
end

return GroupRewardMath
