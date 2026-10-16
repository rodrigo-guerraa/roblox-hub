local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local UIManager = require(ReplicatedStorage:WaitForChild("UIManager"))
local SoundFX = require(script.Parent:WaitForChild("SoundFX"))

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local C = Color3.fromRGB

local UIStyle = {}

UIStyle.Colors = {
	green = C(92, 214, 64),
	blue = C(58, 164, 255),
	purple = C(168, 96, 255),
	gold = C(255, 204, 40),
	orange = C(255, 142, 36),
	red = C(242, 66, 66),
	teal = C(36, 204, 192),
	pink = C(255, 104, 182),
	amber = C(255, 172, 30),
	brown = C(196, 128, 64),
	grey = C(150, 150, 166),
}

UIStyle.Theme = {
	outline = C(28, 20, 24),
	panel = C(255, 247, 228),
	panelEnd = C(246, 224, 186),
	card = C(255, 255, 255),
	cardLine = C(222, 198, 160),
	well = C(238, 220, 188),
	ink = C(74, 46, 26),
	inkSoft = C(150, 116, 82),
	white = C(255, 255, 255),
	dim = C(10, 8, 14),
}

UIStyle.Fonts = {
	title = Enum.Font.LuckiestGuy,
	body = Enum.Font.FredokaOne,
}

function UIStyle.isPhone()
	return camera.ViewportSize.Y < 520
end

-- outline widths are authored for a 720p screen and follow the screen height, so cartoon outlines stay in proportion
local strokes = setmetatable({}, { __mode = "k" })

local function strokeFactor()
	return math.clamp(camera.ViewportSize.Y / 720, 0.6, 1.6)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local factor = strokeFactor()
	for stroke, width in pairs(strokes) do
		stroke.Thickness = width * factor
	end
end)

function UIStyle.stroke(parent, width, color, mode)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UIStyle.Theme.outline
	stroke.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	strokes[stroke] = width or 3
	stroke.Thickness = strokes[stroke] * strokeFactor()
	stroke.Parent = parent
	return stroke
end

function UIStyle.corner(parent, scale)
	local corner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(scale or 0.2, 0)
	corner.Parent = parent
	return corner
end

-- the gradient multiplies BackgroundColor3, so recolouring a button by state keeps its shine
function UIStyle.gloss(parent)
	local gradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C(255, 255, 255)),
		ColorSequenceKeypoint.new(0.45, C(238, 238, 238)),
		ColorSequenceKeypoint.new(1, C(176, 176, 176)),
	})
	gradient.Parent = parent
	return gradient
end

-- FitWithinMaxSize only shrinks, so a zero-height row or a grid cell needs ScaleWithParentSize to grow
function UIStyle.aspect(parent, ratio, dominant)
	dominant = dominant or Enum.DominantAxis.Width
	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.AspectRatio = ratio
	constraint.DominantAxis = dominant
	local derived = parent:IsA("UIGridLayout")
	if parent:IsA("GuiObject") then
		local other = dominant == Enum.DominantAxis.Width and parent.Size.Y or parent.Size.X
		derived = other.Scale == 0 and other.Offset == 0
	end
	constraint.AspectType = derived and Enum.AspectType.ScaleWithParentSize or Enum.AspectType.FitWithinMaxSize
	constraint.Parent = parent
	return constraint
end

function UIStyle.padding(parent, x, y)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(x or 0.04, 0)
	padding.PaddingRight = UDim.new(x or 0.04, 0)
	padding.PaddingTop = UDim.new(y or x or 0.04, 0)
	padding.PaddingBottom = UDim.new(y or x or 0.04, 0)
	padding.Parent = parent
	return padding
end

local function applyCommon(object, props)
	object.Name = props.name or object.ClassName
	object.AnchorPoint = props.anchor or Vector2.zero
	object.Position = props.position or UDim2.new()
	object.Size = props.size or UDim2.fromScale(1, 1)
	object.LayoutOrder = props.order or 0
	object.ZIndex = props.z or 1
	if props.visible == false then
		object.Visible = false
	end
	if props.aspect then
		UIStyle.aspect(object, props.aspect)
	end
