--[[
    Blox Community VN v3.1 - FIXED
    Author: Dungdx | Discord: discord.gg/Hwwa3VYxW6
    Theme : Mystic Blue
--]]

-- Reset guard mỗi lần chạy
getgenv().BloxCommunityVN_Loaded = nil

print("========================================")
print("[BCVN] Bat dau load script...")
print("========================================")

-- Services (an toàn)
local ok, err = pcall(function()
    getgenv().BCVN_Players     = game:GetService("Players")
    getgenv().BCVN_RunService  = game:GetService("RunService")
    getgenv().BCVN_UIS         = game:GetService("UserInputService")
    getgenv().BCVN_Tween       = game:GetService("TweenService")
    getgenv().BCVN_RS          = game:GetService("ReplicatedStorage")
    getgenv().BCVN_Lighting    = game:GetService("Lighting")
    getgenv().BCVN_VIM         = game:GetService("VirtualInputManager")
    getgenv().BCVN_Http        = game:GetService("HttpService")
    getgenv().BCVN_VirtualUser = game:GetService("VirtualUser")
    getgenv().BCVN_Workspace   = game:GetService("Workspace")
end)
if not ok then
    warn("[BCVN] Loi load services:", err)
    return
end

local Players     = getgenv().BCVN_Players
local RunService  = getgenv().BCVN_RunService
local UIS         = getgenv().BCVN_UIS
local TweenSvc    = getgenv().BCVN_Tween
local RS          = getgenv().BCVN_RS
local Lighting    = getgenv().BCVN_Lighting
local VIM         = getgenv().BCVN_VIM
local HttpSvc     = getgenv().BCVN_Http
local VirtualUser = getgenv().BCVN_VirtualUser
local Workspace   = getgenv().BCVN_Workspace
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[BCVN] Khong tim thay LocalPlayer, doi 5s...")
    task.wait(5)
    LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then warn("[BCVN] Van khong co LocalPlayer!"); return end
end

print("[BCVN] Services OK | Player:", LocalPlayer.Name)

--============================================================
-- CONFIG
--============================================================
local T = {
    -- Combat
    FastAttack = true, FastAttackDelay = 0, AttackMethod = "Fast Attack",
    AutoAttackGun = true, BringMonster = true, BringMonsterRadius = 350,
    PosY = 18, SelectWeapon = "Melee",
    -- Move
    WalkSpeed = 50, JumpPower = 50, InfiniteZoom = false, XrayVision = false,
    -- Visual
    RemoveFog = false, LagFix = false, RemoveObservationEffect = false,
    ESPChest = false, ESPFruit = false,
    -- Farm
    AutoFarm = false, AutoFarmBones = false, AutoFarmBoss = false,
    AutoKillAllBosses = false, AutoMaterial = false,
    AutoFarmPrince = false, AutoDoughKing = false,
    AutoChest = false, ChestHopCount = 10, AutoHopChest = false,
    -- Fruit
    AutoFruitFarm = false, AutoStoreFruit = false, TweenFruit = false, HopIfNoFruit = false,
    -- Server
    HopDelay = 10, AutoHop30Min = false,
    -- Misc
    AntiAFK = true,
    -- Macro
    MacroEnabled = false, MacroSkillKeys = {"Z","X","C","V","F"},
    MacroDelay = 0.3, MacroDelayBetween = 0.15,
    -- Tween
    TweenSpeed = 250, checknearestdist = 1500,
    -- Webhook
    Webhook = "", WebhookEnabled = false,
}
getgenv().BCVN_Config = T

--============================================================
-- LAG FIX & FOG
--============================================================
local function ApplyLagFix(on)
    pcall(function()
        local tm = Workspace:FindFirstChildOfClass("Terrain")
        if tm then
            tm.WaterWaveSize = on and 0 or 0.15
            tm.WaterWaveSpeed = on and 0 or 10
            tm.WaterReflectance = on and 0 or 0.1
            tm.WaterTransparency = on and 0 or 0.1
        end
        Lighting.GlobalShadows = not on
        Lighting.FogEnd = on and 9e9 or 100000
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
               or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = not on
            end
        end
        settings().Rendering.QualityLevel = on and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end)
end

local function ApplyRemoveFog(on)
    if not on then return end
    pcall(function()
        Lighting.FogEnd = math.huge
        Lighting.FogStart = 0
        for _, n in ipairs({"FantasySky","Sky","LightingLayers","SeaTerrorCC"}) do
            local o = Lighting:FindFirstChild(n)
            if o then o:Destroy() end
        end
    end)
end

--============================================================
-- TẠO UI (làm ĐẦU TIÊN, bọc pcall)
--============================================================
print("[BCVN] Dang tao UI...")

