-- SotkaHub - safe Roblox Studio prototype
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts in YOUR OWN Roblox experience.
-- This is a UI/demo for your own game, not an executor/third-party game exploit.
-- For DOORS-style highlighting, tag your own objects with CollectionService tags: "Door" and "Item".

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PURPLE = Color3.fromRGB(153, 55, 255)
local DARK = {bg=Color3.fromRGB(14, 10, 23), panel=Color3.fromRGB(24, 17, 38), card=Color3.fromRGB(32, 22, 49), text=Color3.fromRGB(248, 242, 255), sub=Color3.fromRGB(190, 169, 220), line=Color3.fromRGB(120, 45, 220)}
local LIGHT = {bg=Color3.fromRGB(245, 239, 255), panel=Color3.fromRGB(255, 252, 255), card=Color3.fromRGB(235, 222, 255), text=Color3.fromRGB(54, 25, 91), sub=Color3.fromRGB(105, 72, 145), line=Color3.fromRGB(155, 91, 255)}
local palette = DARK
local currentGame = "Choose a game"
local highlightsEnabled = {Door=false, Item=false}
local highlights = {}
local selectedDevice = "ðŸ’»"

local gui = Instance.new("ScreenGui")
gui.Name = "SotkaHubPrototype"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius=UDim.new(0, radius or 10)}, obj)
end
local function stroke(obj, color, thickness)
    make("UIStroke", {Color=color or palette.line, Thickness=thickness or 1, Transparency=0.15}, obj)
end
local function refreshColors()
    -- Recolor all UI elements carrying these attributes.
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            local role = obj:GetAttribute("SotkaRole")
            if role == "bg" then obj.BackgroundColor3 = palette.bg
            elseif role == "panel" then obj.BackgroundColor3 = palette.panel
            elseif role == "card" then obj.BackgroundColor3 = palette.card
            elseif role == "text" and obj:IsA("TextLabel") or role == "text" and obj:IsA("TextButton") then
                obj.TextColor3 = palette.text
            elseif role == "sub" and obj:IsA("TextLabel") then obj.TextColor3 = palette.sub end
        end
    end
    for _,obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("UIStroke") then obj.Color = palette.line end
    end
end

local root = make("Frame", {Name="Main", Size=UDim2.fromOffset(760, 500), Position=UDim2.new(0.5,-380,0.5,-250), BackgroundColor3=palette.bg, BorderSizePixel=0}, gui)
root:SetAttribute("SotkaRole", "bg")
round(root, 16); stroke(root, PURPLE, 2)
make("UISizeConstraint", {MinSize=Vector2.new(320, 390), MaxSize=Vector2.new(900, 650)}, root)

local top = make("Frame", {Size=UDim2.new(1,0,0,56), BackgroundColor3=palette.panel, BorderSizePixel=0}, root)
top:SetAttribute("SotkaRole", "panel"); round(top, 14)
local logo = make("TextLabel", {BackgroundTransparency=1, Position=UDim2.fromOffset(16,5), Size=UDim2.new(1,-140,0,46), Font=Enum.Font.GothamBold, Text="â™› SotkaHub", TextSize=25, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=palette.text}, top)
logo:SetAttribute("SotkaRole", "text")
local close = make("TextButton", {Size=UDim2.fromOffset(38,38), Position=UDim2.new(1,-48,0,9), Text="Ã—", TextSize=28, Font=Enum.Font.GothamMedium, TextColor3=palette.text, BackgroundColor3=palette.card, BorderSizePixel=0}, top)
close:SetAttribute("SotkaRole", "text"); round(close, 10); stroke(close)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

local side = make("Frame", {Position=UDim2.fromOffset(12,68), Size=UDim2.new(0,168,1,-80), BackgroundColor3=palette.panel, BorderSizePixel=0}, root)
side:SetAttribute("SotkaRole", "panel"); round(side, 12)
local content = make("Frame", {Position=UDim2.fromOffset(190,68), Size=UDim2.new(1,-202,1,-80), BackgroundColor3=palette.panel, BorderSizePixel=0}, root)
content:SetAttribute("SotkaRole", "panel"); round(content, 12)

