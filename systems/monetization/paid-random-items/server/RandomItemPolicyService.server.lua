local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PaidRandomItems = require(ReplicatedStorage:WaitForChild("PaidRandomItems"))
local PaidRandomItemsConfig = require(ReplicatedStorage:WaitForChild("PaidRandomItemsConfig"))

local RECEIPT_API_TIMEOUT = 15

local function loadPolicy(player)
	for attempt = 1, PaidRandomItemsConfig.LOOKUP_ATTEMPTS do
		local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
		if player.Parent ~= Players then
			return
		end
		if ok and type(info) == "table" then
			player:SetAttribute(PaidRandomItems.ATTRIBUTE, info.ArePaidRandomItemsRestricted == true)
			return
		end
		if attempt < PaidRandomItemsConfig.LOOKUP_ATTEMPTS then
			task.wait(2 * attempt)
		end
	end
	player:SetAttribute(PaidRandomItems.ATTRIBUTE, true)
	warn("RandomItemPolicyService: policy lookup failed for", player.Name)
end

Players.PlayerAdded:Connect(loadPolicy)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(loadPolicy, player)
end

local deadline = os.clock() + RECEIPT_API_TIMEOUT
while not shared.ReceiptAPI and os.clock() < deadline do
	task.wait()
end
if shared.ReceiptAPI then
	shared.ReceiptAPI.SetBlockedCheck(PaidRandomItems.IsProductBlocked)
else
	warn("RandomItemPolicyService: shared.ReceiptAPI not found; restricted players' receipts are not blocked")
end
