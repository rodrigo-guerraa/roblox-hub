local OfflineConfig = require(script.Parent.OfflineConfig)

local OfflineMath = {}

function OfflineMath.Rate(hasBooster, config)
	config = config or OfflineConfig
	return hasBooster and config.BOOSTED_RATE or config.RATE
end

function OfflineMath.Cap(income, rate, capSeconds, capMultiplier)
	return math.max(0, math.floor((income or 0) * rate * capSeconds * (capMultiplier or 1)))
end

function OfflineMath.Earnings(income, seconds, rate, cap)
	if not seconds or seconds <= 0 or not income or income <= 0 then
		return 0
	end
	return math.min(cap, math.floor(income * seconds * rate))
end

function OfflineMath.NextDouble(doubles, products)
	products = products or OfflineConfig.DOUBLE_PRODUCTS
	local step = products[(doubles or 0) + 1]
	if step and step.id ~= 0 then
		return step
	end
	return nil
end

function OfflineMath.CanDouble(pool, doubles, products)
	products = products or OfflineConfig.DOUBLE_PRODUCTS
	return (pool or 0) > 0 and (doubles or 0) < #products
end

function OfflineMath.Multiplier(doubles)
	return 2 ^ (doubles or 0)
end

return OfflineMath
