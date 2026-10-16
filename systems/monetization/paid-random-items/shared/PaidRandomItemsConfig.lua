local PaidRandomItemsConfig = {}

PaidRandomItemsConfig.ATTRIBUTE = "PaidRandomRestricted"
PaidRandomItemsConfig.MESSAGE = "This isn't available in your region."
PaidRandomItemsConfig.LOOKUP_ATTEMPTS = 3

-- Robux -> currency (when currency pays for random rolls) and Robux -> roll shortcuts, by ReceiptAPI kind
PaidRandomItemsConfig.BLOCKED_PRODUCT_KINDS = {
	currency = true,
	offline_double = true,
}

PaidRandomItemsConfig.BLOCKED_PRODUCT_IDS = {}

-- GamepassConfig keys of passes that change roll odds or add pass-only outcomes
PaidRandomItemsConfig.BLOCKED_PASSES = {}

return PaidRandomItemsConfig
