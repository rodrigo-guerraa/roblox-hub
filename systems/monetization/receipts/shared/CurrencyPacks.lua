local ReceiptConfig = require(script.Parent.ReceiptConfig)

local CurrencyPacks = {}

function CurrencyPacks.List(products)
	local list = {}
	for _, def in ipairs(products or ReceiptConfig.PRODUCTS) do
		if def.kind == "currency" then
			table.insert(list, def)
		end
	end
	return list
end

function CurrencyPacks.ByKey(key, products)
	for _, def in ipairs(CurrencyPacks.List(products)) do
		if def.key == key then
			return def
		end
	end
	return nil
end

function CurrencyPacks.ById(productId, products)
	if type(productId) ~= "number" or productId == 0 then
		return nil
	end
	for _, def in ipairs(CurrencyPacks.List(products)) do
		if def.id == productId then
			return def
		end
	end
	return nil
end

function CurrencyPacks.Payout(def, income)
	if type(def) ~= "table" then
		return 0
	end
	if type(def.amount) == "number" then
		return math.max(0, math.floor(def.amount))
	end
	local scaled = math.floor(math.max(0, tonumber(income) or 0) * (def.seconds or 0))
	return math.max(def.min or 0, scaled)
end

return CurrencyPacks
