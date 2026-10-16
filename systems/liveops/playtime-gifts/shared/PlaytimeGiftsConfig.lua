local PlaytimeGiftsConfig = {}

PlaytimeGiftsConfig.INTERVAL = 600
-- the Nth gift of a session pays this many seconds of income (the last step repeats)
PlaytimeGiftsConfig.SECONDS_LADDER = { 60, 90, 120, 150, 180 }
PlaytimeGiftsConfig.MIN = 1000

PlaytimeGiftsConfig.WINDOW_KEY = "Gift"
PlaytimeGiftsConfig.HUD_ORDER = 0

PlaytimeGiftsConfig.REMOTE_CLAIM = "ClaimGift"
PlaytimeGiftsConfig.REMOTE_UPDATE = "UpdateGift"
PlaytimeGiftsConfig.REMOTE_REQUEST = "RequestGift"

return PlaytimeGiftsConfig
