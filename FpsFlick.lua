--// LuXxS | Roblox | Delta
--// Not tested in Delta. Report errors with the message text.

local Env = (getgenv and getgenv()) or _G
if Env.LuXxS_Unload then pcall(Env.LuXxS_Unload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local FILE = "LuXxS_config.json"

-- ================= HELPERS =================
local function cam() return Workspace.CurrentCamera end

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[LuXxS] " .. tostring(err)) end
    return ok
end

local function HC(h) return Color3.fromHSV(h, 1, 1) end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return nil end
    return c, hum, hrp
end

local function alive(p)
    local c = p and p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end

local function isEnemy(p)
    if p == LP then return false end
    if LP.Team == nil or p.Team == nil then return true end
    return p.Team ~= LP.Team
end

-- ================= NAMES + SETTINGS =================
local NAMES = {"LuXxS", "Zenin", "Saturn", "Nova", "Void"}

local S = {
    nameIdx = 1,
    menuHue = 0, menuScale = 1,
    aimEnabled = false, aimVisCheck = true, aimHoldRMB = true, aimBone = "Head",
    aimSmooth = 8, aimFOV = 120, aimShowFOV = true, aimFOVHue = 0,
    espEnabled = false, espBox2D = true, espBox3D = false, espName = true, espHue = 0.35, espMaxDist = 1500,
    chamsEnabled = false, chamsThrough = true, chamsOutline = true, chamsHue = 0.75, chamsTrans = 0.4,
    trailEnabled = false, trailHue = 0.55, trailTrans = 0.3,
    hatEnabled = false, hatHue = 0.12, hatTrans = 0.2,
    flyEnabled = false, flySpeed = 60, noclipEnabled = false,
    wsEnabled = false, wsValue = 16, jpEnabled = false, jpValue = 50, infJump = false,
    spinEnabled = false, spinSpeed = 200,
    tpEnabled = false, tpDist = 12,
    aaEnabled = false, aaAngle = 90, aaRate = 12,
}

-- ranges used to clamp values loaded from config
local RANGES = {
    nameIdx = {1, #NAMES}, menuHue = {0, 1}, menuScale = {0.6, 1.5},
    aimSmooth = {1, 30}, aimFOV = {10, 600}, aimFOVHue = {0, 1},
    espMaxDist = {100, 3000}, espHue = {0, 1},
    chamsTrans = {0, 1}, chamsHue = {0, 1},
    trailTrans = {0, 1}, trailHue = {0, 1},
    hatTrans = {0, 1}, hatHue = {0, 1},
    flySpeed = {10, 300}, wsValue = {16, 250}, jpValue = {50, 300},
    spinSpeed = {0, 1000}, tpDist = {5, 100},
    aaAngle = {0, 180}, aaRate = {1, 40},
}

local REF, Conns = {}, {}
local function track(c) table.insert(Conns, c) return c end
local function refreshAll() for _, f in ipairs(REF) do safe(f) end end
local function Accent() return HC(S.menuHue) end

-- ================= UI BUILDERS =================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 6)}, o) end
local function stroke(o, col, th) return new("UIStroke", {Color = col or Color3.fromRGB(40,40,46), Thickness = th or 1}, o) end
local function label(parent, text, rightPad)
    return new("TextLabel", {Size = UDim2.new(1, -(rightPad or 60), 1, 0), BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(215,215,222),
        TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

local gui = new("ScreenGui", {Name = "LuXxS", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999},
    (gethui and gethui()) or CoreGui)

local BASE_W, BASE_H = 560, 400
local main = new("Frame", {Size = UDim2.fromOffset(BASE_W, BASE_H), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(14,14,17), BorderSizePixel = 0,
    ClipsDescendants = true}, gui)
corner(main, 12); stroke(main, Color3.fromRGB(35,35,42))
local uiScale = new("UIScale", {}, main)

local header = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(18,18,22), BorderSizePixel = 0}, main)
local title = new("TextLabel", {Size = UDim2.new(0, 200, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
    Text = NAMES[S.nameIdx], Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Accent(),
    TextXAlignment = Enum.TextXAlignment.Left}, header)
new("TextLabel", {Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
    Text = "roblox | delta", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(120,120,130),
    TextXAlignment = Enum.TextXAlignment.Right}, header)

table.insert(REF, function()
    title.TextColor3 = Accent()
    title.Text = NAMES[S.nameIdx]
    uiScale.Scale = S.menuScale
    main.Size = UDim2.fromOffset(BASE_W, BASE_H)
end)

-- drag window by header
do
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

local TAB_NAMES = {"Combat", "Visuals", "Movement", "Misc", "Config"}
local tabBar = new("Frame", {Size = UDim2.new(1, 0, 0, 46), Position = UDim2.new(0, 0, 1, -46),
    BackgroundColor3 = Color3.fromRGB(18,18,22), BorderSizePixel = 0}, main)
local content = new("Frame", {Size = UDim2.new(1, 0, 1, -86), Position = UDim2.fromOffset(0, 40), BackgroundTransparency = 1}, main)

local pages, tabBtns, currentTab = {}, {}, "Combat"
local function selectTab(name)
    currentTab = name
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.TextColor3 = (n == name) and Accent() or Color3.fromRGB(150,150,160) end
end
table.insert(REF, function() selectTab(currentTab) end)

local function makePage(name)
    local sf = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(60,60,70), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, content)
    local holder = new("Frame", {Size = UDim2.new(1, -16, 0, 0), Position = UDim2.fromOffset(8, 8),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, sf)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder}, holder)
    new("UIPadding", {PaddingBottom = UDim.new(0, 8)}, holder)
    local cols = {}
    for i = 1, 2 do
        local c = new("Frame", {Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = i}, holder)
        new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, c)
        cols[i] = c
    end
    pages[name] = sf
    return cols
