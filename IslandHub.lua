if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

local success, Fluent = pcall(function()
	return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
	return warn("Fluent failed to load - enable HttpGet in executor")
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function(c)
	Character = c
	Humanoid = c:WaitForChild("Humanoid")
	Root = c:WaitForChild("HumanoidRootPart")
end)

-- Variables
local WalkSpeed = 16
local JumpPower = 50
local InfiniteJump = false
local Flying = false
local FlySpeed = 80
local Noclip = false
local AutoCollect = false
local AutoChop = false
local FarmRange = 70
local ChopDelay = 0.75

-- UI
local Window = Fluent:CreateWindow({
	Title = "Island Hub",
	SubTitle = "by rayon • Compact",
	Size = UDim2.fromOffset(520, 480),
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Main = Window:AddTab({Title = "Main", Icon = "home"})
local Auto = Window:AddTab({Title = "Autofarm", Icon = "leaf"})

Main:AddSlider("WalkSpeed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 250, Callback = function(v) WalkSpeed = v end})
Main:AddSlider("JumpPower", {Title = "JumpPower", Default = 50, Min = 50, Max = 350, Callback = function(v) JumpPower = v end})
Main:AddToggle("InfiniteJump", {Title = "Infinite Jump", Callback = function(v) InfiniteJump = v end})
Main:AddToggle("Fly", {Title = "Fly", Callback = function(v) Flying = v end})
Main:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 80, Min = 30, Max = 300, Callback = function(v) FlySpeed = v end})
Main:AddToggle("Noclip", {Title = "Noclip", Callback = function(v) Noclip = v end})

Auto:AddToggle("AutoCollect", {Title = "Auto Collect", Callback = function(v) AutoCollect = v end})
Auto:AddToggle("AutoChop", {Title = "Auto Chop Trees", Callback = function(v) AutoChop = v end})
Auto:AddSlider("Range", {Title = "Farm Range", Default = 70, Min = 30, Max = 150, Callback = function(v) FarmRange = v end})
Auto:AddSlider("ChopDelay", {Title = "Chop Delay", Default = 0.75, Min = 0.4, Max = 2, Callback = function(v) ChopDelay = v end})

-- Jump
UIS.JumpRequest:Connect(function()
	if InfiniteJump and Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Autofarm
local lastChop = 0
RunService.Heartbeat:Connect(function()
	if not Root then return end

	if AutoCollect then
		local drops = Workspace:FindFirstChild("Drops")
		if drops then
			for _, drop in ipairs(drops:GetChildren()) do
				local p = drop:FindFirstChildWhichIsA("BasePart")
				if p and (p.Position - Root.Position).Magnitude <= FarmRange then
					Root.CFrame = CFrame.new(p.Position + Vector3.new(0,5,0))
					task.wait(0.1)
				end
			end
		end
	end

	if AutoChop and tick() - lastChop >= ChopDelay then
		-- Equip axe
		local axe = nil
		for _, t in ipairs(Player.Backpack:GetChildren()) do
			if t:IsA("Tool") and t.Name:lower():find("axe") then axe = t break end
		end
		if axe then Humanoid:EquipTool(axe) end

		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:FindFirstChild("Trunk") or obj.Name:find("Tree") or obj.Name:find("Oak") or obj.Name:find("Pine") then
				local trunk = obj:FindFirstChild("Trunk") or obj:FindFirstChildWhichIsA("BasePart")
				if trunk and (trunk.Position - Root.Position).Magnitude <= FarmRange then
					Root.CFrame = CFrame.new(trunk.Position + Vector3.new(0,6,0))
					if axe and axe.Parent == Character then axe:Activate() end
					lastChop = tick()
					task.wait(ChopDelay)
					break
				end
			end
		end
	end
end)

-- Movement
RunService.RenderStepped:Connect(function(dt)
	if not Root or not Humanoid then return end
	Humanoid.WalkSpeed = WalkSpeed
	Humanoid.JumpPower = JumpPower

	if Flying then
		Humanoid.PlatformStand = true
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

		if dir.Magnitude > 0 then
			Root.CFrame += dir.Unit * FlySpeed * dt
		end
	else
		Humanoid.PlatformStand = false
	end

	if Noclip and Character then
		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

Fluent:Notify({Title = "Island Hub", Content = "Loaded Successfully!", Duration = 8})