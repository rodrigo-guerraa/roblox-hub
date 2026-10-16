local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReceiptConfig = require(ReplicatedStorage:WaitForChild("ReceiptConfig"))
local CurrencyPacks = require(ReplicatedStorage:WaitForChild("CurrencyPacks"))

local NOT_PROCESSED = Enum.ProductPurchaseDecision.NotProcessedYet
local GRANTED = Enum.ProductPurchaseDecision.PurchaseGranted

local handlers = {}
local inFlight = {}
local blockedCheck

local API = {}

function API.Register(productId, handler, kind)
	if type(productId) ~= "number" or productId == 0 or type(handler) ~= "function" then
		return false
	end
	if handlers[productId] then
		warn("ReceiptService: product", productId, "registered twice; the last handler wins")
	end
	handlers[productId] = { handler = handler, kind = kind }
	return true
end

function API.Unregister(productId)
	handlers[productId] = nil
end

function API.IsRegistered(productId)
	return handlers[productId] ~= nil
end

function API.GetKind(productId)
	local entry = handlers[productId]
	return entry and entry.kind or nil
end

function API.SetBlockedCheck(fn)
	blockedCheck = type(fn) == "function" and fn or nil
end

function API.IsBlocked(player, productId)
	if not blockedCheck then
		return false
	end
	local ok, blocked = pcall(blockedCheck, player, productId, API.GetKind(productId))
	-- a broken policy check must not unblock anything
	return not ok or blocked == true
end

function API.Prompt(player, productId)
	if not handlers[productId] or API.IsBlocked(player, productId) then
		return false
	end
	MarketplaceService:PromptProductPurchase(player, productId)
	return true
end

-- ProcessReceipt is set-only, so the body lives here where a temporary test Script can call it with fake receipts
function API.HandleReceipt(receiptInfo)
	if type(receiptInfo) ~= "table" then
		return NOT_PROCESSED
	end
	local entry = handlers[receiptInfo.ProductId]
	local purchaseId = receiptInfo.PurchaseId
	if not entry or purchaseId == nil then
		return NOT_PROCESSED
	end
	local DataService = shared.DataServiceAPI
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not DataService or not player then
		return NOT_PROCESSED
	end
	if not DataService.WaitForData(player) or player.Parent ~= Players then
		return NOT_PROCESSED
	end
	if DataService.HasPurchase(player, purchaseId) then
		return GRANTED
	end
	if inFlight[purchaseId] or API.IsBlocked(player, receiptInfo.ProductId) then
		return NOT_PROCESSED
	end

	inFlight[purchaseId] = true
	local ok, granted = pcall(entry.handler, player, receiptInfo)
	inFlight[purchaseId] = nil
	if not ok then
		warn("ReceiptService: handler for", receiptInfo.ProductId, "failed:", granted)
		return NOT_PROCESSED
	end
	if granted ~= true or not DataService.GetData(player) then
		return NOT_PROCESSED
	end
	DataService.RecordPurchase(player, purchaseId)
	return GRANTED
end

local function grantCurrencyPack(def)
	return function(player)
		local Economy = shared.EconomyAPI
		if not Economy then
			return false
		end
		local payout = CurrencyPacks.Payout(def, Economy.GetIncome(player))
		if payout <= 0 then
			return false
		end
		Economy.Grant(player, payout, ReceiptConfig.GRANT_SOURCE)
		return true
	end
end

for _, def in ipairs(CurrencyPacks.List()) do
	if def.id ~= 0 then
		API.Register(def.id, grantCurrencyPack(def), def.kind)
	end
end

shared.ReceiptAPI = API

MarketplaceService.ProcessReceipt = API.HandleReceipt
