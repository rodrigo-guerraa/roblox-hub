local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Debris            = game:GetService("Debris")
local GuiService        = game:GetService("GuiService")

local UIConfig = require(ReplicatedStorage:WaitForChild("UIConfig"))
local SoundFX  = require(script.Parent:WaitForChild("SoundFX"))
local UIStyle  = require(script.Parent:WaitForChild("UIStyle"))

local C = Color3.fromRGB

local Effects = {}

Effects.Colors = {
	gold   = C(255, 205, 60),
	cyan   = C(90, 220, 255),
	amber  = C(255, 160, 40),
	pink   = C(255, 120, 200),
	white  = C(255, 255, 255),
	red    = C(255, 90, 80),
}

local COIN_FLIGHT_SECONDS = 0.6
local COIN_STAGGER        = 0.045
local MAX_COINS           = 16
local CONFETTI_COLORS     = {
	UIStyle.Colors.gold, UIStyle.Colors.blue, UIStyle.Colors.pink, UIStyle.Colors.green,
	UIStyle.Colors.purple, UIStyle.Colors.orange, UIStyle.Colors.teal,
}

local gui = UIStyle.screen("EffectsGui", 20, true)

local currencyTarget = nil

local function tween(object, seconds, goal, style, direction)
	local t = TweenService:Create(object, TweenInfo.new(seconds, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), goal)
	t:Play()
	return t
end

local function fxPart(position)
	local part = Instance.new("Part")
	part.Anchored     = true
	part.CanCollide   = false
	part.CanQuery     = false
	part.CanTouch     = false
	part.CastShadow   = false
	part.Transparency = 1
	part.Size         = Vector3.new(1, 1, 1)
	part.Position     = position
	part.Parent       = workspace
	return part
end

-- world effects

function Effects.Burst(position, color, amount)
	color = color or Effects.Colors.gold
	local holder = fxPart(position)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture       = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color         = ColorSequence.new(color)
	emitter.LightEmission = 0.7
	emitter.Speed         = NumberRange.new(8, 15)
	emitter.SpreadAngle   = Vector2.new(180, 180)
	emitter.Lifetime      = NumberRange.new(0.4, 0.8)
	emitter.Size          = NumberSequence.new(0.7, 0)
	emitter.Acceleration  = Vector3.new(0, -12, 0)
	emitter.Rate          = 0
	emitter.Parent        = holder
	emitter:Emit(amount or 24)
	local light = Instance.new("PointLight")
	light.Color      = color
	light.Range      = 14
	light.Brightness = 3
	light.Parent     = holder
	tween(light, 0.5, { Brightness = 0 })
	Debris:AddItem(holder, 1.5)
end

function Effects.Ring(position, color, radius)
	local ring = fxPart(position)
	ring.Shape        = Enum.PartType.Cylinder
	ring.Material     = Enum.Material.Neon
	ring.Color        = color or Effects.Colors.gold
	ring.Size         = Vector3.new(0.15, 1, 1)
	ring.CFrame       = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Transparency = 0.25
	local diameter = (radius or 5) * 2
	tween(ring, 0.5, { Size = Vector3.new(0.15, diameter, diameter), Transparency = 1 })
	Debris:AddItem(ring, 0.6)
end

function Effects.WorldToScreen(position)
	local camera = workspace.CurrentCamera
	local point, onScreen = camera:WorldToViewportPoint(position)
	return Vector2.new(point.X, point.Y), onScreen and point.Z > 0
end

-- the effects layer ignores the top-bar inset, so objects in ScreenGuis that don't must be shifted down by it
function Effects.CenterOf(guiObject)
	-- AbsolutePosition starts below the top bar in every ScreenGui; effects draw in screen pixels
	return guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2 + GuiService:GetGuiInset()
end

-- screen effects

-- the GuiObject that payout coins fly into (the currency counter); nil = coins pop at the source instead
function Effects.setCurrencyTarget(guiObject)
	currencyTarget = guiObject