local UICreateOk, UI = pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pg then error("Khong tim thay PlayerGui") end

    local old = pg:FindFirstChild("BloxCommunityVN")
    if old then old:Destroy() end

    local TH = {
        Bg=Color3.fromRGB(8,12,24), Panel=Color3.fromRGB(14,22,42),
        Card=Color3.fromRGB(20,30,55), CardHover=Color3.fromRGB(28,42,72),
        Card2=Color3.fromRGB(25,38,65), Stroke=Color3.fromRGB(60,130,220),
        Accent=Color3.fromRGB(0,170,255), AccentDark=Color3.fromRGB(0,110,190),
        AccentGlow=Color3.fromRGB(100,200,255), AccentSoft=Color3.fromRGB(40,90,160),
        Text=Color3.fromRGB(230,240,255), Dim=Color3.fromRGB(140,170,210),
        Green=Color3.fromRGB(80,220,140), Red=Color3.fromRGB(240,90,90),
        Yellow=Color3.fromRGB(255,210,80),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxCommunityVN"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = pg

    -- NÚT Dx
    local dxBtn = Instance.new("TextButton")
    dxBtn.Size = UDim2.fromOffset(52,52)
    dxBtn.Position = UDim2.new(0,20,0.5,-26)
    dxBtn.BackgroundColor3 = TH.AccentDark
    dxBtn.Text = "Dx"
    dxBtn.Font = Enum.Font.GothamBlack
    dxBtn.TextColor3 = Color3.new(1,1,1)
    dxBtn.TextSize = 22
    dxBtn.AutoButtonColor = false
    dxBtn.Active = true
    dxBtn.Draggable = true
    dxBtn.Parent = gui
    local dc = Instance.new("UICorner", dxBtn); dc.CornerRadius = UDim.new(1,0)
    local ds = Instance.new("UIStroke", dxBtn); ds.Color = TH.AccentGlow; ds.Thickness = 2
    local dg = Instance.new("UIGradient", dxBtn)
    dg.Color = ColorSequence.new(TH.Accent, TH.AccentDark); dg.Rotation = 45

    -- MAIN WINDOW
    local root = Instance.new("Frame")
    root.AnchorPoint = Vector2.new(0.5,0.5)
    root.Position = UDim2.fromScale(0.5,0.5)
    root.Size = UDim2.fromOffset(640,420)
    root.BackgroundColor3 = TH.Bg
    root.BorderSizePixel = 0
    root.Parent = gui
    local rc = Instance.new("UICorner", root); rc.CornerRadius = UDim.new(0,12)
    local rstr = Instance.new("UIStroke", root); rstr.Color = TH.Stroke; rstr.Thickness = 1.5
    local bg = Instance.new("UIGradient", root)
    bg.Color = ColorSequence.new(TH.Bg, Color3.fromRGB(12,20,38), TH.Bg)
    bg.Rotation = 135

    local scale = Instance.new("UIScale", root)
    local cam = Workspace.CurrentCamera
    local function fitScale()
        local vp = cam and cam.ViewportSize or Vector2.new(1000,600)
        scale.Scale = math.min(
            math.clamp((vp.X-40)/640,0.6,1.1),
            math.clamp((vp.Y-100)/420,0.6,1.1))
    end
    fitScale()
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale) end

    -- TOP BAR
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = TH.Panel
    top.BorderSizePixel = 0
    top.Parent = root
    local tc = Instance.new("UICorner", top); tc.CornerRadius = UDim.new(0,12)

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(50,40); logo.Position = UDim2.fromOffset(12,0)
    logo.BackgroundTransparency = 1; logo.Text = "Dx"
    logo.Font = Enum.Font.GothamBlack; logo.TextColor3 = TH.AccentGlow
    logo.TextSize = 20; logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = top

    local ttl = Instance.new("TextLabel")
    ttl.Position = UDim2.fromOffset(60,5); ttl.Size = UDim2.fromOffset(200,16)
    ttl.BackgroundTransparency = 1; ttl.Text = "Blox Community VN"
    ttl.Font = Enum.Font.GothamBold; ttl.TextColor3 = TH.Text
    ttl.TextSize = 13; ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = top

    local sub = Instance.new("TextLabel")
    sub.Position = UDim2.fromOffset(60,22); sub.Size = UDim2.fromOffset(280,12)
    sub.BackgroundTransparency = 1
    sub.Text = "by Dungdx  •  discord.gg/Hwwa3VYxW6"
    sub.Font = Enum.Font.Gotham; sub.TextColor3 = TH.Dim
    sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = top

    local function topBtn(text, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(30,24); b.Position = UDim2.new(1,x,0,8)
        b.BackgroundColor3 = TH.Card; b.Text = text
        b.Font = Enum.Font.GothamBold; b.TextColor3 = TH.Text
        b.TextSize = 13; b.AutoButtonColor = false; b.Parent = top
        local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = TH.CardHover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = TH.Card end)
        return b
    end
    local closeB = topBtn("×", -38)
    topBtn("—", -70)
    closeB.MouseButton1Click:Connect(function() gui.Enabled = false end)

    -- DRAG WINDOW
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = root.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)

    dxBtn.MouseButton1Click:Connect(function() root.Visible = not root.Visible end)

    -- KÉO NÚT Dx
    local dxDrag, dxStart, dxStartP
    dxBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dxDrag = true; dxStart = i.Position; dxStartP = dxBtn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dxDrag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dxDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dxStart
            dxBtn.Position = UDim2.new(dxStartP.X.Scale, dxStartP.X.Offset+d.X, dxStartP.Y.Scale, dxStartP.Y.Offset+d.Y)
        end
    end)

    -- TAB BAR
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Position = UDim2.fromOffset(10,46)
    tabBar.Size = UDim2.new(1,-20,0,32)
    tabBar.BackgroundColor3 = TH.Panel
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.CanvasSize = UDim2.fromOffset(0,0)
    tabBar.Parent = root
    local tbc = Instance.new("UICorner", tabBar); tbc.CornerRadius = UDim.new(0,8)
    local tLay = Instance.new("UIListLayout", tabBar)
    tLay.FillDirection = Enum.FillDirection.Horizontal
    tLay.Padding = UDim.new(0,4)
    local tPad = Instance.new("UIPadding", tabBar)
    tPad.PaddingLeft = UDim.new(0,4); tPad.PaddingTop = UDim.new(0,4)

    -- CONTENT
    local content = Instance.new("Frame")
    content.Position = UDim2.fromOffset(10,84)
    content.Size = UDim2.new(1,-20,1,-94)
    content.BackgroundTransparency = 1
    content.Parent = root

    -- HELPERS
    local function mkCorner(o,r) local c = Instance.new("UICorner",o); c.CornerRadius = UDim.new(0,r or 6); return c end
    local function mkStroke(o,c,t) local s = Instance.new("UIStroke",o); s.Color = c or TH.Stroke; s.Thickness = t or 1; return s end

    -- TABS
    local Tabs, ActiveTab = {}, nil
    local tabIcons = {Home="⌂",Farm="▦",Combat="⚔",Player="♙",Fruit="◈",Chest="▣",Island="⌖",Macro="☰",Perf="⚡",Misc="⚙",Webhook="✉",Credit="★"}
    local TabOrder = {"Home","Farm","Combat","Player","Fruit","Chest","Island","Macro","Perf","Misc","Webhook","Credit"}

    local function CreateTab(name)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1,1); frame.BackgroundTransparency = 1
        frame.Visible = false; frame.Parent = content

        local left = Instance.new("ScrollingFrame")
        left.Size = UDim2.new(0.5,-5,1,0); left.BackgroundTransparency = 1
        left.BorderSizePixel = 0; left.ScrollBarThickness = 3
        left.ScrollBarImageColor3 = TH.Accent
        left.AutomaticCanvasSize = Enum.AutomaticSize.Y
        left.CanvasSize = UDim2.fromOffset(0,0); left.Parent = frame

        local right = left:Clone()
        right.Position = UDim2.new(0.5,5,0,0); right.Parent = frame

        local lL = Instance.new("UIListLayout",left); lL.SortOrder = Enum.SortOrder.LayoutOrder; lL.Padding = UDim.new(0,6)
        local rL = Instance.new("UIListLayout",right); rL.SortOrder = Enum.SortOrder.LayoutOrder; rL.Padding = UDim.new(0,6)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80,24); btn.BackgroundColor3 = TH.Card
        btn.Text = (tabIcons[name] or "•").."  "..name
        btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = TH.Dim
        btn.TextSize = 10; btn.AutoButtonColor = false; btn.Parent = tabBar
        mkCorner(btn,6)
        btn.MouseEnter:Connect(function() if ActiveTab ~= name then btn.BackgroundColor3 = TH.CardHover end end)
        btn.MouseLeave:Connect(function() if ActiveTab ~= name then btn.BackgroundColor3 = TH.Card end end)
        btn.MouseButton1Click:Connect(function()
            if ActiveTab == name then return end
            for _, tD in pairs(Tabs) do
                tD.Frame.Visible = false
                tD.Button.BackgroundColor3 = TH.Card
                tD.Button.TextColor3 = TH.Dim
            end
            frame.Visible = true
            btn.BackgroundColor3 = TH.AccentDark
            btn.TextColor3 = TH.Text
            ActiveTab = name
        end)

        local tabObj = {Frame=frame, Button=btn, Left=left, Right=right, _toggle=false, _order=0}
        function tabObj:GetColumn()
            self._toggle = not self._toggle
            return self._toggle and self.Left or self.Right
        end
        function tabObj:AddSection(name)
            local col = self:GetColumn()
            self._order = self._order + 1
            local sec = Instance.new("Frame")
            sec.Size = UDim2.new(1,-2,0,0)
            sec.AutomaticSize = Enum.AutomaticSize.Y
            sec.BackgroundColor3 = TH.Card; sec.BorderSizePixel = 0
            sec.LayoutOrder = self._order; sec.Parent = col
            mkCorner(sec,8); mkStroke(sec, Color3.fromRGB(40,70,120),1)

            local head = Instance.new("Frame")
            head.Size = UDim2.new(1,0,0,26); head.BackgroundTransparency = 1; head.Parent = sec
            local acc = Instance.new("Frame")
            acc.Size = UDim2.fromOffset(20,3); acc.Position = UDim2.fromOffset(10,11)
            acc.BackgroundColor3 = TH.Accent; acc.BorderSizePixel = 0; acc.Parent = head
            mkCorner(acc,2)
            local tl = Instance.new("TextLabel")
            tl.Position = UDim2.fromOffset(36,5); tl.Size = UDim2.new(1,-40,0,16)
            tl.BackgroundTransparency = 1; tl.Text = name
            tl.Font = Enum.Font.GothamBold; tl.TextColor3 = TH.AccentGlow
            tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = head

            local body = Instance.new("Frame")
            body.Position = UDim2.fromOffset(8,28); body.Size = UDim2.new(1,-16,0,0)
            body.AutomaticSize = Enum.AutomaticSize.Y; body.BackgroundTransparency = 1
            body.Parent = sec
            local bL = Instance.new("UIListLayout",body)
            bL.SortOrder = Enum.SortOrder.LayoutOrder; bL.Padding = UDim.new(0,4)
            bL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sec.Size = UDim2.new(1,-2,0, 28 + bL.AbsoluteContentSize.Y + 8)
            end)
            return {Frame = body, Section = sec}
        end
        Tabs[name] = tabObj
        return tabObj
    end

    for _, n in ipairs(TabOrder) do CreateTab(n) end
    Tabs.Home.Frame.Visible = true
    Tabs.Home.Button.BackgroundColor3 = TH.AccentDark
    Tabs.Home.Button.TextColor3 = TH.Text
    ActiveTab = "Home"

    -- COMPONENTS
    local C = {}

    function C:Label(parent, text, desc)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0, desc and 30 or 18)
        f.BackgroundTransparency = 1; f.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,16); l.BackgroundTransparency = 1
        l.Text = text; l.Font = Enum.Font.GothamSemibold
        l.TextColor3 = TH.Dim; l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
        local d
        if desc then
            d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(0,15); d.Size = UDim2.new(1,0,0,15)
            d.BackgroundTransparency = 1; d.Text = desc
            d.Font = Enum.Font.Gotham; d.TextColor3 = TH.Text
            d.TextSize = 10; d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = f
        end
        return {Set = function(_,t) if d then d.Text = t end end}
    end

    function C:Toggle(parent, text, default, cb, desc)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0, desc and 38 or 26)
        row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-55,0,14); l.Position = UDim2.fromOffset(2,2)
        l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.GothamSemibold; l.TextColor3 = TH.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        if desc then
            local d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(2,16); d.Size = UDim2.new(1,-55,0,20)
            d.BackgroundTransparency = 1; d.Text = desc
            d.Font = Enum.Font.Gotham; d.TextColor3 = TH.Dim
            d.TextSize = 8; d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = row
        end
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.fromOffset(40,18); pill.Position = UDim2.new(1,-44,0,4)
        pill.BackgroundColor3 = default and TH.AccentDark or Color3.fromRGB(45,55,75)
        pill.Text = ""; pill.AutoButtonColor = false; pill.Parent = row
        mkCorner(pill,9); mkStroke(pill, default and TH.AccentGlow or TH.Stroke,1)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(13,13); knob.BackgroundColor3 = Color3.fromRGB(230,240,255)
        knob.BorderSizePixel = 0
        knob.Position = default and UDim2.new(1,-15,0,2) or UDim2.fromOffset(2,2)
        knob.Parent = pill; mkCorner(knob,7)
        local st = default and true or false
        local function paint()
            if st then
                pill.BackgroundColor3 = TH.AccentDark; pill.UIStroke.Color = TH.AccentGlow
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1,-15,0,2)}):Play()
            else
                pill.BackgroundColor3 = Color3.fromRGB(45,55,75); pill.UIStroke.Color = TH.Stroke
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(2,2)}):Play()
            end
        end
        pill.MouseButton1Click:Connect(function()
            st = not st; paint()
            if cb then pcall(cb, st) end
        end)
        return {Set = function(_,v) st = not not v; paint(); if cb then pcall(cb,st) end end, Get = function() return st end}
    end

    function C:Button(parent, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = TH.Card2
        b.Text = text; b.Font = Enum.Font.GothamSemibold
        b.TextColor3 = TH.Text; b.TextSize = 10
        b.AutoButtonColor = false; b.Parent = parent
        mkCorner(b,6); mkStroke(b, TH.Stroke,1)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = TH.AccentSoft end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = TH.Card2 end)
        b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
        return b
    end

    function C:Slider(parent, text, min, max, default, cb, step)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,36); row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6,0,0,14); l.Position = UDim2.fromOffset(2,2)
        l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.GothamSemibold; l.TextColor3 = TH.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        local vL = Instance.new("TextLabel")
        vL.Size = UDim2.new(0.35,0,0,14); vL.Position = UDim2.new(0.65,0,0,2)
        vL.BackgroundTransparency = 1; vL.Text = tostring(default)
        vL.Font = Enum.Font.GothamBold; vL.TextColor3 = TH.AccentGlow
        vL.TextSize = 10; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.Parent = row
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1,-4,0,6); track.Position = UDim2.fromOffset(2,22)
        track.BackgroundColor3 = Color3.fromRGB(35,45,65)
        track.BorderSizePixel = 0; track.Parent = row; mkCorner(track,3)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = TH.Accent
        fill.BorderSizePixel = 0; fill.Parent = track; mkCorner(fill,3)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(10,10); knob.AnchorPoint = Vector2.new(0.5,0.5)
        knob.Position = UDim2.new(0,0,0.5,0); knob.BackgroundColor3 = TH.AccentGlow
        knob.BorderSizePixel = 0; knob.Parent = track; mkCorner(knob,5)
        local cur = tonumber(default) or min
        local lo, hi = tonumber(min), tonumber(max)
        local stp = tonumber(step) or 0
        local function setV(v, fire)
            v = math.clamp(v, lo, hi)
            if stp > 0 then v = math.floor((v-lo)/stp+0.5)*stp+lo end
            cur = v
            local t = (hi-lo) == 0 and 0 or (v-lo)/(hi-lo)
            fill.Size = UDim2.new(t,0,1,0)
            knob.Position = UDim2.new(t,0,0.5,0)
            vL.Text = tostring(v)
            if fire and cb then pcall(cb, v) end
        end
        setV(cur, false)
        local dg = false
        local function upd(i)
            local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local t = track.AbsoluteSize.X == 0 and 0 or x/track.AbsoluteSize.X
            setV(lo + (hi-lo)*t, true)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg = true; upd(i)
            end
        end)
        track.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                upd(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end
        end)
        return {Set = function(_,v) setV(tonumber(v) or cur, false) end, Get = function() return cur end}
    end

    function C:Dropdown(parent, text, default, options, cb)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,26); row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.4,0,1,0); l.Position = UDim2.fromOffset(2,0)
        l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.GothamSemibold; l.TextColor3 = TH.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.6,-4,1,0); btn.Position = UDim2.new(0.4,0,0,0)
        btn.BackgroundColor3 = TH.Card2; btn.Text = tostring(default or "None")
        btn.Font = Enum.Font.Gotham; btn.TextColor3 = TH.Text
        btn.TextSize = 9; btn.AutoButtonColor = false; btn.Parent = row
        mkCorner(btn,5); mkStroke(btn, TH.Stroke,1)
        local list = type(options) == "table" and options or {}
        local cur = default
        local popup
        local function closeP() if popup then popup:Destroy(); popup = nil end end
        local function openP()
            closeP()
            popup = Instance.new("Frame")
            popup.Size = UDim2.new(0,160,0,math.min(180,22*#list+6))
            popup.Position = UDim2.new(1,-160,0,28)
            popup.BackgroundColor3 = TH.Panel; popup.ZIndex = 100
            popup.Parent = row; mkCorner(popup,6); mkStroke(popup, TH.Accent,1)
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.fromScale(1,1); sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0; sc.ScrollBarThickness = 2
            sc.ScrollBarImageColor3 = TH.Accent; sc.ZIndex = 101; sc.Parent = popup
            local ll = Instance.new("UIListLayout",sc); ll.Padding = UDim.new(0,2)
            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1,-6,0,20); ob.Position = UDim2.fromOffset(3,0)
                ob.BackgroundColor3 = TH.Card; ob.Text = tostring(opt)
                ob.Font = Enum.Font.Gotham; ob.TextColor3 = TH.Text
                ob.TextSize = 9; ob.AutoButtonColor = false
                ob.ZIndex = 102; ob.Parent = sc; mkCorner(ob,4)
                ob.MouseEnter:Connect(function() ob.BackgroundColor3 = TH.AccentSoft end)
                ob.MouseLeave:Connect(function() ob.BackgroundColor3 = TH.Card end)
                ob.MouseButton1Click:Connect(function()
                    cur = opt; btn.Text = tostring(opt); closeP()
                    if cb then pcall(cb, opt) end
                end)
            end
            sc.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + 6)
        end
        btn.MouseButton1Click:Connect(openP)
        return {
            Set = function(_,v) cur = v; btn.Text = tostring(v); if cb then pcall(cb,v) end end,
            Refresh = function(_,nl) list = type(nl)=="table" and nl or {}; cur = list[1]; btn.Text = tostring(cur or "None") end,
        }
    end

    function C:Textbox(parent, placeholder, cb, default)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,26); row.BackgroundTransparency = 1; row.Parent = parent
        local box = Instance.new("TextBox")
        box.Size = UDim2.fromScale(1,1); box.BackgroundColor3 = TH.Card2
        box.Text = default or ""; box.PlaceholderText = placeholder
        box.PlaceholderColor3 = TH.Dim; box.Font = Enum.Font.Gotham
        box.TextColor3 = TH.Text; box.TextSize = 9; box.ClearTextOnFocus = false
        box.Parent = row; mkCorner(box,5); mkStroke(box, TH.Stroke,1)
        box.FocusLost:Connect(function() if cb then pcall(cb, box.Text) end end)
        return {Set = function(_,v) box.Text = tostring(v or "") end, Get = function() return box.Text end}
    end

    -- NOTIF
    local notifHolder
    local function Notify(title, desc, dur)
        if not notifHolder then
            notifHolder = Instance.new("Frame")
            notifHolder.Size = UDim2.fromOffset(240,400)
            notifHolder.Position = UDim2.new(1,-252,0,60)
            notifHolder.BackgroundTransparency = 1; notifHolder.Parent = gui
            local ll = Instance.new("UIListLayout",notifHolder)
            ll.Padding = UDim.new(0,6); ll.SortOrder = Enum.SortOrder.LayoutOrder
        end
        local n = Instance.new("Frame")
        n.Size = UDim2.fromOffset(240,56); n.BackgroundColor3 = TH.Panel
        n.BorderSizePixel = 0; n.Parent = notifHolder
        mkCorner(n,8); mkStroke(n, TH.Accent,1)
        local acc = Instance.new("Frame")
        acc.Size = UDim2.fromOffset(3,56); acc.BackgroundColor3 = TH.AccentGlow
        acc.BorderSizePixel = 0; acc.Parent = n; mkCorner(acc,2)
        local t = Instance.new("TextLabel")
        t.Position = UDim2.fromOffset(12,8); t.Size = UDim2.new(1,-20,0,15)
        t.BackgroundTransparency = 1; t.Text = tostring(title or "Thong bao")
        t.Font = Enum.Font.GothamBold; t.TextColor3 = TH.AccentGlow
        t.TextSize = 11; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = n
        local d = Instance.new("TextLabel")
        d.Position = UDim2.fromOffset(12,24); d.Size = UDim2.new(1,-20,0,26)
        d.BackgroundTransparency = 1; d.Text = tostring(desc or "")
        d.Font = Enum.Font.Gotham; d.TextColor3 = TH.Text
        d.TextSize = 9; d.TextWrapped = true
        d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = n
        task.delay(dur or 5, function() pcall(function() n:Destroy() end) end)
    end

    return {Gui=gui, Root=root, Tabs=Tabs, Components=C, Theme=TH, Notify=Notify, ToggleBtn=dxBtn}
