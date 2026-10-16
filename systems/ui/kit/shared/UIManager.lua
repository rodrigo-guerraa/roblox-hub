local UIManager = {}

local panels = {}
local panelsChanged = Instance.new("BindableEvent")

UIManager.panelsChanged = panelsChanged.Event

function UIManager.register(name, panel)
	panels[name] = panel
	panel:GetPropertyChangedSignal("Visible"):Connect(function()
		if panel.Visible then
			for otherName, other in pairs(panels) do
				if otherName ~= name and other.Visible then
					other.Visible = false
				end
			end
		end
		panelsChanged:Fire()
	end)
end

function UIManager.getOpenPanels()
	local open = {}
	for _, panel in pairs(panels) do
		if panel.Visible then
			table.insert(open, panel)
		end
	end
	return open
end

local tutorialTargets = {}
local tutorialTargetRegistered = Instance.new("BindableEvent")
local tutorialLocked = false
local tutorialAllowList = {}

function UIManager.registerTutorialTarget(key, instance)
	tutorialTargets[key] = instance
	tutorialTargetRegistered:Fire(key, instance)
end

function UIManager.getTutorialTarget(key)
	return tutorialTargets[key]
end

UIManager.tutorialTargetRegistered = tutorialTargetRegistered.Event

function UIManager.setTutorialLock(locked, allowList)
	tutorialLocked = locked
	tutorialAllowList = {}
	if allowList then
		for _, name in ipairs(allowList) do
			tutorialAllowList[name] = true
		end
	end
end

function UIManager.canOpen(name)
	return not tutorialLocked or tutorialAllowList[name] == true
end

function UIManager.open(name)
	if tutorialLocked and not tutorialAllowList[name] then
		return
	end

	local panel = panels[name]
	if panel then
		panel.Visible = true
	end
end

function UIManager.close(name)
	local panel = panels[name]
	if panel then
		panel.Visible = false
	end
end

function UIManager.toggle(name)
	local panel = panels[name]
	if panel then
		panel.Visible = not panel.Visible
	end
end

return UIManager
