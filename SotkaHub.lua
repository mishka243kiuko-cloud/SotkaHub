-- SotkaHub - purple/black UI prototype for your own Roblox Studio project.
-- Place as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- This is a UI demo only. It does NOT bypass bans, anti-cheat, or grant game permissions.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local PURPLE = Color3.fromRGB(145, 60, 255)
local DARK = Color3.fromRGB(12, 9, 20)
local PANEL = Color3.fromRGB(25, 19, 38)
local TEXT = Color3.fromRGB(245, 239, 255)
local MUTED = Color3.fromRGB(174, 157, 198)

local gui = Instance.new("ScreenGui")
gui.Name = "SotkaHub"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local root = Instance.new("Frame")
root.Name = "Window"
root.Size = UDim2.fromOffset(390, 440)
root.Position = UDim2.new(0.5, -195, 0.5, -220)
root.BackgroundColor3 = DARK
root.BorderSizePixel = 0
root.Active = true
root.Draggable = true
root.Parent = gui
Instance.new("UICorner", root).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", root)
stroke.Color = PURPLE
stroke.Thickness = 2

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -80, 0, 48)
header.Position = UDim2.fromOffset(16, 4)
header.BackgroundTransparency = 1
header.Text = "♛  SotkaHub"
header.TextColor3 = Color3.fromRGB(218, 178, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 24
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = root

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 30)
close.Position = UDim2.new(1, -44, 0, 10)
close.BackgroundColor3 = PANEL
close.Text = "×"
close.TextColor3 = TEXT
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = root
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Activated:Connect(function() root.Visible = false end)

local body = Instance.new("Frame")
body.Position = UDim2.fromOffset(14, 58)
body.Size = UDim2.new(1, -28, 1, -72)
body.BackgroundTransparency = 1
body.Parent = root

local language = "EN"
local selectedDevice = "Phone"
local currentPage = "Home"
local demoUnlocked = false
local labels = {
 EN = {key="Enter demo key", hint="Use DEMO-2026 (UI preview only)", activate="Activate", activated="Key activated!", device="Choose device", language="Choose language", next="Continue", home="Home", games="Games", settings="Settings", mm2="Murder Mystery 2", rivals="RIVALS", other="Other Games", safe="Safe Test Mode (UI demo)", note="Test-mode status is illustrative; configure trusted test access on your own server.", visual="Visual settings", neon="Neon theme", compact="Compact layout", perf="Performance tips", back="Back"},
 RU = {key="Введите демо-ключ", hint="Введите DEMO-2026 (только просмотр)", activate="Активировать", activated="Ключ активирован!", device="Выберите устройство", language="Выберите язык", next="Далее", home="Главная", games="Игры", settings="Настройки", mm2="Murder Mystery 2", rivals="RIVALS", other="Другие игры", safe="Безопасный тестовый режим (демо)", note="Статус показан для примера; доступ к тестам проверяйте на сервере своей игры.", visual="Настройки вида", neon="Неоновая тема", compact="Компактное меню", perf="Советы по производительности", back="Назад"}
}
local function t(k) return labels[language][k] or k end

local function clear()
 for _, child in ipairs(body:GetChildren()) do child:Destroy() end
end
local function label(text, y, height, size)
 local l = Instance.new("TextLabel")
 l.Position = UDim2.fromOffset(4, y)
 l.Size = UDim2.new(1, -8, 0, height or 34)
 l.BackgroundTransparency = 1
 l.Text = text
 l.TextColor3 = TEXT
 l.Font = Enum.Font.GothamMedium
 l.TextSize = size or 15
 l.TextWrapped = true
 l.Parent = body
 return l
