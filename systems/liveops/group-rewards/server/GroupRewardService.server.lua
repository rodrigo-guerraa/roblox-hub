local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Config = require(ReplicatedStorage:WaitForChild("GroupRewardsConfig"))
local GroupRewardMath = require(ReplicatedStorage:WaitForChild("GroupRewardMath"))

local claimEvent = Remotes.event(Config.REMOTE_CLAIM)
local resultEvent = Remotes.event(Config.REMOTE_RESULT)

if Config.GROUP_ID == 0 then
	return
end

local incomeToken = {}
local lastClaim = {}

repeat
	task.wait()
until shared.DataServiceAPI and shared.EconomyAPI
local DataService = shared.DataServiceAPI
local Economy = shared.EconomyAPI

local function isInGroup(player)
	local ok, result = pcall(player.IsInGroup, player, Config.GROUP_ID)
	return ok and result == true
end

-- IsInGroup is cached from join, so someone who joins in-game is checked against their live group list
local function isMemberNow(player)
	local ok, groups = pcall(GroupService.GetGroupsAsync, GroupService, player.UserId)
	if ok and type(groups) == "table" then
		return GroupRewardMath.InGroupList(groups, Config.GROUP_ID)
	end
	return isInGroup(player)
end

local function startIncome(player)
	if incomeToken[player] then
		return
	end
	local token = {}
	incomeToken[player] = token
	task.spawn(function()
		while true do
			task.wait(Config.INCOME_INTERVAL)
			if incomeToken[player] ~= token or player.Parent ~= Players then
				break
			end
			Economy.Grant(player, GroupRewardMath.IncomePayout(Economy.GetIncome(player)), "group")
		end
	end)
end

local function reply(player, ok, message, reward)
	resultEvent:FireClient(player, { ok = ok, message = message, reward = reward })
end

local function onPlayer(player)
	local data = DataService.WaitForData(player)
	if not data then
		return
	end
	player:SetAttribute(Config.CLAIMED_ATTRIBUTE, data.groupJoinClaimed == true)
	if isInGroup(player) then
		startIncome(player)
	end
end

claimEvent.OnServerEvent:Connect(function(player)
	local data = DataService.GetData(player)
	if not data then
		return
	end
	local now = os.clock()
	if lastClaim[player] and now - lastClaim[player] < Config.CLAIM_COOLDOWN then
		return
	end
	lastClaim[player] = now

	if data.groupJoinClaimed then
		reply(player, false, "You already claimed this!")
		return
	end
	if not isMemberNow(player) then
		reply(player, false, "Join the group first!")
		return
	end
	if data.groupJoinClaimed or player.Parent ~= Players then
		return
	end

	data.groupJoinClaimed = true
	player:SetAttribute(Config.CLAIMED_ATTRIBUTE, true)
	local reward = GroupRewardMath.JoinPayout(Economy.GetIncome(player))
	Economy.Grant(player, reward, "group_join")
	reply(player, true, "Thanks for joining!", reward)
	startIncome(player)
end)

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	incomeToken[player] = nil
	lastClaim[player] = nil
end)
