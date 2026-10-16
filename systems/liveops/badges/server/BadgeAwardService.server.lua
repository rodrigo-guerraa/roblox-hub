local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BadgeConfig = require(ReplicatedStorage:WaitForChild("BadgeConfig"))
local BadgeDefinitions = require(ReplicatedStorage:WaitForChild("BadgeDefinitions"))
local BadgeEngine = require(ReplicatedStorage:WaitForChild("BadgeEngine"))

local retryAt = {}
local checking = {}

local function award(player, data, key)
	local id = BadgeConfig.IDS[key]
	local now = os.clock()
	local playerRetry = retryAt[player]
	if playerRetry and playerRetry[key] and now < playerRetry[key] then
		return
	end

	local ok, result = pcall(BadgeService.AwardBadgeAsync, BadgeService, player.UserId, id)
	if not ok or result == false then
		-- an already-owned badge can come back false or error; owning it still counts as done
		local checked, owned = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, id)
		if not checked or owned ~= true then
			retryAt[player] = retryAt[player] or {}
			retryAt[player][key] = now + BadgeConfig.RETRY_SECONDS
			return
		end
	end
	data.badgesAwarded[key] = true
end

local function check(player)
	local DataService = shared.DataServiceAPI
	local data = DataService and DataService.GetData(player)
	if not data or checking[player] then
		return
	end
	checking[player] = true
	data.badgesAwarded = data.badgesAwarded or {}
	local Economy = shared.EconomyAPI
	local ok, pending = pcall(function()
		local state = BadgeDefinitions.StateFromProfile(data, {
			balance = Economy and Economy.GetBalance(player) or 0,
		})
		return BadgeEngine.Pending(BadgeDefinitions.All, state, data.badgesAwarded, BadgeConfig.IDS)
	end)
	if ok then
		for _, key in ipairs(pending) do
			if player.Parent ~= Players then
				break
			end
			award(player, data, key)
		end
	else
		warn("[Badges] judging failed: " .. tostring(pending))
	end
	checking[player] = nil
end

local BadgeAPI = {}

function BadgeAPI.Check(player)
	task.spawn(check, player)
end

function BadgeAPI.HasAwarded(player, key)
	local DataService = shared.DataServiceAPI
	local data = DataService and DataService.GetData(player)
	return data ~= nil and type(data.badgesAwarded) == "table" and data.badgesAwarded[key] == true
end

shared.BadgeAPI = BadgeAPI

repeat
	task.wait()
until shared.DataServiceAPI

Players.PlayerAdded:Connect(function(player)
	if shared.DataServiceAPI.WaitForData(player) then
		check(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	retryAt[player] = nil
	checking[player] = nil
end)

while true do
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(check, player)
	end
	task.wait(BadgeConfig.CHECK_INTERVAL)
end
