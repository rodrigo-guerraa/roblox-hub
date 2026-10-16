local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Config = require(ReplicatedStorage:WaitForChild("SocialPromptsConfig"))
local Icons = require(ReplicatedStorage:WaitForChild("Icons"))
local UIStyle = require(script.Parent:WaitForChild("UIStyle"))
local Notice = require(script.Parent:WaitForChild("Notice"))

local player = Players.LocalPlayer

local function promptFavorite()
	local ok, favorited = pcall(AvatarEditorService.GetFavorite, AvatarEditorService, game.PlaceId, Enum.AvatarItemType.Asset)
	if ok and favorited then
		return
	end
	pcall(AvatarEditorService.PromptSetFavorite, AvatarEditorService, game.PlaceId, Enum.AvatarItemType.Asset, true)
end

local asked = false
local function onMoment()
	if asked or player:GetAttribute(Config.FAVORITE_ATTRIBUTE) ~= true then
		return
	end
	asked = true
	task.delay(Config.FAVORITE_DELAY, promptFavorite)
end
player:GetAttributeChangedSignal(Config.FAVORITE_ATTRIBUTE):Connect(onMoment)
onMoment()

if not Config.INVITE_TILE then
	return
end

local inviteButton, inviteSlot =
	UIStyle.hudButton({ label = "Invite", icon = Icons.Friends, color = UIStyle.Colors.blue, order = Config.INVITE_ORDER })

local function canInvite()
	return pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
end

-- no reward for inviting: incentivized invites are against the rules for a young audience
inviteButton.Activated:Connect(function()
	local ok, allowed = canInvite()
	if ok and allowed then
		pcall(SocialService.PromptGameInvite, SocialService, player)
	else
		Notice.Show("Invites aren't available right now.")
	end
end)

-- accounts that can't send invites don't get a dead button; a failed check keeps it (the click re-checks)
task.spawn(function()
	local ok, allowed = canInvite()
	if ok and not allowed then
		inviteSlot.Visible = false
	end
end)
