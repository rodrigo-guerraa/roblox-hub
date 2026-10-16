local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeEngine = require(ReplicatedStorage.BadgeEngine)
local BadgeDefinitions = require(ReplicatedStorage.BadgeDefinitions)
local BadgeConfig = require(ReplicatedStorage.BadgeConfig)

local function earnedSet(profile, context)
	local set = {}
	local state = BadgeDefinitions.StateFromProfile(profile, context)
	for _, key in ipairs(BadgeEngine.Earned(BadgeDefinitions.All, state)) do
		set[key] = true
	end
	return set
end

local function fixture()
	return {
		{
			key = "A",
			name = "A",
			description = "a",
			earned = function()
				return true
			end,
		},
		{
			key = "B",
			name = "B",
			description = "b",
			earned = function(s)
				return s.n >= 2
			end,
		},
	}
end

return function()
	describe("the game's definitions", function()
		it("line up with BadgeConfig.IDS", function()
			local problems = BadgeEngine.Validate(BadgeDefinitions.All, BadgeConfig.IDS)
			expect(#problems).to.equal(0)
		end)

		it("can be judged on an empty save", function()
			local state = BadgeDefinitions.StateFromProfile({}, nil)
			expect(type(BadgeEngine.Earned(BadgeDefinitions.All, state))).to.equal("table")
			expect(type(BadgeDefinitions.StateFromProfile(nil, nil))).to.equal("table")
		end)
	end)

	describe("the shipped examples", function()
		it("give a brand-new save only the welcome badge", function()
			local set = earnedSet({}, { balance = 0 })
			if BadgeEngine.ByKey(BadgeDefinitions.All).WELCOME then
				expect(set.WELCOME).to.equal(true)
				expect(set.FIRST_PURCHASE).to.equal(nil)
				expect(set.MILLIONAIRE).to.equal(nil)
			end
		end)
	end)

	describe("Earned", function()
		it("lists earned keys in definition order", function()
			local keys = BadgeEngine.Earned(fixture(), { n = 5 })
			expect(#keys).to.equal(2)
			expect(keys[1]).to.equal("A")
			expect(keys[2]).to.equal("B")
			expect(#BadgeEngine.Earned(fixture(), { n = 0 })).to.equal(1)
		end)
	end)

	describe("Pending", function()
		it("skips awarded badges and badges with no live id", function()
			local defs = fixture()
			local state = { n = 5 }
			expect(#BadgeEngine.Pending(defs, state, { A = true }, { A = 1, B = 2 })).to.equal(1)
			local pending = BadgeEngine.Pending(defs, state, {}, { A = 0, B = 2 })
			expect(#pending).to.equal(1)
			expect(pending[1]).to.equal("B")
			expect(#BadgeEngine.Pending(defs, state, nil, nil)).to.equal(2)
		end)
	end)

	describe("Validate", function()
		it("reports missing ids, strays, duplicates and broken entries", function()
			local defs = fixture()
			table.insert(defs, {
				key = "A",
				name = "A",
				description = "a",
				earned = function()
					return true
				end,
			})
			table.insert(defs, { key = "C", name = "C", description = "c" })
			local problems = BadgeEngine.Validate(defs, { A = 1, C = 3, STRAY = 9 })
			local text = table.concat(problems, "\n")
			expect(string.find(text, "duplicate key A", 1, true) ~= nil).to.equal(true)
			expect(string.find(text, "B has no id entry", 1, true) ~= nil).to.equal(true)
			expect(string.find(text, "C has no earned function", 1, true) ~= nil).to.equal(true)
			expect(string.find(text, "STRAY", 1, true) ~= nil).to.equal(true)
		end)
	end)
end
