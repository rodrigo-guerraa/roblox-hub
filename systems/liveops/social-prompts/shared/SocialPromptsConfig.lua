local SocialPromptsConfig = {}

SocialPromptsConfig.INVITE_TILE = true
SocialPromptsConfig.INVITE_ORDER = 11

-- the server sets this Player attribute to true at the game's high point; the client then asks to favorite once
SocialPromptsConfig.FAVORITE_ATTRIBUTE = "FavoritePromptMoment"
-- seconds after the moment, so the game's own celebration plays out before Roblox's prompt appears
SocialPromptsConfig.FAVORITE_DELAY = 4

return SocialPromptsConfig
