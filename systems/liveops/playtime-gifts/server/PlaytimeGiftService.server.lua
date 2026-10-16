local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Config = require(ReplicatedStorage:WaitForChild("PlaytimeGiftsConfig"))
local GiftMath = require(ReplicatedStorage:WaitForChild("GiftMath"))

local claimEvent = Remotes.event(Config.REMOTE_CLAIM)
local updateEvent = Remotes.event(Config.REMOTE_UPDATE)
local requestEvent = Remotes.event(Config.REMOTE_REQUEST)

-- gifts claimed this session: the next gift grows with it and resets on rejoin
local claimedThisSession = {}

repeat
	task.wait()
until shared.DataServiceAPI and shared.EconomyAPI
local DataService = shared.DataServiceAPI
local Economy = shared.EconomyAPI

local function pushGift(player, claimed)
	local data = DataService.GetData(player)
	if not data then
		return
	end
	local progress = GiftMath.Progress(data.giftProgress)
	updateEvent:FireClient(player, {
		progress = progress,
		interval = Config.INTERVAL,
		ready = progress >= Config.INTERVAL,
		giftNumber = (claimedThisSession[player] or 0) + 1,
		claimed = claimed,
	})
end

claimEvent.OnServerEvent:Connect(function(player)
	local data = DataService.GetData(player)
	if not data or not GiftMath.IsReady(data.giftProgress) then
		return
	end
	data.giftProgress = 0
	local number = (claimedThisSession[player] or 0) + 1
	claimedThisSession[player] = number
	local reward = GiftMath.Payout(Economy.GetIncome(player), number)
	Economy.Grant(player, reward, "playtime_gift")
	pushGift(player, reward)
end)

requestEvent.OnServerEvent:Connect(function(player)
	pushGift(player)
end)

local function onPlayer(player)
	if DataService.WaitForData(player) then
		pushGift(player)
	end
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	claimedThisSession[player] = nil
end)

-- online time only; a ready gift stops the clock until it is claimed, so gifts never pile up
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataService.GetData(player)
			if data then
				local progress = GiftMath.Progress(data.giftProgress)
				if progress < Config.INTERVAL then
					data.giftProgress = progress + 1
					if data.giftProgress >= Config.INTERVAL then
						pushGift(player)
					end
				end
			end
		end
	end
end)
