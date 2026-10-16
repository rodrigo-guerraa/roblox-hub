local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIConfig = require(ReplicatedStorage:WaitForChild("UIConfig"))
local SoundFX = require(script.Parent:WaitForChild("SoundFX"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))

if not UIConfig.Music.enabled then
	return
end

local group = Instance.new("SoundGroup")
group.Name = "Music"
group.Volume = 1
group.Parent = SoundService

local function track(def, looped)
	local sound = Instance.new("Sound")
	sound.SoundId = def.id
	sound.Volume = def.volume or 0.22
	sound.Looped = looped
	sound.SoundGroup = group
	sound.Parent = group
	return sound
end

if SoundFX.Ambience then
	track(SoundFX.Ambience, true):Play()
end

local songs = {}
for _, def in ipairs(SoundFX.Music) do
	table.insert(songs, track(def, false))
end

if #songs > 0 then
	local index = math.random(#songs)
	local function playNext()
		index = index % #songs + 1
		songs[index]:Play()
	end
	for _, song in ipairs(songs) do
		song.Ended:Connect(playNext)
	end
	playNext()
end

if not UIConfig.Music.muteButton then
	return
end

local muted = false
local button = UIStyle.hudButton({
	label = "Music",
	icon = Icons.SoundOn,
	color = UIStyle.Colors.teal,
	order = UIConfig.Music.buttonOrder or 9,
})
local icon = button:FindFirstChild("Icon")
button.Activated:Connect(function()
	muted = not muted
	group.Volume = muted and 0 or 1
	if icon and icon:IsA("ImageLabel") then
		icon.Image = muted and Icons.SoundOff or Icons.SoundOn
	end
end)
