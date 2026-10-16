local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OddsDisclosure = require(ReplicatedStorage.OddsDisclosure)

local GROUPS = {
	{ key = "Common", items = { { name = "A" }, { name = "B" }, { name = "C" } } },
	{ key = "Rare", items = { { name = "D" }, { name = "E" } } },
	{ key = "Secret", items = { { name = "F" }, { name = "G" }, { name = "P", passKey = "VIP" } } },
	{ key = "Empty", items = {} },
}

local TABLES = {
	basic = { Common = 70, Rare = 30 },
	top = { Common = 10, Rare = 50, Secret = 40 },
	withEmpty = { Common = 50, Rare = 25, Empty = 25 },
}

local function allowAll()
	return true
end

local function sum(list)
	local total = 0
	for _, entry in ipairs(list) do
		total += entry.percent
	end
	return total
end

local function find(list, name)
	for _, entry in ipairs(list) do
		if entry.item.name == name then
			return entry
		end
	end
	return nil
end

return function()
	describe("Items", function()
		it("adds up to exactly 100% for every table, with or without the pass item", function()
			for _, weights in pairs(TABLES) do
				for _, allow in ipairs({ allowAll, false }) do
					local list = OddsDisclosure.Items(GROUPS, weights, allow or nil)
					expect(#list > 0).to.equal(true)
					expect(math.abs(sum(list) - 100) < 1e-9).to.equal(true)
				end
			end
		end)

		it("only lists a pass item when the filter allows it", function()
			expect(find(OddsDisclosure.Items(GROUPS, TABLES.top, nil), "P")).to.equal(nil)
			expect(find(OddsDisclosure.Items(GROUPS, TABLES.top, function()
				return false
			end), "P")).to.equal(nil)
			expect(find(OddsDisclosure.Items(GROUPS, TABLES.top, allowAll), "P") ~= nil).to.equal(true)
		end)

		it("splits each group's chance evenly across its rollable items", function()
			local without = find(OddsDisclosure.Items(GROUPS, TABLES.top, nil), "F")
			local with = find(OddsDisclosure.Items(GROUPS, TABLES.top, allowAll), "F")
			expect(math.abs(without.percent - 40 / 100 / 2 * 100) < 1e-9).to.equal(true)
			expect(math.abs(with.percent - 40 / 100 / 3 * 100) < 1e-9).to.equal(true)
		end)

		it("never lists a group with no weight", function()
			for _, entry in ipairs(OddsDisclosure.Items(GROUPS, TABLES.basic, allowAll)) do
				expect((TABLES.basic[entry.group] or 0) > 0).to.equal(true)
			end
		end)

		it("leaves weighted groups with nothing rollable out of the total", function()
			local list = OddsDisclosure.Items(GROUPS, TABLES.withEmpty, nil)
			expect(math.abs(find(list, "A").percent - 50 / 75 / 3 * 100) < 1e-9).to.equal(true)
		end)

		it("sorts by chance, then name", function()
			local list = OddsDisclosure.Items(GROUPS, TABLES.basic, nil)
			expect(list[1].item.name).to.equal("A")
			expect(list[#list].item.name).to.equal("E")
		end)

		it("returns an empty list when nothing can roll", function()
			expect(#OddsDisclosure.Items(GROUPS, {}, allowAll)).to.equal(0)
			expect(OddsDisclosure.Roll(GROUPS, {}, allowAll)).to.equal(nil)
		end)
	end)

	describe("Roll", function()
		it("only rolls disclosed items, at about the disclosed rates", function()
			local rng = Random.new(7)
			local counts = {}
			local rolls = 20000
			for _ = 1, rolls do
				local item = OddsDisclosure.Roll(GROUPS, TABLES.top, nil, rng)
				counts[item.name] = (counts[item.name] or 0) + 1
			end
			expect(counts.P).to.equal(nil)
			for _, entry in ipairs(OddsDisclosure.Items(GROUPS, TABLES.top, nil)) do
				local observed = (counts[entry.item.name] or 0) / rolls * 100
				expect(math.abs(observed - entry.percent) < 1.5).to.equal(true)
			end
		end)
	end)

	describe("PassItemChance", function()
		it("matches the pass item's listed chance", function()
			local listed = find(OddsDisclosure.Items(GROUPS, TABLES.top, allowAll), "P").percent
			expect(OddsDisclosure.PassItemChance(GROUPS, TABLES.top, "VIP")).to.equal(listed)
			expect(OddsDisclosure.PassItemChance(GROUPS, TABLES.basic, "VIP")).to.equal(0)
		end)
	end)

	describe("Format", function()
		it("shows two decimals below 10% and one above", function()
			expect(OddsDisclosure.Format(0.5)).to.equal("0.50%")
			expect(OddsDisclosure.Format(1.25)).to.equal("1.25%")
			expect(OddsDisclosure.Format(12.345)).to.equal("12.3%")
		end)
	end)
end