end

function Effects.getCurrencyTarget()
	if currencyTarget and currencyTarget.Parent then
		return currencyTarget
	end
	return nil
end

function Effects.BumpCounter()
	local target = Effects.getCurrencyTarget()
	if not target then return end
	local scale = target:FindFirstChild("BumpScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name   = "BumpScale"
		scale.Parent = target
	end
	scale.Scale = 1.12
	tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function coinSize()
	return math.clamp(gui.AbsoluteSize.Y * 0.055, 22, 50)
end

local function makeCoin()
	local coin = Instance.new("ImageLabel")
	coin.AnchorPoint            = Vector2.new(0.5, 0.5)
	coin.BackgroundTransparency = 1
	coin.Image                  = UIConfig.Currency.icon
	coin.ScaleType              = Enum.ScaleType.Fit
	coin.ZIndex                 = 5
	coin.Parent                 = gui
	return coin
end

local function popCoins(fromScreen, count, base, spread)
	for i = 1, count do
		task.delay((i - 1) * COIN_STAGGER, function()
			local start = fromScreen + Vector2.new(math.random(-20, 20), math.random(-10, 10)) * spread
			local goal = start + Vector2.new(math.random(-60, 60), -math.random(50, 110)) * spread
			local coin = makeCoin()
			coin.Position = UDim2.fromOffset(start.X, start.Y)
			coin.Size = UDim2.fromOffset(base * 0.8, base * 0.8)
			tween(coin, 0.5, { Position = UDim2.fromOffset(goal.X, goal.Y), Rotation = math.random(-180, 180), ImageTransparency = 1 })
			Debris:AddItem(coin, 0.55)
		end)
	end
end

-- classic sim payout: coins pop out of the source and arc into the currency target, bumping it on arrival.
-- `text` (e.g. "+$1.2K") also floats up from the source
function Effects.FlyCoins(fromScreen, count, text)
	SoundFX.play("coin", { gap = 0.12, jitter = true })
	count = math.clamp(math.floor(count or 8), 1, MAX_COINS)
	local base = coinSize()
	local spread = base / 26
	if text then
		Effects.FloatText(text, fromScreen)
	end
	local target = Effects.getCurrencyTarget()
	if not target then
		popCoins(fromScreen, math.min(count, 6), base, spread)
		return
	end
	for i = 1, count do
		task.delay((i - 1) * COIN_STAGGER, function()
			local goal = Effects.CenterOf(target)
			local start = fromScreen + Vector2.new(math.random(-34, 34), math.random(-24, 24)) * spread
			local control = start:Lerp(goal, 0.35) + Vector2.new(math.random(-120, 120), -math.random(80, 170)) * spread
			local coin = makeCoin()
			coin.Position = UDim2.fromOffset(start.X, start.Y)
			coin.Size = UDim2.fromOffset(base * 0.5, base * 0.5)
			local spin = math.random(-360, 360)
			local started = os.clock()
			local connection
			connection = RunService.RenderStepped:Connect(function()
				local t = math.clamp((os.clock() - started) / COIN_FLIGHT_SECONDS, 0, 1)
				local eased = t * t * (3 - 2 * t)
				local a = start:Lerp(control, eased)
				local b = control:Lerp(goal, eased)
				local p = a:Lerp(b, eased)
				coin.Position = UDim2.fromOffset(p.X, p.Y)
				coin.Rotation = spin * t
				local size = base * (t < 0.15 and (0.5 + t / 0.15 * 0.5) or (1 - math.max(0, t - 0.8) * 2.5))
				coin.Size = UDim2.fromOffset(size, size)
				if t >= 1 then
					connection:Disconnect()
					coin:Destroy()
					Effects.BumpCounter()
				end
			end)
		end)
	end
end

-- big outlined title text; returns the label, its outline and the UIScale it pops on
local function shoutLabel(text, color, size, position, outline, maxText, z)
	local label = UIStyle.text(gui, {
		text = text, font = UIStyle.Fonts.title, color = color, outline = outline, max = maxText,
		anchor = Vector2.new(0.5, 0.5), position = position, size = size, z = z,
	})
	local stroke = label:FindFirstChildOfClass("UIStroke")
	local scale = Instance.new("UIScale")
	scale.Parent = label
	return label, stroke, scale
end

local function fadeOut(label, stroke, seconds)
	tween(label, seconds, { TextTransparency = 1 })
	if stroke then
		tween(stroke, seconds, { Transparency = 1 })
	end
end

function Effects.FloatText(text, screenPos, color, size)
	local height = 0.075 * (size or 30) / 30
	local label, stroke, scale = shoutLabel(text, color or UIStyle.Colors.gold, UDim2.fromScale(0.6, height),
		UDim2.fromOffset(screenPos.X, screenPos.Y), 3, math.floor((size or 30) * 1.6), 7)
	local rise = gui.AbsoluteSize.Y * 0.1
	scale.Scale = 0.4
	tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	tween(label, 1, { Position = UDim2.fromOffset(screenPos.X, screenPos.Y - rise) })
	task.delay(0.6, function()
		fadeOut(label, stroke, 0.4)
	end)
	Debris:AddItem(label, 1.1)
end

function Effects.ScreenFlash(color, strength, seconds)
	local flash = Instance.new("Frame")
	flash.Size                   = UDim2.fromScale(1, 1)
	flash.BackgroundColor3       = color or Effects.Colors.white
	flash.BackgroundTransparency = 1 - (strength or 0.5)
	flash.BorderSizePixel        = 0
	flash.ZIndex                 = 1
	flash.Parent                 = gui
	tween(flash, seconds or 0.35, { BackgroundTransparency = 1 })
	Debris:AddItem(flash, (seconds or 0.35) + 0.1)
end

function Effects.Confetti(count)
	local viewport = gui.AbsoluteSize
	local unit = math.clamp(viewport.Y / 720, 0.6, 1.6)
	for _ = 1, count or 40 do
		local piece = Instance.new("Frame")
		piece.AnchorPoint      = Vector2.new(0.5, 0.5)
		piece.Size             = UDim2.fromOffset(math.random(9, 15) * unit, math.random(15, 24) * unit)
		piece.BackgroundColor3 = CONFETTI_COLORS[math.random(1, #CONFETTI_COLORS)]
		piece.BorderSizePixel  = 0
		piece.Rotation         = math.random(0, 360)
		piece.ZIndex           = 4
		UIStyle.corner(piece, 0.3)
		local stroke = UIStyle.stroke(piece, 1.5)
		local x = math.random(0, math.floor(viewport.X))
		piece.Position = UDim2.fromOffset(x, -20)
		piece.Parent   = gui
		local fall = math.random(110, 190) / 100
		local drift = TweenInfo.new(fall, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(piece, drift, {
			Position = UDim2.fromOffset(x + math.random(-120, 120) * unit, viewport.Y * math.random(55, 100) / 100),
			Rotation = piece.Rotation + math.random(-540, 540),
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(stroke, drift, { Transparency = 1 }):Play()
		Debris:AddItem(piece, fall + 0.1)
	end
end

function Effects.Banner(text, color)
	local label, stroke, scale = shoutLabel(text, color or UIStyle.Colors.gold, UDim2.fromScale(0.9, 0.15),
		UDim2.fromScale(0.5, 0.31), 5, 110, 8)
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color    = ColorSequence.new(Color3.new(1, 1, 1), C(214, 214, 214))
	gradient.Parent   = label
	scale.Scale = 0.2
	tween(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(1.3, function()
		fadeOut(label, stroke, 0.4)
		tween(scale, 0.4, { Scale = 1.3 })
	end)
	Debris:AddItem(label, 1.8)
end

return Effects