end

-- scaled text with a size cap; `outline` gives it the cartoon text outline
function UIStyle.text(parent, props)
	props = props or {}
	local label = Instance.new("TextLabel")
	applyCommon(label, props)
	label.BackgroundTransparency = 1
	label.Font = props.font or UIStyle.Fonts.body
	label.Text = props.text or ""
	label.TextColor3 = props.color or UIStyle.Theme.ink
	-- TextWrapped = false switches TextScaled off, so scaling is set last and short labels just never need to wrap
	label.TextWrapped = props.wrap ~= false
	label.TextScaled = true
	label.RichText = props.rich == true
	label.TextXAlignment = props.alignX or Enum.TextXAlignment.Center
	label.TextYAlignment = props.alignY or Enum.TextYAlignment.Center
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = props.max or 48
	cap.MinTextSize = 6
	cap.Parent = label
	if props.outline then
		UIStyle.stroke(
			label,
			type(props.outline) == "number" and props.outline or 2,
			props.outlineColor,
			Enum.ApplyStrokeMode.Contextual
		)
	end
	label.Parent = parent
	return label
end

function UIStyle.image(parent, props)
	props = props or {}
	local image = Instance.new("ImageLabel")
	applyCommon(image, props)
	image.BackgroundTransparency = 1
	image.Image = props.image or ""
	image.ScaleType = Enum.ScaleType.Fit
	if props.square ~= false and not props.aspect then
		UIStyle.aspect(image, 1)
	end
	image.Parent = parent
	return image
end

local function bounce(button)
	local scale = button:FindFirstChild("PressScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "PressScale"
		scale.Parent = button
	end
	local function to(value)
		TweenService
			:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = value })
			:Play()
	end
	button.MouseEnter:Connect(function()
		to(1.06)
	end)
	button.MouseLeave:Connect(function()
		to(1)
	end)
	button.MouseButton1Down:Connect(function()
		to(0.92)
	end)
	button.MouseButton1Up:Connect(function()
		to(1)
	end)
	button.Activated:Connect(function()
		SoundFX.play("click")
	end)
end

-- a chunky glossy button; its text lives in the child "Label" (UIStyle.setText) so it can carry a real outline
function UIStyle.button(parent, props)
	props = props or {}
	local button = Instance.new("TextButton")
	applyCommon(button, props)
	button.BackgroundColor3 = props.color or UIStyle.Colors.green
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Text = ""
	button:SetAttribute("BaseColor", button.BackgroundColor3)
	UIStyle.corner(button, props.round and 0.5 or 0.28)
	UIStyle.stroke(button, props.outlineWidth or 3)
	UIStyle.gloss(button)

	local hasIcon = props.icon ~= nil and props.icon ~= ""
	if hasIcon then
		UIStyle.image(button, {
			name = "Icon",
			image = props.icon,
			anchor = Vector2.new(0, 0.5),
			position = UDim2.fromScale(0.06, 0.5),
			size = UDim2.fromScale(0.3, 0.8),
		})
	end
	if props.text then
		UIStyle.text(button, {
			name = "Label",
			text = props.text,
			font = props.font or UIStyle.Fonts.body,
			color = props.textColor or UIStyle.Theme.white,
			outline = 2,
			max = props.max or 40,
			anchor = Vector2.new(hasIcon and 1 or 0.5, 0.5),
			position = hasIcon and UDim2.fromScale(0.95, 0.5) or UDim2.fromScale(0.5, 0.5),
			size = hasIcon and UDim2.fromScale(0.6, 0.72) or UDim2.fromScale(0.86, 0.72),
		})
	end
	bounce(button)
	button.Parent = parent
	return button
end

function UIStyle.setText(button, text)
	local label = button:FindFirstChild("Label")
	if label then
		label.Text = text
	else
		button.Text = text
	end
end

-- greys a button out (or restores its colour); a disabled button ignores clicks
function UIStyle.setEnabled(button, enabled, color)
	if color then
		button:SetAttribute("BaseColor", color)
	end
	button.Active = enabled
	button.Interactable = enabled
	button.BackgroundColor3 = enabled and (button:GetAttribute("BaseColor") or UIStyle.Colors.green)
		or UIStyle.Colors.grey
	button:SetAttribute("Enabled", enabled)
