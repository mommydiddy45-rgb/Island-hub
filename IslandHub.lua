if not game:IsLoaded() then
	game.Loaded:Wait()
end

repeat task.wait() until game.Players.LocalPlayer

if not loadstring then
	return warn("Executor does not support loadstring")
end

-- UI

local success, Fluent = pcall(function()
	return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
	return warn("Failed to load Fluent UI")
end

-- SERVICES

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer

-- CHARACTER

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function(Char)
	Character = Char
	Humanoid = Char:WaitForChild("Humanoid")
	Root = Char:WaitForChild("HumanoidRootPart")
end)

-- WINDOW

local Window = Fluent:CreateWindow({
	Title = "Island Hub",
	SubTitle = "by rayon",
	TabWidth = 160,
	Size = UDim2.fromOffset(520, 420),
	Acrylic = false,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({
		Title = "Main",
		Icon = "home"
	})
}

local MainTab = Tabs.Main

-- WALKSPEED

local WalkSpeed = 16

MainTab:AddSlider("WalkSpeed", {
	Title = "WalkSpeed",
	Default = 16,
	Min = 16,
	Max = 150,
	Rounding = 1,

	Callback = function(Value)
		WalkSpeed = Value
	end
})

-- JUMP POWER

local JumpPower = 50

MainTab:AddSlider("JumpPower", {
	Title = "JumpPower",
	Default = 50,
	Min = 50,
	Max = 250,
	Rounding = 1,

	Callback = function(Value)
		JumpPower = Value
	end
})

-- INFINITE JUMP

local InfiniteJump = false

MainTab:AddToggle("InfiniteJump", {
	Title = "Infinite Jump",
	Default = false,

	Callback = function(Value)
		InfiniteJump = Value
	end
})

UIS.JumpRequest:Connect(function()
	if InfiniteJump and Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- FLY

local Flying = false
local FlySpeed = 70

MainTab:AddSlider("FlySpeed", {
	Title = "Fly Speed",
	Default = 70,
	Min = 20,
	Max = 200,
	Rounding = 1,

	Callback = function(Value)
		FlySpeed = Value
	end
})

MainTab:AddToggle("Fly", {
	Title = "Fly",
	Default = false,

	Callback = function(Value)
		Flying = Value
	end
})

-- SAVE LAYOUT

local SavedLayout = {}

MainTab:AddButton({
	Title = "Save Layout",

	Callback = function()

		table.clear(SavedLayout)

		for _, v in pairs(workspace:GetDescendants()) do

			if v:IsA("Part") and v.Anchored then

				local distance = (v.Position - Root.Position).Magnitude

				if distance <= 100 then

					table.insert(SavedLayout, {
						Size = v.Size,
						CFrame = v.CFrame,
						Color = v.Color,
						Material = v.Material
					})
				end
			end
		end

		Fluent:Notify({
			Title = "Island Hub",
			Content = "Saved "..#SavedLayout.." parts",
			Duration = 5
		})
	end
})

-- PREVIEW LAYOUT

MainTab:AddButton({
	Title = "Preview Layout",

	Callback = function()

		for _, data in pairs(SavedLayout) do

			local p = Instance.new("Part")

			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 0.5

			p.Size = data.Size
			p.CFrame = data.CFrame
			p.Color = data.Color
			p.Material = data.Material

			p.Parent = workspace

			Debris:AddItem(p, 30)
		end

		Fluent:Notify({
			Title = "Island Hub",
			Content = "Preview Generated",
			Duration = 5
		})
	end
})

-- REJOIN

MainTab:AddButton({
	Title = "Rejoin",

	Callback = function()
		TeleportService:Teleport(game.PlaceId, Player)
	end
})

-- MAIN LOOP

RunService.RenderStepped:Connect(function(delta)

	if not Character or not Root or not Humanoid then
		return
	end

	local Camera = workspace.CurrentCamera

	-- WALKSPEED

	Humanoid.WalkSpeed = WalkSpeed

	-- JUMP POWER

	Humanoid.JumpPower = JumpPower

	-- FLY

	if Flying then

		Humanoid.PlatformStand = true

		local MoveDirection = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			MoveDirection += Camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.S) then
			MoveDirection -= Camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.A) then
			MoveDirection -= Camera.CFrame.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.D) then
			MoveDirection += Camera.CFrame.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			MoveDirection += Vector3.new(0,1,0)
		end

		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			MoveDirection -= Vector3.new(0,1,0)
		end

		if MoveDirection.Magnitude > 0 then
			Root.CFrame += MoveDirection.Unit * FlySpeed * delta
		end

	else
		Humanoid.PlatformStand = false
	end
end)

-- NOTIFY

Fluent:Notify({
	Title = "Island Hub",
	Content = "Loaded Successfully",
	Duration = 5
})
