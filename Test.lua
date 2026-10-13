-- file: main.lua, target: Roblox MM2, executor: Delta
-- Lokeii MM2 — floating menu + role ESP (murderer/sheriff/innocent)
-- loadstring(game:HttpGet("URL"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- clean old
for _, n in ipairs({"LokeiiMM2"}) do
    if game.CoreGui:FindFirstChild(n) then game.CoreGui[n]:Destroy() end
    if LP:FindFirstChild(n) then LP[n]:Destroy() end
end

local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

-- ROOT
local gui = mk("ScreenGui", {
    Name = "LokeiiMM2", ResetOnSpawn = false,
    IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, game.CoreGui)

-- ===== FLOATING ICON =====
local icon = mk("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0.5, -25),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Text = "MM2", TextColor3 = Color3.fromRGB(220, 80, 80),
    Font = Enum.Font.GothamBold, TextSize = 13,
    BorderSizePixel = 0, AutoButtonColor = false
}, gui)
mk("UICorner", {CornerRadius = UDim.new(0, 12)}, icon)
mk("UIStroke", {Color = Color3.fromRGB(220, 80, 80), Thickness = 2}, icon)

-- ===== MAIN FRAME =====
local frame = mk("Frame", {
    Size = UDim2.new(0, 300, 0, 400),
    Position = UDim2.new(0.5, -150, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24),
    BorderSizePixel = 0, Active = true, Visible = false
}, gui)
mk("UICorner", {CornerRadius = UDim.new(0, 10)}, frame)
mk("UIStroke", {Color = Color3.fromRGB(60, 60, 80), Thickness = 1}, frame)

mk("TextLabel", {
    Size = UDim2.new(1, -40, 0, 32), Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1, Text = "Lokeii MM2",
    TextColor3 = Color3.fromRGB(230, 230, 235),
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left
}, frame)

local close = mk("TextButton", {
    Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -34, 0, 3),
    BackgroundColor3 = Color3.fromRGB(200, 60, 60), Text = "X",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0
}, frame)
mk("UICorner", {CornerRadius = UDim.new(0, 6)}, close)

local scroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0, 10, 0, 42),
    BackgroundColor3 = Color3.fromRGB(26, 26, 32), BorderSizePixel = 0,
    ScrollBarThickness = 5, CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, frame)
mk("UICorner", {CornerRadius = UDim.new(0, 8)}, scroll)
mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, scroll)

-- ===== TOGGLE FACTORY =====
local function addToggle(text, default, cb)
    local on = default or false
    local b = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = on and Color3.fromRGB(55, 125, 85) or Color3.fromRGB(40, 40, 50),
        Text = text .. ": " .. (on and "ON" or "OFF"),
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0
    }, scroll)
    mk("UICorner", {CornerRadius = UDim.new(0, 6)}, b)
    b.MouseButton1Click:Connect(function()
        on = not on
        b.BackgroundColor3 = on and Color3.fromRGB(55, 125, 85) or Color3.fromRGB(40, 40, 50)
        b.Text = text .. ": " .. (on and "ON" or "OFF")
        if cb then cb(on) end
    end)
    return b
end

-- ===== DRAG LOGIC =====
local function makeDraggable(handle, target, onShortClick)
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = i.Position
            startPos = target.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement 
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - dragStart
        if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then
            moved = true
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    
    UIS.InputEnded:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false
        if not moved and onShortClick then onShortClick() end
    end)
end

makeDraggable(icon, icon, function()
    frame.Visible = true
    icon.Visible = false
end)

makeDraggable(frame, frame, nil)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    icon.Visible = true
end)

-- ===== ESP =====
local espOn = false
local drawings = {}   -- player -> {line, label, highlight}

local function roleOf(p)
    if not p.Character then return "innocent" end
    local bp, ch = p:FindFirstChild("Backpack"), p.Character
    if (bp and bp:FindFirstChild("Knife")) or ch:FindFirstChild("Knife") then
        return "murderer"
    end
    if (bp and bp:FindFirstChild("Gun")) or ch:FindFirstChild("Gun") then
        return "sheriff"
    end
    return "innocent"
end

local COLORS = {
    murderer = Color3.fromRGB(255, 60, 60),
    sheriff  = Color3.fromRGB(60, 140, 255),
    innocent = Color3.fromRGB(60, 220, 90)
}

local function makeDrawing(player)
    if drawings[player] then return end
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Visible = false
    
    local label = Drawing.new("Text")
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.OutlineColor = Color3.fromRGB(0, 0, 0)
    label.Visible = false
    
    drawings[player] = {line = line, label = label, hl = nil}
end

local function removeDrawing(player)
    local d = drawings[player]
    if not d then return end
    if d.line then d.line:Remove() end
    if d.label then d.label:Remove() end
    if d.hl then d.hl:Destroy() end
    drawings[player] = nil
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then
            if drawings[p] then removeDrawing(p) end
        else
            makeDrawing(p)
            local d = drawings[p]
            local ch = p.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local head = ch and ch:FindFirstChild("Head")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            
            if not espOn or not hrp or not head or not hum or hum.Health <= 0 then
                d.line.Visible = false
                d.label.Visible = false
                if d.hl then d.hl.Enabled = false end
            else
                local role = roleOf(p)
                local color = COLORS[role]
                
                -- screen pos of head
                local headPos, onScreen = Cam:WorldToViewportPoint(head.Position)
                local rootPos = Cam:WorldToViewportPoint(hrp.Position)
                local myPos = Cam.CFrame.Position
                local dist = math.floor((myPos - hrp.Position).Magnitude)
                
                -- line from bottom of screen to target
                local screenBottom = Vector2.new(rootPos.X, Cam.ViewportSize.Y)
                
                if onScreen then
                    d.line.From = screenBottom
                    d.line.To = Vector2.new(headPos.X, headPos.Y)
                    d.line.Color = color
                    d.line.Visible = true
                    
                    d.label.Text = p.Name .. " | " .. role .. " | " .. dist .. "m"
                    d.label.Position = Vector2.new(headPos.X, headPos.Y - 20)
                    d.label.Color = color
                    d.label.Visible = true
                else
                    d.line.Visible = false
                    d.label.Visible = false
                end
                
                -- highlight
                if d.hl and d.hl.Adornee ~= ch then
                    d.hl:Destroy()
                    d.hl = nil
                end
                if not d.hl then
                    d.hl = Instance.new("Highlight")
                    d.hl.Adornee = ch
                    d.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    d.hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    d.hl.Parent = ch
                end
                d.hl.FillColor = color
                d.hl.Enabled = true
            end
        end
    end
end

Players.PlayerRemoving:Connect(removeDrawing)

-- toggle button in menu
addToggle("ESP (roles, lines, names)", false, function(s)
    espOn = s
    if not s then
        for _, p in ipairs(Players:GetPlayers()) do
            local d = drawings[p]
            if d then
                d.line.Visible = false
                d.label.Visible = false
                if d.hl then d.hl.Enabled = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(updateESP)

-- RightShift toggle
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if frame.Visible then
            frame.Visible = false
            icon.Visible = true
        else
            frame.Visible = true
            icon.Visible = false
        end
    end
end)

print("[Lokeii] MM2 loaded. RightShift — toggle menu.")
