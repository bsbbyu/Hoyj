-- ==========================================
-- KEREN HUB - BARISTA ULTIMATE AUTO FARM
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("[Keren Hub] Memuat Full-Cycle Auto Farm Barista...")

-- 1. STATE MANAGEMENT DARI NOTIFIKASI GAME
local CurrentState = "IDLE" 

local BaristaEvent = ReplicatedStorage:WaitForChild("BaristaAssets"):WaitForChild("Events"):WaitForChild("BaristaEvent")
local CurrentToken = nil

BaristaEvent.OnClientEvent:Connect(function(action, data)
    if action == "JobStarted" or action == "SpawnNPC" then
        if type(data) == "table" and data.Token then
            CurrentToken = data.Token
        end
    end
end)

-- Tangkap Notif Teks In-Game Secara Real-Time
PlayerGui.DescendantAdded:Connect(function(v)
    if v:IsA("TextLabel") or v:IsA("TextButton") then
        local text = v.Text
        if text:find("Shift di mulai") then
            CurrentState = "JOB_STARTED"
        elseif text:find("Npc") then
            CurrentState = "NPC_ARRIVED"
        elseif text:find("Sedang menyeduh") then
            CurrentState = "BREWING"
        elseif text:find("Pesanan sudah siap") then
            CurrentState = "READY"
        elseif text:find("Kerja bagus") then
            CurrentState = "DONE"
        end
    end
end)

-- Koordinat Lokasi Kerja Barista
local COORDS = {
    ShiftSpot     = CFrame.new(-4992.262, 4.287, -716.253),
    CoffeeMachine = CFrame.new(-4997.648, 4.287, -794.613),
    Customer      = CFrame.new(-4996.451, 4.287, -760.959)
}

-- 2. METODE "BAR GEDE" (KUNCI TARGETZONE SUMBU Y = 1 & AUTO CLICK)
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local baristaGui = PlayerGui:FindFirstChild("BaristaGUI")
            if baristaGui then
                local targetZone = baristaGui:FindFirstChild("TargetZone", true)
                if targetZone then
                    -- Paksa ukuran sumbu Y jadi 1 secara konstan biar minigame auto-win!
                    targetZone.Size = UDim2.new(targetZone.Size.X.Scale, targetZone.Size.X.Offset, 1, 0)
                end
                
                for _, v in pairs(baristaGui:GetDescendants()) do
                    if (v:IsA("TextButton") or v:IsA("ImageButton")) and firesignal then
                        firesignal(v.MouseButton1Click)
                    end
                end
            end
        end)
    end
end)

-- 3. ANTI-AFK SYSTEM
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- Fungsi Pendukung (Job Request, Tween Movement, Proximity Prompt)
local function selectBaristaJob()
    pcall(function()
        local Event = ReplicatedStorage:FindFirstChild("JobEvents") and ReplicatedStorage.JobEvents:FindFirstChild("TeamChangeRequest")
        if Event then
            Event:FireServer("Barista", 11378976, 1, 0, "Detector")
        end
    end)
end

local function smoothMoveTo(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / 3
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
    end)
end

local function fireNearestPrompt()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Parent then
                local partPos = v.Parent:IsA("Model") and v.Parent.PrimaryPart and v.Parent.PrimaryPart.Position or (v.Parent:IsA("BasePart") and v.Parent.Position)
                if partPos and (partPos - hrp.Position).Magnitude <= 15 then
                    if fireproximityprompt then
                        fireproximityprompt(v)
                    end
                end
            end
        end
    end)
end

-- 4. MAIN LOOP AUTOMATION
task.spawn(function()
    selectBaristaJob()
    task.wait(1.5)

    while true do
        pcall(function()
            -- Step 1: Pergi ke Tempat Shift & Ambil Tugas
            smoothMoveTo(COORDS.ShiftSpot)
            fireNearestPrompt()
            
            repeat task.wait(0.2) until CurrentState == "JOB_STARTED" or CurrentState == "NPC_ARRIVED"

            -- Step 2: Pergi ke Mesin Kopi & Proses Minigame (Bar Gede menghandle otomatis)
            smoothMoveTo(COORDS.CoffeeMachine)
            BaristaEvent:FireServer("TryBrew")
            task.wait(0.3)
            
            if CurrentToken then
                BaristaEvent:FireServer("CompleteMinigame", { ["Token"] = CurrentToken })
            end

            repeat task.wait(0.2) until CurrentState == "READY"

            -- Step 3: Antar Pesanan ke Pelanggan
            smoothMoveTo(COORDS.Customer)
            BaristaEvent:FireServer("ServeOrder")

            repeat task.wait(0.2) until CurrentState == "DONE"

            -- Reset untuk siklus berikutnya
            CurrentState = "IDLE"
            print("[Keren Hub] Siklus Selesai! Mengulang kembali...")
        end)
        task.wait(0.5)
    end
end)

print("[Keren Hub] Script Barista Auto Farm Berhasil Dieksekusi!")