end

local cols = {}
for i, name in ipairs(TAB_NAMES) do
    cols[name] = makePage(name)
    local b = new("TextButton", {Size = UDim2.new(1/#TAB_NAMES, 0, 1, 0), Position = UDim2.new((i-1)/#TAB_NAMES, 0, 0, 0),
        BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextColor3 = Color3.fromRGB(150,150,160), AutoButtonColor = false}, tabBar)
    tabBtns[name] = b
    b.MouseButton1Click:Connect(function() selectTab(name) end)
end

local function section(col, text)
    local card = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(22,22,27), BorderSizePixel = 0}, col)
    corner(card, 8); stroke(card, Color3.fromRGB(34,34,40))
    new("UIPadding", {PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}, card)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, card)
    new("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left}, card)
    return card
end

local function toggle(parent, text, flag)
    local r = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1}, parent)
    label(r, text)
    local box = new("TextButton", {Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -34, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(40,40,46), Text = "", AutoButtonColor = false, BorderSizePixel = 0}, r)
    corner(box, 9)
    local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0}, box)
    corner(knob, 7)
    local function paint()
        local on = S[flag]
        TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = on and Accent() or Color3.fromRGB(40,40,46)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = on and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}):Play()
    end
    box.MouseButton1Click:Connect(function() S[flag] = not S[flag]; refreshAll() end)
    table.insert(REF, paint)
    paint()
end

