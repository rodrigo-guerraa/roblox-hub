local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return
end

local tests = ReplicatedStorage:FindFirstChild("Tests")
if not tests then
	return
end
if tests:GetAttribute("RunTests") ~= true then
	return
end

local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

local roots = {}
for _, child in ipairs(tests:GetChildren()) do
	if child:IsA("ModuleScript") and child.Name:match("%.spec$") then
		table.insert(roots, child)
	end
	if child:IsA("Folder") then
		table.insert(roots, child)
	end
end

TestEZ.TestBootstrap:run(roots, TestEZ.Reporters.TextReporter)
