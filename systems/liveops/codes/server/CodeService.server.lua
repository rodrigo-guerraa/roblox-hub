local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local CodesConfig = require(ReplicatedStorage:WaitForChild("CodesConfig"))
local CodeData = require(ReplicatedStorage:WaitForChild("CodeData"))

local redeemEvent = Remotes.event(CodesConfig.REMOTE_REDEEM)
local resultEvent = Remotes.event(CodesConfig.REMOTE_RESULT)

local lastAttempt = {}

repeat
	task.wait()
until shared.DataServiceAPI and shared.EconomyAPI
local DataService = shared.DataServiceAPI
local Economy = shared.EconomyAPI

local function reply(player, ok, message, reward)
	resultEvent:FireClient(player, { ok = ok, message = message, reward = reward })
end

redeemEvent.OnServerEvent:Connect(function(player, text)
	if type(text) ~= "string" or #text > 200 then
		return
	end
	local data = DataService.GetData(player)
	if not data then
		return
	end

	local now = os.clock()
	if lastAttempt[player] and now - lastAttempt[player] < CodesConfig.ATTEMPT_COOLDOWN then
		reply(player, false, "Slow down! Try again in a moment.")
		return
	end
	lastAttempt[player] = now

	local def, reason, code = CodeData.Lookup(text, os.time())
	if not def then
		reply(player, false, reason == "expired" and "That code has expired." or "That code doesn't exist.")
		return
	end
	data.redeemedCodes = data.redeemedCodes or {}
	if data.redeemedCodes[code] then
		reply(player, false, "You already used that code!")
		return
	end

	data.redeemedCodes[code] = true
	local reward = CodeData.Reward(def, Economy.GetIncome(player))
	Economy.Grant(player, reward, "code")
	reply(player, true, def.description or "Code redeemed!", reward)
end)

Players.PlayerRemoving:Connect(function(player)
	lastAttempt[player] = nil
end)
