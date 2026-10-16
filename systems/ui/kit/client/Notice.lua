local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

local SHOW_SECONDS = 1.8
local FADE = TweenInfo.new(0.3)

local gui = UIStyle.screen("NoticeGui", 6)

local toast = UIStyle.panel(gui, {
	name = "Toast",
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.72),
	color = UIStyle.Theme.card,
	corner = 0.5,
	outlineWidth = 3,
	visible = false,
})
local stroke = toast:FindFirstChildOfClass("UIStroke")

local label = UIStyle.text(toast, {
	name = "Label",
	color = UIStyle.Theme.ink,
	max = 40,
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.52),
	size = UDim2.fromScale(0.9, 0.6),
})

-- the pill hugs its text: height follows the screen, width follows the text at that height
local function fit(text)
	local screen = gui.AbsoluteSize
	if screen.X <= 0 or screen.Y <= 0 then
		screen = workspace.CurrentCamera.ViewportSize
	end
	local height = screen.Y * (UIStyle.isPhone() and 0.1 or 0.058)
	local textSize = math.max(8, math.floor(height * 0.55))
	local width = TextService:GetTextSize(text, textSize, UIStyle.Fonts.body, Vector2.new(math.huge, math.huge)).X
			* 1.12
		+ height
	toast.Size = UDim2.fromScale(math.min(width / screen.X, 0.9), height / screen.Y)
end

local token = 0

local Notice = {}

function Notice.Show(text)
	token += 1
	local mine = token
	text = tostring(text)
	fit(text)
	label.Text = text
	label.TextTransparency = 0
	toast.BackgroundTransparency = 0
	stroke.Transparency = 0
	toast.Visible = true
	UIStyle.pop(toast, 0.8)
	task.delay(SHOW_SECONDS, function()
		if mine ~= token then
			return
		end
		TweenService:Create(label, FADE, { TextTransparency = 1 }):Play()
		TweenService:Create(toast, FADE, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(stroke, FADE, { Transparency = 1 }):Play()
		task.delay(0.3, function()
			if mine == token then
				toast.Visible = false
			end
		end)
	end)
end

return Notice
