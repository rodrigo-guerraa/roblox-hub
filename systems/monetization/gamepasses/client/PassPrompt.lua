local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamepassConfig = require(ReplicatedStorage:WaitForChild("GamepassConfig"))
local Notice = require(script.Parent:WaitForChild("Notice"))

local policyModule = ReplicatedStorage:WaitForChild("PaidRandomItems", 2)
local PaidRandomItems = policyModule and require(policyModule)

local player = Players.LocalPlayer

local PassPrompt = {}

local lastOffer = {}

function PassPrompt.Owns(key)
	return player:GetAttribute(GamepassConfig.Attribute(key)) == true
end

function PassPrompt.OwnershipChanged(key)
	return player:GetAttributeChangedSignal(GamepassConfig.Attribute(key))
end

function PassPrompt.CanBuy(key)
	return not (PaidRandomItems and PaidRandomItems.IsPassBlocked(player, key))
end

function PassPrompt.Offer(key, cooldown)
	if PassPrompt.Owns(key) or not PassPrompt.CanBuy(key) then
		return false
	end
	local now = os.clock()
	if lastOffer[key] and now - lastOffer[key] < (cooldown or 0) then
		return false
	end
	lastOffer[key] = now
	local def = GamepassConfig.ByKey[key]
	if not def or def.id == 0 then
		Notice.Show(string.format("%s isn't on sale yet!", def and def.title or "This pass"))
		return true
	end
	MarketplaceService:PromptGamePassPurchase(player, def.id)
	return true
end

return PassPrompt
