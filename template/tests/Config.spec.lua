local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config)

return function()
	describe("Config", function()
		it("loads", function()
			expect(type(Config)).to.equal("table")
		end)
	end)
end