end

function UIStyle.isEnabled(button)
	return button:GetAttribute("Enabled") ~= false
end

-- a rounded, outlined frame: the base for windows, cards and wells
function UIStyle.panel(parent, props)
	props = props or {}
	local frame = Instance.new("Frame")
	applyCommon(frame, props)
	frame.BackgroundColor3 = props.color or UIStyle.Theme.panel
	frame.BorderSizePixel = 0
	if props.transparency then
		frame.BackgroundTransparency = props.transparency
	end
	UIStyle.corner(frame, props.corner or 0.12)
	if props.outlineWidth ~= 0 then
		UIStyle.stroke(frame, props.outlineWidth or 3, props.outlineColor)
	end
	if props.gloss then
		UIStyle.gloss(frame)
	end
	frame.Parent = parent
	return frame
end

function UIStyle.card(parent, props)
	props = props or {}
	props.color = props.color or UIStyle.Theme.card
	props.outlineColor = props.outlineColor or UIStyle.Theme.cardLine
	props.outlineWidth = props.outlineWidth or 2
	props.corner = props.corner or 0.14
	return UIStyle.panel(parent, props)
end

-- a scrolling list (rows stack) or grid (`columns` per row); rows/cells get their height from an aspect ratio, so the
-- list scales with the screen. Children of a list should use Size (1, 0, 0, 0) plus UIStyle.aspect
function UIStyle.scroll(parent, props)
	props = props or {}
	local scroll = Instance.new("ScrollingFrame")
	applyCommon(scroll, props)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = UIStyle.isPhone() and 4 or 7
	scroll.ScrollBarImageColor3 = UIStyle.Theme.inkSoft
	scroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

	local gap = props.gap or 8
	local layout
	if props.columns then
		layout = Instance.new("UIGridLayout")
		layout.CellSize = UDim2.new(1 / props.columns, -gap, 0, 0)
		layout.CellPadding = UDim2.fromOffset(gap, gap)
		UIStyle.aspect(layout, props.cellAspect or 1)
	else
		layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, gap)
	end
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = scroll

	-- room for the outlines of the first and last rows
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = scroll

	-- AutomaticCanvasSize undercounts rows sized by aspect constraints, cutting off the end of the list
	local function fitCanvas()
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fitCanvas)
	fitCanvas()

	scroll.Parent = parent
	return scroll, layout
end

-- a progress bar; returns the frame and set(fraction)
function UIStyle.bar(parent, props)
	props = props or {}
	local back = UIStyle.panel(parent, {
		name = props.name or "Bar",
		anchor = props.anchor,
		position = props.position,
		size = props.size,
		order = props.order,
		color = UIStyle.Theme.well,
		corner = 0.5,
		outlineWidth = props.outlineWidth or 2,
	})
	local fill = UIStyle.panel(back, {
		name = "Fill",
		size = UDim2.fromScale(0, 1),
		color = props.color or UIStyle.Colors.green,
		corner = 0.5,
		outlineWidth = 0,
		gloss = true,
	})
	local label
	if props.text ~= false then
		label = UIStyle.text(back, {
			name = "Label",
			color = UIStyle.Theme.white,
			outline = 2,
			size = UDim2.fromScale(0.94, 0.8),
			anchor = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.5),
			z = 2,
		})
	end
	local function set(fraction, text)
		fraction = math.clamp(fraction or 0, 0, 1)
		fill.Visible = fraction > 0
		TweenService:Create(
			fill,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{ Size = UDim2.fromScale(math.max(fraction, 0.06), 1) }
		):Play()
		if label and text then
			label.Text = text
		end
	end
	return back, set
end

-- AbsolutePosition is measured from below Roblox's top bar; UIStyle.screen layers are measured from the top of the screen
function UIStyle.screenTop(object)
	return object.AbsolutePosition.Y + GuiService:GetGuiInset().Y
end

