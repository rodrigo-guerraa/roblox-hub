local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OfflineMath = require(ReplicatedStorage.OfflineMath)

local LADDER = {
	{ id = 1, price = 9 },
	{ id = 2, price = 19 },
	{ id = 0, price = 39 },
}

return function()
	describe("Rate", function()
		it("uses the boosted rate only with the booster", function()
			local config = { RATE = 0.5, BOOSTED_RATE = 1 }
			expect(OfflineMath.Rate(false, config)).to.equal(0.5)
			expect(OfflineMath.Rate(true, config)).to.equal(1)
		end)
	end)

	describe("Earnings", function()
		it("pays income x seconds x rate below the cap", function()
			expect(OfflineMath.Earnings(10, 100, 0.5, 1e9)).to.equal(500)
		end)

		it("stops at the cap", function()
			local cap = OfflineMath.Cap(10, 0.5, 3600, 1)
			expect(cap).to.equal(18000)
			expect(OfflineMath.Earnings(10, 86400, 0.5, cap)).to.equal(18000)
		end)

		it("scales the cap by its multiplier", function()
			expect(OfflineMath.Cap(10, 1, 100, 1.5)).to.equal(1500)
		end)

		it("pays nothing for no time away or no income", function()
			expect(OfflineMath.Earnings(10, 0, 1, 1e9)).to.equal(0)
			expect(OfflineMath.Earnings(10, -50, 1, 1e9)).to.equal(0)
			expect(OfflineMath.Earnings(0, 100, 1, 1e9)).to.equal(0)
			expect(OfflineMath.Earnings(nil, 100, 1, 1e9)).to.equal(0)
		end)
	end)

	describe("doubling ladder", function()
		it("offers the next step until the ladder runs out", function()
			expect(OfflineMath.NextDouble(0, LADDER).price).to.equal(9)
			expect(OfflineMath.NextDouble(1, LADDER).price).to.equal(19)
			expect(OfflineMath.NextDouble(3, LADDER)).to.equal(nil)
		end)

		it("never offers a step whose product isn't created", function()
			expect(OfflineMath.NextDouble(2, LADDER)).to.equal(nil)
		end)

		it("refuses to double an empty pool or past the end", function()
			expect(OfflineMath.CanDouble(100, 0, LADDER)).to.equal(true)
			expect(OfflineMath.CanDouble(0, 0, LADDER)).to.equal(false)
			expect(OfflineMath.CanDouble(100, 3, LADDER)).to.equal(false)
		end)

		it("multiplies by two per double", function()
			expect(OfflineMath.Multiplier(0)).to.equal(1)
			expect(OfflineMath.Multiplier(5)).to.equal(32)
		end)
	end)
end
