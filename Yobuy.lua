-- ==========================================
-- KEREN HUB • OFFICE WORKER (WIND UI VERSION)
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Set Tema WindUI
WindUI:AddTheme({
    Name = "Dark",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

local Window = WindUI:CreateWindow({
    Title   = "Keren Hub",
    Author  = "Office Worker Automation",
    Folder  = "kerenhub",
    Icon    = "briefcase",
    Theme   = "Dark",
    Acrylic = true,
    Transparent = true,
    Background = "rbxassetid://84152360484913",
    Size    = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey  = Enum.KeyCode.RightShift,
    Resizable  = true,
    AutoScale  = true,
    NewElements = true,
    BackgroundImageTransparency = 0.65,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    SideBarWidth = 200,
    Topbar = {
        Height      = 44,
        ButtonsType = "Default",
    },
    OpenButton = {
        Title = "Keren Hub",
        Icon = "zap",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
        Color = ColorSequence.new(
            Color3.fromHex("#000000"),
            Color3.fromHex("#000000")
        ),
    },
    User = {
        Enabled  = true,
        Anonymous = false,
        Callback = function()
            print("user panel clicked")
        end,
    },
})

-- ==========================================
-- MAIN TAB (AUTO FARM & AUTO SOLVER)
-- ==========================================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house"
})

MainTab:Paragraph({
    Title = "Office Worker Automation",
    Desc = "Fitur Auto Farm + Auto-Solver Math Kuis Kantor Aktif Otomatis."
})

local AutoOfficeEnabled = false
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

local CorrectAnswerEvent = JobEvents:WaitForChild("CorrectAnswer")
local GenerateQuestionEvent = JobEvents:WaitForChild("GenerateQuestion")

-- Dengerin Event Game Asli
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
    CurrentTargetComputer = computerName
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
    CurrentTargetComputer = nil
end)

-- ==========================================
-- AUTO-SOLVER PENJUMLAHAN MATEMATIKA KANTOR
-- ==========================================
GenerateQuestionEvent.OnClientEvent:Connect(function(questionText, options, questionID)
    if not AutoOfficeEnabled then return end
    task.wait(0.4) -- Jeda natural biar aman dari deteksi server
    
    pcall(function()
        -- Bersihin teks soal dari simbol teks (ambil ekspresi matematikanya doang)
        local cleanExpr = questionText:gsub("=.*", ""):gsub("[^%d%+%-*%/%(%)]", "")
        
        -- Hitung hasil matematika pakai loadstring aman
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end
        local correctAnswerValue = tostring(mathFunc())
        
        -- Cocokkan hasil dengan pilihan jawaban di game lalu tembak server!
        for _, opt in ipairs(options) do
            local optClean = tostring(opt.Text):gsub("%D", "")
            if optClean == correctAnswerValue or tostring(opt.Text) == correctAnswerValue then
                CorrectAnswerEvent:FireServer(opt.ID, questionID)
                break
            end
        end
    end)
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

-- Teleport halus ke depan part printer
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

-- Toggle Utama di WindUI
MainTab:Toggle({
    Title = "Auto Farm Office + Math Solver",
    Desc = "Otomatis ambil job, teleport ke printer, dan jawab soal kuis angka.",
    Value = false,
    Callback = function(state)
        AutoOfficeEnabled = state
        WindUI:Notify({
            Title = "Office Auto Farm",
            Content = state ? "Status: AKTIF 🟢" : "Status: MATI 🔴",
            Duration = 3
        })
    end,
})

-- ==========================================
-- SETTINGS TAB (TEMA & TRANSPARANSI)
-- ==========================================
local ThemeTab = Window:Tab({ Title = "Settings", Icon = "settings" })

ThemeTab:Dropdown({
    Title  = "Theme",
    Values = (function()
        local names = {}
        for name in pairs(WindUI:GetThemes()) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end)(),
    Value   = WindUI:GetCurrentTheme(),
    Callback = function(selected)
        WindUI:SetTheme(selected)
    end,
})

ThemeTab:Toggle({
    Title = "Acrylic",
    Value = WindUI:GetTransparency(),
    Callback = function()
        local isOn = Window.Acrylic
        WindUI:ToggleAcrylic(not isOn)
    end,
})

ThemeTab:Toggle({
    Title = "Transparent",
    Value = WindUI:GetTransparency(),
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

local currentKey = Enum.KeyCode.RightShift

ThemeTab:Keybind({
    Title = "Toggle UI Key",
    Value = currentKey,
    Callback = function(v)
        currentKey = (typeof(v) == "EnumItem") and v or Enum.KeyCode[v]
        Window:SetToggleKey(currentKey)
    end,
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == currentKey then
        Window:Toggle()
    end
end)

-- Notifikasi Selamat Datang
WindUI:Notify({
  Title = "Keren Hub",
  Content = "Berhasil dimuat! Silakan nyalakan Auto Farm di Tab Main.",
  Duration = 5,
})