function UIStyle.screenBottom(object)
	return UIStyle.screenTop(object) + object.AbsoluteSize.Y
end

function UIStyle.screen(name, order, ignoreInset)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = ignoreInset ~= false
	gui.DisplayOrder = order or 5
	gui.Parent = playerGui
	return gui
end

-- pop an element in from `from` (default 0.85) to full size on its own UIScale
function UIStyle.pop(object, from)
	local scale = object:FindFirstChild("PopScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "PopScale"
		scale.Parent = object
	end
	scale.Scale = from or 0.85
	TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()
end

-- a modal window: dimmed backdrop, cream panel, coloured title ribbon over the top edge, round close button.
-- Registered with UIManager under props.key; fill win.body. Sized from the screen with a fixed aspect ratio
function UIStyle.window(props)
	local gui = UIStyle.screen(props.name, props.order or 5)

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = UIStyle.Theme.dim
	overlay.BackgroundTransparency = 0.45
	overlay.Active = true
	overlay.Visible = false
	overlay.Parent = gui

	local frame = UIStyle.panel(overlay, {
		name = "Panel",
		anchor = Vector2.new(0.5, 0.5),
		color = UIStyle.Theme.panel,
		corner = 0.05,
		outlineWidth = 4,
	})
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new(C(255, 255, 255), C(240, 228, 206))
	gradient.Parent = frame
	UIStyle.aspect(frame, props.aspect or 1.55)
	local cap = Instance.new("UISizeConstraint")
	cap.MaxSize = Vector2.new(1320, 860)
	cap.Parent = frame

	local function place()
		local inset = GuiService:GetGuiInset().Y
		frame.Position = UDim2.new(0.5, 0, 0.5, math.floor(inset / 2) + (UIStyle.isPhone() and 6 or 12))
		frame.Size = UIStyle.isPhone() and UDim2.new(0.94, 0, 0.84, -inset) or UDim2.new(0.84, 0, 0.78, -inset)
	end
	place()
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(place)

	local ribbon = UIStyle.panel(frame, {
		name = "Ribbon",
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromScale(0.46, 0.13),
		color = props.color or UIStyle.Colors.orange,
		corner = 0.5,
		outlineWidth = 4,
		gloss = true,
		z = 3,
	})
	local title = UIStyle.text(ribbon, {
		name = "Title",
		text = props.title or "",
		font = UIStyle.Fonts.title,
		color = UIStyle.Theme.white,
		outline = 3,
		max = 56,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.5, 0.54),
		size = UDim2.fromScale(props.icon and 0.66 or 0.84, 0.78),
		z = 4,
	})
	local icon
	if props.icon then
		icon = UIStyle.image(ribbon, {
			name = "Icon",
			image = props.icon,
			anchor = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.07, 0.42),
			size = UDim2.fromScale(0.5, 1.7),
			z = 5,
		})
	end

	local close = UIStyle.button(frame, {
		name = "Close",
		text = "X",
		font = UIStyle.Fonts.title,
		color = UIStyle.Colors.red,
		round = true,
		outlineWidth = 3,
		anchor = Vector2.new(0.5, 0.5),
		position = UDim2.new(1, -6, 0, 6),
		size = UDim2.fromScale(0.13, 0.13),
		aspect = 1,
		z = 5,
	})

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromScale(0.035, 0.12)
	body.Size = UDim2.fromScale(0.93, 0.84)
	body.Parent = frame

	local win = {
		gui = gui,
		overlay = overlay,
		frame = frame,
		ribbon = ribbon,
		title = title,
		icon = icon,
		body = body,
		close = close,
	}

	function win.open()
		UIManager.open(props.key)
	end
	function win.hide()
		overlay.Visible = false
	end
	function win.toggle()
		if overlay.Visible then
			win.hide()
		else
			win.open()
		end
	end
	function win.setTitle(text)
		title.Text = text
	end

	UIManager.register(props.key, overlay)
	overlay:GetPropertyChangedSignal("Visible"):Connect(function()
		if overlay.Visible then
			UIStyle.pop(frame)
			if props.onOpen then
				props.onOpen()
			end
		elseif props.onClose then
			props.onClose()
		end
	end)
	close.Activated:Connect(win.hide)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Escape and overlay.Visible then
			win.hide()
		end
	end)
	return win
