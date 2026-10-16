local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local UIConfig = require(ReplicatedStorage:WaitForChild("UIConfig"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Effects = require(script.Parent:WaitForChild("Effects"))

local player = Players.LocalPlayer
local config = UIConfig.Currency

local PANEL_ASPECT = 3.4
local RATE_DROP = 1.3
local COUNT_SECONDS = 0.7
local INK = UIStyle.Theme.ink

local screenGui = UIStyle.screen("CurrencyDisplay", 2)

local panel = UIStyle.panel(screenGui, {
	name = "Panel",
	anchor = Vector2.new(0.5, 0),
	position = UDim2.new(0.5, 0, 0, 10),
	color = UIStyle.Theme.card,
	corner = 0.5,
	outlineWidth = 3,
})
UIStyle.aspect(panel, PANEL_ASPECT)
local panelGradient = Instance.new("UIGradient")
panelGradient.Rotation = 90
panelGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), UIStyle.Theme.panelEnd)
panelGradient.Parent = panel

-- the counter's footprint including the rate pill, untouched by the bump UIScale; banners and toasts stack below it
local footprint = Instance.new("Frame")
footprint.Name = "Footprint"
footprint.AnchorPoint = panel.AnchorPoint
footprint.Position = panel.Position
footprint.Size = UDim2.fromScale(1, 1)
footprint.BackgroundTransparency = 1
footprint.Parent = screenGui
local footprintAspect = UIStyle.aspect(footprint, PANEL_ASPECT)

UIStyle.image(panel, {
	name = "Icon",
	image = config.icon,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.05, 0.5),
	size = UDim2.fromScale(1, 1.35),
	z = 3,
})

local amountLabel = UIStyle.text(panel, {
	name = "Amount",
	text = config.prefix .. "0",
	font = UIStyle.Fonts.title,
	color = INK,
	max = 64,
	wrap = false,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.6, 0.47),
	size = UDim2.fromScale(0.66, 0.7),
	z = 2,
})

local ratePill = UIStyle.panel(panel, {
	name = "Rate",
	anchor = Vector2.new(0.5, 0.4),
	position = UDim2.fromScale(0.6, 1),
	size = UDim2.fromScale(0.52, 0.5),
	color = UIStyle.Colors.green,
	corner = 0.5,
	outlineWidth = 2,
	gloss = true,
	z = 4,
	visible = false,
})

local rateLabel = UIStyle.text(ratePill, {
	name = "Income",
	text = config.prefix .. "0" .. config.rateSuffix,
	font = UIStyle.Fonts.title,
	color = UIStyle.Theme.white,
	outline = 2,
	max = 32,
	wrap = false,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.54),
	size = UDim2.fromScale(0.86, 0.8),
	z = 5,
})

local function place()
	local height = UIStyle.isPhone() and 0.12 or 0.075
	local drop = ratePill.Visible and RATE_DROP or 1
	panel.Size = UDim2.fromScale(0.6, height)
	footprint.Size = UDim2.fromScale(0.6, height * drop)
	footprintAspect.AspectRatio = PANEL_ASPECT / drop
end
place()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(place)

UIStyle.registerTopCard(footprint)
Effects.setCurrencyTarget(panel)

local displayed = 0
local seeded = false
local countToken = 0

local function show(value)
	amountLabel.Text = config.prefix .. NumberFormat.Short(value)
end

-- gains roll up (timed to land with the flying coins), spends snap down with a red flash
local function setAmount(amount)
	amount = tonumber(amount) or 0
	countToken += 1
	local token = countToken
	if not seeded or amount <= displayed then
		if seeded and amount < displayed then
			amountLabel.TextColor3 = UIStyle.Colors.red
			TweenService:Create(amountLabel, TweenInfo.new(0.5), { TextColor3 = INK }):Play()
		end
		seeded = true
		displayed = amount
		show(amount)
		return
	end
	local from = displayed
	local started = os.clock()
	task.spawn(function()
		while token == countToken do
			local t = math.min(1, (os.clock() - started) / COUNT_SECONDS)
			displayed = from + (amount - from) * (1 - (1 - t) ^ 3)
			show(displayed)
			if t >= 1 then
				break
			end
			RunService.Heartbeat:Wait()
		end
	end)
end

local function setIncome()
	local income = player:GetAttribute(config.incomeAttribute)
	local visible = config.showIncome and type(income) == "number"
	if ratePill.Visible ~= visible then
		ratePill.Visible = visible
		place()
	end
	if visible then
		rateLabel.Text = config.prefix .. NumberFormat.Short(income) .. config.rateSuffix
	end
end

player:GetAttributeChangedSignal(config.attribute):Connect(function()
	setAmount(player:GetAttribute(config.attribute))
end)
player:GetAttributeChangedSignal(config.incomeAttribute):Connect(setIncome)

if player:GetAttribute(config.attribute) ~= nil then
	setAmount(player:GetAttribute(config.attribute))
end
setIncome()
