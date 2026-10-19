-- Sotka Hub Purple UI demo for your own Roblox Studio project
-- Install as LocalScript in StarterPlayer > StarterPlayerScripts
-- Demo key: SOTKA5. Game buttons are placeholders, not cheats.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SotkaHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local purple = Color3.fromRGB(130, 75, 245)
local bg = Color3.fromRGB(15, 12, 23)
local panel = Color3.fromRGB(29, 24, 42)
local white = Color3.fromRGB(245, 240, 255)
local muted = Color3.fromRGB(175, 164, 195)

local function make(class, props, parent)
    local x = Instance.new(class)
    for k,v in pairs(props) do x[k] = v end
    x.Parent = parent
    return x
end
local function round(x)
    make("UICorner", {CornerRadius=UDim.new(0,10)}, x)
end
local function text(parent, value, size, pos, font, color)
    return make("TextLabel", {BackgroundTransparency=1, Text=value, Size=size, Position=pos,
        Font=font or Enum.Font.Gotham, TextColor3=color or white, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, parent)
end
local function btn(parent, value, size, pos, color)
    local b=make("TextButton",{Text=value,Size=size,Position=pos,BackgroundColor3=color or panel,
        TextColor3=white,Font=Enum.Font.GothamSemibold,TextSize=13},parent)
    round(b)
    return b
end

local keyFrame=make("Frame",{Size=UDim2.fromOffset(320,190),Position=UDim2.new(.5,-160,.5,-95),
    BackgroundColor3=bg,BorderSizePixel=0},gui)
round(keyFrame)
make("UIStroke",{Color=purple,Thickness=2},keyFrame)
text(keyFrame,"✦ SOTKA HUB",UDim2.new(1,-28,0,35),UDim2.fromOffset(14,10),Enum.Font.GothamBold).TextSize=23
text(keyFrame,"PURPLE EDITION  •  MULTI-GAME UI",UDim2.new(1,-28,0,20),UDim2.fromOffset(14,44),nil,muted).TextSize=10
local keyBox=make("TextBox",{Size=UDim2.new(1,-28,0,38),Position=UDim2.fromOffset(14,72),
    BackgroundColor3=panel,TextColor3=white,PlaceholderText="Enter key",Text="",ClearTextOnFocus=false,
    Font=Enum.Font.Gotham,TextSize=14},keyFrame)
round(keyBox)
local status=text(keyFrame,"Demo key: SOTKA5",UDim2.new(1,-28,0,20),UDim2.fromOffset(14,113),nil,muted)
status.TextSize=11
local activate=btn(keyFrame,"UNLOCK HUB",UDim2.new(1,-28,0,36),UDim2.fromOffset(14,140),purple)

activate.Activated:Connect(function()
    if keyBox.Text ~= "SOTKA5" then status.Text="Wrong key — try SOTKA5"; return end
    keyFrame:Destroy()
    local main=make("Frame",{Size=UDim2.fromOffset(540,370),Position=UDim2.new(.5,-270,.5,-185),
        BackgroundColor3=bg,BorderSizePixel=0},gui)
    round(main); make("UIStroke",{Color=purple,Thickness=2},main)
    local header=make("Frame",{Size=UDim2.new(1,0,0,55),BackgroundColor3=panel,BorderSizePixel=0},main)
    round(header)
    text(header,"✦ SOTKA HUB",UDim2.new(1,-60,0,30),UDim2.fromOffset(16,7),Enum.Font.GothamBold).TextSize=22
    text(header,"PURPLE EDITION • v1.0",UDim2.new(1,-60,0,15),UDim2.fromOffset(18,34),nil,muted).TextSize=9
    local close=btn(header,"×",UDim2.fromOffset(32,32),UDim2.new(1,-42,0,10),purple)
    close.TextSize=22; close.Activated:Connect(function() gui:Destroy() end)
    local nav=make("Frame",{Size=UDim2.new(0,150,1,-68),Position=UDim2.fromOffset(10,62),
        BackgroundColor3=panel,BorderSizePixel=0},main); round(nav)
    local body=make("Frame",{Size=UDim2.new(1,-172,1,-68),Position=UDim2.fromOffset(162,62),
        BackgroundColor3=panel,BorderSizePixel=0},main); round(body)
    local games={
        {"HOME",{"About Sotka Hub","Controls & help"}},
        {"MURDER MYSTERY 2",{"Round status display","Coin counter display","Practice mode settings"}},
        {"RIVALS",{"Training settings","Sensitivity display","Practice panel"}},
        {"BUILD A BOAT",{"Build checklist","Test mode panel","Reset test layout"}},
        {"SINKING BOAT",{"Boat status display","Test controls","Reset test session"}},
        {"OTHER GAMES",{"UI scale settings","Show help","About"}},
    }
    local current
    local function page(title,items)
        if current then current:Destroy() end
        current=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},body)
        text(current,title,UDim2.new(1,-24,0,32),UDim2.fromOffset(12,10),Enum.Font.GothamBold).TextSize=18
        text(current,"Own-game UI demo • buttons are placeholders",UDim2.new(1,-24,0,30),UDim2.fromOffset(12,42),nil,muted).TextSize=10
        local y=82
        for _,item in ipairs(items) do
            local b=btn(current,"   "..item,UDim2.new(1,-24,0,36),UDim2.fromOffset(12,y))
            b.TextXAlignment=Enum.TextXAlignment.Left
            b.Activated:Connect(function()
                local note=current:FindFirstChild("Notice")
                if not note then note=text(current,"",UDim2.new(1,-24,0,42),UDim2.new(0,12,1,-48),nil,Color3.fromRGB(100,230,160)); note.Name="Notice"; note.TextSize=11 end
                note.Text=item.." is a placeholder. Add the feature in your own game."
            end)
            y=y+43
        end
    end
    local y=10
    for _,entry in ipairs(games) do
        local b=btn(nav,entry[1],UDim2.new(1,-14,0,38),UDim2.fromOffset(7,y))
        b.TextSize=10
        b.Activated:Connect(function() page(entry[1],entry[2]) end)
        y=y+43
    end
    page(games[1][1],games[1][2])
end)
