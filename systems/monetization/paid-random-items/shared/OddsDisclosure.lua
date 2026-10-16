local OddsDisclosure = {}

-- groups: ordered { { key = "Common", items = { item, ... } }, ... }; weights: { [groupKey] = weight }.
-- An item is rollable when allow(item, groupKey) is true; without `allow`, items carrying a passKey are left out.
local function rollable(item, groupKey, allow)
	if allow then
		return allow(item, groupKey) == true
	end
	return item.passKey == nil
end

local function pools(groups, weights, allow)
	local result, total = {}, 0
	for _, group in ipairs(groups) do
		local weight = weights[group.key] or 0
		if weight > 0 then
			local pool = {}
			for _, item in ipairs(group.items or {}) do
				if rollable(item, group.key, allow) then
					table.insert(pool, item)
				end
			end
			if #pool > 0 then
				table.insert(result, { key = group.key, weight = weight, pool = pool })
				total += weight
			end
		end
	end
	return result, total
end

function OddsDisclosure.Items(groups, weights, allow)
	local result, total = pools(groups, weights, allow)
	local list = {}
	if total <= 0 then
		return list
	end
	for _, entry in ipairs(result) do
		for _, item in ipairs(entry.pool) do
			table.insert(list, { item = item, group = entry.key, percent = entry.weight / total / #entry.pool * 100 })
		end
	end
	table.sort(list, function(a, b)
		if a.percent ~= b.percent then
			return a.percent > b.percent
		end
		return tostring(a.item.name) < tostring(b.item.name)
	end)
	return list
end

-- rolls with the exact pools Items discloses, so the shown odds are the real ones
function OddsDisclosure.Roll(groups, weights, allow, rng)
	local result, total = pools(groups, weights, allow)
	if total <= 0 then
		return nil, nil
	end
	local pick = rng and rng:NextNumber(0, total) or math.random() * total
	local chosen = result[#result]
	for _, entry in ipairs(result) do
		if pick < entry.weight then
			chosen = entry
			break
		end
		pick -= entry.weight
	end
	local index = rng and rng:NextInteger(1, #chosen.pool) or math.random(1, #chosen.pool)
	return chosen.pool[index], chosen.key
end

function OddsDisclosure.Format(percent)
	if percent < 10 then
		return string.format("%.2f%%", percent)
	end
	return string.format("%.1f%%", percent)
end

-- the total chance per roll of the items gated by `passKey`, as an owner of that pass (and no other) would roll
function OddsDisclosure.PassItemChance(groups, weights, passKey)
	local list = OddsDisclosure.Items(groups, weights, function(item)
		return item.passKey == nil or item.passKey == passKey
	end)
	local chance = 0
	for _, entry in ipairs(list) do
		if entry.item.passKey == passKey then
			chance += entry.percent
		end
	end
	return chance
end

return OddsDisclosure
