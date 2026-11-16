-- ==========================================
-- FUNGSI DETEKSI HANYA PROXIMITY PRINTER
-- ==========================================
local function walkToActivePrinter()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. Lepas dari kursi dulu
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(1)
        end

        local targetPrinterName = nil
        local targetPos = nil
        local targetPrompt = nil
        local activePrinters = {}

        -- 2. Scan khusus ProximityPrompt di dalam masing-masing model Print_1 s/d Print_5
        local attempts = 0
        while #activePrinters == 0 and attempts < 15 do
            attempts = attempts + 1
            activePrinters = {}

            for i = 1, 5 do
                local pName = "Print_" + i -- (pastikan string concat bener)
                local pNameReal = "Print_" .. i
                local printerModel = ComputersFolder:FindFirstChild(pNameReal)
                
                if printerModel then
                    -- Cari ProximityPrompt yang spesifik di dalam printer ini
                    local prompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        table.insert(activePrinters, {name = pNameReal, prompt = prompt})
                    end
                end
            end

            if #activePrinters == 0 then
                task.wait(0.4)
            end
        end

        if #activePrinters > 0 then
            print("• Proximity printer aktif terdeteksi (" .. #activePrinters .. " printer)")
            targetPrinterName = activePrinters[1].name
            targetPos = PrinterCoordinates[targetPrinterName]
            targetPrompt = activePrinters[1].prompt
        else
            -- Fallback kalau masih loading, paksa ke Print_1
            targetPrinterName = "Print_1"
            targetPos = PrinterCoordinates["Print_1"]
            local pModel = ComputersFolder:FindFirstChild("Print_1")
            if pModel then
                targetPrompt = pModel:FindFirstChildOfClass("ProximityPrompt", true)
            end
        end

        if targetPos and targetPrinterName then
            print("[Keren Hub] Menuju ke printer: " .. targetPrinterName)
            
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })

            path:ComputeAsync(hrp.Position, targetPos + Vector3.new(0, 0, 1.5))
            
            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for _, waypoint in ipairs(waypoints) do
                    humanoid:MoveTo(waypoint.Position)
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    local reached = false
                    local conn
                    conn = humanoid.MoveToFinished:Connect(function(isReached)
                        reached = true
                        if conn then conn:Disconnect() end
                    end)
                    
                    local t = tick()
                    while not reached and (tick() - t) < 0.8 do
                        task.wait(0.05)
                    end
                    if conn then conn:Disconnect() end
                end
            else
                humanoid:MoveTo(targetPos)
                task.wait(1.5)
            end

            task.wait(0.3)
            if targetPrompt and fireproximityprompt then
                fireproximityprompt(targetPrompt)
                print("• Semua lancar (Berhasil interaksi dengan " .. targetPrinterName .. ")")
            end
        else
            print("[Keren Hub] Gagal mendeteksi proximity printer.")
        end
    end)
end
