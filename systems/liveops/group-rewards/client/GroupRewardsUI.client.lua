local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("GroupRewardsConfig"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local GroupRewards = require(script.Parent:WaitForChild("GroupRewards"))

if not GroupRewards.enabled() then
	return
end

local player = Players.LocalPlayer

local win = UIStyle.window({
	name = "GroupRewardsUI",
	key = Config.WINDOW_KEY,
	title = "OUR GROUP",
	color = UIStyle.Colors.blue,
	icon = Icons.Friends,
	aspect = 2.2,
})
local sizeCap = win.frame:FindFirstChildOfClass("UISizeConstraint")
if sizeCap then
	sizeCap.MaxSize = Vector2.new(760, 380)
end

GroupRewards.mountCard(win.body, {
	anchor = Vector2.new(0.5, 0.5),
	position = UDim2.fromScale(0.5, 0.55),
	size = UDim2.fromScale(1, 0.82),
})

if Config.HUD_TILE then
	local tile = UIStyle.hudButton({
		label = "Group",
		icon = Icons.Friends,
		color = UIStyle.Colors.blue,
		order = Config.HUD_ORDER,
	})
	tile.Activated:Connect(win.toggle)
end

local lastPadTouch = 0
local wired = setmetatable({}, { __mode = "k" })

local function wirePad(pad)
	if wired[pad] or not pad:IsA("BasePart") then
		return
	end
	wired[pad] = true
	pad.Touched:Connect(function(hit)
		local character = player.Character
		if not character or not hit:IsDescendantOf(character) then
			return
		end
		local now = os.clock()
		if now - lastPadTouch < Config.PAD_COOLDOWN then
			return
		end
		lastPadTouch = now
		GroupRewards.joinOrClaim()
	end)
end

CollectionService:GetInstanceAddedSignal(Config.PAD_TAG):Connect(wirePad)
for _, pad in ipairs(CollectionService:GetTagged(Config.PAD_TAG)) do
	wirePad(pad)
end
