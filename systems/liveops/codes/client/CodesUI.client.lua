local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local CodesConfig = require(ReplicatedStorage:WaitForChild("CodesConfig"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local SoundFX = require(script.Parent:WaitForChild("SoundFX"))

local redeemEvent = Remotes.event(CodesConfig.REMOTE_REDEEM)
local resultEvent = Remotes.event(CodesConfig.REMOTE_RESULT)

local Theme = UIStyle.Theme
local Colors = UIStyle.Colors

local SUCCESS = Color3.fromRGB(46, 150, 56)
local FAILURE = Color3.fromRGB(214, 52, 52)

local toggleButton =
	UIStyle.hudButton({ label = "Codes", icon = Icons.Codes, color = Colors.purple, order = CodesConfig.HUD_ORDER })

local win = UIStyle.window({
	name = "CodesUI",
	key = CodesConfig.WINDOW_KEY,
	title = "CODES",
	color = Colors.purple,
	icon = Icons.Codes,
	aspect = 1.9,
})
local sizeCap = win.frame:FindFirstChildOfClass("UISizeConstraint")
if sizeCap then
	sizeCap.MaxSize = Vector2.new(720, 600)
end

local section = Instance.new("Frame")
section.Name = "CodeSection"
section.BackgroundTransparency = 1
section.Size = UDim2.fromScale(1, 1)
section.Parent = win.body

UIStyle.text(section, {
	name = "Prompt",
	text = "Enter a code for a free reward!",
	font = UIStyle.Fonts.title,
	color = Theme.ink,
	max = 32,
	anchor = Vector2.new(0.5, 0),
	position = UDim2.fromScale(0.5, 0.02),
	size = UDim2.fromScale(0.9, 0.155),
})

local box = Instance.new("TextBox")
box.Name = "CodeBox"
box.AnchorPoint = Vector2.new(0.5, 0)
box.Position = UDim2.fromScale(0.5, 0.207)
box.Size = UDim2.fromScale(0.86, 0.26)
box.BackgroundColor3 = Theme.card
box.BorderSizePixel = 0
box.Font = UIStyle.Fonts.body
box.PlaceholderText = "Type a code..."
box.PlaceholderColor3 = Theme.inkSoft
box.Text = ""
box.TextColor3 = Theme.ink
box.TextScaled = true
box.ClearTextOnFocus = false
box.Parent = section
UIStyle.corner(box, 0.3)
UIStyle.stroke(box, 3, Theme.cardLine)
UIStyle.padding(box, 0.04, 0.2)
local boxCap = Instance.new("UITextSizeConstraint")
boxCap.MaxTextSize = 36
boxCap.Parent = box

local redeemButton = UIStyle.button(section, {
	name = "RedeemButton",
	text = "REDEEM",
	font = UIStyle.Fonts.title,
	color = Colors.green,
	anchor = Vector2.new(0.5, 0),
	position = UDim2.fromScale(0.5, 0.52),
	size = UDim2.fromScale(0.56, 0.26),
})

local status = UIStyle.text(section, {
	name = "Status",
	text = CodesConfig.HINT,
	color = Theme.inkSoft,
	max = 26,
	anchor = Vector2.new(0.5, 0),
	position = UDim2.fromScale(0.5, 0.81),
	size = UDim2.fromScale(0.95, 0.17),
})

local function submit()
	local text = box.Text
	if text == "" then
		return
	end
	status.Text = "Checking..."
	status.TextColor3 = Theme.inkSoft
	redeemEvent:FireServer(text)
end

redeemButton.Activated:Connect(submit)
box.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submit()
	end
end)

resultEvent.OnClientEvent:Connect(function(result)
	if type(result) ~= "table" then
		return
	end
	if result.ok then
		status.Text = string.format("+%s!  %s", NumberFormat.Money(result.reward or 0), result.message or "")
		status.TextColor3 = SUCCESS
		box.Text = ""
		SoundFX.play("victory")
		Effects.FlyCoins(Effects.CenterOf(redeemButton), 16)
	else
		status.Text = result.message or "That didn't work."
		status.TextColor3 = FAILURE
		SoundFX.play("deny")
	end
end)

-- the group card joins the window only when the group-rewards system is installed and enabled
task.spawn(function()
	local groupModule = script.Parent:FindFirstChild("GroupRewards") or script.Parent:WaitForChild("GroupRewards", 5)
	if not groupModule then
		return
	end
	local GroupRewards = require(groupModule)
	if not GroupRewards.enabled() then
		return
	end
	local ratio = win.frame:FindFirstChildOfClass("UIAspectRatioConstraint")
	if ratio then
		ratio.AspectRatio = 1.2
	end
	section.Size = UDim2.fromScale(1, 0.58)
	GroupRewards.mountCard(win.body, {
		anchor = Vector2.new(0.5, 0),
		position = UDim2.fromScale(0.5, 0.6),
		size = UDim2.fromScale(0.98, 0.38),
	})
end)

toggleButton.Activated:Connect(win.toggle)
