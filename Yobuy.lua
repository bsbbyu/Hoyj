-- ==========================================
-- Yobuy.lua - KEREN HUB (MAIN UI LOADER)
-- ==========================================

-- 1. Load WindUI Library Resmi (Latest Version)
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 2. Buat Jendela Panel Utama & Menu
local Window = WindUI:CreateWindow({
    Title = "Keren Hub",
    Icon = "monitor",
    Author = "Office Bot",
    Folder = "OfficeBotConfig",
    Size = UDim2.fromOffset(480, 320),
    Transparent = true,
    Theme = "Dark",
})

local MainTab = Window:Tab({
    Title = "Automation",
    Icon = "home",
})

-- Variabel global status bot
getgenv().AutoFarmActive = true

MainTab:Toggle({
    Title = "Auto Farm Office",
    Desc = "Aktifkan atau matikan bot otomatis kantor",
    Value = false,
    Callback = function(state)
        getgenv().AutoFarmActive = state
        local statusText = "Bot dimatikan!"
        if state then
            statusText = "Bot diaktifkan!"
        end
        WindUI:Notify({
            Title = "Status Bot",
            Content = statusText,
            Duration = 2
        })
    end
})

MainTab:Button({
    Title = "Manual Run Printer",
    Desc = "Panggil fungsi jalan ke printer sekarang",
    Callback = function()
        if getgenv().RunManualPrinter then
            task.spawn(getgenv().RunManualPrinter)
            WindUI:Notify({
                Title = "Informasi",
                Content = "Mencari printer aktif...",
                Duration = 2
            })
        end
    end
})

WindUI:Notify({
    Title = "UI Berhasil Dimuat",
    Content = "Menghubungkan logika bot...",
    Duration = 2
})

-- 3. Tarik dan jalankan file logika bot kedua (Hujre.lua) secara otomatis di baliknya
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bsbbyu/Hujre/refs/heads/main/Hujre.lua"))()
end)

if not success then
    warn("[Keren Hub] Gagal memuat file logika Hujre: " .. tostring(err))
end
