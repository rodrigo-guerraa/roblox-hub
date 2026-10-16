local BadgeConfig = {}

-- one id per BadgeDefinitions key; 0 = not created yet (skipped, so a badge goes live by setting its id)
BadgeConfig.IDS = {
	WELCOME = 0,
	FIRST_PURCHASE = 0,
	MILLIONAIRE = 0,
}

BadgeConfig.CHECK_INTERVAL = 5
BadgeConfig.RETRY_SECONDS = 60

return BadgeConfig
