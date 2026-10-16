local CodesConfig = {}

-- Rewards are `seconds` of the player's income, never below `min`. `expires` (os.time) is optional; `active = false` retires a code.
CodesConfig.CODES = {
	RELEASE = { seconds = 300, min = 500, description = "Thanks for playing!" },
	WELCOME = { seconds = 120, min = 200, description = "Welcome! Here's a little boost." },
}

CodesConfig.MAX_LENGTH = 30
CodesConfig.ATTEMPT_COOLDOWN = 2

CodesConfig.WINDOW_KEY = "Codes"
CodesConfig.HUD_ORDER = 10
CodesConfig.HINT = "Find codes in our Roblox group!"

CodesConfig.REMOTE_REDEEM = "RedeemCode"
CodesConfig.REMOTE_RESULT = "CodeResult"

return CodesConfig
