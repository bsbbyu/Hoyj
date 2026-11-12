-- ==========================================
-- KEREN HUB - OFFICE WORKER (WIND UI STABLE)
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "💼 Keren Hub - Office 💼",
    Icon = "briefcase",
    Author = "by Kenzo",
    Folder = "KerenHubOfficeConfig"
})

local MainTab = Window:Tab({ Title = "🏠 Home", Icon = "home" })
local MainSection = MainTab:Section({ Title = "Main Farm Office" })
local SettingsSection = MainTab:Section({ Title = "Settings & Extra" })

-- ==========================================
-- VARIABEL & LAYANAN UTAMA
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AutoOfficeEnabled = false
local AntiAfkEnabled = false
local NoclipEnabled = false
local BlackScreenEnabled = false

local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

local CorrectAnswerEvent = JobEvents:WaitForChild("CorrectAnswer")
local GenerateQuestionEvent = JobEvents:WaitForChild("GenerateQuestion")
local farmThread = nil

pcall(function()
    GuiService:SetGameplayPausedNotificationEnabled(false)
end)

-- ==========================================
-- FUNGSI OVERLAY HITAM PEKAT + LOGO K
-- ==========================================
local function showOverlay()
    pcall(function()
        if not BlackScreenEnabled then return end
        if PlayerGui:FindFirstChild("KHubAutoOfficeOverlay") then return end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "KHubAutoOfficeOverlay"
        screenGui.Parent = PlayerGui
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local bgFrame = Instance.new("Frame")
        bgFrame.Name = "BackgroundOverlay"
        bgFrame.Size = UDim2.new(1, 0, 1, 0)
        bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bgFrame.BackgroundTransparency = 0
        bgFrame.Parent = screenGui

        local centerContainer = Instance.new("Frame")
        centerContainer.Name = "CenterContainer"
        centerContainer.Size = UDim2.new(0, 300, 0, 250)
        centerContainer.Position = UDim2.new(0.5, -150, 0.5, -125)
        centerContainer.BackgroundTransparency = 1
        centerContainer.Parent = bgFrame

        local logoBox = Instance.new("Frame")
        logoBox.Name = "LogoBox"
        logoBox.Size = UDim2.new(0, 90, 0, 90)
        logoBox.Position = UDim2.new(0.5, -45, 0, 10)
        logoBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        logoBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
        logoBox.BorderSizePixel = 2
        logoBox.Parent = centerContainer

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 12)
        uiCorner.Parent = logoBox

        local logoText = Instance.new("TextLabel")
        logoText.Name = "LogoLetter"
        logoText.Size = UDim2.new(1, 0, 1, 0)
        logoText.BackgroundTransparency = 1
        logoText.Text = "K"
        logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
        logoText.TextSize = 50
        logoText.Font = Enum.Font.GothamBold
        logoText.Parent = logoBox

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "HubTitle"
        titleLabel.Size = UDim2.new(1, 0, 0, 40)
        titleLabel.Position = UDim2.new(0, 0, 0, 110)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Keren Hub"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 26
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Parent = centerContainer

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusText"
        statusLabel.Size = UDim2.new(1, 0, 0, 25)
        statusLabel.Position = UDim2.new(0, 0, 0, 150)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Office Worker Running..."
        statusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        statusLabel.TextSize = 13
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.Parent = centerContainer
    end)
end

local function hideOverlay()
    pcall(function()
        if PlayerGui:FindFirstChild("KHubAutoOfficeOverlay") then
            PlayerGui.KHubAutoOfficeOverlay:Destroy()
        end
    end)
end

-- ==========================================
-- LISTENER & LOGIKA UTAMA OFFICE
-- ==========================================
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
    CurrentTargetComputer = computerName
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
    CurrentTargetComputer = nil
end)

-- Auto-Solver Kuis Penjumlahan Matematika Kantor
GenerateQuestionEvent.OnClientEvent:Connect(function(questionText, options, questionID)
    if not AutoOfficeEnabled then return end
    task.wait(0.3)
    
    pcall(function()
        local cleanExpr = questionText:gsub("=.*", ""):gsub("[^%d%+%-*%/%(%)]", "")
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end
        local correctAnswerValue = tostring(mathFunc())
        
        for _, opt in ipairs(options) do
            local optClean = tostring(opt.Text):gsub("%D", "")
            if optClean == correctAnswerValue or tostring(opt.Text) == correctAnswerValue then
                CorrectAnswerEvent:FireServer(opt.ID, questionID)
                break
            end
        end
    end)
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if AntiAfkEnabled then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

local function selectOfficeJob()
    pcall(function()
        local TeamChange = JobEvents:FindFirstChild("TeamChangeRequest")
        if TeamChange then
            TeamChange:FireServer("Office Worker", 11378976, 1, 0, "Detector")
            task.wait(2)
        end
    end)
end

local function teleportToPart(targetPart)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPart then return end
        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)
    end)
end

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

-- ==========================================
-- LOOPING UTAMA AUTO FARM OFFICE
-- ==========================================
local function startFarmLoop()
    if farmThread then task.cancel(farmThread) end
    
    farmThread = task.spawn(function()
        while true do
            task.wait(1)
            if not AutoOfficeEnabled then break end

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
    end)
end

-- ==========================================
-- ELEMEN UI WINDUI
-- ==========================================
MainSection:Toggle({
    Title = "Auto Farm Office + Math Solver",
    Desc = "Otomatis ambil job kantor, teleport printer, & jawab soal kuis",
    Value = false,
    Callback = function(State)
        AutoOfficeEnabled = State
        NoclipEnabled = State
        
        if State then
            showOverlay()
            WindUI:Notify({ Title = "Office Auto Farm", Content = "Auto Farm Aktif!", Duration = 2 })
            startFarmLoop()
        else
            hideOverlay()
            WindUI:Notify({ Title = "Office Auto Farm", Content = "Auto Farm Dimatikan.", Duration = 2 })
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
        end
    end
})

SettingsSection:Toggle({
    Title = "Black Screen Overlay",
    Desc = "Layar hitam pekat saat auto-farm menyala",
    Value = false,
    Callback = function(State)
        BlackScreenEnabled = State
        if State and AutoOfficeEnabled then
            showOverlay()
        else
            hideOverlay()
        end
        WindUI:Notify({ Title = "Black Screen", Content = "Status: " .. (State and "Aktif" or "Mati"), Duration = 2 })
    end
})

SettingsSection:Toggle({
    Title = "Anti-AFK",
    Desc = "Mencegah agar tidak ke-kick otomatis oleh server",
    Value = false,
    Callback = function(State)
        AntiAfkEnabled = State
        if State then
            WindUI:Notify({ Title = "Anti-AFK", Content = "Anti-AFK Diaktifkan!", Duration = 2 })
        else
            WindUI:Notify({ Title = "Anti-AFK", Content = "Anti-AFK Dimatikan.", Duration = 2 })
        end
    end
})

WindUI:Notify({ Title = "Keren Hub Loaded", Content = "UI Office Worker Siap Digass!", Duration = 4 })
