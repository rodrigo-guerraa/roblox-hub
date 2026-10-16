local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local UIConfig = require(ReplicatedStorage:WaitForChild("UIConfig"))

local SoundFX = {}

-- Roblox-licensed library audio (APM Music, Pro Sound Effects) and engine-bundled sounds, so every id plays in any game
SoundFX.Sounds = {
	click = { id = "rbxasset://sounds/clickfast.wav", volume = 0.5 },
	coin = { id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.35, pitch = 1.25 },
	pop = { id = "rbxassetid://9119669295", volume = 0.6 },
	crack = { id = "rbxassetid://9113959343", volume = 0.8 },
	reveal = { id = "rbxassetid://1839881844", volume = 0.5 },
	levelup = { id = "rbxassetid://9045119921", volume = 0.45 },
	fanfare = { id = "rbxassetid://1839982934", volume = 0.55 },
	victory = { id = "rbxasset://sounds/victory.wav", volume = 0.45 },
	deny = { id = "rbxasset://sounds/snap.mp3", volume = 0.5, pitch = 0.7 },
	talk = { id = "rbxassetid://6957635256", volume = 0.7 },
	dialogOpen = { id = "rbxassetid://3779053277", volume = 0.45 },
	dialogClose = { id = "rbxassetid://3779036535", volume = 0.5 },
}
for name, def in pairs(UIConfig.Sounds or {}) do
	SoundFX.Sounds[name] = def
end

SoundFX.Music = UIConfig.Music.tracks or {}
SoundFX.Ambience = UIConfig.Music.ambience

local group = Instance.new("SoundGroup")
group.Name = "SFX"
group.Volume = 1
group.Parent = SoundService
SoundFX.Group = group

local lastPlayed = {}

-- `gap` keeps rapid repeats (payout sweeps, button mashing) from stacking into noise
function SoundFX.play(name, options)
	local def = SoundFX.Sounds[name]
	if not def then
		return
	end
	options = options or {}
	local now = os.clock()
	if lastPlayed[name] and now - lastPlayed[name] < (options.gap or 0.05) then
		return
	end
	lastPlayed[name] = now
	local sound = Instance.new("Sound")
	sound.SoundId = def.id
	sound.Volume = (options.volume or def.volume or 0.5)
	sound.PlaybackSpeed = (options.pitch or def.pitch or 1) * (options.jitter and (0.94 + math.random() * 0.12) or 1)
	sound.SoundGroup = group
	sound.Parent = group
	sound:Play()
	Debris:AddItem(sound, 8)
	return sound
end

return SoundFX
