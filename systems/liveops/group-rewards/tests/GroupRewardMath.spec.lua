local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupRewardMath = require(ReplicatedStorage.GroupRewardMath)

local CONFIG = { JOIN_SECONDS = 300, JOIN_MIN = 5000, INCOME_SECONDS = 60, INCOME_MIN = 1000 }

return function()
	describe("JoinPayout", function()
		it("pays seconds of income, never below the minimum", function()
			expect(GroupRewardMath.JoinPayout(100, CONFIG)).to.equal(30000)
			expect(GroupRewardMath.JoinPayout(1, CONFIG)).to.equal(5000)
			expect(GroupRewardMath.JoinPayout(nil, CONFIG)).to.equal(5000)
		end)

		it("works with the shipped config", function()
			expect(GroupRewardMath.JoinPayout(0) >= 0).to.equal(true)
		end)
	end)

	describe("IncomePayout", function()
		it("pays seconds of income, never below the minimum", function()
			expect(GroupRewardMath.IncomePayout(1000, CONFIG)).to.equal(60000)
			expect(GroupRewardMath.IncomePayout(0, CONFIG)).to.equal(1000)
			expect(GroupRewardMath.IncomePayout(2.5, CONFIG)).to.equal(1000)
		end)
	end)

	describe("InGroupList", function()
		it("finds the group in a GetGroupsAsync list", function()
			local groups = { { Id = 1, Name = "A" }, { Id = 42, Name = "B" } }
			expect(GroupRewardMath.InGroupList(groups, 42)).to.equal(true)
			expect(GroupRewardMath.InGroupList(groups, 7)).to.equal(false)
		end)

		it("treats bad input as not a member", function()
			expect(GroupRewardMath.InGroupList(nil, 42)).to.equal(false)
			expect(GroupRewardMath.InGroupList({ "junk" }, 42)).to.equal(false)
		end)
	end)
end
