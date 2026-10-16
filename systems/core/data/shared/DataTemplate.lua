local DataConfig = require(script.Parent:WaitForChild("DataConfig"))

return {
	dataVersion = DataConfig.DATA_VERSION,
	currency = 0,
	totalEarned = 0,
	lastSeen = 0,
	purchaseIds = {},
}
