local DataConfig = require(script.Parent:WaitForChild("DataConfig"))
local DataMigrations = require(script.Parent:WaitForChild("DataMigrations"))

local SaveMigrations = {}

-- saves older than this come from pre-launch builds and start over
SaveMigrations.BASELINE = DataConfig.MIGRATION_BASELINE
SaveMigrations.Steps = DataMigrations

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, inner in pairs(value) do
		copy[deepCopy(key)] = deepCopy(inner)
	end
	return copy
end

-- statuses: "current"/"migrated" (use the returned data), "reset", "newer", "missingStep"/"failed" (refuse the join); the input is never modified
function SaveMigrations.Migrate(data, targetVersion, steps)
	steps = steps or SaveMigrations.Steps
	local version = type(data) == "table" and data.dataVersion or nil
	if type(version) ~= "number" or version ~= version or version < SaveMigrations.BASELINE then
		return "reset", nil
	end
	if version > targetVersion then
		return "newer", nil
	end
	if version == targetVersion then
		return "current", data
	end
	local working = deepCopy(data)
	while version < targetVersion do
		local step = steps[version]
		if type(step) ~= "function" then
			return "missingStep", nil
		end
		local ok = pcall(step, working)
		if not ok then
			return "failed", nil
		end
		version += 1
		working.dataVersion = version
	end
	return "migrated", working
end

return SaveMigrations