local gameList = {"ðŸšª  DOORS", "ðŸ”ª  Murder Mystery 2", "ðŸªµ  Lumber Tycoon 2", "â¤ï¸  Undertale", "ðŸ¾  Pet Simulator 99", "âš”ï¸  Rivals"}
local selectedButton
local statusLabel
local function clearContent()
    for _,c in ipairs(content:GetChildren()) do if not c:IsA("UICorner") and not c:IsA("UIStroke") then c:Destroy() end end
end
local function addText(parent, text, size, pos, bounds, role)
    local label = make("TextLabel", {BackgroundTransparency=1, Text=text, TextSize=size or 15, Font=Enum.Font.Gotham, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center, Position=pos, Size=bounds, TextColor3=(role=="sub" and palette.sub or palette.text)}, parent)
    label:SetAttribute("SotkaRole", role or "text")
    return label
end
local function addButton(parent, text, pos, size, callback)
    local b = make("TextButton", {Position=pos, Size=size, BackgroundColor3=palette.card, BorderSizePixel=0, Text=text, TextColor3=palette.text, TextSize=14, Font=Enum.Font.GothamMedium, TextWrapped=true, AutoButtonColor=true}, parent)
    b:SetAttribute("SotkaRole", "card"); round(b, 9); stroke(b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function setHighlight(tag, enabled)
    highlightsEnabled[tag] = enabled
    for _,h in pairs(highlights[tag] or {}) do if h and h.Parent then h:Destroy() end end
    highlights[tag] = {}
    if not enabled then return end
    for _,inst in ipairs(CollectionService:GetTagged(tag)) do
        if inst:IsDescendantOf(workspace) then
            local h = Instance.new("Highlight")
            h.Name = "SotkaHubDemoHighlight"
            h.Adornee = inst
            h.FillColor = tag == "Door" and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(255, 215, 70)
            h.OutlineColor = h.FillColor
            h.FillTransparency = 0.72
            h.DepthMode = Enum.HighlightDepthMode.Occluded
            h.Parent = inst
            table.insert(highlights[tag], h)
        end
    end
end

local function toggleRow(parent, labelText, tag, y)
    addText(parent, labelText, 14, UDim2.fromOffset(16,y), UDim2.new(1,-105,0,34), "text")
    local b
    b = addButton(parent, highlightsEnabled[tag] and "ON âœ“" or "OFF â–¡", UDim2.new(1,-82,0,y+3), UDim2.fromOffset(64,28), function()
        setHighlight(tag, not highlightsEnabled[tag])
        b.Text = highlightsEnabled[tag] and "ON âœ“" or "OFF â–¡"
    end)
end

local function showHome()
    currentGame = "Choose a game"
    clearContent()
    addText(content, "Choose a game", 22, UDim2.fromOffset(18,10), UDim2.new(1,-36,0,38), "text")
    addText(content, "Each game has its own controls. Demo features work in your own Roblox Studio experience.", 12, UDim2.fromOffset(18,48), UDim2.new(1,-36,0,42), "sub")
    for i,name in ipairs(gameList) do
        local col = (i-1)%2; local row = math.floor((i-1)/2)
        addButton(content, name .. "   â€º", UDim2.fromOffset(18+col*255, 105+row*88), UDim2.fromOffset(238,70), function()
            currentGame = name
            showGame(name)
        end)
    end
end

function showGame(name)
    clearContent()
    addButton(content, "â€¹ Back to games", UDim2.fromOffset(14,12), UDim2.fromOffset(125,30), showHome)
    addText(content, name, 21, UDim2.fromOffset(150,8), UDim2.new(1,-165,0,38), "text")
    if string.find(name, "DOORS", 1, true) then
        addText(content, "Exploration helpers", 15, UDim2.fromOffset(18,54), UDim2.new(1,-36,0,28), "sub")
        toggleRow(content, "Highlight tagged doors", "Door", 88)
        toggleRow(content, "Highlight tagged items", "Item", 132)
        addText(content, "Setup: in your own place, tag door models with 'Door' and collectible objects with 'Item' using CollectionService.", 12, UDim2.fromOffset(18,184), UDim2.new(1,-36,0,70), "sub")
    elseif string.find(name, "Murder Mystery 2", 1, true) then
        addText(content, "Own-game weapon skin demo", 15, UDim2.fromOffset(18,58), UDim2.new(1,-36,0,28), "sub")
        addText(content, "Choose a visual preview. This prototype does not grant items in the original MM2.", 12, UDim2.fromOffset(18,84), UDim2.new(1,-36,0,42), "sub")
        local skins = {"Classic", "Purple Neon", "Frost", "Golden"}
        for i,skin in ipairs(skins) do
            addButton(content, "ðŸ”ª  "..skin, UDim2.fromOffset(18+((i-1)%2)*220, 140+math.floor((i-1)/2)*55), UDim2.fromOffset(205,42), function()
                if statusLabel then statusLabel:Destroy() end
                statusLabel = addText(content, "Preview selected: "..skin.." (connect this to your own game's weapon system)", 13, UDim2.fromOffset(18,260), UDim2.new(1,-36,0,42), "text")
            end)
        end
    elseif string.find(name, "Lumber Tycoon 2", 1, true) then
        addText(content, "Woodworking guide", 15, UDim2.fromOffset(18,58), UDim2.new(1,-36,0,28), "sub")
        for i,item in ipairs({"Select tree", "Select log", "Chop saw guide", "Sawmill guide", "Selling wood", "Build mode"}) do
            local col=(i-1)%2; local row=math.floor((i-1)/2)
            addButton(content, item, UDim2.fromOffset(18+col*220,100+row*54), UDim2.fromOffset(205,42), function()
                if statusLabel then statusLabel:Destroy() end
                statusLabel = addText(content, item..": add your own game's interaction here.", 13, UDim2.fromOffset(18,275), UDim2.new(1,-36,0,40), "text")
            end)
        end
    elseif string.find(name, "Undertale", 1, true) then
        for i,item in ipairs({"Battle", "Inventory", "Items", "Stats", "Settings"}) do
            addButton(content, item, UDim2.fromOffset(18,58+(i-1)*48), UDim2.new(1,-36,0,38), function()
                if statusLabel then statusLabel:Destroy() end
                statusLabel = addText(content, item.." selected â€” connect this to your own game's systems.", 13, UDim2.fromOffset(18,320), UDim2.new(1,-36,0,40), "text")
            end)
        end
    else
        addText(content, "Game-specific controls", 15, UDim2.fromOffset(18,58), UDim2.new(1,-36,0,28), "sub")
        addText(content, "This is a starter menu. Add features that match your own game's mechanics here.", 13, UDim2.fromOffset(18,92), UDim2.new(1,-36,0,60), "text")
    end
end

addText(side, "NAVIGATION", 11, UDim2.fromOffset(14,12), UDim2.new(1,-28,0,24), "sub")
addButton(side, "âŒ‚   Home", UDim2.fromOffset(10,42), UDim2.new(1,-20,0,38), showHome)
addButton(side, "ðŸŽ®  Games", UDim2.fromOffset(10,86), UDim2.new(1,-20,0,38), showHome)
addText(side, "THEME", 11, UDim2.fromOffset(14,143), UDim2.new(1,-28,0,22), "sub")
addButton(side, "â˜€  Light", UDim2.fromOffset(10,168), UDim2.new(0.5,-14,0,34), function() palette=LIGHT; refreshColors() end)
addButton(side, "â˜¾  Dark", UDim2.new(0.5,4,0,168), UDim2.new(0.5,-14,0,34), function() palette=DARK; refreshColors() end)
addText(side, "DEVICE", 11, UDim2.fromOffset(14,216), UDim2.new(1,-28,0,22), "sub")
addButton(side, "ðŸ’»", UDim2.fromOffset(10,242), UDim2.fromOffset(42,38), function() selectedDevice="ðŸ’»"; root.Size=UDim2.fromOffset(760,500); root.Position=UDim2.new(0.5,-380,0.5,-250) end)
addButton(side, "â–£", UDim2.fromOffset(58,242), UDim2.fromOffset(42,38), function() selectedDevice="â–£"; root.Size=UDim2.fromOffset(600,500); root.Position=UDim2.new(0.5,-300,0.5,-250) end)
addButton(side, "â–¯", UDim2.fromOffset(106,242), UDim2.fromOffset(42,38), function() selectedDevice="â–¯"; root.Size=UDim2.fromOffset(360,540); root.Position=UDim2.new(0.5,-180,0.5,-270) end)
addText(side, "Own-game UI prototype", 10, UDim2.fromOffset(12,side.AbsoluteSize.Y-34), UDim2.new(1,-24,0,24), "sub")

-- Optional hide/show hotkey: RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end)

showHome()
