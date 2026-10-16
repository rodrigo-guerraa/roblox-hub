local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyPacks = require(ReplicatedStorage.CurrencyPacks)
local ReceiptConfig = require(ReplicatedStorage.ReceiptConfig)

local PRODUCTS = {
	{ key = "hour", kind = "currency", id = 11, seconds = 3600, min = 100 },
	{ key = "flat", kind = "currency", id = 12, amount = 5000 },
	{ key = "other", kind = "boost", id = 13 },
	{ key = "unset", kind = "currency", id = 0, amount = 1 },
}

return function()
	describe("Payout", function()
		it("pays the configured seconds of income", function()
			expect(CurrencyPacks.Payout(PRODUCTS[1], 25)).to.equal(90000)
			expect(CurrencyPacks.Payout(PRODUCTS[1], 2.5)).to.equal(9000)
		end)

		it("never pays below the minimum", function()
			expect(CurrencyPacks.Payout(PRODUCTS[1], 0)).to.equal(100)
			expect(CurrencyPacks.Payout(PRODUCTS[1], nil)).to.equal(100)
			expect(CurrencyPacks.Payout(PRODUCTS[1], -50)).to.equal(100)
		end)

		it("pays a flat amount regardless of income", function()
			expect(CurrencyPacks.Payout(PRODUCTS[2], 1e9)).to.equal(5000)
		end)

		it("pays nothing for a missing definition", function()
			expect(CurrencyPacks.Payout(nil, 100)).to.equal(0)
		end)
	end)

	describe("lookup", function()
		it("lists only currency products", function()
			expect(#CurrencyPacks.List(PRODUCTS)).to.equal(3)
		end)

		it("finds packs by id and key, never by the unset id 0", function()
			expect(CurrencyPacks.ById(12, PRODUCTS).key).to.equal("flat")
			expect(CurrencyPacks.ById(13, PRODUCTS)).to.equal(nil)
			expect(CurrencyPacks.ById(0, PRODUCTS)).to.equal(nil)
			expect(CurrencyPacks.ById("12", PRODUCTS)).to.equal(nil)
			expect(CurrencyPacks.ByKey("hour", PRODUCTS).id).to.equal(11)
		end)
	end)

	describe("ReceiptConfig", function()
		it("defines every currency pack with a number id, a price of at least 2 Robux and a payout", function()
			local seen = {}
			for _, def in ipairs(CurrencyPacks.List()) do
				expect(type(def.id)).to.equal("number")
				if def.id ~= 0 then
					expect(seen[def.id]).to.equal(nil)
					seen[def.id] = true
				end
				expect(def.price >= 2).to.equal(true)
				expect(type(def.amount) == "number" or type(def.seconds) == "number").to.equal(true)
			end
			expect(#CurrencyPacks.List(ReceiptConfig.PRODUCTS)).to.equal(#CurrencyPacks.List())
		end)
	end)
end
