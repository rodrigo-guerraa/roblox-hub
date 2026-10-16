local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config)

return function()
	describe("Config", function()
		it("has a positive save version", function()
			expect(Config.DATA_VERSION >= 1).to.equal(true)
		end)
	end)
end
