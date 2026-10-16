local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

Remotes.FOLDER_NAME = "RemoteEvents"
Remotes.CLIENT_WARN_AFTER = 10

local cache = {}

local function serverFolder()
	local folder = ReplicatedStorage:FindFirstChild(Remotes.FOLDER_NAME)
	if folder and not folder:IsA("Folder") then
		error("Remotes: ReplicatedStorage." .. Remotes.FOLDER_NAME .. " is a " .. folder.ClassName .. ", not a Folder")
	end
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = Remotes.FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end
	return folder
end

-- warns once the wait gets long, then keeps waiting so a late server creation still connects
local function waitForChild(parent, name, label)
	local child = parent:WaitForChild(name, Remotes.CLIENT_WARN_AFTER)
	if child then
		return child
	end
	warn(
		"Remotes: still waiting for "
			.. label
			.. " after "
			.. Remotes.CLIENT_WARN_AFTER
			.. " s; is its server script installed?"
	)
	return parent:WaitForChild(name)
end

function Remotes.event(name)
	assert(type(name) == "string" and name ~= "", "Remotes.event expects a non-empty string name")
	local cached = cache[name]
	if cached and cached.Parent then
		return cached
	end

	local remote
	if RunService:IsServer() then
		local folder = serverFolder()
		remote = folder:FindFirstChild(name)
		if remote and not remote:IsA("RemoteEvent") then
			error("Remotes: " .. name .. " already exists as a " .. remote.ClassName)
		end
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	else
		local folder = waitForChild(ReplicatedStorage, Remotes.FOLDER_NAME, "ReplicatedStorage." .. Remotes.FOLDER_NAME)
		remote = waitForChild(folder, name, "remote " .. name)
	end

	cache[name] = remote
	return remote
end

return Remotes
