local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Config = require(ReplicatedStorage:WaitForChild("PlaytimeGiftsConfig"))
local GiftMath = require(ReplicatedStorage:WaitForChild("GiftMath"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local SoundFX = require(script.Parent:WaitForChild("SoundFX"))
local Notice = require(script.Parent:WaitForChild("Notice"))

local player = Players.LocalPlayer

local claimEvent = Remotes.event(Config.REMOTE_CLAIM)
local updateEvent = Remotes.event(Config.REMOTE_UPDATE)
local requestEvent = Remotes.event(Config.REMOTE_REQUEST)

local Colors, Theme = UIStyle.Colors, UIStyle.Theme

local state = nil
local receivedAt = 0
local claiming = false

local tile = UIStyle.hudButton({ label = "Gift", icon = Icons.Gift, color = Colors.red, order = Config.HUD_ORDER })
local tileLabel = tile:FindFirstChild("Label", true)

local badge = UIStyle.panel(tile, {
	name = "Badge",
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.92, 0.08),
	size = UDim2.fromScale(0.34, 0.34),
	color = Colors.gold,
	corner = 0.5,
	outlineWidth = 2,
	aspect = 1,
	z = 4,
	visible = false,
})
UIStyle.text(badge, { name = "Mark", text = "!", font = UIStyle.Fonts.title, color = Theme.white, outline = 2, z = 5 })

local win = UIStyle.window({
	name = "GiftUI",
	key = Config.WINDOW_KEY,
	title = "FREE GIFT",
	color = Colors.red,
	icon = Icons.Gift,
	aspect = 1.5,
})
local body = win.body

local giftImage = UIStyle.image(body, {
	name = "GiftImage",
	image = Icons.Gift,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.18, 0.42),
	size = UDim2.fromScale(0.34, 0.62),
})
local giftScale = Instance.new("UIScale")
giftScale.Parent = giftImage

local heading = UIStyle.text(body, {
	name = "Heading",
	text = "Gift #1",
	font = UIStyle.Fonts.title,
	color = Theme.ink,
	max = 40,
	position = UDim2.fromScale(0.38, 0.06),
	size = UDim2.fromScale(0.6, 0.14),
	alignX = Enum.TextXAlignment.Left,
})
local rewardLabel = UIStyle.text(body, {
	name = "Reward",
	text = "+$0",
	font = UIStyle.Fonts.title,
	color = Colors.green,
	outline = 3,
	max = 72,
	position = UDim2.fromScale(0.38, 0.2),
	size = UDim2.fromScale(0.6, 0.24),
	alignX = Enum.TextXAlignment.Left,
})
local _, setTimer = UIStyle.bar(body, {
	name = "Timer",
	position = UDim2.fromScale(0.38, 0.5),
	size = UDim2.fromScale(0.58, 0.13),
	color = Colors.red,
})
local hint = UIStyle.text(body, {
	name = "Hint",
	text = "",
	color = Theme.inkSoft,
	max = 26,
	position = UDim2.fromScale(0.02, 0.66),
	size = UDim2.fromScale(0.96, 0.1),
})
local claimButton = UIStyle.button(body, {
	name = "ClaimButton",
	text = "CLAIM",
	font = UIStyle.Fonts.title,
	color = Colors.green,
	icon = Icons.Gift,
	max = 44,
	anchor = Vector2.new(0.5, 0),
	position = UDim2.fromScale(0.5, 0.8),
	size = UDim2.fromScale(0.5, 0.18),
})

local function secondsLeft()
	if not state then
		return Config.INTERVAL
	end
	if state.ready then
		return 0
	end
	return math.max(0, state.interval - state.progress - (os.clock() - receivedAt))
end

local function formatTime(seconds)
	seconds = math.ceil(seconds)
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function preview(number)
	return GiftMath.Payout(player:GetAttribute("IncomePerSecond") or 0, number)
end

local function refresh()
	local number = state and state.giftNumber or 1
	local ready = state ~= nil and state.ready
	local left = secondsLeft()
	heading.Text = string.format("Gift #%d", number)
	rewardLabel.Text = "+" .. NumberFormat.Money(preview(number))
	if ready then
		setTimer(1, "READY!")
		UIStyle.setText(claimButton, "CLAIM")
	else
		local interval = state and state.interval or Config.INTERVAL
		setTimer(1 - left / interval, formatTime(left) .. " left")
		UIStyle.setText(claimButton, "WAIT " .. formatTime(left))
	end
	UIStyle.setEnabled(claimButton, ready and not claiming)
	hint.Text = string.format("Gifts grow the longer you play! Next one: +%s", NumberFormat.Money(preview(number + 1)))
	if tileLabel then
		tileLabel.Text = ready and "CLAIM!" or formatTime(left)
	end
	badge.Visible = ready
end

updateEvent.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	local wasReady = state ~= nil and state.ready
	state = payload
	receivedAt = os.clock()
	claiming = false
	if payload.claimed then
		local from = Effects.CenterOf(win.overlay.Visible and claimButton or tile)
		SoundFX.play("victory")
		Effects.FlyCoins(from, 18)
		Effects.FloatText("+" .. NumberFormat.Money(payload.claimed), from - Vector2.new(0, 40))
	elseif payload.ready and not wasReady then
		SoundFX.play("pop")
		Notice.Show("Your free gift is ready!")
	end
	refresh()
end)

claimButton.Activated:Connect(function()
	if claiming or not UIStyle.isEnabled(claimButton) then
		return
	end
	claiming = true
	UIStyle.setEnabled(claimButton, false)
	claimEvent:FireServer()
end)

tile.Activated:Connect(win.toggle)

player:GetAttributeChangedSignal("IncomePerSecond"):Connect(refresh)

-- countdown, plus a wobble on the gift while it waits to be opened
task.spawn(function()
	local t = 0
	while true do
		task.wait(0.25)
		t += 0.25
		refresh()
		local ready = state ~= nil and state.ready
		local wobble = ready and (1 + 0.08 * math.sin(t * 6)) or 1
		TweenService:Create(giftScale, TweenInfo.new(0.25), { Scale = wobble }):Play()
		local icon = tile:FindFirstChild("Icon")
		if icon then
			icon.Rotation = ready and 10 * math.sin(t * 8) or 0
		end
	end
end)

requestEvent:FireServer()
refresh()
