--[[
    Blox Community VN - Full Rebuild v3
    Author: Dungdx
    Discord: https://discord.gg/Hwwa3VYxW6
    Theme: Mystic Blue (Xanh dương huyền ảo)
    Features: Auto Farm, Fast Attack, Chest, Fruit, Macro, Lag Fix, ESP, Webhook, v.v.
--]]

--============================================================
-- 1. BẢO VỆ & KHỞI TẠO
--============================================================
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UIS = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local Lighting = cloneref(game:GetService("Lighting"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local HttpService = cloneref(game:GetService("HttpService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer

-- Chống load trùng
if getgenv().BloxCommunityVN_Loaded then
    return warn("[Blox Community VN] Script đã chạy rồi!")
end
getgenv().BloxCommunityVN_Loaded = true

--============================================================
-- 2. CONFIG MẶC ĐỊNH
--============================================================
local Config = {
    -- Auto Farm
    AutoFarm = false,
    AutoFarmBones = false,
    AutoFarmBoss = false,
    AutoKillAllBosses = false,
    AutoFarmMaterial = false,
    AutoFarmPrince = false,
    AutoDoughKing = false,
    AutoFarmSeaEvents = false,
    AutoTyrantOfTheSkies = false,
    AutoChest = false,
    AutoMaterial = false,
    
    -- Combat
    FastAttack = true,
    FastAttackDelay = 0,
    AttackMethod = "Fast Attack",  -- Fast Attack / Legit Attack
    AutoAttackGun = true,
    BringMonster = true,
    BringMonsterRadius = 350,
    PosY = 18,
    PosMethod = "Above",
    SelectWeapon = "Melee",
    
    -- Movement
    WalkSpeed = 50,
    JumpPower = 50,
    InfiniteZoom = false,
    XrayVision = false,
    
    -- Visual
    NoFog = false,
    RemoveObservationEffect = false,
    ESPPlayer = false,
    ESPChest = false,
    ESPFruit = false,
    ESPIsland = false,
    ESPBerry = false,
    
    -- Fruit
    AutoStoreFruit = false,
    TweenFruit = false,
    AutoFruitFarm = false,   -- TÍNH NĂNG MỚI: Auto nhặt trái
    HopIfNoFruit = false,
    
    -- Server
    HopDelay = 10,
    AutoHop30Min = false,
    
    -- Performance
    LagFix = false,          -- TÍNH NĂNG MỚI: Fix lag bật/tắt
    AutoFastMode = false,
    RemoveFog = false,       -- TÍNH NĂNG: Xóa sương mù bật/tắt
    
    -- Webhook
    Webhook = "",
    WebhookEnabled = false,
    
    -- Misc
    AntiAFK = true,
    TeamSelectLoad = "Pirates",
    
    -- Macro (TÍNH NĂNG MỚI)
    MacroEnabled = false,
    MacroSkillKeys = {"Z", "X", "C", "V", "F"},
    MacroDelay = 0.5,
    MacroDelayBetween = 0.15,
    
    -- Tween
    TweenSpeed = 250,
    BoatSpeed = 230,
    BypassTP = true,
    ForceAnchoredY = false,
}

-- Lưu vào getgenv để dễ truy cập
getgenv().BloxCommunityVN_Config = Config
local T = Config  -- alias ngắn

--============================================================
-- 3. LAG FIX FUNCTION (TÍNH NĂNG MỚI - BẬT/TẮT ĐƯỢC)
--============================================================
local function ApplyLagFix(enabled)
    pcall(function()
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = enabled and 0 or 0.15
            Terrain.WaterWaveSpeed = enabled and 0 or 10
            Terrain.WaterReflectance = enabled and 0 or 0.1
            Terrain.WaterTransparency = enabled and 0 or 0.1
        end
        Lighting.GlobalShadows = not enabled
        Lighting.FogEnd = enabled and 9e9 or 100000
        
        for _, d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
               or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                d.Enabled = not enabled
            end
        end
        
        if enabled then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

--============================================================
-- 4. XÓA SƯƠNG MÙ (BẬT/TẮT)
--============================================================
local function ApplyRemoveFog(enabled)
    pcall(function()
        if enabled then
            Lighting.FogEnd = math.huge
            Lighting.FogStart = 0
            Lighting.FogColor = Color3.new(0.5, 0.5, 0.5)
            for _, name in ipairs({"FantasySky", "Sky", "LightingLayers", "SeaTerrorCC", "Atmosphere"}) do
                local obj = Lighting:FindFirstChild(name)
                if obj then obj:Destroy() end
            end
        end
    end)
end

--============================================================
-- 5. UI STANDALONE - MYSTIC BLUE THEME
--============================================================
local function CreateUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Xóa UI cũ nếu có
    local oldUI = playerGui:FindFirstChild("BloxCommunityVN")
    if oldUI then oldUI:Destroy() end
    
    -- === THEME MYSTIC BLUE ===
    local Theme = {
        -- Nền chính - xanh đen huyền ảo
        Bg           = Color3.fromRGB(8, 12, 24),
        Panel        = Color3.fromRGB(14, 22, 42),
        Card         = Color3.fromRGB(20, 30, 55),
        CardHover    = Color3.fromRGB(28, 42, 72),
        Card2        = Color3.fromRGB(25, 38, 65),
        
        -- Viền & accent xanh dương
        Stroke       = Color3.fromRGB(60, 130, 220),
        Accent       = Color3.fromRGB(0, 170, 255),
        AccentDark   = Color3.fromRGB(0, 110, 190),
        AccentGlow   = Color3.fromRGB(100, 200, 255),
        AccentSoft   = Color3.fromRGB(40, 90, 160),
        
        -- Text
        Text         = Color3.fromRGB(230, 240, 255),
        Dim          = Color3.fromRGB(140, 170, 210),
        Green        = Color3.fromRGB(80, 220, 140),
        Red          = Color3.fromRGB(240, 90, 90),
        Yellow       = Color3.fromRGB(255, 210, 80),
    }
    
    -- === ROOT GUI ===
    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxCommunityVN"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui
    
    -- === NÚT TOGGLE "Dx" (KÉO ĐƯỢC) ===
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "DxToggle"
    toggleBtn.Size = UDim2.fromOffset(50, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    toggleBtn.BackgroundColor3 = Theme.AccentDark
    toggleBtn.Text = "Dx"
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 20
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.Draggable = true  -- Cho phép kéo
    toggleBtn.Parent = gui
    
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(1, 0)
    
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Color = Theme.AccentGlow
    toggleStroke.Thickness = 2
    
    -- Hiệu ứng glow
    local toggleGradient = Instance.new("UIGradient", toggleBtn)
    toggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentDark),
    })
    toggleGradient.Rotation = 45
    
    -- === MAIN WINDOW ===
    local root = Instance.new("Frame")
    root.Name = "MainWindow"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromOffset(640, 420)
    root.BackgroundColor3 = Theme.Bg
    root.BorderSizePixel = 0
    root.Visible = true
    root.Parent = gui
    
    local rootCorner = Instance.new("UICorner", root)
    rootCorner.CornerRadius = UDim.new(0, 12)
    
    local rootStroke = Instance.new("UIStroke", root)
    rootStroke.Color = Theme.Stroke
    rootStroke.Thickness = 1.5
    
    -- Hiệu ứng gradient nền
    local bgGradient = Instance.new("UIGradient", root)
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Bg),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 20, 38)),
        ColorSequenceKeypoint.new(1, Theme.Bg),
    })
    bgGradient.Rotation = 135
    
    local scale = Instance.new("UIScale", root)
    scale.Scale = 1
    
    -- Fit scale theo màn hình
    local cam = Workspace.CurrentCamera
    local function fitScale()
        local vp = cam and cam.ViewportSize or Vector2.new(1000, 600)
        local sx = math.clamp((vp.X - 40) / 640, 0.6, 1.1)
        local sy = math.clamp((vp.Y - 100) / 420, 0.6, 1.1)
        scale.Scale = math.min(sx, sy)
    end
    fitScale()
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)
    end
    
    -- === TOP BAR ===
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Theme.Panel
    topBar.BorderSizePixel = 0
    topBar.Parent = root
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
    
    -- Che góc dưới topbar
    local topBarCover = Instance.new("Frame")
    topBarCover.Size = UDim2.new(1, 0, 0, 12)
    topBarCover.Position = UDim2.new(0, 0, 1, -12)
    topBarCover.BackgroundColor3 = Theme.Panel
    topBarCover.BorderSizePixel = 0
    topBarCover.Parent = topBar
    
    -- Logo Dx
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(50, 40)
    logo.Position = UDim2.fromOffset(12, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "Dx"
    logo.Font = Enum.Font.GothamBlack
    logo.TextColor3 = Theme.AccentGlow
    logo.TextSize = 20
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(60, 5)
    title.Size = UDim2.fromOffset(200, 16)
    title.BackgroundTransparency = 1
    title.Text = "Blox Community VN"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Theme.Text
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(60, 22)
    subtitle.Size = UDim2.fromOffset(240, 12)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by Dungdx  •  discord.gg/Hwwa3VYxW6"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Theme.Dim
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = topBar
    
    -- Nút close & minimize
    local function makeTopBtn(text, xPos, w)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(w or 30, 24)
        b.Position = UDim2.new(1, xPos, 0, 8)
        b.BackgroundColor3 = Theme.Card
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Theme.Text
        b.TextSize = 13
        b.AutoButtonColor = false
        b.Parent = topBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.CardHover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Card end)
        return b
    end
    
    local closeBtn = makeTopBtn("×", -38, 30)
    local minBtn = makeTopBtn("—", -70, 30)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    
    -- === DRAG WINDOW ===
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle UI
    toggleBtn.MouseButton1Click:Connect(function()
        root.Visible = not root.Visible
    end)
    
    -- Kéo nút Dx
    local dxDragging, dxStart, dxStartPos
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dxDragging = true
            dxStart = input.Position
            dxStartPos = toggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dxDragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dxDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dxStart
            toggleBtn.Position = UDim2.new(
                dxStartPos.X.Scale, dxStartPos.X.Offset + delta.X,
                dxStartPos.Y.Scale, dxStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- === TAB BAR ===
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Name = "TabBar"
    tabBar.Position = UDim2.fromOffset(10, 46)
    tabBar.Size = UDim2.new(1, -20, 0, 32)
    tabBar.BackgroundColor3 = Theme.Panel
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.CanvasSize = UDim2.fromOffset(0, 0)
    tabBar.Parent = root
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)
    
    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPad = Instance.new("UIPadding", tabBar)
    tabPad.PaddingLeft = UDim.new(0, 4)
    tabPad.PaddingTop = UDim.new(0, 4)
    
    -- === CONTENT AREA ===
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(10, 84)
    content.Size = UDim2.new(1, -20, 1, -94)
    content.BackgroundTransparency = 1
    content.Parent = root
    
    -- === CÁC HÀM TIỆN ÍCH UI ===
    local function makeCorner(obj, r)
        local c = Instance.new("UICorner", obj)
        c.CornerRadius = UDim.new(0, r or 6)
        return c
    end
    
    local function makeStroke(obj, color, thickness)
        local s = Instance.new("UIStroke", obj)
        s.Color = color or Theme.Stroke
        s.Thickness = thickness or 1
        return s
    end
    
    -- === TAB MANAGEMENT ===
    local Tabs = {}
    local ActiveTab = nil
    
    local tabIcons = {
        Home      = "⌂",
        Farm      = "▦",
        Combat    = "⚔",
        Player    = "♙",
        Fruit     = "◈",
        Chest     = "▣",
        Island    = "⌖",
        Macro     = "☰",
        Perf      = "⚡",
        Misc      = "⚙",
        Webhook   = "✉",
        Credit    = "★",
    }
    
    -- Thứ tự tab theo yêu cầu
    local TabOrder = {
        "Home", "Farm", "Combat", "Player", "Fruit", "Chest", "Island",
        "Macro", "Perf", "Misc", "Webhook", "Credit",
    }
    
    local function CreateTab(name)
        -- Tab frame
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.Parent = content
        
        -- Chia 2 cột
        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Name = "Left"
        leftCol.Size = UDim2.new(0.5, -5, 1, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.BorderSizePixel = 0
        leftCol.ScrollBarThickness = 3
        leftCol.ScrollBarImageColor3 = Theme.Accent
        leftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        leftCol.CanvasSize = UDim2.fromOffset(0, 0)
        leftCol.Parent = frame
        
        local rightCol = Instance.new("ScrollingFrame")
        rightCol.Name = "Right"
        rightCol.Size = UDim2.new(0.5, -5, 1, 0)
        rightCol.Position = UDim2.new(0.5, 5, 0, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.BorderSizePixel = 0
        rightCol.ScrollBarThickness = 3
        rightCol.ScrollBarImageColor3 = Theme.Accent
        rightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        rightCol.CanvasSize = UDim2.fromOffset(0, 0)
        rightCol.Parent = frame
        
        local lLayout = Instance.new("UIListLayout", leftCol)
        lLayout.SortOrder = Enum.SortOrder.LayoutOrder
        lLayout.Padding = UDim.new(0, 6)
        
        local rLayout = Instance.new("UIListLayout", rightCol)
        rLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rLayout.Padding = UDim.new(0, 6)
        
        -- Tab button
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.fromOffset(80, 24)
        btn.BackgroundColor3 = Theme.Card
        btn.Text = (tabIcons[name] or "•") .. "  " .. name
        btn.Font = Enum.Font.GothamSemibold
        btn.TextColor3 = Theme.Dim
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = tabBar
        makeCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            if ActiveTab ~= name then
                btn.BackgroundColor3 = Theme.CardHover
            end
        end)
        btn.MouseLeave:Connect(function()
            if ActiveTab ~= name then
                btn.BackgroundColor3 = Theme.Card
            end
        end)
        
        btn.MouseButton1Click:Connect(function()
            if ActiveTab == name then return end
            for tabName, tabData in pairs(Tabs) do
                tabData.Frame.Visible = false
                tabData.Button.BackgroundColor3 = Theme.Card
                tabData.Button.TextColor3 = Theme.Dim
            end
            frame.Visible = true
            btn.BackgroundColor3 = Theme.AccentDark
            btn.TextColor3 = Theme.Text
            ActiveTab = name
        end)
        
        local tabObj = {
            Frame = frame,
            Button = btn,
            Left = leftCol,
            Right = rightCol,
            _columnToggle = false,
            _order = 0,
        }
        
        -- Chọn cột (xoay vòng trái/phải)
        function tabObj:GetColumn()
            self._columnToggle = not self._columnToggle
            return self._columnToggle and self.Left or self.Right
        end
        
        -- Thêm section (nhóm chức năng)
        function tabObj:AddSection(sectionName)
            local col = self:GetColumn()
            self._order = self._order + 1
            
            local section = Instance.new("Frame")
            section.Name = sectionName or "Section"
            section.Size = UDim2.new(1, -2, 0, 0)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BackgroundColor3 = Theme.Card
            section.BorderSizePixel = 0
            section.LayoutOrder = self._order
            section.Parent = col
            makeCorner(section, 8)
            makeStroke(section, Color3.fromRGB(40, 70, 120), 1)
            
            -- Header
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 26)
            header.BackgroundTransparency = 1
            header.Parent = section
            
            local accentBar = Instance.new("Frame")
            accentBar.Size = UDim2.fromOffset(20, 3)
            accentBar.Position = UDim2.fromOffset(10, 11)
            accentBar.BackgroundColor3 = Theme.Accent
            accentBar.BorderSizePixel = 0
            accentBar.Parent = header
            makeCorner(accentBar, 2)
            
            local titleLbl = Instance.new("TextLabel")
            titleLbl.Position = UDim2.fromOffset(36, 5)
            titleLbl.Size = UDim2.new(1, -40, 0, 16)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = sectionName
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextColor3 = Theme.AccentGlow
            titleLbl.TextSize = 11
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = header
            
            -- Body
            local body = Instance.new("Frame")
            body.Position = UDim2.fromOffset(8, 28)
            body.Size = UDim2.new(1, -16, 0, 0)
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.BackgroundTransparency = 1
            body.Parent = section
            
            local bodyLayout = Instance.new("UIListLayout", body)
            bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodyLayout.Padding = UDim.new(0, 4)
            
            bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Size = UDim2.new(1, -2, 0, 28 + bodyLayout.AbsoluteContentSize.Y + 8)
            end)
            
            return { Frame = body, Section = section }
        end
        
        Tabs[name] = tabObj
        return tabObj
    end
    
    -- Tạo tất cả tab theo thứ tự
    for _, name in ipairs(TabOrder) do
        CreateTab(name)
    end
    
    -- Active tab đầu tiên
    Tabs.Home.Frame.Visible = true
    Tabs.Home.Button.BackgroundColor3 = Theme.AccentDark
    Tabs.Home.Button.TextColor3 = Theme.Text
    ActiveTab = "Home"
    
    -- === COMPONENT FACTORY ===
    local Components = {}
    
    -- Label
    function Components:Label(parent, text, desc)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, desc and 30 or 18)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.GothamSemibold
        l.TextColor3 = Theme.Dim
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = frame
        
        local d
        if desc then
            d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(0, 15)
            d.Size = UDim2.new(1, 0, 0, 15)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.Font = Enum.Font.Gotham
            d.TextColor3 = Theme.Text
            d.TextSize = 10
            d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = frame
        end
        
        return {
            Set = function(_, txt) if d then d.Text = txt end end,
        }
    end
    
    -- Toggle (nút gạt)
    function Components:Toggle(parent, text, default, callback, desc)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, desc and 38 or 26)
        row.BackgroundTransparency = 1
        row.Parent = parent
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -55, 0, 14)
        l.Position = UDim2.fromOffset(2, 2)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.GothamSemibold
        l.TextColor3 = Theme.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        
        if desc then
            local d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(2, 16)
            d.Size = UDim2.new(1, -55, 0, 20)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.Font = Enum.Font.Gotham
            d.TextColor3 = Theme.Dim
            d.TextSize = 8
            d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = row
        end
        
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.fromOffset(40, 18)
        pill.Position = UDim2.new(1, -44, 0, 4)
        pill.BackgroundColor3 = default and Theme.AccentDark or Color3.fromRGB(45, 55, 75)
        pill.Text = ""
        pill.AutoButtonColor = false
        pill.Parent = row
        makeCorner(pill, 9)
        makeStroke(pill, default and Theme.AccentGlow or Theme.Stroke, 1)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(13, 13)
        knob.BackgroundColor3 = Color3.fromRGB(230, 240, 255)
        knob.BorderSizePixel = 0
        knob.Position = default and UDim2.new(1, -15, 0, 2) or UDim2.fromOffset(2, 2)
        knob.Parent = pill
        makeCorner(knob, 7)
        
        local state = default and true or false
        local function paint()
            if state then
                pill.BackgroundColor3 = Theme.AccentDark
                pill.UIStroke.Color = Theme.AccentGlow
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -15, 0, 2)}):Play()
            else
                pill.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
                pill.UIStroke.Color = Theme.Stroke
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(2, 2)}):Play()
            end
        end
        
        pill.MouseButton1Click:Connect(function()
            state = not state
            paint()
            if callback then pcall(callback, state) end
        end)
        
        return {
            Set = function(_, v)
                state = not not v
                paint()
                if callback then pcall(callback, state) end
            end,
            Get = function() return state end,
        }
    end
    
    -- Button
    function Components:Button(parent, text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 26)
        b.BackgroundColor3 = Theme.Card2
        b.Text = text
        b.Font = Enum.Font.GothamSemibold
        b.TextColor3 = Theme.Text
        b.TextSize = 10
        b.AutoButtonColor = false
        b.Parent = parent
        makeCorner(b, 6)
        makeStroke(b, Theme.Stroke, 1)
        
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.AccentSoft end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Card2 end)
        b.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)
        
        return b
    end
    
    -- Slider
    function Components:Slider(parent, text, min, max, default, callback, step)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundTransparency = 1
        row.Parent = parent
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 0, 14)
        l.Position = UDim2.fromOffset(2, 2)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.GothamSemibold
        l.TextColor3 = Theme.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.35, 0, 0, 14)
        valLbl.Position = UDim2.new(0.65, 0, 0, 2)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(default)
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextColor3 = Theme.AccentGlow
        valLbl.TextSize = 10
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = row
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -4, 0, 6)
        track.Position = UDim2.fromOffset(2, 22)
        track.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
        track.BorderSizePixel = 0
        track.Parent = row
        makeCorner(track, 3)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        makeCorner(fill, 3)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(10, 10)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Theme.AccentGlow
        knob.BorderSizePixel = 0
        knob.Parent = track
        makeCorner(knob, 5)
        
        local cur = tonumber(default) or min
        local lo, hi = tonumber(min), tonumber(max)
        local st = tonumber(step) or 0
        
        local function setVal(v, fire)
            v = math.clamp(v, lo, hi)
            if st > 0 then v = math.floor((v - lo) / st + 0.5) * st + lo end
            cur = v
            local t = (hi - lo) == 0 and 0 or (v - lo) / (hi - lo)
            fill.Size = UDim2.new(t, 0, 1, 0)
            knob.Position = UDim2.new(t, 0, 0.5, 0)
            valLbl.Text = tostring(v)
            if fire and callback then pcall(callback, v) end
        end
        
        setVal(cur, false)
        
        local draggingSlider = false
        local function update(input)
            local x = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local t = track.AbsoluteSize.X == 0 and 0 or x / track.AbsoluteSize.X
            setVal(lo + (hi - lo) * t, true)
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                update(input)
            end
        end)
        track.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)
        
        return {
            Set = function(_, v) setVal(tonumber(v) or cur, false) end,
            Get = function() return cur end,
        }
    end
    
    -- Dropdown
    function Components:Dropdown(parent, text, default, options, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = parent
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.4, 0, 1, 0)
        l.Position = UDim2.fromOffset(2, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.GothamSemibold
        l.TextColor3 = Theme.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.6, -4, 1, 0)
        btn.Position = UDim2.new(0.4, 0, 0, 0)
        btn.BackgroundColor3 = Theme.Card2
        btn.Text = tostring(default or "None")
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = Theme.Text
        btn.TextSize = 9
        btn.AutoButtonColor = false
        btn.Parent = row
        makeCorner(btn, 5)
        makeStroke(btn, Theme.Stroke, 1)
        
        local list = type(options) == "table" and options or {}
        local current = default
        
        local popup
        local function closePopup() if popup then popup:Destroy(); popup = nil end end
        local function openPopup()
            closePopup()
            popup = Instance.new("Frame")
            popup.Size = UDim2.new(0, 160, 0, math.min(180, 22 * #list + 6))
            popup.Position = UDim2.new(1, -160, 0, 28)
            popup.BackgroundColor3 = Theme.Panel
            popup.ZIndex = 100
            popup.Parent = row
            makeCorner(popup, 6)
            makeStroke(popup, Theme.Accent, 1)
            
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.fromScale(1, 1)
            sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0
            sc.ScrollBarThickness = 2
            sc.ScrollBarImageColor3 = Theme.Accent
            sc.ZIndex = 101
            sc.Parent = popup
            
            local ll = Instance.new("UIListLayout", sc)
            ll.Padding = UDim.new(0, 2)
            
            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, -6, 0, 20)
                ob.Position = UDim2.fromOffset(3, 0)
                ob.BackgroundColor3 = Theme.Card
                ob.Text = tostring(opt)
                ob.Font = Enum.Font.Gotham
                ob.TextColor3 = Theme.Text
                ob.TextSize = 9
                ob.AutoButtonColor = false
                ob.ZIndex = 102
                ob.Parent = sc
                makeCorner(ob, 4)
                
                ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Theme.AccentSoft end)
                ob.MouseLeave:Connect(function() ob.BackgroundColor3 = Theme.Card end)
                ob.MouseButton1Click:Connect(function()
                    current = opt
                    btn.Text = tostring(opt)
                    closePopup()
                    if callback then pcall(callback, opt) end
                end)
            end
            
            sc.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + 6)
        end
        
        btn.MouseButton1Click:Connect(openPopup)
        
        return {
            Set = function(_, v)
                current = v
                btn.Text = tostring(v)
                if callback then pcall(callback, v) end
            end,
            Refresh = function(_, newList)
                list = type(newList) == "table" and newList or {}
                current = list[1]
                btn.Text = tostring(current or "None")
            end,
        }
    end
    
    -- Textbox
    function Components:Textbox(parent, placeholder, callback, default)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = parent
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.fromScale(1, 1)
        box.BackgroundColor3 = Theme.Card2
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Theme.Dim
        box.Font = Enum.Font.Gotham
        box.TextColor3 = Theme.Text
        box.TextSize = 9
        box.ClearTextOnFocus = false
        box.Parent = row
        makeCorner(box, 5)
        makeStroke(box, Theme.Stroke, 1)
        
        box.FocusLost:Connect(function()
            if callback then pcall(callback, box.Text) end
        end)
        
        return {
            Set = function(_, v) box.Text = tostring(v or "") end,
            Get = function() return box.Text end,
        }
    end
    
    -- Notification
    local notifHolder
    local function Notify(title, desc, duration)
        if not notifHolder then
            notifHolder = Instance.new("Frame")
            notifHolder.Name = "Notifs"
            notifHolder.Size = UDim2.fromOffset(240, 400)
            notifHolder.Position = UDim2.new(1, -252, 0, 60)
            notifHolder.BackgroundTransparency = 1
            notifHolder.Parent = gui
            
            local ll = Instance.new("UIListLayout", notifHolder)
            ll.Padding = UDim.new(0, 6)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
        end
        
        local n = Instance.new("Frame")
        n.Size = UDim2.fromOffset(240, 56)
        n.BackgroundColor3 = Theme.Panel
        n.BorderSizePixel = 0
        n.Parent = notifHolder
        makeCorner(n, 8)
        makeStroke(n, Theme.Accent, 1)
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.fromOffset(3, 56)
        accent.BackgroundColor3 = Theme.AccentGlow
        accent.BorderSizePixel = 0
        accent.Parent = n
        makeCorner(accent, 2)
        
        local t = Instance.new("TextLabel")
        t.Position = UDim2.fromOffset(12, 8)
        t.Size = UDim2.new(1, -20, 0, 15)
        t.BackgroundTransparency = 1
        t.Text = tostring(title or "Thông báo")
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = Theme.AccentGlow
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = n
        
        local d = Instance.new("TextLabel")
        d.Position = UDim2.fromOffset(12, 24)
        d.Size = UDim2.new(1, -20, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = tostring(desc or "")
        d.Font = Enum.Font.Gotham
        d.TextColor3 = Theme.Text
        d.TextSize = 9
        d.TextWrapped = true
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = n
        
        task.delay(duration or 5, function()
            pcall(function() n:Destroy() end)
        end)
    end
    
    return {
        Gui = gui,
        Root = root,
        Tabs = Tabs,
        Components = Components,
        Theme = Theme,
        Notify = Notify,
        ToggleBtn = toggleBtn,
    }
end

local UI = CreateUI()
local Tabs = UI.Tabs
local C = UI.Components
local Theme = UI.Theme

local function Notify(title, desc, dur)
    pcall(function() UI.Notify(title, desc, dur) end)
end

print("[Blox Community VN] UI khởi tạo thành công!")