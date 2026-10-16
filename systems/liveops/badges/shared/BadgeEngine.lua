local BadgeEngine = {}

function BadgeEngine.ByKey(definitions)
	local byKey = {}
	for _, badge in ipairs(definitions) do
		byKey[badge.key] = badge
	end
	return byKey
end

function BadgeEngine.Earned(definitions, state)
	local keys = {}
	for _, badge in ipairs(definitions) do
		if badge.earned(state) then
			table.insert(keys, badge.key)
		end
	end
	return keys
end

-- earned, has a live id, and not yet recorded as awarded
function BadgeEngine.Pending(definitions, state, awarded, ids)
	local keys = {}
	awarded = awarded or {}
	for _, key in ipairs(BadgeEngine.Earned(definitions, state)) do
		local id = ids and ids[key]
		if not awarded[key] and (ids == nil or (type(id) == "number" and id ~= 0)) then
			table.insert(keys, key)
		end
	end
	return keys
end

-- problems with a definitions list against an ids map; empty when everything lines up
function BadgeEngine.Validate(definitions, ids)
	local problems = {}
	local seen = {}
	for index, badge in ipairs(definitions) do
		if type(badge.key) ~= "string" or badge.key == "" then
			table.insert(problems, string.format("badge %d has no key", index))
		elseif seen[badge.key] then
			table.insert(problems, "duplicate key " .. badge.key)
		else
			seen[badge.key] = true
			if type(badge.earned) ~= "function" then
				table.insert(problems, badge.key .. " has no earned function")
			end
			if type(badge.name) ~= "string" or type(badge.description) ~= "string" then
				table.insert(problems, badge.key .. " needs a name and description")
			end
			if type(ids[badge.key]) ~= "number" then
				table.insert(problems, badge.key .. " has no id entry")
			end
		end
	end
	for key in pairs(ids) do
		if not seen[key] then
			table.insert(problems, "id entry " .. tostring(key) .. " has no definition")
		end
	end
	return problems
end

return BadgeEngine
