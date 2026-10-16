local Icons = require(script.Parent:WaitForChild("Icons"))

local C = Color3.fromRGB

return {
	Title = "MY GAME",

	Currency = {
		icon = Icons.Coin,
		prefix = "$",
		rateSuffix = "/s",
		showIncome = true,
		attribute = "Currency",
		incomeAttribute = "IncomePerSecond",
	},

	LoadingScreen = {
		enabled = true,
		icon = Icons.Star,
		timeout = 10,
		-- each entry: "EventName", or { event = "UpdateX", request = "RequestX" } to re-pull a payload another script consumed
		waitEvents = {},
		waitAttributes = { "Currency" },
		topColor = C(110, 206, 92),
		bottomColor = C(34, 118, 64),
		barColor = C(255, 142, 36),
	},

	Music = {
		enabled = true,
		muteButton = true,
		buttonOrder = 9,
		tracks = {
			{ id = "rbxassetid://1842776748", volume = 0.22 },
			{ id = "rbxassetid://1836676241", volume = 0.22 },
			{ id = "rbxassetid://1839151320", volume = 0.22 },
		},
		ambience = nil,
	},

	-- extra or replacement SoundFX entries: name = { id, volume?, pitch? }
	Sounds = {},
}
