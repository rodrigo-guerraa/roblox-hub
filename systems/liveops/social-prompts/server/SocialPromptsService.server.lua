local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("SocialPromptsConfig"))

local SocialPromptsAPI = {}

-- call at the game's first big high point; asks once per player ever (saved), returns whether it asked
function SocialPromptsAPI.FavoriteMoment(player)
	local DataService = shared.DataServiceAPI
	local data = DataService and DataService.GetData(player)
	if not data or data.favoritePromptShown or player.Parent ~= Players then
		return false
	end
	data.favoritePromptShown = true
	player:SetAttribute(Config.FAVORITE_ATTRIBUTE, true)
	return true
end

shared.SocialPromptsAPI = SocialPromptsAPI