end

-- restyles a button made elsewhere to the kit look, keeping its own text
function UIStyle.styleButton(button, variant)
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Font = UIStyle.Fonts.body
	button.TextColor3 = UIStyle.Theme.white
	button.TextStrokeColor3 = UIStyle.Theme.outline
	button.TextStrokeTransparency = 0.2
	button:SetAttribute("BaseColor", button.BackgroundColor3)
	UIStyle.corner(button, variant == "close" and 0.5 or 0.28)
	if not button:FindFirstChildOfClass("UIStroke") then
		UIStyle.stroke(button, 3)
	end
	UIStyle.gloss(button)
	if variant == "close" then
		button.BackgroundColor3 = UIStyle.Colors.red
		button.Text = "X"
		button.Font = UIStyle.Fonts.title
		button.TextSize = math.max(button.TextSize, 16)
	end
	bounce(button)
	return button
end

-- shrinks `object` (never grows it) until it fits its ScreenGui around its AnchorPoint. The scale is kept in the FitScale
-- attribute; pop-in tweens on the same UIScale end at UIStyle.fitScale(object)
function UIStyle.fitToScreen(object, options)
	options = options or {}
	local margin = options.margin or 8
	local scale = object:FindFirstChild("FitScale") or Instance.new("UIScale")
	scale.Name = "FitScale"
	scale.Parent = object
	local applied = nil

	local function refresh()
		local gui = object:FindFirstAncestorWhichIsA("LayerCollector")
		if not gui or scale.Scale <= 0 then
			return
		end
		local size = object.AbsoluteSize / scale.Scale
		if size.X <= 0 or size.Y <= 0 then
			return
		end
		local anchor = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint
		local low = gui.AbsolutePosition
		local high = low + gui.AbsoluteSize
		if options.belowTopBar then
			low = Vector2.new(low.X, math.max(low.Y, 0))
		end
		local function limit(a, c, lo, hi)
			local s = math.huge
			if a > 0 then
				s = math.min(s, (c - lo - margin) / a)
			end
			if a < 1 then
				s = math.min(s, (hi - margin - c) / (1 - a))
			end
			return s
		end
		local fit = math.min(
			1,
			limit(object.AnchorPoint.X, anchor.X, low.X, high.X) / size.X,
			limit(object.AnchorPoint.Y, anchor.Y, low.Y, high.Y) / size.Y
		)
		fit = math.clamp(fit, 0.4, 1)
		-- re-fires during pop-in tweens; only a real change touches the scale so the tween isn't cut short
		if applied and math.abs(fit - applied) < 0.01 then
			return
		end
		applied = fit
		object:SetAttribute("FitScale", fit)
		scale.Scale = fit
	end

	object:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	object:GetPropertyChangedSignal("AbsolutePosition"):Connect(refresh)
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
	task.defer(refresh)
	return scale, refresh
end

function UIStyle.fitScale(object)
	return object:GetAttribute("FitScale") or 1
end

-- HUD dock: a 2-wide grid of menu tiles on the left and a fast-travel row bottom-right, sized from the screen height.
-- every tile sits in a fixed slot so hiding a covered tile never reflows the others
local TILE_GAP = 0.14
local TRAVEL_GAP = 0.3
local EDGE = 12

local dockGui = UIStyle.screen("HudDock", 3)

local leftDock = Instance.new("Frame")
leftDock.Name = "Left"
leftDock.BackgroundTransparency = 1
leftDock.Parent = dockGui

local grid = Instance.new("UIGridLayout")
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = leftDock

local travelDock = Instance.new("Frame")
travelDock.Name = "Travel"
travelDock.AnchorPoint = Vector2.new(1, 1)
travelDock.BackgroundTransparency = 1
travelDock.Parent = dockGui

local row = Instance.new("UIListLayout")
row.FillDirection = Enum.FillDirection.Horizontal
row.HorizontalAlignment = Enum.HorizontalAlignment.Right
row.SortOrder = Enum.SortOrder.LayoutOrder
row.Parent = travelDock