local function slider(parent, text, flag, mn, mx, step, suffix, isHue, fmt)
    local r = new("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1}, parent)
    label(r, text, 70).Size = UDim2.new(1, -70, 0, 16)
    local val = new("TextLabel", {Size = UDim2.new(0, 70, 0, 16), Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = Color3.fromRGB(160,160,170), TextXAlignment = Enum.TextXAlignment.Right}, r)
    local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Color3.fromRGB(40,40,46), BorderSizePixel = 0}, r)
    corner(bar, 3)
    local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0}, bar)
    corner(fill, 3)
    local hit = new("TextButton", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, r)

    local function paint()
        local v = S[flag]
        fill.Size = UDim2.new((v - mn) / (mx - mn), 0, 1, 0)
        fill.BackgroundColor3 = isHue and HC(v) or Accent()
        if fmt then val.Text = fmt(v)
        elseif isHue then val.Text = math.floor(v * 100 + 0.5) .. "%"
        elseif step < 1 then val.Text = string.format("%.2f", v) .. (suffix or "")
        else val.Text = math.floor(v + 0.5) .. (suffix or "") end
    end
    local function setFromX(x)
        local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        S[flag] = math.clamp(math.floor((mn + (mx - mn) * p) / step + 0.5) * step, mn, mx)
        refreshAll()
    end
    local dragging = false
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(i.Position.X)
        end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    table.insert(REF, paint)
    paint()
end

local function dropdown(parent, text, flag, opts)
    local r = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1}, parent)
    label(r, text, 130)
    local btn = new("TextButton", {Size = UDim2.fromOffset(110, 20), Position = UDim2.new(1, -110, 0, 1),
        BackgroundColor3 = Color3.fromRGB(30,30,36), Text = S[flag], Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, BorderSizePixel = 0}, r)
    corner(btn, 5)
    table.insert(REF, function() btn.Text = S[flag] end)
    btn.MouseButton1Click:Connect(function()
        local idx = table.find(opts, S[flag]) or 1
        S[flag] = opts[idx % #opts + 1]
        refreshAll()
    end)
end

local function button(parent, text, cb)
    local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.fromRGB(32,32,38),
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.new(1,1,1),
        AutoButtonColor = false, BorderSizePixel = 0}, parent)
    corner(b, 6)
    b.MouseButton1Click:Connect(function() safe(cb) end)
end

