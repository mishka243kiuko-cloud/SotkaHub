-- Sotka Hub - starter template for your own Roblox Studio game
-- Key: SOTKA5
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- This is for your own game; server-authoritative coin collection should be
-- implemented separately in ServerScriptService.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local KEY = "SOTKA5"
local gui = Instance.new("ScreenGui")
gui.Name = "SotkaHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local frame = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(300, 220),
    Position = UDim2.new(0.5, -150, 0.5, -110),
    BackgroundColor3 = Color3.fromRGB(25, 25, 32),
    BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, frame)

make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.fromOffset(10, 6),
    BackgroundTransparency = 1,
    Text = "👑 SOTKA HUB",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
}, frame)

local keyBox = make("TextBox", {
    Size = UDim2.new(1, -30, 0, 38),
    Position = UDim2.fromOffset(15, 55),
    BackgroundColor3 = Color3.fromRGB(43, 43, 54),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    PlaceholderText = "Enter key...",
    Text = "",
    ClearTextOnFocus = false,
    TextScaled = true,
    Font = Enum.Font.Gotham,
}, frame)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, keyBox)

local status = make("TextLabel", {
    Size = UDim2.new(1, -30, 0, 24),
    Position = UDim2.fromOffset(15, 96),
    BackgroundTransparency = 1,
    Text = "Enter the key to unlock the demo menu",
    TextColor3 = Color3.fromRGB(210, 210, 220),
    TextScaled = true,
    Font = Enum.Font.Gotham,
}, frame)

local activate = make("TextButton", {
    Size = UDim2.new(1, -30, 0, 38),
    Position = UDim2.fromOffset(15, 130),
    BackgroundColor3 = Color3.fromRGB(100, 75, 220),
    Text = "ACTIVATE",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
}, frame)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, activate)

activate.Activated:Connect(function()
    if keyBox.Text ~= KEY then
        status.Text = "Wrong key"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    frame:Destroy()

    local menu = make("Frame", {
        Name = "UnlockedMenu",
        Size = UDim2.fromOffset(280, 200),
        Position = UDim2.new(0.5, -140, 0.5, -100),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
    }, gui)
    make("UICorner", {CornerRadius = UDim.new(0, 12)}, menu)

    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1,
        Text = "SOTKA HUB • DEMO",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
    }, menu)

    local info = make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 95),
        Position = UDim2.fromOffset(10, 50),
        BackgroundTransparency = 1,
        Text = "Key accepted!\\nAdd your own-game features here.\\nCoin rewards must be verified by the server.",
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextWrapped = true,
        TextScaled = true,
        Font = Enum.Font.Gotham,
    }, menu)

    local close = make("TextButton", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.fromOffset(10, 155),
        BackgroundColor3 = Color3.fromRGB(100, 75, 220),
        Text = "CLOSE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
    }, menu)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
    close.Activated:Connect(function()
        gui:Destroy()
    end)
end)

-- Make the panel draggable on desktop and touch devices.
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
