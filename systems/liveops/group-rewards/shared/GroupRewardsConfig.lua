local GroupRewardsConfig = {}

-- 0 turns the whole system off (no income, no card, no window, no pad)
GroupRewardsConfig.GROUP_ID = 0

GroupRewardsConfig.INCOME_INTERVAL = 600
GroupRewardsConfig.INCOME_SECONDS = 60
GroupRewardsConfig.INCOME_MIN = 1000

GroupRewardsConfig.JOIN_SECONDS = 300
GroupRewardsConfig.JOIN_MIN = 5000

GroupRewardsConfig.CLAIM_COOLDOWN = 3

GroupRewardsConfig.PAD_TAG = "GroupPad"
GroupRewardsConfig.PAD_COOLDOWN = 8

GroupRewardsConfig.WINDOW_KEY = "Group"
GroupRewardsConfig.HUD_TILE = false
GroupRewardsConfig.HUD_ORDER = 12

GroupRewardsConfig.CLAIMED_ATTRIBUTE = "GroupRewardClaimed"
GroupRewardsConfig.REMOTE_CLAIM = "ClaimGroupReward"
GroupRewardsConfig.REMOTE_RESULT = "GroupRewardResult"

return GroupRewardsConfig