local function note(parent, text)
    new("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(130,130,140),
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

-- ================= PAGES =================
local L, R = cols.Combat[1], cols.Combat[2]
local c1 = section(L, "Aimbot")
toggle(c1, "Aimbot", "aimEnabled")
toggle(c1, "Visible Check", "aimVisCheck")
toggle(c1, "Hold Right Click", "aimHoldRMB")
dropdown(c1, "Bone", "aimBone", {"Head", "UpperTorso", "HumanoidRootPart"})
slider(c1, "Smoothness", "aimSmooth", 1, 30, 1, "")
slider(c1, "FOV", "aimFOV", 10, 600, 1, "px")
local c2 = section(R, "FOV Circle")
toggle(c2, "Show FOV", "aimShowFOV")
slider(c2, "FOV Color", "aimFOVHue", 0, 1, 0.01, nil, true)

L, R = cols.Visuals[1], cols.Visuals[2]
c1 = section(L, "ESP")
toggle(c1, "ESP", "espEnabled")
toggle(c1, "2D Box", "espBox2D")
toggle(c1, "3D Box", "espBox3D")
toggle(c1, "Names", "espName")
slider(c1, "Max Distance", "espMaxDist", 100, 3000, 50, " st")
slider(c1, "ESP Color", "espHue", 0, 1, 0.01, nil, true)
c1 = section(L, "Chinese Hat")
toggle(c1, "Hat", "hatEnabled")
slider(c1, "Transparency", "hatTrans", 0, 1, 0.05, "")
slider(c1, "Hat Color", "hatHue", 0, 1, 0.01, nil, true)
c2 = section(R, "Chams")
toggle(c2, "Chams", "chamsEnabled")
toggle(c2, "Through Walls", "chamsThrough")
toggle(c2, "Outline", "chamsOutline")
slider(c2, "Fill Transparency", "chamsTrans", 0, 1, 0.05, "")
slider(c2, "Chams Color", "chamsHue", 0, 1, 0.01, nil, true)
c2 = section(R, "Trail")
toggle(c2, "Trail", "trailEnabled")
slider(c2, "Transparency", "trailTrans", 0, 1, 0.05, "")
slider(c2, "Trail Color", "trailHue", 0, 1, 0.01, nil, true)

L, R = cols.Movement[1], cols.Movement[2]
c1 = section(L, "Fly / Noclip")
toggle(c1, "Fly", "flyEnabled")
slider(c1, "Fly Speed", "flySpeed", 10, 300, 1, "")
toggle(c1, "Noclip", "noclipEnabled")
c2 = section(R, "Speed")
toggle(c2, "WalkSpeed", "wsEnabled")
slider(c2, "WalkSpeed Value", "wsValue", 16, 250, 1, "")
toggle(c2, "JumpPower", "jpEnabled")
slider(c2, "JumpPower Value", "jpValue", 50, 300, 1, "")
toggle(c2, "Infinite Jump", "infJump")

L, R = cols.Misc[1], cols.Misc[2]
c1 = section(L, "Anti Aim")
toggle(c1, "Anti Aim", "aaEnabled")
slider(c1, "Angle", "aaAngle", 0, 180, 1, "°")
slider(c1, "Jitter Rate", "aaRate", 1, 40, 1, "/s")
c1 = section(L, "Spin")
toggle(c1, "Spin", "spinEnabled")
slider(c1, "Spin Speed", "spinSpeed", 0, 1000, 10, "°/s")
c2 = section(R, "Third Person")
toggle(c2, "Third Person", "tpEnabled")
slider(c2, "Distance", "tpDist", 5, 100, 1, " st")
c2 = section(R, "Menu")
slider(c2, "Cheat Name", "nameIdx", 1, #NAMES, 1, nil, false, function(v) return NAMES[v] end)
slider(c2, "Menu Color", "menuHue", 0, 1, 0.01, nil, true)
slider(c2, "Menu Scale", "menuScale", 0.6, 1.5, 0.05, "x")
c2 = section(R, "Bypass")
note(c2, "Client-side only. No remotes fired, property writes only on change. Server-side checks in a game can still flag speed, fly or teleport.")

L, R = cols.Config[1], cols.Config[2]
c1 = section(L, "Config")

local function clampLoaded(k, v)
    local r = RANGES[k]
    if r then return math.clamp(v, r[1], r[2]) end
    return v
end

local function saveCfg()
    if not writefile then warn("[LuXxS] writefile not available") return end
    writefile(FILE, HttpService:JSONEncode(S))
end

local function loadCfg()
    if not (readfile and isfile and isfile(FILE)) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(FILE)) end)
    if not (ok and type(data) == "table") then return end
    for k, v in pairs(data) do
        if S[k] ~= nil and type(S[k]) == type(v) then
            if type(v) == "number" then v = clampLoaded(k, v) end
            S[k] = v
        end
    end
    refreshAll()
end

button(c1, "Save Config", saveCfg)
button(c1, "Load Config", loadCfg)
c2 = section(R, "Info")
note(c2, "Toggle menu: RightShift or click the Saturn icon. Drag the header to move. Config file: " .. FILE)

-- ================= ICON + OPEN/CLOSE ANIMATION =================
local icon = new("TextButton", {Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(20, 20),
    BackgroundColor3 = Color3.fromRGB(14,14,17), Text = "", AutoButtonColor = false, Visible = false, BorderSizePixel = 0}, gui)
corner(icon, 14); stroke(icon, Color3.fromRGB(40,40,46))
new("UIAspectRatioConstraint", {AspectRatio = 1}, icon)
local planet = new("Frame", {Size = UDim2.fromOffset(26, 26), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Accent(), BorderSizePixel = 0}, icon)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, planet)
local ring = new("Frame", {Size = UDim2.fromOffset(48, 14), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Rotation = -20}, icon)
new("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
local ringStroke = stroke(ring, Accent(), 2)
table.insert(REF, function() planet.BackgroundColor3 = Accent(); ringStroke.Color = Accent() end)

local open = true
local function setOpen(v)
    open = v
    if v then
        icon.Visible = false
        main.Visible = true
        main.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(BASE_W, BASE_H)}):Play()
    else
        local tw = TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.fromOffset(0, 0)})
        tw:Play()
        tw.Completed:Connect(function()
            if open then return end
            main.Visible = false
            icon.Visible = true
            icon.Size = UDim2.fromOffset(0, 0)
            TweenService:Create(icon, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.fromOffset(56, 56)}):Play()
        end)
    end
