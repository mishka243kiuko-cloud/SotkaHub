-- SotkaHub UI prototype for YOUR OWN Roblox Studio experience.
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Game-specific controls are demo UI; connect them to mechanics in your own game.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("SotkaHub")
if old then old:Destroy() end

local purple = Color3.fromRGB(160, 75, 255)
local dark = {bg=Color3.fromRGB(15,10,24), panel=Color3.fromRGB(27,18,42), card=Color3.fromRGB(39,26,58), text=Color3.fromRGB(250,245,255), sub=Color3.fromRGB(194,174,218)}
local light = {bg=Color3.fromRGB(246,240,255), panel=Color3.fromRGB(255,252,255), card=Color3.fromRGB(231,218,250), text=Color3.fromRGB(55,25,86), sub=Color3.fromRGB(112,82,145)}
local colors = dark
local highlights = {Door=false, Item=false}
local highlightObjects = {Door={}, Item={}}
local currentPage = "Games"

local gui = Instance.new("ScreenGui")
gui.Name = "SotkaHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, radius) make("UICorner", {CornerRadius=UDim.new(0,radius or 10)}, o) end
local function outline(o)
    make("UIStroke", {Color=purple, Thickness=1.2, Transparency=0.15}, o)
end
local function label(parent, text, size, pos, dim, color)
    return make("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=color or colors.text, Font=Enum.Font.Gotham, TextSize=size or 14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center, Position=pos, Size=dim}, parent)
end
local function button(parent, text, pos, dim, callback)
    local b=make("TextButton", {Text=text, TextColor3=colors.text, Font=Enum.Font.GothamMedium, TextSize=14, TextWrapped=true, BackgroundColor3=colors.card, BorderSizePixel=0, Position=pos, Size=dim, AutoButtonColor=true}, parent)
    corner(b,9); outline(b); b.MouseButton1Click:Connect(callback)
    return b
end

local root=make("Frame", {Name="Window", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.fromScale(.94,.84), BackgroundColor3=colors.bg, BorderSizePixel=0}, gui)
root.ClipsDescendants=true; corner(root,14); outline(root)
make("UISizeConstraint", {MinSize=Vector2.new(300,300), MaxSize=Vector2.new(1000,700)}, root)
local scale=make("UIScale", {Scale=1}, root)
local function resize()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    if v.X < 600 then scale.Scale=.82 else scale.Scale=1 end
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()

local header=make("Frame", {Size=UDim2.new(1,0,0,48), BackgroundColor3=colors.panel, BorderSizePixel=0}, root)
corner(header,12)
label(header,"♛  SotkaHub",20,UDim2.fromOffset(14,0),UDim2.new(1,-110,1,0),colors.text).Font=Enum.Font.GothamBold
local close=button(header,"×",UDim2.new(1,-42,0,6),UDim2.fromOffset(34,34),function() gui.Enabled=false end)
close.TextSize=25
local hide=button(header,"—",UDim2.new(1,-82,0,6),UDim2.fromOffset(34,34),function() root.Visible=false end)
hide.TextSize=20

local sidebar=make("Frame", {Position=UDim2.fromOffset(8,56), Size=UDim2.new(0,140,1,-64), BackgroundColor3=colors.panel, BorderSizePixel=0}, root)
corner(sidebar,10)
local content=make("ScrollingFrame", {Name="Page", Position=UDim2.fromOffset(156,56), Size=UDim2.new(1,-164,1,-64), BackgroundColor3=colors.panel, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=purple, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, root)
corner(content,10)
local layout=make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, content)
make("UIPadding", {PaddingTop=UDim.new(0,12), PaddingBottom=UDim.new(0,12), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)}, content)

local function refreshTheme()
    root.BackgroundColor3=colors.bg; header.BackgroundColor3=colors.panel; sidebar.BackgroundColor3=colors.panel; content.BackgroundColor3=colors.panel
    for _,o in ipairs(gui:GetDescendants()) do
        if o:IsA("TextLabel") or o:IsA("TextButton") then
            o.TextColor3=colors.text
            if o:IsA("TextButton") then o.BackgroundColor3=colors.card end
        elseif o:IsA("Frame") and o~=root and o~=header and o~=sidebar and o~=content then
            -- keep the visual grouping consistent with the selected theme
        end
    end
