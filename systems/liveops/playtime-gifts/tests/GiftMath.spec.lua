local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GiftMath = require(ReplicatedStorage.GiftMath)
local PlaytimeGiftsConfig = require(ReplicatedStorage.PlaytimeGiftsConfig)

return function()
	describe("Payout", function()
		local steps = PlaytimeGiftsConfig.SECONDS_LADDER

		it("pays each gift's seconds of income, growing through the session", function()
			for number, seconds in ipairs(steps) do
				expect(GiftMath.Payout(100000, number)).to.equal(math.max(PlaytimeGiftsConfig.MIN, 100000 * seconds))
			end
			expect(GiftMath.Payout(100000, 2) > GiftMath.Payout(100000, 1)).to.equal(true)
		end)

		it("repeats the last step once the ladder runs out", function()
			expect(GiftMath.Payout(100000, #steps + 5)).to.equal(100000 * steps[#steps])
		end)

		it("never pays less than the minimum", function()
			expect(GiftMath.Payout(0, 1)).to.equal(PlaytimeGiftsConfig.MIN)
			expect(GiftMath.Payout(nil, nil)).to.equal(PlaytimeGiftsConfig.MIN)
		end)

		it("clamps silly gift numbers to the ladder", function()
			expect(GiftMath.Payout(100000, 0)).to.equal(GiftMath.Payout(100000, 1))
			expect(GiftMath.Payout(100000, -3)).to.equal(GiftMath.Payout(100000, 1))
			expect(GiftMath.Payout(100000, 2.7)).to.equal(GiftMath.Payout(100000, 2))
		end)

		it("uses a passed config", function()
			local config = { SECONDS_LADDER = { 10, 20 }, MIN = 5 }
			expect(GiftMath.Payout(3, 1, config)).to.equal(30)
			expect(GiftMath.Payout(3, 9, config)).to.equal(60)
			expect(GiftMath.Payout(0, 1, config)).to.equal(5)
		end)
	end)

	describe("Progress", function()
		local config = { INTERVAL = 600 }

		it("clamps saved progress between 0 and the interval", function()
			expect(GiftMath.Progress(nil, config)).to.equal(0)
			expect(GiftMath.Progress("junk", config)).to.equal(0)
			expect(GiftMath.Progress(-5, config)).to.equal(0)
			expect(GiftMath.Progress(250, config)).to.equal(250)
			expect(GiftMath.Progress(9999, config)).to.equal(600)
		end)

		it("is ready only at the interval", function()
			expect(GiftMath.IsReady(599, config)).to.equal(false)
			expect(GiftMath.IsReady(600, config)).to.equal(true)
		end)
	end)
end