UIStyle.TravelDock = travelDock
UIStyle.LeftDock = leftDock

local tiles = {}
local sideCards = setmetatable({}, { __mode = "k" })
local topCards = setmetatable({}, { __mode = "k" })

local function shown(object)
	if not object.Parent or not object.Visible or object.AbsoluteSize.X <= 0 then
		return false
	end
	local gui = object:FindFirstAncestorWhichIsA("LayerCollector")
	return gui ~= nil and gui.Enabled and gui:IsDescendantOf(playerGui)
end

-- a card docked at the left or right edge (e.g. a held-item card); while visible it narrows topLane on its side
function UIStyle.registerSideCard(object)
	sideCards[object] = true
end

-- a top-centre element (currency counter, event banner); topLaneY stacks below the visible ones
function UIStyle.registerTopCard(object)
	topCards[object] = true
end

-- the free strip across the top of the screen between the menu and any side card, in screen pixels
function UIStyle.topLane(gap, extraCards)
	gap = gap or 8
	local left = leftDock.AbsolutePosition.X + leftDock.AbsoluteSize.X + gap
	local right = camera.ViewportSize.X - left
	local middle = camera.ViewportSize.X / 2
	local function narrow(card)
		if not shown(card) then
			return
		end
		local x = card.AbsolutePosition.X
		if x + card.AbsoluteSize.X / 2 >= middle then
			right = math.min(right, x - gap)
		else
			left = math.max(left, x + card.AbsoluteSize.X + gap)
		end
	end
	for card in pairs(sideCards) do
		narrow(card)
	end
	for _, card in ipairs(extraCards or {}) do
		narrow(card)
	end
	return left, math.max(right, left + 40)
end

-- the screen Y just below every visible registered top card (or just below the top bar when none is showing)
function UIStyle.topLaneY(gap, skip)
	gap = gap or 8
	local y = GuiService:GetGuiInset().Y + gap
	for card in pairs(topCards) do
		if card ~= skip and shown(card) then
			y = math.max(y, UIStyle.screenBottom(card) + gap)
		end
	end
	return y
end

local function countVisibleSlots(dock)
	local count = 0
	for _, child in ipairs(dock:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then
			count += 1
		end
	end
	return count
end

local function touchControls()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	return touchGui ~= nil and touchGui.Enabled and touchGui or nil
end

-- the menu sits mid-left (or, with touch controls, just under the top bar and above the thumbstick); the travel row
-- bottom-right, left of the jump button. Re-run every second because the top bar inset and touch controls appear late
local function layoutDocks()
	local screen = camera.ViewportSize
	local inset = GuiService:GetGuiInset().Y
	local touch = touchControls()

	local rows = math.max(1, math.ceil(countVisibleSlots(leftDock) / 2))
	local aspect = (2 + TILE_GAP) / (rows + (rows - 1) * TILE_GAP)
	local height = math.clamp(screen.Y * 0.11, 50, 104) * (rows + (rows - 1) * TILE_GAP)
	local stick = touch and touch:FindFirstChild("ThumbstickStart", true)
	if touch then
		local bottom = stick and stick.Visible and (stick.AbsolutePosition.Y + inset - 8) or screen.Y * 0.62
		height = math.min(height, bottom - (inset + 6))
		leftDock.AnchorPoint = Vector2.new(0, 0)
		leftDock.Position = UDim2.fromOffset(EDGE, inset + 6)
	else
		height = math.min(height, screen.Y - inset - 2 * EDGE)
		leftDock.AnchorPoint = Vector2.new(0, 0.5)
		leftDock.Position = UDim2.new(0, EDGE, 0.5, math.floor(inset / 2))
	end
	leftDock.Size = UDim2.fromOffset(math.floor(height * aspect), math.floor(height))
	grid.CellSize = UDim2.fromScale(1 / (2 + TILE_GAP), 1 / (rows + (rows - 1) * TILE_GAP))
	grid.CellPadding =
		UDim2.fromScale(TILE_GAP / (2 + TILE_GAP), rows > 1 and TILE_GAP / (rows + (rows - 1) * TILE_GAP) or 0)

	local count = math.max(1, countVisibleSlots(travelDock))
	local size = math.clamp(screen.Y * 0.13, 50, 96)
	travelDock.Size = UDim2.fromOffset(math.floor(size * (count + (count - 1) * TRAVEL_GAP)), math.floor(size * 1.3))
	row.Padding = UDim.new(0, math.floor(size * TRAVEL_GAP))
	local right = EDGE
	local jump = touch and touch:FindFirstChild("JumpButton", true)
	if jump and jump.Visible then
		right = math.max(EDGE, screen.X - jump.AbsolutePosition.X + 8)
	end
	travelDock.Position = UDim2.new(1, -right, 1, -EDGE)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutDocks)
