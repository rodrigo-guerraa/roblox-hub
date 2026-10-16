local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PaidRandomItems = require(ReplicatedStorage.PaidRandomItems)
local PaidRandomItemsConfig = require(ReplicatedStorage.PaidRandomItemsConfig)

local function fakePlayer(value)
	return {
		GetAttribute = function(_, name)
			if name == PaidRandomItems.ATTRIBUTE then
				return value
			end
			return nil
		end,
	}
end

local function firstKey(set)
	for key, on in pairs(set) do
		if on then
			return key
		end
	end
	return nil
end

return function()
	describe("IsRestricted", function()
		it("treats an unknown policy as restricted", function()
			expect(PaidRandomItems.IsRestricted(fakePlayer(nil))).to.equal(true)
			expect(PaidRandomItems.IsRestricted(fakePlayer(true))).to.equal(true)
			expect(PaidRandomItems.IsRestricted(fakePlayer(false))).to.equal(false)
		end)
	end)

	describe("IsProductBlocked", function()
		it("blocks configured kinds only for restricted players", function()
			local kind = firstKey(PaidRandomItemsConfig.BLOCKED_PRODUCT_KINDS)
			if not kind then
				return
			end
			expect(PaidRandomItems.IsProductBlocked(fakePlayer(true), 123, kind)).to.equal(true)
			expect(PaidRandomItems.IsProductBlocked(fakePlayer(nil), 123, kind)).to.equal(true)
			expect(PaidRandomItems.IsProductBlocked(fakePlayer(false), 123, kind)).to.equal(false)
		end)

		it("never blocks unlisted products", function()
			expect(PaidRandomItems.IsProductBlocked(fakePlayer(true), -1, "__unlisted_kind")).to.equal(false)
			expect(PaidRandomItems.IsProductBlocked(fakePlayer(true), -1, nil)).to.equal(false)
		end)
	end)

	describe("passes", function()
		it("never blocks an unlisted pass", function()
			expect(PaidRandomItems.IsPassBlocked(fakePlayer(true), "__unlisted_pass")).to.equal(false)
			expect(PaidRandomItems.PassAffectsRolls(fakePlayer(true), "__unlisted_pass")).to.equal(true)
		end)
	end)
end
