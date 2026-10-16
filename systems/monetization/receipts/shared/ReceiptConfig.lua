local ReceiptConfig = {}

-- id 0 = not created yet (never registered). price is display-only: the Creator Dashboard price is charged.
-- kind = "currency": pays `seconds` of income (EconomyAPI.GetIncome), never below `min`, or a flat `amount`.
ReceiptConfig.PRODUCTS = {
	{
		key = "currencySmall",
		kind = "currency",
		id = 0,
		price = 3,
		title = "Small Money Pack",
		seconds = 3600,
		min = 100,
	},
	{
		key = "currencyMedium",
		kind = "currency",
		id = 0,
		price = 15,
		title = "Medium Money Pack",
		seconds = 4 * 3600,
		min = 500,
	},
	{
		key = "currencyLarge",
		kind = "currency",
		id = 0,
		price = 30,
		title = "Large Money Pack",
		seconds = 12 * 3600,
		min = 2000,
	},
}

ReceiptConfig.GRANT_SOURCE = "currency_pack"

return ReceiptConfig