end)

if not UICreateOk then
    warn("[BCVN] LOI TAO UI:", tostring(UI))
    return
end

local Tabs = UI.Tabs
local C = UI.Components
local Theme = UI.Theme
local function Notify(t,d,dur) pcall(function() UI.Notify(t,d,dur) end) end

print("[BCVN] UI DA HIEN! Nhin goc trai man hinh co nut 'Dx'")

--============================================================
-- BACKEND (chạy trong task.spawn, bọc pcall để không crash UI)
--============================================================
task.spawn(function()
    local ok, err = pcall(function()
        print("[BCVN] Dang load backend...")

        -- Remotes (không block)
        local Remotes = RS:WaitForChild("Remotes", 20)
        if not Remotes then warn("[BCVN] Khong co Remotes"); return end
        local NetMod = RS:FindFirstChild("Modules")
        local Net = NetMod and NetMod:WaitForChild("Net", 10) or nil
        local CommF = Remotes:WaitForChild("CommF_", 10)
        local CommE = Remotes:WaitForChild("CommE", 10)

        -- Player state (không crash nếu nil)
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid", 10)
        local HRP = Character:WaitForChild("HumanoidRootPart", 10)
        local Data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:WaitForChild("Data", 20)
        local Level = Data and Data:FindFirstChild("Level") or nil
        local Beli = Data and Data:FindFirstChild("Beli") or nil
        local Fragments = Data and Data:FindFirstChild("Fragments") or nil

        local Enemies = Workspace:WaitForChild("Enemies", 30)
        local SeaBeasts = Workspace:FindFirstChild("SeaBeasts")
        local ChestModels = Workspace:FindFirstChild("ChestModels")
        local WorldOrigin = Workspace:FindFirstChild("_WorldOrigin")

        local MapAttr = Workspace:GetAttribute("MAP")
        local IsSea1 = MapAttr == "Sea1"
        local IsSea2 = MapAttr == "Sea2"
        local IsSea3 = MapAttr == "Sea3"

        LocalPlayer.CharacterAdded:Connect(function(nc)
            Character = nc
            Humanoid = nc:WaitForChild("Humanoid", 10)
            HRP = nc:WaitForChild("HumanoidRootPart", 10)
        end)

        print("[BCVN] Backend OK | Sea:", tostring(MapAttr))

        -- ==================== TWEEN ====================
        local TweenState = {Cancel=false, BodyVel=nil, Gen=0}
        local function StopTween()
            TweenState.Cancel = true
            TweenState.Gen = TweenState.Gen + 1
            if TweenState.BodyVel and TweenState.BodyVel.Parent then
                pcall(function() TweenState.BodyVel:Destroy() end)
            end
            TweenState.BodyVel = nil
        end
        local function TweenTo(target, keep)
            if not HRP or not HRP.Parent then return end
            if typeof(target) == "Vector3" then target = CFrame.new(target) end
            if typeof(target) ~= "CFrame" then return end
            TweenState.Cancel = false
            TweenState.Gen = TweenState.Gen + 1
            local myGen = TweenState.Gen
            local startCF = HRP.CFrame
            local dist = (target.Position - startCF.Position).Magnitude
            if dist < 5 then HRP.CFrame = target; return end
            if not TweenState.BodyVel or not TweenState.BodyVel.Parent then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DxTween"
                bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                bv.Velocity = Vector3.zero; bv.P = 10000; bv.Parent = HRP
                TweenState.BodyVel = bv
            end
            local speed = T.TweenSpeed or 250
            local steps = math.clamp(math.ceil(dist/(speed*0.02)), 3, 500)
            local startPos = startCF.Position
            for i = 1, steps do
                if TweenState.Gen ~= myGen or TweenState.Cancel then break end
                if not HRP or not HRP.Parent then break end
                local a = i/steps
                local newPos = startPos:Lerp(target.Position, a)
                TweenState.BodyVel.Velocity = (newPos - HRP.Position) * 60
                if dist > 50 then
                    HRP.CFrame = CFrame.new(HRP.Position:Lerp(target.Position, a*0.3), HRP.Position + (target.Position - HRP.Position).Unit)
                end
                RunService.Heartbeat:Wait()
            end
            if TweenState.Gen == myGen then
                pcall(function() HRP.CFrame = target
                    if TweenState.BodyVel then TweenState.BodyVel.Velocity = Vector3.zero end end)
                if not keep and TweenState.BodyVel then
                    TweenState.BodyVel:Destroy(); TweenState.BodyVel = nil
                end
            end
        end

        -- ==================== COMBAT ====================
        local function GetEnemies(range)
            range = range or 2000
            local list = {}
            if not HRP or not Enemies then return list end
            local p = HRP.Position
            for _, m in ipairs(Enemies:GetChildren()) do
                local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                local mHu = m:FindFirstChildOfClass("Humanoid")
                if mH and mHu and mHu.Health > 0 then
                    local d = (mH.Position - p).Magnitude
                    if d <= range then table.insert(list,{m,mH,d,mHu}) end
                end
            end
            table.sort(list, function(a,b) return a[3] < b[3] end)
            return list
        end

        local function GetEquippedWeapon()
            if not Character then return nil end
            return Character:FindFirstChildOfClass("Tool")
        end

        local function EquipWeaponType(tip)
            if not Humanoid or not Character or not tip then return end
            local cur = Character:FindFirstChildOfClass("Tool")
            if cur and cur.ToolTip == tip then return end
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == tip then
                    Humanoid:EquipTool(tool); task.wait(0.05); return tool
                end
            end
        end

        local function FastAttack()
            if not T.FastAttack then return end
            if not Character or not Humanoid or Humanoid.Health <= 0 then return end
            local tool = GetEquippedWeapon()
            if not tool then return end

            if T.SelectWeapon == "Gun" and tool.ToolTip == "Gun" then
                local remote = tool:FindFirstChild("RemoteEvent")
                local targets = GetEnemies(500)
                if #targets > 0 then
                    local tP = targets[1][2].Position
                    if remote then pcall(function() remote:FireServer("TAP", tP) end) end
                    local sR = Net and Net:FindFirstChild("RE/ShootGunEvent")
                    if sR then pcall(function() sR:FireServer(tP, {targets[1][2]}) end) end
                end
                return
            end

            local lc = tool:FindFirstChild("LeftClickRemote")
            local targets = GetEnemies(200)
            if #targets > 0 then
                local target = targets[1][2]
                local dist = targets[1][3]
                if dist > 15 then
                    TweenTo(CFrame.new(target.Position + Vector3.new(0, T.PosY or 18, 0)))
                end
                if lc then pcall(function() lc:FireServer(Vector3.new(0.01,-500,0.01), 1, true) end) end
                local reg = Net and Net:FindFirstChild("RE/RegisterHit")
                if reg then
                    local hits = {}
                    for i = 1, math.min(3,#targets) do
                        table.insert(hits, {targets[i][1], targets[i][2]})
                    end
                    pcall(function()
                        reg:FireServer(target, hits, nil, nil,
                            tostring(LocalPlayer.UserId):sub(2,4)..tostring(tick()):sub(-5))
                    end)
                end
            end
        end

        local lastBring = 0
        local function BringMonsters()
            if not T.BringMonster or not HRP or not HRP.Parent then return end
            local n = tick()
            if n - lastBring < 0.5 then return end
            lastBring = n
            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", T.BringMonsterRadius or 350) end)
            for _, m in ipairs(Enemies:GetChildren()) do
                local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                local mHu = m:FindFirstChildOfClass("Humanoid")
                if mH and mHu and mHu.Health > 0 then
                    local d = (mH.Position - HRP.Position).Magnitude
                    if d <= (T.BringMonsterRadius or 350) and d > 20 then
                        pcall(function()
                            mH.CFrame = CFrame.new(HRP.Position + Vector3.new(math.random(-5,5),5,math.random(-5,5)))
                        end)
                    end
                end
            end
        end

        -- ==================== CHEST ====================
        local ChestCounter = 0
        local function GetNearestChest()
            if not ChestModels or not HRP or not HRP.Parent then return nil end
            local p = HRP.Position
            local near, nd = nil, math.huge
            for _, c in ipairs(ChestModels:GetChildren()) do
                local r = c:FindFirstChild("RootPart")
                if r and r.Parent and c:GetAttribute("IsDisabled") ~= true then
                    local d = (r.Position - p).Magnitude
                    if d < nd then near, nd = r, d end
                end
            end
            return near
        end

        local function AutoChestLoop()
            if not T.AutoChest or not HRP or not HRP.Parent then return end
            local ch = GetNearestChest()
            if ch then
                TweenTo(ch.CFrame + Vector3.new(0,3,0))
                ChestCounter = ChestCounter + 1
                task.wait(0.05)
            else
                if ChestCounter > 0 then
                    Notify("Chest Farm","Het ruong! Da nhat "..ChestCounter.." ruong.", 5)
                    ChestCounter = 0
                end
                task.wait(1)
            end
        end

        -- ==================== FRUIT ====================
        local FruitBL = {}
        local function GetNearestFruit()
            local p = HRP and HRP.Position
            if not p then return nil end
            local near, nd = nil, math.huge
            for _, o in ipairs(Workspace:GetChildren()) do
                if o:IsA("Tool") and (o.Name:find("Fruit") or o:FindFirstChild("Handle")) then
                    local h = o:FindFirstChild("Handle")
                    if h then
                        local d = (h.Position - p).Magnitude
                        if d < nd and not FruitBL[o] then near, nd = o, d end
                    end
                end
                if o:IsA("Model") and o.Name:find("Fruit") then
                    local h = o:FindFirstChild("Handle") or o.PrimaryPart
                    if h then
                        local d = (h.Position - p).Magnitude
                        if d < nd and not FruitBL[o] then near, nd = o, d end
                    end
                end
            end
            return near, nd
        end

        local function AutoFruitLoop()
            if not T.AutoFruitFarm or not HRP or not HRP.Parent then return end
            local f, d = GetNearestFruit()
            if f then
                local h = f:FindFirstChild("Handle") or f.PrimaryPart
                if h then
                    if d > 10 then TweenTo(h.CFrame + Vector3.new(0,2,0))
                    else
                        pcall(function()
                            firetouchinterest(HRP, h, 0)
                            task.wait(0.05)
                            firetouchinterest(HRP, h, 1)
                        end)
                        FruitBL[f] = true
                        task.delay(2, function() FruitBL[f] = nil end)
                    end
                end
                task.wait(0.1)
            else
                if T.HopIfNoFruit then
                    Notify("Fruit Farm","Khong co trai! Hop sau "..T.HopDelay.."s", 4)
                    task.wait(T.HopDelay or 10)
                    pcall(function()
                        RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
                    end)
                end
                task.wait(0.5)
            end
        end

        -- ==================== MACRO ====================
        local MacroRunning = false
        local function StopMacro() MacroRunning = false end
        local function RunMacro()
            if not T.MacroEnabled or MacroRunning then return end
            MacroRunning = true
            task.spawn(function()
                while T.MacroEnabled and MacroRunning do
                    for _, k in ipairs(T.MacroSkillKeys) do
                        if not T.MacroEnabled or not MacroRunning then break end
                        local kc = Enum.KeyCode[k]
                        if kc then
                            pcall(function()
                                VIM:SendKeyEvent(true, kc, false, game)
                                task.wait(T.MacroDelay or 0.3)
                                VIM:SendKeyEvent(false, kc, false, game)
                            end)
                        end
                        task.wait(T.MacroDelayBetween or 0.15)
                    end
                    task.wait(0.5)
                end
                MacroRunning = false
            end)
        end

        -- ==================== ISLAND ====================
        local IslandCoords = {
            Sea1 = {
                ["Starter Island"]=Vector3.new(-1053,5,4251),
                ["Marine Fortress"]=Vector3.new(-4895,8,4350),
                ["Middle Town"]=Vector3.new(-916,5,4500),
                ["Jungle"]=Vector3.new(-1610,36,149),
                ["Pirate Village"]=Vector3.new(-1160,5,3845),
                ["Desert"]=Vector3.new(1055,5,4280),
                ["Frozen Village"]=Vector3.new(1200,30,-1400),
                ["Marine Ford"]=Vector3.new(-5100,15,-4200),
                ["Skylands"]=Vector3.new(-4880,720,-3230),
                ["Colosseum"]=Vector3.new(-1500,5,-2100),
                ["Prison"]=Vector3.new(4850,5,710),
                ["Magma Village"]=Vector3.new(-5220,3,870),
                ["Underwater City"]=Vector3.new(60500,4,1100),
                ["Fountain City"]=Vector3.new(5150,5,3000),
                ["Rumble Arena"]=Vector3.new(-6500,5,8500),
            },
            Sea2 = {
                ["Kingdom of Rose"]=Vector3.new(0,0,0),
                ["Swan Mansion"]=Vector3.new(-245,73,300),
                ["Hot and Cold"]=Vector3.new(2500,8,-1200),
                ["Cursed Ship"]=Vector3.new(912,125,32800),
                ["Ice Castle"]=Vector3.new(5630,25,-6000),
                ["Forgotten Island"]=Vector3.new(-3000,8,-1000),
                ["Cafe"]=Vector3.new(-380,73,260),
                ["Green Zone"]=Vector3.new(-5500,8,-350),
                ["Graveyard"]=Vector3.new(-9500,6,6000),
                ["Snow Mountain"]=Vector3.new(1350,87,-1300),
                ["Factory"]=Vector3.new(430,8,-1350),
            },
            Sea3 = {
                ["Port Town"]=Vector3.new(-260,6,5245),
                ["Hydra Island"]=Vector3.new(5660,1000,850),
                ["Great Tree"]=Vector3.new(2950,2280,-7200),
                ["Castle on the Sea"]=Vector3.new(-5100,314,-3150),
                ["Haunted Castle"]=Vector3.new(-9500,150,6000),
                ["Sea of Treats"]=Vector3.new(-1000,10,-12000),
                ["Peanut Island"]=Vector3.new(1950,8,-12200),
                ["Tiki Outpost"]=Vector3.new(-16300,8,400),
                ["Floating Turtle"]=Vector3.new(-12400,375,-7500),
                ["Mansion"]=Vector3.new(-12300,320,-6630),
            },
        }
        local function GetIslandList()
            if IsSea1 then return IslandCoords.Sea1 end
            if IsSea2 then return IslandCoords.Sea2 end
            if IsSea3 then return IslandCoords.Sea3 end
            return {}
        end
        local function GetIslandNames()
            local names = {}
            for k in pairs(GetIslandList()) do table.insert(names, k) end
            table.sort(names)
            return names
        end

        -- ==================== ESP ====================
        local ESPSprites = {}
        local function ClearESP()
            for _, o in pairs(ESPSprites) do
                if o and o.Parent then pcall(function() o:Destroy() end) end
            end
            ESPSprites = {}
        end
        local function CreateESP(parent, text, color)
            if parent:FindFirstChild("DxESP") then return end
            local bb = Instance.new("BillboardGui")
            bb.Name = "DxESP"
            bb.Size = UDim2.new(0,200,0,30)
            bb.StudsOffset = Vector3.new(0,3,0)
            bb.AlwaysOnTop = true
            bb.Parent = parent
            local l = Instance.new("TextLabel")
            l.Size = UDim2.fromScale(1,1); l.BackgroundTransparency = 1
            l.Text = text; l.Font = Enum.Font.GothamBold
            l.TextColor3 = color or Theme.AccentGlow
            l.TextStrokeTransparency = 0.3; l.TextSize = 12
            l.Parent = bb
            ESPSprites[parent] = bb
        end
        local function UpdateESP()
            if T.ESPChest and ChestModels then
                for _, ch in ipairs(ChestModels:GetChildren()) do
                    local r = ch:FindFirstChild("RootPart")
                    if r then CreateESP(r, "Chest", Theme.Yellow) end
                end
            end
            if T.ESPFruit then
                for _, o in ipairs(Workspace:GetChildren()) do
                    if o:IsA("Tool") and o.Name:find("Fruit") then
                        local h = o:FindFirstChild("Handle")
                        if h then CreateESP(h, o.Name, Theme.Red) end
                    end
                end
            end
        end

        -- ==================== HELPERS ====================
        local function ApplyWalkSpeed()
            if Humanoid and T.WalkSpeed then pcall(function() Humanoid.WalkSpeed = T.WalkSpeed end) end
        end
        local function ApplyJumpPower()
            if Humanoid and T.JumpPower then
                pcall(function() Humanoid.UseJumpPower = true; Humanoid.JumpPower = T.JumpPower end)
            end
        end
        local function ApplyInfiniteZoom()
            LocalPlayer.CameraMaxZoomDistance = T.InfiniteZoom and math.huge or 128
        end
        local function SendWebhook(title, desc)
            if not T.WebhookEnabled or T.Webhook == "" then return end
            local req = (syn and syn.request) or http_request
            if not req then return end
            local body = HttpSvc:JSONEncode({
                embeds = {{
                    title = title, description = desc, color = 3066993,
                    footer = {text = "Blox Community VN - Dungdx"},
                    timestamp = DateTime.now():ToIsoDate(),
                }}
            })
            pcall(function()
                req({Url = T.Webhook, Method = "POST",
                    Headers = {["Content-Type"]="application/json"}, Body = body})
            end)
        end

        -- ==================== BUILD TABS ====================
        -- HOME
        do
            local s1 = Tabs.Home:AddSection("Tong quan")
            C:Label(s1.Frame, "Chao mung, "..LocalPlayer.DisplayName.."!", "Dungdx | discord.gg/Hwwa3VYxW6")
            C:Label(s1.Frame, "Sea: "..tostring(MapAttr))
            local stat = C:Label(s1.Frame, "Dang tai...")
            task.spawn(function()
                while task.wait(2) do
                    pcall(function()
                        local lv = Level and Level.Value or "?"
                        local be = Beli and Beli.Value or "?"
                        local fr = Fragments and Fragments.Value or "?"
                        stat:Set("Lv:"..lv.."  Beli:"..be.."  Frags:"..fr)
                    end)
                end
            end)
            local s2 = Tabs.Home:AddSection("Bat nhanh")
            C:Toggle(s2.Frame, "Fast Attack", T.FastAttack, function(v) T.FastAttack = v end, "Danh sieu nhanh")
            C:Toggle(s2.Frame, "Auto Chest", T.AutoChest, function(v) T.AutoChest = v; ChestCounter = 0 end, "Nhat ruong")
            C:Toggle(s2.Frame, "Auto Nhat Trai", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end, "Nhat trai roi")
            C:Toggle(s2.Frame, "Bring Monster", T.BringMonster, function(v) T.BringMonster = v end, "Keo quai lai gan")
            C:Toggle(s2.Frame, "Lag Fix", T.LagFix, function(v) T.LagFix = v; ApplyLagFix(v) end, "Giam lag")
            C:Toggle(s2.Frame, "Xoa Suong Mu", T.RemoveFog, function(v) T.RemoveFog = v; ApplyRemoveFog(v) end, "Xoa fog")
        end

        -- FARM
        do
            local s1 = Tabs.Farm:AddSection("Auto Farm")
            C:Toggle(s1.Frame, "Auto Farm Quest", T.AutoFarm, function(v) T.AutoFarm = v end, "Farm quai")
            C:Toggle(s1.Frame, "Auto Farm Bones", T.AutoFarmBones, function(v) T.AutoFarmBones = v end, "Farm xuong")
            C:Dropdown(s1.Frame, "Vu khi", T.SelectWeapon, {"Melee","Sword","Blox Fruit","Gun"}, function(v) T.SelectWeapon = v end)
            C:Slider(s1.Frame, "Do cao bay", 5, 100, T.PosY, function(v) T.PosY = v end)
            C:Slider(s1.Frame, "Bring Radius", 50, 500, T.BringMonsterRadius, function(v) T.BringMonsterRadius = v end)
            C:Slider(s1.Frame, "Tween Speed", 50, 500, T.TweenSpeed, function(v) T.TweenSpeed = v end)

            local s2 = Tabs.Farm:AddSection("Boss Farm")
            local bossList = IsSea1 and {"The Gorilla King","Yeti","Warden","Swan","Magma Admiral","Fishman Lord","Thunder God","Cyborg"}
                or IsSea2 and {"Diamond","Jeremy","Orbitus","Don Swan","Tide Keeper"}
                or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen"}
            C:Dropdown(s2.Frame, "Boss", bossList[1], bossList, function(v) T.SelectBoss = v end)
            C:Toggle(s2.Frame, "Auto Boss", T.AutoFarmBoss, function(v) T.AutoFarmBoss = v end)
            C:Toggle(s2.Frame, "Kill All Bosses", T.AutoKillAllBosses, function(v) T.AutoKillAllBosses = v end)

            local s3 = Tabs.Farm:AddSection("Farm Khac")
            C:Toggle(s3.Frame, "Farm Material", T.AutoMaterial, function(v) T.AutoMaterial = v end)
            C:Toggle(s3.Frame, "Cake Prince", T.AutoFarmPrince, function(v) T.AutoFarmPrince = v end)
            C:Toggle(s3.Frame, "Dough King", T.AutoDoughKing, function(v) T.AutoDoughKing = v end)
        end

        -- COMBAT
        do
            local s1 = Tabs.Combat:AddSection("Combat")
            C:Toggle(s1.Frame, "Fast Attack", T.FastAttack, function(v) T.FastAttack = v end, "Danh sieu nhanh")
            C:Toggle(s1.Frame, "Auto Gun", T.AutoAttackGun, function(v) T.AutoAttackGun = v end)
            C:Slider(s1.Frame, "Attack Delay", 0, 1, T.FastAttackDelay, function(v) T.FastAttackDelay = v end, 0.01)
            C:Toggle(s1.Frame, "Bring Monster", T.BringMonster, function(v) T.BringMonster = v end)

            local s2 = Tabs.Combat:AddSection("Macro Combo")
            C:Toggle(s2.Frame, "Bat Macro", T.MacroEnabled, function(v)
                T.MacroEnabled = v
                if v then RunMacro() else StopMacro() end
            end, "Combo tu dong")
            C:Slider(s2.Frame, "Giu phim (s)", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
            C:Slider(s2.Frame, "Delay giua phim", 0.05, 2, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)
            C:Textbox(s2.Frame, "Z,X,C,V,F", function(v)
                local ks = {}
                for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end
                if #ks > 0 then T.MacroSkillKeys = ks end
            end, table.concat(T.MacroSkillKeys, ","))
        end

        -- PLAYER
        do
            local s1 = Tabs.Player:AddSection("Di chuyen")
            C:Slider(s1.Frame, "Walk Speed", 16, 500, T.WalkSpeed, function(v) T.WalkSpeed = v; ApplyWalkSpeed() end)
            C:Slider(s1.Frame, "Jump Power", 50, 500, T.JumpPower, function(v) T.JumpPower = v; ApplyJumpPower() end)
            C:Toggle(s1.Frame, "Infinite Zoom", T.InfiniteZoom, function(v) T.InfiniteZoom = v; ApplyInfiniteZoom() end)
            C:Toggle(s1.Frame, "X-Ray Vision", T.XrayVision, function(v)
                T.XrayVision = v
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("BasePart") then p.LocalTransparencyModifier = v and 0.7 or 0 end
                end
            end)

            local s2 = Tabs.Player:AddSection("ESP")
            C:Toggle(s2.Frame, "ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
            C:Toggle(s2.Frame, "ESP Fruit", T.ESPFruit, function(v) T.ESPFruit = v end)
            C:Button(s2.Frame, "Xoa ESP", function() ClearESP(); Notify("ESP","Da xoa",3) end)

            local s3 = Tabs.Player:AddSection("Nhan vat")
            C:Button(s3.Frame, "Reset Nhan Vat", function()
                if Character and Character:FindFirstChild("Head") then Character.Head:Destroy() end
            end)
            C:Toggle(s3.Frame, "Remove Obs Effect", T.RemoveObservationEffect, function(v) T.RemoveObservationEffect = v end)
        end

        -- FRUIT
        do
            local s1 = Tabs.Fruit:AddSection("Auto Nhat Trai")
            C:Toggle(s1.Frame, "Auto Nhat Trai", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end, "Bay toi nhat trai")
            C:Toggle(s1.Frame, "Hop neu khong co", T.HopIfNoFruit, function(v) T.HopIfNoFruit = v end)
            C:Slider(s1.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)

            local s2 = Tabs.Fruit:AddSection("Luu Trai")
            C:Toggle(s2.Frame, "Auto Store Fruit", T.AutoStoreFruit, function(v) T.AutoStoreFruit = v end)

            local s3 = Tabs.Fruit:AddSection("Teleport Trai")
            C:Button(s3.Frame, "Tim & TP ngay", function()
                local f, d = GetNearestFruit()
                if f then
                    local h = f:FindFirstChild("Handle") or f.PrimaryPart
                    if h then TweenTo(h.CFrame + Vector3.new(0,3,0))
                        Notify("Fruit","Tim thay: "..f.Name,4) end
                else Notify("Fruit","Khong co trai!",3) end
            end)
        end

        -- CHEST
        do
            local s1 = Tabs.Chest:AddSection("Chest Farm")
            C:Toggle(s1.Frame, "Auto Chest", T.AutoChest, function(v) T.AutoChest = v; ChestCounter = 0 end, "Nhat ruong nhanh")
            C:Toggle(s1.Frame, "Hop het ruong", T.AutoHopChest, function(v) T.AutoHopChest = v end)
            C:Slider(s1.Frame, "So ruong truoc hop", 1, 50, 10, function(v) T.ChestHopCount = v end)
            C:Toggle(s1.Frame, "ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
        end

        -- ISLAND
        do
            local s1 = Tabs.Island:AddSection("TP Dao")
            local islNames = GetIslandNames()
            local selIsl = islNames[1] or "None"
            if #islNames > 0 then
                C:Dropdown(s1.Frame, "Chon dao", selIsl, islNames, function(v) selIsl = v end)
            else
                C:Label(s1.Frame, "Khong co dao trong sea nay")
            end
            C:Button(s1.Frame, "TP toi dao", function()
                local c = GetIslandList()[selIsl]
                if c then Notify("TP","Toi: "..selIsl,3); TweenTo(CFrame.new(c)) end
            end)

            local s2 = Tabs.Island:AddSection("TP Sea")
            C:Button(s2.Frame, "Sea 1", function() pcall(function() CommF:InvokeServer("TravelMain") end) end)
            C:Button(s2.Frame, "Sea 2", function() pcall(function() CommF:InvokeServer("TravelDressrosa") end) end)
            C:Button(s2.Frame, "Sea 3", function() pcall(function() CommF:InvokeServer("TravelZou") end) end)

            local s3 = Tabs.Island:AddSection("Server Hop")
            C:Button(s3.Frame, "Rejoin", function()
                pcall(function() RS.__ServerBrowser:InvokeServer("teleport", game.JobId) end)
            end)
            C:Button(s3.Frame, "Random Hop", function()
                Notify("Hop","Dang tim server...",3)
                task.spawn(function()
                    for i = 1, 100 do
                        local servers = RS.__ServerBrowser:InvokeServer(i)
                        if typeof(servers) == "table" then
                            for jobId, info in pairs(servers) do
                                if info.Count and info.Count < 12 and jobId ~= game.JobId then
                                    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", jobId) end)
                                    return
                                end
                            end
                        end
                    end
                end)
            end)
        end

        -- MACRO
        do
            local s1 = Tabs.Macro:AddSection("Combo Macro")
            C:Label(s1.Frame, "Setup combo", "VD: Z,X,C,V,F")
            C:Toggle(s1.Frame, "Bat Macro", T.MacroEnabled, function(v)
                T.MacroEnabled = v
                if v then RunMacro() else StopMacro() end
            end)
            C:Textbox(s1.Frame, "Z,X,C,V,F", function(v)
                local ks = {}
                for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end
                if #ks > 0 then T.MacroSkillKeys = ks; Notify("Macro","Da set: "..table.concat(ks," > "),3) end
            end, table.concat(T.MacroSkillKeys, ","))
            C:Slider(s1.Frame, "Giu phim (s)", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
            C:Slider(s1.Frame, "Delay giua phim", 0.05, 2, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)

            local s2 = Tabs.Macro:AddSection("Preset")
            C:Button(s2.Frame, "Z-X-C", function() T.MacroSkillKeys = {"Z","X","C"}; Notify("Macro","Preset Z-X-C",3) end)
            C:Button(s2.Frame, "Z-X-C-V-F", function() T.MacroSkillKeys = {"Z","X","C","V","F"}; Notify("Macro","Preset full",3) end)
            C:Button(s2.Frame, "Z-Z-X-X", function() T.MacroSkillKeys = {"Z","Z","X","X"}; Notify("Macro","Preset combo doi",3) end)
        end

        -- PERF
        do
            local s1 = Tabs.Perf:AddSection("Hieu Nang")
            C:Toggle(s1.Frame, "Lag Fix", T.LagFix, function(v) T.LagFix = v; ApplyLagFix(v) end, "Giam lag, 50-60 FPS")
            C:Toggle(s1.Frame, "Xoa Suong Mu", T.RemoveFog, function(v) T.RemoveFog = v; ApplyRemoveFog(v) end)
            C:Button(s1.Frame, "Don bo nho", function()
                pcall(function()
                    if collectgarbage then collectgarbage("collect") end
                    for _, o in ipairs(Workspace:GetChildren()) do
                        if o:IsA("BasePart") and (o.Name:find("Slash") or o.Name:find("Effect")) then o:Destroy() end
                    end
                end)
                Notify("Cleaner","Da don!",3)
            end)
            local s3 = Tabs.Perf:AddSection("FPS")
            local fpsL = C:Label(s3.Frame, "FPS: --")
            task.spawn(function()
                local fr, lu = 0, tick()
                RunService.RenderStepped:Connect(function()
                    fr = fr + 1
                    if tick() - lu >= 1 then
                        fpsL:Set("FPS: "..fr)
                        fr = 0; lu = tick()
                    end
                end)
            end)
        end

        -- MISC
        do
            local s1 = Tabs.Misc:AddSection("Anti-AFK")
            C:Toggle(s1.Frame, "Anti AFK", T.AntiAFK, function(v) T.AntiAFK = v end)
            local s2 = Tabs.Misc:AddSection("Server")
            C:Toggle(s2.Frame, "Auto Hop 30 phut", T.AutoHop30Min, function(v) T.AutoHop30Min = v end)
            C:Slider(s2.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)
            local s3 = Tabs.Misc:AddSection("Team")
            C:Button(s3.Frame, "Pirates", function() pcall(function() CommF:InvokeServer("SetTeam","Pirates") end) end)
            C:Button(s3.Frame, "Marines", function() pcall(function() CommF:InvokeServer("SetTeam","Marines") end) end)
            local s4 = Tabs.Misc:AddSection("Codes")
            C:Button(s4.Frame, "Redeem Codes", function()
                Notify("Codes","Dang redeem...",3)
                task.spawn(function()
                    local codes = {"SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","KITTGAMING","FUDDSM0NEY","GAMER_ROBOT_1M"}
                    for _, cd in ipairs(codes) do
                        pcall(function() Remotes.Redeem:InvokeServer(cd) end)
                        task.wait(0.5)
                    end
                    Notify("Codes","Da thu "..#codes.." codes!",5)
                end)
            end)
        end

        -- WEBHOOK
        do
            local s1 = Tabs.Webhook:AddSection("Discord Webhook")
            C:Label(s1.Frame, "Gui thong bao ve Discord", "Dan URL webhook")
            C:Textbox(s1.Frame, "https://discord.com/api/webhooks/...", function(v) T.Webhook = v end, T.Webhook)
            C:Toggle(s1.Frame, "Bat Webhook", T.WebhookEnabled, function(v) T.WebhookEnabled = v end)
            C:Button(s1.Frame, "Test Webhook", function()
                if T.Webhook == "" then Notify("Webhook","Chua co URL!",3); return end
                SendWebhook("Blox Community VN", "Test OK!\nUser: **"..LocalPlayer.Name.."**")
                Notify("Webhook","Da gui test!",3)
            end)
        end

        -- CREDIT
        do
            local s1 = Tabs.Credit:AddSection("Thong Tin")
            C:Label(s1.Frame, "Blox Community VN", "Full Rebuild v3.1")
            C:Label(s1.Frame, "Tac gia", "Dungdx")
            C:Label(s1.Frame, "Discord", "discord.gg/Hwwa3VYxW6")
            local s2 = Tabs.Credit:AddSection("Links")
            C:Button(s2.Frame, "Copy Discord Link", function()
                pcall(function() setclipboard("https://discord.gg/Hwwa3VYxW6") end)
                Notify("Credit","Da copy!",3)
            end)
        end

        -- ==================== LOOPS ====================
        task.spawn(function()
            while task.wait(T.FastAttackDelay or 0) do
                if T.FastAttack then pcall(FastAttack) end
            end
        end)
        task.spawn(function()
            while task.wait(0.5) do
                if T.BringMonster then pcall(BringMonsters) end
            end
        end)
        task.spawn(function()
            while task.wait(0.2) do
                if T.AutoChest then pcall(AutoChestLoop) end
            end
        end)
        task.spawn(function()
            while task.wait(0.3) do
                if T.AutoFruitFarm then pcall(AutoFruitLoop) end
            end
        end)
        task.spawn(function()
            while task.wait(0.5) do
                if T.AutoFarm or T.AutoFarmBones or T.AutoFarmBoss or T.AutoKillAllBosses then
                    pcall(function()
                        local targets = GetEnemies(T.checknearestdist or 1500)
                        if #targets > 0 then
                            local tH = targets[1][2]
                            local d = targets[1][3]
                            if d > 30 then TweenTo(CFrame.new(tH.Position + Vector3.new(0, T.PosY or 18, 0))) end
                            EquipWeaponType(T.SelectWeapon)
                        end
                    end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(1) do
                if T.ESPChest or T.ESPFruit then pcall(UpdateESP) end
            end
        end)
        task.spawn(function()
            while task.wait(1) do
                if Humanoid then pcall(ApplyWalkSpeed); pcall(ApplyJumpPower) end
            end
        end)
        task.spawn(function()
            while task.wait(2) do
                if T.AutoStoreFruit then
                    pcall(function()
                        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                local nm = tool:GetAttribute("OriginalName") or tool.Name:match("^(.-)%-") or tool.Name
                                pcall(function() CommF:InvokeServer("StoreFruit", nm, tool) end)
                            end
                        end
                    end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(60) do
                if T.AntiAFK then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0,0))
                    end)
                end
            end
        end)
        local startT = tick()
        task.spawn(function()
            while task.wait(30) do
                if T.AutoHop30Min and tick() - startT >= 1800 then
                    startT = tick()
                    Notify("Hop","30 phut roi, dang hop...",5)
                    pcall(function()
                        RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
                    end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(5) do
                if T.LagFix then
                    pcall(function() Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9 end)
                end
                if T.RemoveFog then pcall(ApplyRemoveFog, true) end
            end
        end)

        -- Notify khởi động
        task.spawn(function()
            task.wait(1)
            Notify("Blox Community VN","Load thanh cong!\nDungdx | discord.gg/Hwwa3VYxW6", 8)
            task.wait(2)
            Notify("Huong dan","Nut 'Dx' trai man hinh de an/hien UI.\nKeo duoc nut nay.", 8)
        end)

        print("[BCVN] BACKEND LOAD XONG! Moi tinh nang san sang.")
    end)
    if not ok then
        warn("[BCVN] LOI BACKEND (UI van hien):", tostring(err))
        Notify("Loi backend", tostring(err):sub(1,80), 10)
    end
end)

getgenv().BloxCommunityVN_Loaded = true
print("[BCVN] ========== SCRIPT SAN SANG ==========")
return "Blox Community VN v3.1 - Fixed"