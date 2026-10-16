local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberFormat = require(ReplicatedStorage.NumberFormat)

return function()
	describe("Short", function()
		it("leaves small whole numbers alone", function()
			expect(NumberFormat.Short(0)).to.equal("0")
			expect(NumberFormat.Short(999)).to.equal("999")
		end)

		it("keeps one decimal for small fractions", function()
			expect(NumberFormat.Short(37.5)).to.equal("37.5")
		end)

		it("abbreviates thousands, millions and billions", function()
			expect(NumberFormat.Short(1450)).to.equal("1.4K")
			expect(NumberFormat.Short(150000)).to.equal("150K")
			expect(NumberFormat.Short(25300000)).to.equal("25.3M")
			expect(NumberFormat.Short(2000000000)).to.equal("2B")
		end)

		it("rounds down so a total never looks bigger than it is", function()
			expect(NumberFormat.Short(1999)).to.equal("1.9K")
		end)

		it("keeps the sign of negative numbers", function()
			expect(NumberFormat.Short(-1450)).to.equal("-1.4K")
		end)

		it("treats non-numbers and NaN as zero", function()
			expect(NumberFormat.Short(nil)).to.equal("0")
			expect(NumberFormat.Short("abc")).to.equal("0")
			expect(NumberFormat.Short(0 / 0)).to.equal("0")
		end)
	end)

	describe("Money / Rate", function()
		it("prefixes the currency symbol and suffixes /s", function()
			expect(NumberFormat.Money(2500000)).to.equal(NumberFormat.CURRENCY .. "2.5M")
			expect(NumberFormat.Rate(30)).to.equal(NumberFormat.CURRENCY .. "30/s")
		end)
	end)
end
