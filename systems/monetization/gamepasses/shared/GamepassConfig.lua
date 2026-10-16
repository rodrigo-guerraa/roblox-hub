local GamepassConfig = {}

-- every pass counts as owned in Studio playtests (never in a live server)
GamepassConfig.FORCE_OWNED_IN_STUDIO = false

GamepassConfig.ATTRIBUTE_PREFIX = "Pass_"

-- id 0 = not on sale yet. price is display-only and must match the Creator Dashboard.
GamepassConfig.Passes = {
	{ key = "DOUBLE_CURRENCY", id = 0, price = 49, title = "2x Money", description = "Double all your earnings" },
	{
		key = "OFFLINE_BOOSTER",
		id = 0,
		price = 15,
		title = "Offline Booster",
		description = "Earn full income while you're away",
	},
}

GamepassConfig.ByKey = {}
for _, def in ipairs(GamepassConfig.Passes) do
	GamepassConfig.ByKey[def.key] = def
end

function GamepassConfig.Attribute(key)
	return GamepassConfig.ATTRIBUTE_PREFIX .. key
end

return GamepassConfig
