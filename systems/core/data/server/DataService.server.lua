local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataConfig = require(ReplicatedStorage:WaitForChild("DataConfig"))

local playerData = {}
local loadedPlayers = {}
local failedPlayers = {}
local profiles = {}

local function isPlayer(value)
	return typeof(value) == "Instance" and value:IsA("Player")
end

-- a BindableEvent would deep-copy the data table, so listeners get the live table through this signal instead
local listeners = {}
local PlayerLoaded = {}

function PlayerLoaded:Connect(handler)
	assert(type(handler) == "function", "PlayerLoaded:Connect expects a function")
	local connection = { Connected = true }
	function connection.Disconnect()
		connection.Connected = false
		listeners[connection] = nil
	end
	listeners[connection] = handler
	return connection
end

function PlayerLoaded:Once(handler)
	assert(type(handler) == "function", "PlayerLoaded:Once expects a function")
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		handler(...)
	end)
	return connection
end

function PlayerLoaded:Wait()
	local thread = coroutine.running()
	self:Once(function(...)
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

local function fireLoaded(player, data)
	local handlers = {}
	for _, handler in pairs(listeners) do
		table.insert(handlers, handler)
	end
	for _, handler in ipairs(handlers) do
		task.spawn(handler, player, data)
	end
end

local API = {}

API.PlayerLoaded = PlayerLoaded

function API.GetData(player)
	if not isPlayer(player) or not loadedPlayers[player.UserId] then
		return nil
	end
	return playerData[player.UserId]
end

function API.WaitForData(player)
	if not isPlayer(player) then
		return nil
	end
	local userId = player.UserId
	while not loadedPlayers[userId] do
		if failedPlayers[userId] or player.Parent ~= Players then
			return nil
		end
		task.wait()
	end
	if player.Parent ~= Players then
		return nil
	end
	return playerData[userId]
end

local function isPurchaseId(value)
	return (type(value) == "string" and value ~= "") or (type(value) == "number" and value == value)
end

function API.HasPurchase(player, purchaseId)
	local data = API.GetData(player)
	if not data or not isPurchaseId(purchaseId) or type(data.purchaseIds) ~= "table" then
		return false
	end
	return table.find(data.purchaseIds, purchaseId) ~= nil
end

function API.RecordPurchase(player, purchaseId)
	local data = API.GetData(player)
	if not data or not isPurchaseId(purchaseId) then
		return false
	end
	if type(data.purchaseIds) ~= "table" then
		data.purchaseIds = {}
	end
	if table.find(data.purchaseIds, purchaseId) then
		return true
	end
	table.insert(data.purchaseIds, purchaseId)
	while #data.purchaseIds > DataConfig.PURCHASE_HISTORY do
		table.remove(data.purchaseIds, 1)
	end
	return true
end

shared.DataServiceAPI = API

local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local SaveMigrations = require(ReplicatedStorage:WaitForChild("SaveMigrations"))
local DataTemplate = require(ReplicatedStorage:WaitForChild("DataTemplate"))

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

local function newData()
	local data = deepCopy(DataTemplate)
	data.dataVersion = DataConfig.DATA_VERSION
	data.lastSeen = 0
	return data
end

-- with API access off, ProfileStore falls back to an in-memory store on its own
local storeName = DataConfig.STORE_NAME .. (RunService:IsStudio() and DataConfig.STUDIO_SUFFIX or "")
local profileStore = ProfileStore.New(storeName, newData())

local function onPlayerAdded(player)
	local userId = player.UserId
	loadedPlayers[userId] = nil
	failedPlayers[userId] = nil

	local profile = profileStore:StartSessionAsync(DataConfig.KEY_PREFIX .. userId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		failedPlayers[userId] = true
		if player.Parent == Players then
			player:Kick("Your data could not be loaded. Please rejoin.")
		end
		return
	end

	profile:AddUserId(userId)
	-- migrate before Reconcile, which would fill a missing dataVersion from the template
	local status, migrated = SaveMigrations.Migrate(profile.Data, DataConfig.DATA_VERSION)
	if status == "newer" or status == "missingStep" or status == "failed" then
		failedPlayers[userId] = true
		profile:EndSession()
		if status ~= "newer" then
			warn("DataService: save migration", status, "for", userId)
		end
		player:Kick(
			status == "newer" and "A newer version of the game is out! Please rejoin to play it."
				or "Your data couldn't be loaded right now. Please rejoin."
		)
		return
	elseif status == "reset" then
		profile.Data = newData()
	elseif status == "migrated" then
		profile.Data = migrated
	end
	profile:Reconcile()

	if type(profile.Data.lastSeen) ~= "number" or profile.Data.lastSeen == 0 then
		profile.Data.lastSeen = os.time()
	end

	profile.OnSessionEnd:Connect(function()
		profiles[userId] = nil
		playerData[userId] = nil
		loadedPlayers[userId] = nil
		player:Kick("Your data is now active on another server. Please rejoin.")
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	profiles[userId] = profile
	playerData[userId] = profile.Data
	loadedPlayers[userId] = true
	fireLoaded(player, profile.Data)
end

local function onPlayerRemoving(player)
	local userId = player.UserId
	local data = playerData[userId]
	if data then
		data.lastSeen = os.time()
	end
	local profile = profiles[userId]
	profiles[userId] = nil
	playerData[userId] = nil
	loadedPlayers[userId] = nil
	failedPlayers[userId] = nil
	if profile then
		profile:EndSession()
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
