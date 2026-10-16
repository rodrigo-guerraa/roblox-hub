local PaidRandomItemsConfig = require(script.Parent.PaidRandomItemsConfig)

local PaidRandomItems = {}

PaidRandomItems.ATTRIBUTE = PaidRandomItemsConfig.ATTRIBUTE
PaidRandomItems.MESSAGE = PaidRandomItemsConfig.MESSAGE

-- unknown (lookup pending or failed) counts as restricted
function PaidRandomItems.IsRestricted(player)
	return player:GetAttribute(PaidRandomItems.ATTRIBUTE) ~= false
end

function PaidRandomItems.IsProductKindBlocked(productId, kind)
	return (kind ~= nil and PaidRandomItemsConfig.BLOCKED_PRODUCT_KINDS[kind] == true)
		or PaidRandomItemsConfig.BLOCKED_PRODUCT_IDS[productId] == true
end

function PaidRandomItems.IsProductBlocked(player, productId, kind)
	return PaidRandomItems.IsProductKindBlocked(productId, kind) and PaidRandomItems.IsRestricted(player)
end

function PaidRandomItems.IsPassBlocked(player, key)
	return PaidRandomItemsConfig.BLOCKED_PASSES[key] == true and PaidRandomItems.IsRestricted(player)
end

-- a restricted player who owns an odds-changing pass anyway (bought before, or elsewhere) still rolls without it
function PaidRandomItems.PassAffectsRolls(player, key)
	return not PaidRandomItems.IsPassBlocked(player, key)
end

return PaidRandomItems
