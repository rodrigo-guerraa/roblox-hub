local BadgeDefinitions = {}

-- Game-owned: replace these examples. Every badge is judged from the save, so anyone who already qualifies gets it when its id goes live.
BadgeDefinitions.All = {
	{
		key = "WELCOME",
		name = "Welcome!",
		description = "Join the game.",
		earned = function()
			return true
		end,
	},
	{
		key = "FIRST_PURCHASE",
		name = "Supporter",
		description = "Make your first purchase.",
		earned = function(s)
			return s.purchases >= 1
		end,
	},
	{
		key = "MILLIONAIRE",
		name = "Millionaire",
		description = "Have 1,000,000 at once.",
		earned = function(s)
			return s.balance >= 1e6
		end,
	},
}

local function count(t)
	local n = 0
	if type(t) == "table" then
		for _ in pairs(t) do
			n += 1
		end
	end
	return n
end

-- the numbers the badges look at; `context` carries live values the server reads outside the save (balance)
function BadgeDefinitions.StateFromProfile(data, context)
	data = data or {}
	context = context or {}
	return {
		purchases = count(data.purchaseIds),
		balance = tonumber(context.balance) or 0,
	}
end

return BadgeDefinitions