end
local function clearPage()
    for _,c in ipairs(content:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") and not c:IsA("UICorner") then c:Destroy() end end
end
local function addPageTitle(t, sub)
    local title=label(content,t,21,UDim2.new(),UDim2.new(1,0,0,34)); title.LayoutOrder=1; title.Font=Enum.Font.GothamBold
    if sub then local s=label(content,sub,12,UDim2.new(),UDim2.new(1,0,0,38),colors.sub); s.LayoutOrder=2 end
end
local function pageButton(t, cb)
    local b=button(content,t,UDim2.new(),UDim2.new(1,0,0,42),cb); b.LayoutOrder=#content:GetChildren()+1; return b
end
local games={"🚪  DOORS","🔪  Murder Mystery 2","🪵  Lumber Tycoon 2","❤️  Undertale","🐾  Pet Simulator 99","⚔️  Rivals"}
local function openGame(name)
    currentPage=name; clearPage(); addPageTitle(name,"Only this game's menu is open. Back returns to game selection.")
    pageButton("‹  Back to games",function() currentPage="Games"; clearPage(); addPageTitle("Choose a game","Select a game to open its own menu."); for _,g in ipairs(games) do pageButton(g,function() openGame(g) end) end end)
    if name:find("DOORS",1,true) then
        pageButton("Highlight doors: OFF □",function() highlights.Door=not highlights.Door; for _,h in ipairs(highlightObjects.Door) do if h.Parent then h:Destroy() end end; table.clear(highlightObjects.Door); if highlights.Door then for _,obj in ipairs(CollectionService:GetTagged("Door")) do if obj:IsDescendantOf(workspace) then local h=Instance.new("Highlight"); h.Adornee=obj; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.FillColor=Color3.fromRGB(95,170,255); h.OutlineColor=h.FillColor; h.Parent=obj; table.insert(highlightObjects.Door,h) end end end; end)
        pageButton("Highlight items: OFF □",function() highlights.Item=not highlights.Item; for _,h in ipairs(highlightObjects.Item) do if h.Parent then h:Destroy() end end; table.clear(highlightObjects.Item); if highlights.Item then for _,obj in ipairs(CollectionService:GetTagged("Item")) do if obj:IsDescendantOf(workspace) then local h=Instance.new("Highlight"); h.Adornee=obj; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.FillColor=Color3.fromRGB(255,210,75); h.OutlineColor=h.FillColor; h.Parent=obj; table.insert(highlightObjects.Item,h) end end end end)
        local note=label(content,"For your own place: tag your door models 'Door' and item models 'Item' with CollectionService.",12,UDim2.new(),UDim2.new(1,0,0,54),colors.sub); note.LayoutOrder=20
    elseif name:find("Murder Mystery 2",1,true) then
        label(content,"Own-game weapon skin preview",13,UDim2.new(),UDim2.new(1,0,0,32),colors.sub).LayoutOrder=3
        for _,skin in ipairs({"Classic","Purple Neon","Frost","Golden"}) do pageButton("🔪  "..skin,function() pageButton("Selected preview: "..skin.." (demo)",function() end) end) end
    elseif name:find("Lumber Tycoon 2",1,true) then
        for _,action in ipairs({"Select tree","Select log","Chop saw guide","Sawmill guide","Sell wood guide","Build mode guide"}) do pageButton(action,function() pageButton(action..": connect this to your own game's mechanics.",function() end) end) end
    elseif name:find("Undertale",1,true) then
        for _,action in ipairs({"Battle","Inventory","Items","Stats","Settings"}) do pageButton(action,function() pageButton(action.." selected (demo)",function() end) end) end
    else
        pageButton("Collect / interact guide",function() pageButton("Demo control selected",function() end) end)
        pageButton("Settings",function() pageButton("Demo settings selected",function() end) end)
    end
end

label(sidebar,"MENU",11,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),colors.sub)
local navHome=button(sidebar,"⌂  Home",UDim2.fromOffset(8,36),UDim2.new(1,-16,0,36),function() currentPage="Home"; clearPage(); addPageTitle("Home","Welcome to SotkaHub."); pageButton("Choose a game",function() currentPage="Games"; clearPage(); addPageTitle("Choose a game","Select a game to open its own menu."); for _,g in ipairs(games) do pageButton(g,function() openGame(g) end) end end) end)
local navGames=button(sidebar,"🎮  Games",UDim2.fromOffset(8,78),UDim2.new(1,-16,0,36),function() currentPage="Games"; clearPage(); addPageTitle("Choose a game","Select a game to open its own menu."); for _,g in ipairs(games) do pageButton(g,function() openGame(g) end) end end)
label(sidebar,"THEME",11,UDim2.fromOffset(12,130),UDim2.new(1,-24,0,20),colors.sub)
button(sidebar,"☀",UDim2.fromOffset(8,154),UDim2.new(.5,-12,0,34),function() colors=light; refreshTheme() end)
button(sidebar,"☾",UDim2.new(.5,4,0,154),UDim2.new(.5,-12,0,34),function() colors=dark; refreshTheme() end)
label(sidebar,"DEVICE",11,UDim2.fromOffset(12,204),UDim2.new(1,-24,0,20),colors.sub)
button(sidebar,"💻",UDim2.fromOffset(8,228),UDim2.fromOffset(36,34),function() root.Size=UDim2.fromScale(.94,.84); resize() end)
button(sidebar,"▣",UDim2.fromOffset(49,228),UDim2.fromOffset(36,34),function() root.Size=UDim2.fromScale(.82,.86); resize() end)
button(sidebar,"▯",UDim2.fromOffset(90,228),UDim2.fromOffset(36,34),function() root.Size=UDim2.fromScale(.7,.88); resize() end)

currentPage="Games"; addPageTitle("Choose a game","Select a game to open its own menu.")
for _,g in ipairs(games) do pageButton(g,function() openGame(g) end) end
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then
        if root.Visible then root.Visible=false else gui.Enabled=true; root.Visible=true end
    end
end)
-- Re-open button when the window is collapsed with the minus button.
local reopen=make("TextButton",{Name="ReopenSotkaHub",Text="S",TextColor3=Color3.new(1,1,1),TextSize=18,Font=Enum.Font.GothamBold,BackgroundColor3=purple,Size=UDim2.fromOffset(42,42),Position=UDim2.new(0,12,0.5,-21),Visible=false},gui)
corner(reopen,12); reopen.MouseButton1Click:Connect(function() root.Visible=true; reopen.Visible=false end)
hide.MouseButton1Click:Connect(function() root.Visible=false; reopen.Visible=true end)
