-- ==========================================
-- KEREN HUB - OFFICE WORKER (CLEAN COMPKILLER)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Load Compkiller UI Library dari GitHub resmi
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

-- Loading Screen & Window Utama (Buka/Tutup pakai Left Alt)
Compkiller:Loader("rbxassetid://120245531583106", 2).yield();

local Window = Compkiller.new({
	Name = "KEREN HUB • Office Worker",
	Keybind = "LeftAlt",
	Logo = "rbxassetid://120245531583106",
	Scale = Compkiller.Scale.Window,
	TextSize = 15,
});

-- Notifikasi Selamat Datang
local Notifier = Compkiller.newNotify();
Notifier.new({
	Title = "Keren Hub Loaded",
	Content = "Tekan [Left Alt] untuk Buka/Tutup UI!",
	Duration = 5,
	Icon = "rbxassetid://120245531583106"
});

-- Buat Kategori & Tab Utama
Window:DrawCategory({
	Name = "Main Features"
});

local FarmTab = Window:DrawTab({
	Name = "Auto Farm",
	Icon = "briefcase",
	EnableScrolling = true
});

local FarmSection = FarmTab:DrawSection({
	Name = "Office Worker Automation",
	Position = 'left'	
});

-- ==========================================
-- LOGIC AUTO-FARM OFFICE WORKER
-- ==========================================
local AutoOfficeEnabled = false
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

-- Dengerin Event Game Asli
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
	CurrentTargetComputer = computerName
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
	CurrentTargetComputer = nil
end)

-- Anti-AFK
task.spawn(function()
	LocalPlayer.Idled:Connect(function()
		VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
	end)
end)

-- Join Team Office Worker
local function selectOfficeJob()
	pcall(function()
		local TeamChange = JobEvents:FindFirstChild("TeamChangeRequest")
		if TeamChange then
			TeamChange:FireServer("Office Worker", 11378976, 1, 0, "Detector")
			task.wait(2)
		end
	end)
end

-- Teleport halus langsung ke depan part printer
local function teleportToPart(targetPart)
	pcall(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp or not targetPart then return end

		hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
		task.wait(0.3)
	end)
end

-- Interaksi ProximityPrompt Natural
local function interactPrompt(prompt)
	if not prompt then return end
	local holdTime = prompt.HoldDuration or 0
	if holdTime > 0 then
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(holdTime + 0.1)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	else
		if fireproximityprompt then
			fireproximityprompt(prompt)
		end
	end
end

-- MAIN LOOP AUTO FARM
task.spawn(function()
	while true do
		if AutoOfficeEnabled then
			pcall(function()
				if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Office Worker") then
					selectOfficeJob()
				end

				if CurrentTargetComputer then
					local targetModel = ComputersFolder:FindFirstChild(CurrentTargetComputer)
					if targetModel and targetModel:FindFirstChild("Part") then
						local targetPart = targetModel.Part
						local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")

						teleportToPart(targetPart)
						task.wait(0.5)
						
						if prompt then
							interactPrompt(prompt)
						end
					end
				end
			end)
		end
		task.wait(1)
	end
end)

-- Toggle Utama (Bersih tanpa teks status ribet)
FarmSection:AddToggle({
	Name = "Auto Farm Office",
	Flag = "AutoFarm_Office",
	Default = false,
	Callback = function(state)
		AutoOfficeEnabled = state
	end,
})

-- Tab Settings Tema Bawaan Compkiller
Window:DrawCategory({
	Name = "Misc"
})

local ThemeTab = Window:DrawTab({
	Icon = "paintbrush",
	Name = "Themes",
	Type = "Single"
})

ThemeTab:DrawSection({
	Name = "UI Themes"
}):AddDropdown({
	Name = "Select Theme",
	Default = "Default",
	Values = {
		"Default",
		"Dark Green",
		"Dark Blue",
		"Purple Rose",
		"Skeet"
	},
	Callback = function(v)
		Compkiller:SetTheme(v)
	end,
})
