local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Config = require(ReplicatedStorage:WaitForChild("GroupRewardsConfig"))
local GroupRewardMath = require(ReplicatedStorage:WaitForChild("GroupRewardMath"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local SoundFX = require(script.Parent:WaitForChild("SoundFX"))
local Notice = require(script.Parent:WaitForChild("Notice"))

local player = Players.LocalPlayer

local CLAIM_TIMEOUT = 6

local GroupRewards = {}

local changed = Instance.new("BindableEvent")
GroupRewards.Changed = changed.Event

local isMember = false
local claiming = false
local prompting = false
local claimToken = 0
local source = nil
local claimEvent = nil

function GroupRewards.enabled()
	return Config.GROUP_ID ~= 0
end

function GroupRewards.claimed()
	return player:GetAttribute(Config.CLAIMED_ATTRIBUTE) == true
end

function GroupRewards.joinReward()
	return GroupRewardMath.JoinPayout(player:GetAttribute("IncomePerSecond") or 0)
end

-- "claimed" | "claiming" | "member" | "join"
function GroupRewards.state()
	if GroupRewards.claimed() then
		return "claimed"
	end
	if claiming then
		return "claiming"
	end
	return isMember and "member" or "join"
end

local function effectOrigin()
	if source and source.Parent and source:IsDescendantOf(player) and source.AbsoluteSize.X > 0 then
		return Effects.CenterOf(source)
	end
	return workspace.CurrentCamera.ViewportSize / 2
end

-- not in the group: Roblox's join prompt; in it: claim the one-time reward; already claimed: nothing
function GroupRewards.joinOrClaim(fromGui)
	if not GroupRewards.enabled() or claiming or prompting or GroupRewards.claimed() then
		return
	end
	source = fromGui
	if isMember then
		if not claimEvent then
			return
		end
		claiming = true
		claimToken += 1
		local mine = claimToken
		changed:Fire()
		claimEvent:FireServer()
		task.delay(CLAIM_TIMEOUT, function()
			if claiming and claimToken == mine then
				claiming = false
				changed:Fire()
			end
		end)
		return
	end
	prompting = true
	local ok, membership = pcall(GroupService.PromptJoinAsync, GroupService, Config.GROUP_ID)
	prompting = false
	if not ok then
		Notice.Show("Find our group on the game page!")
	elseif membership == Enum.GroupMembershipStatus.Joined or membership == Enum.GroupMembershipStatus.AlreadyMember then
		isMember = true
		SoundFX.play("victory")
	elseif membership == Enum.GroupMembershipStatus.JoinRequestPending then
		Notice.Show("Join request sent!")
	end
	changed:Fire()
end

function GroupRewards.mountCard(parent, props)
	props = props or {}
	local card = UIStyle.card(parent, {
		name = props.name or "GroupCard",
		anchor = props.anchor,
		position = props.position,
		size = props.size,
		outlineColor = UIStyle.Colors.blue,
		outlineWidth = 3,
	})
	UIStyle.image(card, {
		name = "Icon",
		image = Icons.Friends,
		anchor = Vector2.new(0, 0.5),
		position = UDim2.fromScale(0.03, 0.5),
		size = UDim2.fromScale(0.2, 0.78),
	})
	UIStyle.text(card, {
		name = "Title",
		text = "Join our group!",
		font = UIStyle.Fonts.title,
		color = UIStyle.Theme.ink,
		max = 34,
		alignX = Enum.TextXAlignment.Left,
		position = UDim2.fromScale(0.25, 0.08),
		size = UDim2.fromScale(0.42, 0.36),
	})
	local perk = UIStyle.text(card, {
		name = "Perk",
		text = "",
		color = UIStyle.Theme.inkSoft,
		max = 22,
		alignX = Enum.TextXAlignment.Left,
		position = UDim2.fromScale(0.25, 0.46),
		size = UDim2.fromScale(0.44, 0.46),
	})
	local button = UIStyle.button(card, {
		name = "GroupButton",
		text = "JOIN",
		font = UIStyle.Fonts.title,
		color = UIStyle.Colors.blue,
		anchor = Vector2.new(1, 0.5),
		position = UDim2.fromScale(0.97, 0.5),
		size = UDim2.fromScale(0.28, 0.5),
	})

	local minutes = math.max(1, math.floor(Config.INCOME_INTERVAL / 60 + 0.5))
	local function refresh()
		local state = GroupRewards.state()
		local reward = NumberFormat.Money(GroupRewards.joinReward())
		if state == "claimed" then
			perk.Text = string.format("Thanks! You get a bonus every %d min.", minutes)
			UIStyle.setText(button, "CLAIMED")
			UIStyle.setEnabled(button, false)
		elseif state == "member" or state == "claiming" then
			perk.Text = string.format("Claim %s now, plus a bonus every %d min!", reward, minutes)
			UIStyle.setText(button, "CLAIM")
			UIStyle.setEnabled(button, state == "member", UIStyle.Colors.green)
		else
			perk.Text = string.format("Get %s now, plus a bonus every %d min!", reward, minutes)
			UIStyle.setText(button, "JOIN")
			UIStyle.setEnabled(button, true, UIStyle.Colors.blue)
		end
	end

	button.Activated:Connect(function()
		if UIStyle.isEnabled(button) then
			GroupRewards.joinOrClaim(button)
		end
	end)
	GroupRewards.Changed:Connect(refresh)
	player:GetAttributeChangedSignal("IncomePerSecond"):Connect(refresh)
	refresh()
	return card
end

if GroupRewards.enabled() then
	task.spawn(function()
		local ok, member = pcall(player.IsInGroup, player, Config.GROUP_ID)
		isMember = ok and member == true
		changed:Fire()
	end)
	task.spawn(function()
		claimEvent = Remotes.event(Config.REMOTE_CLAIM)
		Remotes.event(Config.REMOTE_RESULT).OnClientEvent:Connect(function(result)
			claiming = false
			if type(result) == "table" then
				if result.ok then
					local from = effectOrigin()
					SoundFX.play("victory")
					Effects.FlyCoins(from, 18)
					Effects.FloatText("+" .. NumberFormat.Money(result.reward or 0), from - Vector2.new(0, 40))
				else
					Notice.Show(result.message or "That didn't work.")
				end
			end
			changed:Fire()
		end)
	end)
	player:GetAttributeChangedSignal(Config.CLAIMED_ATTRIBUTE):Connect(function()
		changed:Fire()
	end)
end

return GroupRewards
