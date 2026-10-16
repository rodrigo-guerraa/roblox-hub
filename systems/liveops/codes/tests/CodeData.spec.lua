local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CodeData = require(ReplicatedStorage.CodeData)

return function()
	describe("Normalize", function()
		it("ignores case and spaces", function()
			expect(CodeData.Normalize("  re lease ")).to.equal("RELEASE")
		end)

		it("rejects empty, too long and non-string input", function()
			expect(CodeData.Normalize("   ")).to.equal(nil)
			expect(CodeData.Normalize(string.rep("A", CodeData.MAX_LENGTH + 1))).to.equal(nil)
			expect(CodeData.Normalize(42)).to.equal(nil)
			expect(CodeData.Normalize(nil)).to.equal(nil)
		end)
	end)

	describe("Lookup", function()
		it("finds every listed code however it is typed", function()
			for code, def in pairs(CodeData.Codes) do
				if def.active ~= false and not def.expires then
					local found, reason, normalized = CodeData.Lookup(string.lower(code), 0)
					expect(found).to.equal(def)
					expect(reason).to.equal(nil)
					expect(normalized).to.equal(code)
				end
			end
		end)

		it("only lists codes that are already normalised", function()
			for code in pairs(CodeData.Codes) do
				expect(CodeData.Normalize(code)).to.equal(code)
			end
		end)

		it("rejects unknown and retired codes", function()
			local _, reason = CodeData.Lookup("NOT-A-REAL-CODE", 0)
			expect(reason).to.equal("invalid")
			CodeData.Codes.TEMPOFF = { seconds = 1, min = 1, active = false }
			_, reason = CodeData.Lookup("tempoff", 0)
			CodeData.Codes.TEMPOFF = nil
			expect(reason).to.equal("invalid")
		end)

		it("rejects expired codes", function()
			CodeData.Codes.TEMPOLD = { seconds = 1, min = 1, expires = 100 }
			local okDef = CodeData.Lookup("tempold", 50)
			local _, reason = CodeData.Lookup("tempold", 200)
			CodeData.Codes.TEMPOLD = nil
			expect(okDef ~= nil).to.equal(true)
			expect(reason).to.equal("expired")
		end)
	end)

	describe("Reward", function()
		it("pays seconds of income, never below the minimum", function()
			local def = { seconds = 60, min = 500 }
			expect(CodeData.Reward(def, 1000)).to.equal(60000)
			expect(CodeData.Reward(def, 1)).to.equal(500)
			expect(CodeData.Reward(def, nil)).to.equal(500)
		end)

		it("floors fractional income", function()
			expect(CodeData.Reward({ seconds = 10, min = 0 }, 1.25)).to.equal(12)
		end)
	end)
end
