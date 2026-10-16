local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OfflineConfig = require(ReplicatedStorage:WaitForChild("OfflineConfig"))
local OfflineMath = require(ReplicatedStorage:WaitForChild("OfflineMath"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local REQUEST_COOLDOWN = 1
local DEPENDENCY_TIMEOUT = 15

local capMultiplier
local lastRequest = {}
local cappedPool = {}
local offlineEvent

local API = {}

function API.SetCapMultiplier(fn)
	capMultiplier = type(fn) == "function" and fn or nil
end

function API.GetPool(player)
	local data = shared.DataServiceAPI and shared.DataServiceAPI.GetData(player)
	return data and data.offlinePool or 0
end

function API.GetDoubles(player)
	local data = shared.DataServiceAPI and shared.DataServiceAPI.GetData(player)
	return data and data.offlineDoubles or 0
end

local function push(player, data, capped)
	if not offlineEvent then
		return
	end
	offlineEvent:FireClient(player, {
		amount = data.offlinePool or 0,
		capped = capped == true or cappedPool[player.UserId] == true,
		doubles = data.offlineDoubles or 0,
		maxDoubles = #OfflineConfig.DOUBLE_PRODUCTS,
	})
end

function API.Collect(player)
	local data = shared.DataServiceAPI and shared.DataServiceAPI.GetData(player)
	local Economy = shared.EconomyAPI
	if not data or not Economy then
		return 0
	end
	local pool = data.offlinePool or 0
	if pool <= 0 then
		return 0
	end
	data.offlinePool = 0
	data.offlineDoubles = 0
	cappedPool[player.UserId] = nil
	Economy.Grant(player, pool, OfflineConfig.GRANT_SOURCE)
	if offlineEvent then
		offlineEvent:FireClient(player, {
			amount = 0,
			collected = pool,
			doubles = 0,
			maxDoubles = #OfflineConfig.DOUBLE_PRODUCTS,
		})
	end
	return pool
end

-- false (empty pool, finished ladder) leaves the receipt NotProcessedYet instead of charging for nothing
function API.GrantDouble(player)
	local data = shared.DataServiceAPI and shared.DataServiceAPI.GetData(player)
	if not data or not OfflineMath.CanDouble(data.offlinePool, data.offlineDoubles) then
		return false
	end
	data.offlinePool = data.offlinePool * 2
	data.offlineDoubles = (data.offlineDoubles or 0) + 1
	push(player, data, false)
	return true
end

shared.OfflineEarningsAPI = API

offlineEvent = Remotes.event("OfflineEarnings")
local collectEvent = Remotes.event("CollectOffline")
local requestEvent = Remotes.event("RequestOffline")

local function waitFor(name)
	local deadline = os.clock() + DEPENDENCY_TIMEOUT
	while not shared[name] and os.clock() < deadline do
		task.wait()
	end
	return shared[name]
end

local function hasBooster(player)
	if OfflineConfig.BOOSTER_PASS_KEY == "" then
		return false
	end
	local Gamepasses = shared.GamepassAPI
	if not Gamepasses then
		return false
	end
	Gamepasses.WaitForOwnership(player)
	return Gamepasses.HasPass(player, OfflineConfig.BOOSTER_PASS_KEY)
end

local function onPlayerAdded(player)
	local DataService = waitFor("DataServiceAPI")
	local data = DataService and DataService.WaitForData(player)
	if not data then
		return
	end
	local lastSeen = tonumber(data.lastSeen) or 0
	local seconds = lastSeen > 0 and os.time() - lastSeen or 0

	local booster = hasBooster(player)
	local Economy = waitFor("EconomyAPI")
	data = DataService.GetData(player)
	if not data or not Economy then
		return
	end
	data.offlinePool = data.offlinePool or 0
	data.offlineDoubles = data.offlineDoubles or 0

	local earned, capped = 0, false
	if seconds >= OfflineConfig.MIN_AWAY_SECONDS then
		local income = Economy.GetIncome(player)
		local rate = OfflineMath.Rate(booster)
		local multiplier = 1
		if capMultiplier then
			local ok, value = pcall(capMultiplier, player)
			multiplier = ok and tonumber(value) or 1
		end
		local cap = OfflineMath.Cap(income, rate, OfflineConfig.CAP_SECONDS, multiplier)
		earned = OfflineMath.Earnings(income, seconds, rate, cap)
		capped = earned > 0 and earned >= cap
	end
	data.offlinePool += earned
	cappedPool[player.UserId] = capped or nil
	if data.offlinePool > 0 then
		push(player, data, capped)
	else
		data.offlineDoubles = 0
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	lastRequest[player.UserId] = nil
	cappedPool[player.UserId] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

collectEvent.OnServerEvent:Connect(function(player)
	API.Collect(player)
end)

requestEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if lastRequest[player.UserId] and now - lastRequest[player.UserId] < REQUEST_COOLDOWN then
		return
	end
	lastRequest[player.UserId] = now
	local data = shared.DataServiceAPI and shared.DataServiceAPI.GetData(player)
	if data and (data.offlinePool or 0) > 0 then
		push(player, data, false)
	end
end)

local Receipts = waitFor("ReceiptAPI")
if Receipts then
	for _, step in ipairs(OfflineConfig.DOUBLE_PRODUCTS) do
		if step.id ~= 0 then
			Receipts.Register(step.id, API.GrantDouble, OfflineConfig.PRODUCT_KIND)
		end
	end
else
	warn("OfflineEarningsService: shared.ReceiptAPI not found; the doubling products are not sold")
end
