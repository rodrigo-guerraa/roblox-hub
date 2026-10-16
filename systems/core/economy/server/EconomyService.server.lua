local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EconomyConfig = require(ReplicatedStorage:WaitForChild("EconomyConfig"))

local CURRENCY_ATTRIBUTE = EconomyConfig.CURRENCY_ATTRIBUTE
local INCOME_ATTRIBUTE = EconomyConfig.INCOME_ATTRIBUTE

local function isPlayer(value)
	return typeof(value) == "Instance" and value:IsA("Player")
end

local function isAmount(value)
	return type(value) == "number" and value >= 0 and value < math.huge
end

local function getData(player)
	local dataAPI = shared.DataServiceAPI
	if not dataAPI then
		return nil
	end
	return dataAPI.GetData(player)
end

local function balanceOf(data)
	local balance = data.currency
	if type(balance) ~= "number" or balance ~= balance or balance < 0 then
		data.currency = 0
		return 0
	end
	return balance
end

local API = {}

function API.GetBalance(player)
	if not isPlayer(player) then
		return 0
	end
	local data = getData(player)
	return data and balanceOf(data) or 0
end

function API.Grant(player, amount, _source)
	if not isPlayer(player) then
		return 0
	end
	local data = getData(player)
	if not data then
		warn("EconomyAPI.Grant: data not loaded for", player.Name)
		return 0
	end
	local balance = balanceOf(data)
	if not isAmount(amount) or amount == 0 then
		return balance
	end
	data.currency = balance + amount
	data.totalEarned = (tonumber(data.totalEarned) or 0) + amount
	player:SetAttribute(CURRENCY_ATTRIBUTE, data.currency)
	return data.currency
end

function API.Spend(player, amount, _source)
	if not isPlayer(player) or not isAmount(amount) then
		return false
	end
	local data = getData(player)
	if not data then
		return false
	end
	local balance = balanceOf(data)
	if balance < amount then
		return false
	end
	data.currency = balance - amount
	player:SetAttribute(CURRENCY_ATTRIBUTE, data.currency)
	return true
end

function API.GetIncome(player)
	if not isPlayer(player) then
		return 0
	end
	local income = player:GetAttribute(INCOME_ATTRIBUTE)
	if type(income) ~= "number" or not isAmount(income) then
		return 0
	end
	return income
end

shared.EconomyAPI = API

repeat
	task.wait()
until shared.DataServiceAPI
local DataServiceAPI = shared.DataServiceAPI

local function onPlayerAdded(player)
	local data = DataServiceAPI.WaitForData(player)
	if not data then
		return
	end
	local startBalance = EconomyConfig.STUDIO_START_BALANCE
	if RunService:IsStudio() and isAmount(startBalance) and balanceOf(data) < startBalance then
		data.currency = startBalance
	end
	player:SetAttribute(CURRENCY_ATTRIBUTE, balanceOf(data))
	if player:GetAttribute(INCOME_ATTRIBUTE) == nil then
		player:SetAttribute(INCOME_ATTRIBUTE, 0)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- picks up direct writes to data.currency made outside this API
while true do
	task.wait(EconomyConfig.ATTRIBUTE_SYNC_INTERVAL)
	for _, player in ipairs(Players:GetPlayers()) do
		local data = DataServiceAPI.GetData(player)
		if data then
			local balance = balanceOf(data)
			if player:GetAttribute(CURRENCY_ATTRIBUTE) ~= balance then
				player:SetAttribute(CURRENCY_ATTRIBUTE, balance)
			end
		end
	end
end
