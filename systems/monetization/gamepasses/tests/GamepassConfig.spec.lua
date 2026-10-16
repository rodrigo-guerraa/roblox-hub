local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassConfig = require(ReplicatedStorage.GamepassConfig)

return function()
	it("has unique keys, all indexed by ByKey", function()
		local seen = {}
		for _, def in ipairs(GamepassConfig.Passes) do
			expect(type(def.key)).to.equal("string")
			expect(seen[def.key]).to.equal(nil)
			seen[def.key] = true
			expect(GamepassConfig.ByKey[def.key]).to.equal(def)
		end
	end)

	it("never reuses a real pass id", function()
		local seen = {}
		for _, def in ipairs(GamepassConfig.Passes) do
			expect(type(def.id)).to.equal("number")
			if def.id ~= 0 then
				expect(seen[def.id]).to.equal(nil)
				seen[def.id] = true
			end
		end
	end)

	it("gives every pass a title, description and a price of at least 2 Robux", function()
		for _, def in ipairs(GamepassConfig.Passes) do
			expect(type(def.title)).to.equal("string")
			expect(type(def.description)).to.equal("string")
			expect(def.price >= 2).to.equal(true)
		end
	end)

	it("builds the Player attribute name from the key", function()
		expect(GamepassConfig.Attribute("VIP")).to.equal(GamepassConfig.ATTRIBUTE_PREFIX .. "VIP")
	end)
end
