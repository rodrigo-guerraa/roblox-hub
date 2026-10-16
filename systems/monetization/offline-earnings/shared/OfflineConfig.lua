local OfflineConfig = {}

OfflineConfig.RATE = 0.5
OfflineConfig.BOOSTED_RATE = 1
-- a GamepassConfig key that raises RATE to BOOSTED_RATE; "" = no booster
OfflineConfig.BOOSTER_PASS_KEY = "OFFLINE_BOOSTER"
OfflineConfig.CAP_SECONDS = 8 * 3600
OfflineConfig.MIN_AWAY_SECONDS = 60

OfflineConfig.GRANT_SOURCE = "offline"
OfflineConfig.PRODUCT_KIND = "offline_double"

-- each buy doubles the pending pool again; step N is offered after N-1 doubles, collecting resets the ladder.
-- id 0 = not created; price is display-only.
OfflineConfig.DOUBLE_PRODUCTS = {
	{ id = 0, price = 9 },
	{ id = 0, price = 19 },
	{ id = 0, price = 39 },
	{ id = 0, price = 79 },
	{ id = 0, price = 159 },
}

OfflineConfig.TITLE = "WELCOME BACK!"
OfflineConfig.LEAD = "You earned this while you were away:"

return OfflineConfig
