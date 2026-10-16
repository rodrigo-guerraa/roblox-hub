local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local UIConfig = require(ReplicatedStorage:WaitForChild("UIConfig"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local config = UIConfig.LoadingScreen
if not config.enabled then
	return
end

local player = Players.LocalPlayer

local waits = {}
for _, entry in ipairs(config.waitEvents or {}) do
	if type(entry) == "string" then
		table.insert(waits, { kind = "event", name = entry })
	elseif type(entry) == "table" and entry.event then
		table.insert(waits, { kind = "event", name = entry.event, request = entry.request })
	end
end
for _, name in ipairs(config.waitAttributes or {}) do
	table.insert(waits, { kind = "attribute", name = name })
end

local received = {}

local screenGui = UIStyle.screen("LoadingScreen", 100, true)

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
backdrop.BorderSizePixel = 0
backdrop.Active = true
backdrop.Parent = screenGui
local backdropGradient = Instance.new("UIGradient")
backdropGradient.Rotation = 90
backdropGradient.Color = ColorSequence.new(config.topColor, config.bottomColor)
backdropGradient.Parent = backdrop

local content = Instance.new("Frame")
content.Name = "Content"
content.AnchorPoint = Vector2.new(0.5, 0.5)
content.Position = UDim2.fromScale(0.5, 0.5)
content.Size = UDim2.fromScale(0.8, 0.7)
content.BackgroundTransparency = 1
content.Parent = backdrop
UIStyle.aspect(content, 1.6)
local contentCap = Instance.new("UISizeConstraint")
contentCap.MaxSize = Vector2.new(760, 475)
contentCap.Parent = content
local contentScale = Instance.new("UIScale")
contentScale.Parent = content

local icon = UIStyle.image(content, {
	name = "Icon",
	image = config.icon or "",
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.25),
	size = UDim2.fromScale(0.4, 0.44),
})

UIStyle.text(content, {
	name = "Title",
	text = UIConfig.Title,
	font = UIStyle.Fonts.title,
	color = UIStyle.Colors.gold,
	outline = 5,
	max = 100,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.6),
	size = UDim2.fromScale(1, 0.22),
	z = 2,
})

local bar, setProgress = UIStyle.bar(content, {
	name = "Progress",
	color = config.barColor,
	outlineWidth = 3,
	position = UDim2.fromScale(0.19, 0.78),
	size = UDim2.fromScale(0.62, 0.11),
})
local subtitle = bar:FindFirstChild("Label")
subtitle.Name = "Subtitle"
subtitle.Font = UIStyle.Fonts.title
setProgress(0, "Loading")

local function countReceived()
	local count = 0
	for _, entry in ipairs(waits) do
		if received[entry] then
			count += 1
		end
	end
	return count
end

local hidden = false
task.spawn(function()
	local step = 0
	while not hidden do
		setProgress(
			#waits > 0 and countReceived() / #waits or 1,
			"Loading" .. string.rep(".", math.floor(step / 4) % 4)
		)
		icon.Rotation = math.sin(step * 0.5) * 10
		step += 1
		task.wait(0.1)
	end
end)

local connections = {}
local fontsReady = false

local function tryHide()
	if hidden or not fontsReady or countReceived() < #waits then
		return
	end
	hidden = true

	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	table.clear(connections)

	TweenService
		:Create(contentScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 })
		:Play()
	local fadeBackdrop = TweenService:Create(
		backdrop,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	fadeBackdrop:Play()
	fadeBackdrop.Completed:Connect(function()
		screenGui:Destroy()
	end)
end

local function mark(entry)
	received[entry] = true
	tryHide()
end

local Remotes = nil
for _, entry in ipairs(waits) do
	if entry.kind == "attribute" then
		if player:GetAttribute(entry.name) ~= nil then
			received[entry] = true
		else
			table.insert(
				connections,
				player:GetAttributeChangedSignal(entry.name):Connect(function()
					mark(entry)
				end)
			)
		end
	else
		Remotes = Remotes or require(ReplicatedStorage:WaitForChild("Remotes"))
		task.spawn(function()
			local event = Remotes.event(entry.name)
			if hidden then
				return
			end
			table.insert(
				connections,
				event.OnClientEvent:Connect(function()
					mark(entry)
				end)
			)
			-- a queued payload goes only to the first listener, so another script may already have consumed it
			if entry.request and not received[entry] then
				Remotes.event(entry.request):FireServer()
			end
		end)
	end
end

-- the cartoon fonts stream in after join; hiding before they land flashes every label in the default font
task.spawn(function()
	local samples = {}
	for _, label in ipairs(content:GetDescendants()) do
		if label:IsA("TextLabel") then
			table.insert(samples, label)
		end
	end
	pcall(ContentProvider.PreloadAsync, ContentProvider, samples)
	fontsReady = true
	tryHide()
end)

task.delay(config.timeout or 10, function()
	fontsReady = true
	if hidden then
		return
	end
	local missing = {}
	for _, entry in ipairs(waits) do
		if not received[entry] then
			table.insert(missing, entry.name)
		end
	end
	if #missing > 0 then
		warn("LoadingScreen: timeout reached. Missing initial sync from: " .. table.concat(missing, ", "))
	end
	for _, entry in ipairs(waits) do
		received[entry] = true
	end
	tryHide()
end)