end
local function button(text, y, callback, color)
 local b = Instance.new("TextButton")
 b.Position = UDim2.fromOffset(4, y)
 b.Size = UDim2.new(1, -8, 0, 40)
 b.BackgroundColor3 = color or PANEL
 b.BorderSizePixel = 0
 b.Text = text
 b.TextColor3 = TEXT
 b.Font = Enum.Font.GothamMedium
 b.TextSize = 15
 b.Parent = body
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
 b.Activated:Connect(callback)
 return b
end
local function showKey()
 clear()
 label("♨  " .. t("key"), 4, 34, 18)
 local input = Instance.new("TextBox")
 input.Position = UDim2.fromOffset(4, 48)
 input.Size = UDim2.new(1, -8, 0, 42)
 input.BackgroundColor3 = PANEL
 input.BorderSizePixel = 0
 input.PlaceholderText = t("hint")
 input.Text = ""
 input.TextColor3 = TEXT
 input.PlaceholderColor3 = MUTED
 input.Font = Enum.Font.Gotham
 input.TextSize = 14
 input.ClearTextOnFocus = false
 input.Parent = body
 Instance.new("UICorner", input).CornerRadius = UDim.new(0, 9)
 local status = label("", 94, 34, 13)
 button(t("activate"), 138, function()
  if input.Text == "DEMO-2026" then
   demoUnlocked = true
   status.Text = "✓  " .. t("activated")
   status.TextColor3 = Color3.fromRGB(110, 255, 170)
   task.wait(0.6)
   showDevice()
  else
   status.Text = language == "RU" and "Неверный демо-ключ" or "Invalid demo key"
   status.TextColor3 = Color3.fromRGB(255, 110, 140)
  end
 end, PURPLE)
 label("UI demo only — not real authentication or anti-ban protection.", 194, 46, 12).TextColor3 = MUTED
end
function showDevice()
 clear()
 label(t("device"), 4, 34, 18)
 for i, name in ipairs({"Computer", "Tablet", "Phone"}) do
  button(name, 48 + (i-1)*48, function() selectedDevice = name; showLanguage() end)
 end
end
function showLanguage()
 clear()
 label(t("language"), 4, 34, 18)
 button("English", 52, function() language = "EN"; showHome() end, PURPLE)
 button("Русский", 104, function() language = "RU"; showHome() end)
end
function showPage(titleText, entries)
 clear()
 label(titleText, 2, 36, 18)
 for i, entry in ipairs(entries) do
  local b = button("◈  " .. entry, 42 + (i-1)*48, function() end)
  b.TextXAlignment = Enum.TextXAlignment.Left
  b.Text = "   ◈  " .. entry
 end
 button("←  " .. t("back"), math.min(42 + #entries*48, 340), showHome, PURPLE)
end
function showHome()
 clear()
 label("Welcome to SotkaHub", 0, 34, 20)
 label(t("note"), 34, 54, 12).TextColor3 = MUTED
 button("⚔  " .. t("mm2"), 96, function()
  showPage(t("mm2"), language == "RU" and {"Монеты (демо)", "Роли (справка)", "Выживание (справка)", "Визуальные настройки"} or {"Coins (demo)", "Roles (reference)", "Survival (reference)", "Visual settings"})
 end)
 button("🎯  " .. t("rivals"), 144, function()
  showPage(t("rivals"), language == "RU" and {"Оружие (справка)", "Тренировка прицеливания", "Статистика боя", "Производительность"} or {"Weapons (reference)", "Aim training", "Combat stats", "Performance"})
 end)
 button("🎮  " .. t("other"), 192, function()
  showPage(t("other"), language == "RU" and {"Другие игровые разделы", "Тестовые функции"} or {"Other game sections", "Test features"})
 end)
 button("⚙  " .. t("settings"), 240, function()
  showPage(t("settings"), {t("visual"), t("neon"), t("compact"), t("perf"), t("safe")})
 end)
 label("Device: " .. selectedDevice .. "   •   " .. (language == "RU" and "Демо-режим" or "Demo mode"), 300, 30, 12).TextColor3 = MUTED
end
showKey()
