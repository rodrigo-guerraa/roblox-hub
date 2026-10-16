local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataConfig = require(ReplicatedStorage.DataConfig)
local DataTemplate = require(ReplicatedStorage.DataTemplate)
local SaveMigrations = require(ReplicatedStorage.SaveMigrations)

return function()
	local base = SaveMigrations.BASELINE

	describe("Migrate", function()
		it("passes a current save through untouched", function()
			local data = { dataVersion = DataConfig.DATA_VERSION, currency = 5 }
			local status, out = SaveMigrations.Migrate(data, DataConfig.DATA_VERSION)
			expect(status).to.equal("current")
			expect(out).to.equal(data)
		end)

		it("resets saves from before the baseline or without a version", function()
			expect((SaveMigrations.Migrate({ dataVersion = base - 1 }, base))).to.equal("reset")
			expect((SaveMigrations.Migrate({ currency = 10 }, base))).to.equal("reset")
			expect((SaveMigrations.Migrate(nil, base))).to.equal("reset")
			expect((SaveMigrations.Migrate({ dataVersion = 0 / 0 }, base))).to.equal("reset")
		end)

		it("refuses a save from a newer build", function()
			local status, out = SaveMigrations.Migrate({ dataVersion = base + 5 }, base)
			expect(status).to.equal("newer")
			expect(out).to.equal(nil)
		end)

		it("chains every step up to the target", function()
			local steps = {
				[base] = function(data)
					data.gems = 0
				end,
				[base + 1] = function(data)
					data.gems += 3
				end,
			}
			local status, out = SaveMigrations.Migrate({ dataVersion = base, currency = 7 }, base + 2, steps)
			expect(status).to.equal("migrated")
			expect(out.dataVersion).to.equal(base + 2)
			expect(out.gems).to.equal(3)
			expect(out.currency).to.equal(7)
		end)

		it("never touches the original save, even when it migrates", function()
			local original = { dataVersion = base, nested = { currency = 1 } }
			local _, out = SaveMigrations.Migrate(original, base + 1, {
				[base] = function(data)
					data.nested.currency = 99
				end,
			})
			expect(original.dataVersion).to.equal(base)
			expect(original.nested.currency).to.equal(1)
			expect(out.nested.currency).to.equal(99)
		end)

		it("refuses instead of guessing when a step is missing", function()
			local original = { dataVersion = base }
			local status, out = SaveMigrations.Migrate(original, base + 2, { [base] = function() end })
			expect(status).to.equal("missingStep")
			expect(out).to.equal(nil)
			expect(original.dataVersion).to.equal(base)
		end)

		it("leaves the save alone when a step errors", function()
			local original = { dataVersion = base, currency = 3 }
			local status = SaveMigrations.Migrate(original, base + 1, {
				[base] = function(data)
					data.currency = 0
					error("boom")
				end,
			})
			expect(status).to.equal("failed")
			expect(original.currency).to.equal(3)
		end)
	end)

	describe("shipped chain", function()
		it("has a step for every version from the baseline up to DataConfig.DATA_VERSION", function()
			for version = base, DataConfig.DATA_VERSION - 1 do
				expect(type(SaveMigrations.Steps[version])).to.equal("function")
			end
		end)

		it("never sits below the baseline", function()
			expect(DataConfig.DATA_VERSION >= base).to.equal(true)
		end)

		it("stamps new saves with the current version", function()
			expect(DataTemplate.dataVersion).to.equal(DataConfig.DATA_VERSION)
		end)
	end)
end
