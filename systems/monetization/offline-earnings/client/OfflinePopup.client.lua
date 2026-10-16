local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OfflineConfig = require(ReplicatedStorage:WaitForChild("OfflineConfig"))
local OfflineMath = require(ReplicatedStorage:WaitForChild("OfflineMath"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local Notice = require(script.Parent:WaitForChild("Notice"))

-- other hub systems are optional; a short bounded wait covers replication order without stalling when absent
local function optional(parent, name)
	local module = parent:WaitForChild(name, 2)
	return module and require(module) or nil
end

local PaidRandomItems = optional(ReplicatedStorage, "PaidRandomItems")
local GamepassConfig = optional(ReplicatedStorage, "GamepassConfig")
local PassPrompt = optional(script.Parent, "PassPrompt")

local player = Players.LocalPlayer

local offlineEvent = Remotes.event("OfflineEarnings")
local collectEvent = Remotes.event("CollectOffline")
local requestEvent = Remotes.event("RequestOffline")

local Colors = UIStyle.Colors
local Theme = UIStyle.Theme

local gui = UIStyle.screen("OfflinePopupGui", 6)

local popup
local info

local function clearPopup()
	if popup then
		popup:Destroy()
		popup = nil
	end
end

local function boosterKey()
	local key = OfflineConfig.BOOSTER_PASS_KEY
	if key == "" or not PassPrompt or PassPrompt.Owns(key) or not PassPrompt.CanBuy(key) then
		return nil
	end
	return key
end

local function doubleStep(doubles)
	local step = OfflineMath.NextDouble(doubles)
	if step and PaidRandomItems and PaidRandomItems.IsProductBlocked(player, step.id, OfflineConfig.PRODUCT_KIND) then
		return nil
	end
	return step
end

local function render()
	local reshow = popup ~= nil
	clearPopup()
	if not info or (info.amount or 0) <= 0 then
		return
	end

	local passKey = boosterKey()
	local frame = UIStyle.panel(gui, {
		name = "OfflinePopup",
		color = Theme.panel,
		corner = 0.08,
		outlineWidth = 4,
		z = 5,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.5, UIStyle.isPhone() and 0.58 or 0.54),
		size = UIStyle.isPhone() and UDim2.fromScale(0.8, 0.62) or UDim2.fromScale(0.6, 0.42),
		aspect = passKey and 1.35 or 1.65,
	})
	popup = frame

	local ribbon = UIStyle.panel(frame, {
		name = "Ribbon",
		color = Colors.gold,
		corner = 0.5,
		outlineWidth = 4,
		gloss = true,
		z = 3,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromScale(0.66, 0.17),
	})
	UIStyle.text(ribbon, {
		name = "Title",
		text = OfflineConfig.TITLE,
		font = UIStyle.Fonts.title,
		color = Theme.white,
		outline = 3,
		z = 4,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.57, 0.54),
		size = UDim2.fromScale(0.7, 0.78),
		max = 48,
	})
	UIStyle.image(ribbon, {
		name = "Coin",
		image = Icons.CoinStack or Icons.Coin or "",
		z = 5,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.08, 0.42),
		size = UDim2.fromScale(0.5, 1.9),
	})

	local rows = passKey and { lead = 0.14, amount = 0.25, amountH = 0.19, buttons = 0.5, buttonsH = 0.21 }
		or { lead = 0.16, amount = 0.29, amountH = 0.22, buttons = 0.6, buttonsH = 0.27 }

	local doubles = info.doubles or 0
	local suffix = info.capped and " (max)" or ""
	if doubles > 0 then
		suffix = string.format(" (x%d!)", OfflineMath.Multiplier(doubles))
	end
	UIStyle.text(frame, {
		name = "Lead",
		text = OfflineConfig.LEAD,
		color = Theme.ink,
		anchor = Vector2.new(0.5, 0),
		position = UDim2.fromScale(0.5, rows.lead),
		size = UDim2.fromScale(0.86, 0.11),
		max = 28,
	})
	UIStyle.text(frame, {
		name = "Amount",
		text = NumberFormat.Money(info.amount) .. suffix,
		font = UIStyle.Fonts.title,
		color = Colors.green,
		outline = 3,
		anchor = Vector2.new(0.5, 0),
		position = UDim2.fromScale(0.5, rows.amount),
		size = UDim2.fromScale(0.86, rows.amountH),
		max = 64,
	})

	local function button(name, text, color, x)
		return UIStyle.button(frame, {
			name = name,
			text = text,
			color = color,
			font = UIStyle.Fonts.title,
			max = 34,
			anchor = Vector2.new(0.5, 0),
			position = UDim2.fromScale(x, rows.buttons),
			size = UDim2.fromScale(0.42, rows.buttonsH),
		})
	end

	local step = doubleStep(doubles)
	local collectButton = button("CollectButton", "COLLECT", Colors.green, step and 0.27 or 0.5)
	collectButton.Activated:Connect(function()
		if not UIStyle.isEnabled(collectButton) then
			return
		end
		UIStyle.setEnabled(collectButton, false)
		collectEvent:FireServer()
		task.delay(3, function()
			if collectButton.Parent then
				UIStyle.setEnabled(collectButton, true)
			end
		end)
	end)
	if step then
		local label = string.format("%s\nR$ %d", doubles == 0 and "COLLECT 2X" or "DOUBLE AGAIN", step.price)
		button("DoubleButton", label, Colors.blue, 0.73).Activated:Connect(function()
			if PaidRandomItems and PaidRandomItems.IsProductBlocked(player, step.id, OfflineConfig.PRODUCT_KIND) then
				Notice.Show(PaidRandomItems.MESSAGE)
				return
			end
			MarketplaceService:PromptProductPurchase(player, step.id)
		end)
	end

	if passKey then
		local ratio = math.floor(OfflineConfig.BOOSTED_RATE / OfflineConfig.RATE + 0.5)
		local def = GamepassConfig and GamepassConfig.ByKey[passKey]
		UIStyle.button(frame, {
			name = "BoosterButton",
			color = Colors.purple,
			max = 24,
			text = string.format("%s: earn %dx while you're away!", def and def.title or "Offline Booster", ratio),
			anchor = Vector2.new(0.5, 0),
			position = UDim2.fromScale(0.5, 0.77),
			size = UDim2.fromScale(0.9, 0.15),
		}).Activated
			:Connect(function()
				PassPrompt.Offer(passKey)
			end)
	end

	if not reshow then
		UIStyle.pop(frame)
	end
end

offlineEvent.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	local collected = tonumber(payload.collected) or 0
	if collected > 0 and popup then
		local from = Effects.CenterOf(popup)
		Effects.FlyCoins(from, 14)
		Effects.FloatText("+" .. NumberFormat.Money(collected), from - Vector2.new(0, 40))
	end
	info = (tonumber(payload.amount) or 0) > 0 and payload or nil
	render()
end)

local function rerender()
	if popup then
		render()
	end
end

if PaidRandomItems then
	player:GetAttributeChangedSignal(PaidRandomItems.ATTRIBUTE):Connect(rerender)
end
if PassPrompt and OfflineConfig.BOOSTER_PASS_KEY ~= "" then
	PassPrompt.OwnershipChanged(OfflineConfig.BOOSTER_PASS_KEY):Connect(rerender)
end

requestEvent:FireServer()
