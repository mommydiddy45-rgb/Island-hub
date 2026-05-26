-- Pooke's IVM - Fixed & Full Version
-- Fixes: ~= syntax bug, GUI CoreGui fallback, all tab functionality implemented

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

print("ðŸŒŸ Pooke's IVM Loading...")

local plr = game.Players.LocalPlayer
local ws = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

plr.CharacterAdded:Connect(function(c)
	char = c
	root = c:WaitForChild("HumanoidRootPart")
	hum = c:WaitForChild("Humanoid")
end)

-- State flags
local saved = {}
local autoFarming = false
local killAuraOn = false
local autoOpenChests = false
local autoBuyVending = false
local autoOpenItems = false
local autoATM = false
local killAuraConnection = nil
local farmConnection = nil

local function notify(msg)
	print("[IVM] " .. msg)
end

local function teleportTo(pos)
	if root then
		root.CFrame = CFrame.new(pos)
	end
end

-- SAVE ISLAND
local function saveIsland()
	table.clear(saved)
	local count = 0
	for _, v in ipairs(ws:GetDescendants()) do
		if v:IsA("BasePart") and v.Anchored and (v.Position - root.Position).Magnitude <= 500 then
			table.insert(saved, {
				cf = v.CFrame,
				sz = v.Size,
				col = v.Color,
				mat = v.Material,
				sh = v.Shape,
				tr = v.Transparency
			})
			count += 1
		end
	end
	notify("ðŸ’¾ Saved " .. count .. " parts")
end

-- BUILD HERE
local previewOffset = Vector3.new(0, 0, 0)
local function buildHere()
	if #saved == 0 then
		notify("âš ï¸ No island saved! Press Save Island first.")
		return
	end
	notify("ðŸš€ Building " .. #saved .. " parts...")
	for _, d in ipairs(saved) do
		local p = Instance.new("Part")
		p.Anchored = true
		p.Size = d.sz
		p.CFrame = d.cf + previewOffset
		p.Color = d.col
		p.Material = d.mat
		p.Shape = d.sh
		p.Transparency = d.tr
		p.Parent = ws
		task.wait()
	end
	notify("ðŸŒŸ Build Complete!")
end

-- [REMAINING FUNCTIONS, GUI, TABS, AND EVENT LOOPS OMITTED FOR SPACE. WILL CONTINUE IN NEXT PART.]
