local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GamepassConfig = require(ReplicatedStorage:WaitForChild("GamepassConfig"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local REQUEST_COOLDOWN = 2

local ownership = {}
-- monotonic per-UserId join tokens: a load that yielded past a leave/rejoin must not write
local joinTokens = {}
local erroredKeys = {}
local loaded = {}
local lastRequest = {}

local changed = Instance.new("BindableEvent")

local API = {}

API.Changed = changed.Event

function API.HasPass(player, key)
	local map = ownership[player.UserId]
	return map ~= nil and map[key] == true
end

function API.GetOwnership(player)
	local map = ownership[player.UserId]
	return map and table.clone(map) or {}
end

function API.IsLoaded(player)
	return loaded[player.UserId] == true
end

function API.WaitForOwnership(player, timeout)
	local deadline = os.clock() + (timeout or 10)
	while not loaded[player.UserId] and player.Parent == Players and os.clock() < deadline do
		task.wait(0.1)
	end
	return loaded[player.UserId] == true
end

shared.GamepassAPI = API

local studioOverride = RunService:IsStudio() and GamepassConfig.FORCE_OWNED_IN_STUDIO == true

local ownershipEvent = Remotes.event("GamepassOwnership")
local requestEvent = Remotes.event("RequestGamepasses")

local function checkOwnership(player, id)
	if type(id) ~= "number" or id == 0 then
		return false, true
	end
	local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
	if not ok then
		warn("GamepassService: ownership check failed for", player.Name, id)
		return false, false
	end
	return owns == true, true
end

local function push(player)
	local map = ownership[player.UserId]
	if not map then
		return
	end
	for _, def in ipairs(GamepassConfig.Passes) do
		player:SetAttribute(GamepassConfig.Attribute(def.key), map[def.key] == true)
	end
	ownershipEvent:FireClient(player, map)
end

local function loadOwnership(player, token)
	local map, errs = {}, {}
	for _, def in ipairs(GamepassConfig.Passes) do
		if studioOverride then
			map[def.key] = true
		else
			local owns, ok = checkOwnership(player, def.id)
			map[def.key] = owns
			if not ok then
				errs[def.key] = true
			end
		end
	end
	if player.Parent ~= Players or joinTokens[player.UserId] ~= token then
		return false
	end
	local existing = ownership[player.UserId]
	if existing then
		-- OR-merge: a purchase that landed mid-load must not be downgraded by a stale false
		for key, owns in pairs(map) do
			existing[key] = existing[key] == true or owns
		end
	else
		ownership[player.UserId] = map
	end
	erroredKeys[player.UserId] = next(errs) and errs or nil
	return true
end

local function onPlayerAdded(player)
	local token = (joinTokens[player.UserId] or 0) + 1
	joinTokens[player.UserId] = token
	if loadOwnership(player, token) then
		loaded[player.UserId] = true
		push(player)
		changed:Fire(player, nil)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	ownership[player.UserId] = nil
	erroredKeys[player.UserId] = nil
	loaded[player.UserId] = nil
	lastRequest[player.UserId] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

requestEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if lastRequest[player.UserId] and now - lastRequest[player.UserId] < REQUEST_COOLDOWN then
		return
	end
	lastRequest[player.UserId] = now
	local map = ownership[player.UserId]
	local errs = erroredKeys[player.UserId]
	if map and errs then
		for key in pairs(errs) do
			local def = GamepassConfig.ByKey[key]
			local owns, ok = checkOwnership(player, def and def.id)
			if ok then
				map[key] = map[key] == true or owns
				errs[key] = nil
			end
		end
		if not next(errs) then
			erroredKeys[player.UserId] = nil
		end
	end
	push(player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased or gamePassId == 0 then
		return
	end
	local key
	for _, def in ipairs(GamepassConfig.Passes) do
		if def.id == gamePassId then
			key = def.key
			break
		end
	end
	if not key then
		return
	end
	-- the join-time load may still be in flight: store now, loadOwnership merges instead of replacing
	local map = ownership[player.UserId]
	if not map then
		map = {}
		ownership[player.UserId] = map
	end
	map[key] = true
	push(player)
	changed:Fire(player, key)
end)