end
icon.MouseButton1Click:Connect(function() setOpen(true) end)
track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then setOpen(not open) end
end))

local wm = new("TextLabel", {Size = UDim2.fromOffset(260, 18), Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1, Text = NAMES[S.nameIdx] .. " | Roblox", Font = Enum.Font.GothamMedium, TextSize = 13,
    TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, TextStrokeTransparency = 0.5}, gui)

-- ================= FOV CIRCLE + ESP (Drawing) =================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1; fovCircle.NumSides = 64; fovCircle.Filled = false

local SIGNS = {{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}
local EDGES = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
local espObjs = {}

local function makeEsp(p)
    local o = {sq = Drawing.new("Square"), name = Drawing.new("Text"), lines = {}}
    o.sq.Thickness = 1.5; o.sq.Filled = false
    o.name.Center = true; o.name.Outline = true; o.name.Size = 14
    for _ = 1, 12 do
        local l = Drawing.new("Line"); l.Thickness = 1.2; table.insert(o.lines, l)
    end
    espObjs[p] = o
    return o
end
local function hideEsp(o)
    o.sq.Visible = false; o.name.Visible = false
    for _, l in ipairs(o.lines) do l.Visible = false end
end
local function killEsp(p)
    local o = espObjs[p]
    if not o then return end
    o.sq:Remove(); o.name:Remove()
    for _, l in ipairs(o.lines) do l:Remove() end
    espObjs[p] = nil
end

local function updateEsp(p, o)
    local c = p.Character
    if not (S.espEnabled and alive(p) and c and cam()) then hideEsp(o) return end
    local hrp = c.HumanoidRootPart
    if (hrp.Position - cam().CFrame.Position).Magnitude > S.espMaxDist then hideEsp(o) return end

    local bcf, size = c:GetBoundingBox()
    local col = HC(S.espHue)
    local pts = {}
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyOn = false
    for i, s in ipairs(SIGNS) do
        local w = bcf * CFrame.new(s[1] * size.X / 2, s[2] * size.Y / 2, s[3] * size.Z / 2)
        local sp, on = cam():WorldToViewportPoint(w.Position)
        pts[i] = Vector2.new(sp.X, sp.Y)
        if on then anyOn = true end
        minX = math.min(minX, sp.X); maxX = math.max(maxX, sp.X)
        minY = math.min(minY, sp.Y); maxY = math.max(maxY, sp.Y)
    end
    if not anyOn then hideEsp(o) return end

    o.sq.Visible = S.espBox2D
    o.sq.Color = col
    o.sq.Position = Vector2.new(minX, minY)
    o.sq.Size = Vector2.new(maxX - minX, maxY - minY)

    for i, e in ipairs(EDGES) do
        local l = o.lines[i]
        l.Visible = S.espBox3D
        l.Color = col
        l.From = pts[e[1]]; l.To = pts[e[2]]
    end

    o.name.Visible = S.espName
    o.name.Text = p.Name
    o.name.Color = col
    o.name.Position = Vector2.new((minX + maxX) / 2, minY - 16)
end

-- ================= CHAMS =================
local chamsObjs = {}
local function updateChams(p)
    local c = p.Character
    local h = chamsObjs[p]
    if not (S.chamsEnabled and alive(p) and c) then
        if h then h:Destroy(); chamsObjs[p] = nil end
        return
    end
    if not h or h.Parent ~= c then
        if h then h:Destroy() end
        h = new("Highlight", {Adornee = c}, c)
        chamsObjs[p] = h
    end
    h.DepthMode = S.chamsThrough and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    h.FillColor = HC(S.chamsHue)
    h.FillTransparency = S.chamsTrans
    h.OutlineColor = HC(S.chamsHue)
    h.OutlineTransparency = S.chamsOutline and 0 or 1
end

-- ================= TRAIL + HAT (local) =================
local trail, hat
local function setupTrail()
    local _, _, hrp = getChar()
    if not hrp then return end
    if trail and trail.Parent == hrp then return end
    if trail then trail:Destroy() end
    local a0 = new("Attachment", {Position = Vector3.new(0, 1.2, 0)}, hrp)
    local a1 = new("Attachment", {Position = Vector3.new(0, -1.2, 0)}, hrp)
    trail = new("Trail", {Attachment0 = a0, Attachment1 = a1, Lifetime = 0.6, FaceCamera = true, Enabled = false}, hrp)
end

local function updateHat()
    local _, _, _ = getChar()
    local c = LP.Character
    local head = c and c:FindFirstChild("Head")
    if not (S.hatEnabled and head) then
        if hat then hat:Destroy(); hat = nil end
        return
    end
    if not hat or hat.Adornee ~= head then
        if hat then hat:Destroy() end
        -- ConeHandleAdornment points along local -Y after this rotation, so the tip sits above the head.
        -- If it renders upside down on your executor, change Angles(math.rad(180)) to Angles(0,0,0).
        hat = new("ConeHandleAdornment", {Adornee = head, Height = 0.9, Radius = 0.7,
            CFrame = CFrame.new(0, 1.2, 0) * CFrame.Angles(math.rad(180), 0, 0), ZIndex = 1, AlwaysOnTop = false}, head)
    end
    hat.Color3 = HC(S.hatHue)
    hat.Transparency = S.hatTrans
end

-- ================= AIMBOT =================
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

local function visibleTo(part)
    local c = cam()
    if not c then return false end
    rp.FilterDescendantsInstances = LP.Character and {LP.Character} or {}
    local origin = c.CFrame.Position
    local res = Workspace:Raycast(origin, part.Position - origin, rp)
    return res == nil or res.Instance:IsDescendantOf(part.Parent)
end

local function getTarget()
    local c = cam()
    if not c then return nil end
    local best, bestD = nil, S.aimFOV
    local vs = c.ViewportSize
    local center = Vector2.new(vs.X / 2, vs.Y / 2)
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and alive(p) then
            local ch = p.Character
            local part = ch:FindFirstChild(S.aimBone) or ch:FindFirstChild("Head")
            if part then
                local sp, on = c:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestD and (not S.aimVisCheck or visibleTo(part)) then
                        best, bestD = part, d
                    end
                end
            end
        end
    end
    return best
end

RunService:BindToRenderStep("LuXxS_Aim", Enum.RenderPriority.Camera.Value + 1, function()
    if not S.aimEnabled then return end
    if S.aimHoldRMB and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local c = cam()
    if not c then return end
    local t = getTarget()
    if t then
        c.CFrame = c.CFrame:Lerp(CFrame.lookAt(c.CFrame.Position, t.Position), math.clamp(1 / S.aimSmooth, 0.02, 1))
    end
end)

-- ================= MOVEMENT STATE =================
local tpOn, wsOn, jpOn, flyOn, ncOn = false, false, false, false, false
local aaT, aaFlip = 0, false
local ncParts = {}

local function setNoclip(c, on)
    if on then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                ncParts[p] = true
                p.CanCollide = false
            end
        end
    else
        for p in pairs(ncParts) do
            if p.Parent then p.CanCollide = true end
        end
        ncParts = {}
    end
end

-- ================= MAIN LOOPS =================
track(RunService.RenderStepped:Connect(function(dt)
    local c = cam()
    if c then
        local vs = c.ViewportSize
        fovCircle.Visible = S.aimEnabled and S.aimShowFOV
        fovCircle.Radius = S.aimFOV
        fovCircle.Position = Vector2.new(vs.X / 2, vs.Y / 2)
        fovCircle.Color = HC(S.aimFOVHue)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then safe(updateEsp, p, espObjs[p] or makeEsp(p)) end
    end
    ring.Rotation = -20 + math.sin(os.clock() * 2) * 10
    if dt > 0 then wm.Text = string.format(NAMES[S.nameIdx] .. " | Roblox | %d fps", math.floor(1 / dt)) end
end))

track(RunService.Heartbeat:Connect(function(dt)
    -- third person: only lock zoom while enabled, restore once
    if S.tpEnabled then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = S.tpDist
        LP.CameraMinZoomDistance = S.tpDist
        tpOn = true
    elseif tpOn then
        LP.CameraMinZoomDistance = 0.5; LP.CameraMaxZoomDistance = 128; tpOn = false
    end

    local c, hum, hrp = getChar()
    if c then
        -- walkspeed (write only on change, restore once)
        if S.wsEnabled then
            if hum.WalkSpeed ~= S.wsValue then hum.WalkSpeed = S.wsValue end
            wsOn = true
        elseif wsOn then hum.WalkSpeed = 16; wsOn = false end

        -- jumppower
        if S.jpEnabled then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if hum.JumpPower ~= S.jpValue then hum.JumpPower = S.jpValue end
            jpOn = true
        elseif jpOn then hum.JumpPower = 50; jpOn = false end

        -- fly
        if S.flyEnabled and cam() then
            local cf = cam().CFrame
            local d = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then d += cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d += cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis end
            hum.PlatformStand = true
            hrp.AssemblyLinearVelocity = d.Magnitude > 0 and d.Unit * S.flySpeed or Vector3.zero
            flyOn = true
        elseif flyOn then
            hum.PlatformStand = false; flyOn = false
        end

        -- noclip: one pass when turned on, restore when turned off
        if S.noclipEnabled then
            setNoclip(c, true)
            ncOn = true
        elseif ncOn then
            setNoclip(c, false)
            ncOn = false
        end

        -- spin wins over anti aim
        if S.spinEnabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed * dt), 0)
        elseif S.aaEnabled and cam() then
            aaT += dt
            if aaT >= 1 / S.aaRate then aaT = 0; aaFlip = not aaFlip end
            local yaw = select(2, cam().CFrame:ToEulerAnglesYXZ())
            local off = math.rad(aaFlip and S.aaAngle or -S.aaAngle)
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw + off, 0)
        end
    end

    -- trail / hat / chams
    if S.trailEnabled then safe(setupTrail) end
    if trail then
        trail.Enabled = S.trailEnabled
        trail.Color = ColorSequence.new(HC(S.trailHue))
        trail.Transparency = NumberSequence.new(S.trailTrans)
    end
    safe(updateHat)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then safe(updateChams, p) end
    end
end))

track(UIS.JumpRequest:Connect(function()
    if S.infJump then
        local _, hum = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

track(Players.PlayerRemoving:Connect(function(p)
    killEsp(p)
    if chamsObjs[p] then chamsObjs[p]:Destroy(); chamsObjs[p] = nil end
end))

-- ================= UNLOAD =================
Env.LuXxS_Unload = function()
    RunService:UnbindFromRenderStep("LuXxS_Aim")
    for _, c in ipairs(Conns) do c:Disconnect() end
    for p in pairs(espObjs) do killEsp(p) end
    for _, h in pairs(chamsObjs) do h:Destroy() end
    if hat then hat:Destroy() end
    if trail then trail:Destroy() end
    fovCircle:Remove()
    LP.CameraMinZoomDistance = 0.5; LP.CameraMaxZoomDistance = 128
    local c = LP.Character
    if c then setNoclip(c, false) end
    gui:Destroy()
    Env.LuXxS_Unload = nil
end

-- ================= INIT =================
selectTab("Combat")
setOpen(true)