task.spawn(function()
	while true do
		layoutDocks()
		task.wait(1)
	end
end)

function UIStyle.hudButton(options)
	local travel = options.dock == "travel"

	local slot = Instance.new("Frame")
	slot.Name = options.label .. "Slot"
	slot.BackgroundTransparency = 1
	slot.LayoutOrder = options.order or 0
	if travel then
		slot.Size = UDim2.fromScale(1, 1)
		UIStyle.aspect(slot, 1 / 1.3)
	end
	slot.Parent = travel and travelDock or leftDock

	local button = Instance.new("TextButton")
	button.Name = options.label .. "Button"
	button.Size = travel and UDim2.fromScale(1, 1 / 1.3) or UDim2.fromScale(1, 1)
	button.BackgroundColor3 = options.color or UIStyle.Colors.grey
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = slot
	UIStyle.corner(button, travel and 0.5 or 0.26)
	UIStyle.stroke(button, 3)
	UIStyle.gloss(button)
	bounce(button)

	local isImage = type(options.icon) == "string" and string.find(options.icon, "^rbxassetid://") ~= nil
	if isImage then
		UIStyle.image(button, {
			name = "Icon",
			image = options.icon,
			anchor = Vector2.new(0.5, 0.5),
			position = travel and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.4),
			size = travel and UDim2.fromScale(0.78, 0.78) or UDim2.fromScale(0.74, 0.64),
		})
	else
		UIStyle.text(button, {
			name = "Icon",
			text = options.icon or "",
			font = Enum.Font.GothamBold,
			anchor = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.42),
			size = UDim2.fromScale(0.7, 0.6),
		})
	end

	local label = UIStyle.text(travel and slot or button, {
		name = "Label",
		text = string.upper(options.label),
		font = UIStyle.Fonts.title,
		color = UIStyle.Theme.white,
		outline = 2,
		anchor = travel and Vector2.new(0.5, 1) or Vector2.new(0.5, 1),
		position = travel and UDim2.fromScale(0.5, 1) or UDim2.fromScale(0.5, 0.97),
		size = travel and UDim2.fromScale(1.3, 0.26) or UDim2.fromScale(1.02, 0.3),
		z = 2,
	})

	table.insert(tiles, { button = button, slot = slot, label = label })
	task.defer(layoutDocks)
	return button, slot
end

-- "covered" check: hide any tile that an open panel sits on top of
local function screenRect(object)
	return object.AbsolutePosition + GuiService:GetGuiInset(), object.AbsoluteSize
end

local function overlaps(a, b)
	local ap, as = screenRect(a)
	local bp, bs = screenRect(b)
	return ap.X < bp.X + bs.X and bp.X < ap.X + as.X and ap.Y < bp.Y + bs.Y and bp.Y < ap.Y + as.Y
end

local function refreshCovered()
	local open = UIManager.getOpenPanels()
	for _, tile in ipairs(tiles) do
		local covered = false
		for _, panel in ipairs(open) do
			if overlaps(tile.slot, panel) then
				covered = true
				break
			end
		end
		tile.button.Visible = not covered
		if tile.label.Parent == tile.slot then
			tile.label.Visible = not covered
		end
	end
end

UIManager.panelsChanged:Connect(function()
	refreshCovered()
	task.defer(refreshCovered)
end)

return UIStyle
