local PlaytimeGiftsConfig = require(script.Parent:WaitForChild("PlaytimeGiftsConfig"))

local GiftMath = {}

function GiftMath.Payout(income, giftNumber, config)
	config = config or PlaytimeGiftsConfig
	local steps = config.SECONDS_LADDER
	local seconds = steps[math.clamp(math.floor(tonumber(giftNumber) or 1), 1, #steps)]
	return math.max(config.MIN, math.floor((income or 0) * seconds))
end

function GiftMath.Progress(saved, config)
	config = config or PlaytimeGiftsConfig
	return math.clamp(tonumber(saved) or 0, 0, config.INTERVAL)
end

function GiftMath.IsReady(saved, config)
	config = config or PlaytimeGiftsConfig
	return GiftMath.Progress(saved, config) >= config.INTERVAL
end

return GiftMath
