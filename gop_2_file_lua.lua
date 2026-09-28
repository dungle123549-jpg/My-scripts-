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

--============================================================
-- 6. SETUP SERVICES & REMOTES
--============================================================
local RS = ReplicatedStorage
local Remotes = RS:WaitForChild("Remotes", 30)
local Net = RS:WaitForChild("Modules"):WaitForChild("Net", 10)
local CommF = Remotes:WaitForChild("CommF_", 10)
local CommE = Remotes:WaitForChild("CommE", 10)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local HRP = Character:WaitForChild("HumanoidRootPart", 10)
local Data = LocalPlayer:WaitForChild("Data", 30)
local Level = Data:WaitForChild("Level")
local Beli = Data:WaitForChild("Beli")
local Fragments = Data:WaitForChild("Fragments")

local Enemies = Workspace:WaitForChild("Enemies", 30)
local SeaBeasts = Workspace:WaitForChild("SeaBeasts", 30)
local ChestModels = Workspace:FindFirstChild("ChestModels")
local WorldOrigin = Workspace:WaitForChild("_WorldOrigin", 30)
local Locations = WorldOrigin:WaitForChild("Locations")

local MapAttr = Workspace:GetAttribute("MAP")
local IsSea1 = MapAttr == "Sea1"
local IsSea2 = MapAttr == "Sea2"
local IsSea3 = MapAttr == "Sea3"

-- Cập nhật khi respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid", 10)
    HRP = newChar:WaitForChild("HumanoidRootPart", 10)
end)

print("[Blox Community VN] Remotes đã setup. Sea:", MapAttr)

--============================================================
-- 7. TWEEN MANAGER (di chuyển nhanh, không lag)
--============================================================
local TweenState = {
    Active = false,
    Cancel = false,
    BodyVel = nil,
    Gen = 0,
}

local function StopTween()
    TweenState.Cancel = true
    TweenState.Gen = TweenState.Gen + 1
    if TweenState.BodyVel and TweenState.BodyVel.Parent then
        pcall(function() TweenState.BodyVel:Destroy() end)
    end
    TweenState.BodyVel = nil
    if HRP then
        local bv = HRP:FindFirstChild("DxTween")
        if bv then bv:Destroy() end
    end
    TweenState.Active = false
end

local function TweenTo(targetCFrame, keepVel)
    if not HRP or not HRP.Parent then return end
    if typeof(targetCFrame) == "Vector3" then
        targetCFrame = CFrame.new(targetCFrame)
    end
    if typeof(targetCFrame) ~= "CFrame" then return end
    
    TweenState.Cancel = false
    TweenState.Gen = TweenState.Gen + 1
    local myGen = TweenState.Gen
    TweenState.Active = true
    
    local startCF = HRP.CFrame
    local distance = (targetCFrame.Position - startCF.Position).Magnitude
    if distance < 5 then
        HRP.CFrame = targetCFrame
        TweenState.Active = false
        return
    end
    
    -- BodyVelocity di chuyển mượt, không bị đứng hình
    if not TweenState.BodyVel or not TweenState.BodyVel.Parent then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "DxTween"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.P = 10000
        bv.Parent = HRP
        TweenState.BodyVel = bv
    end
    
    local speed = T.TweenSpeed or 250
    local steps = math.clamp(math.ceil(distance / (speed * 0.02)), 3, 500)
    local startPos = startCF.Position
    
    for i = 1, steps do
        if TweenState.Gen ~= myGen or TweenState.Cancel then break end
        if not HRP or not HRP.Parent then break end
        
        local alpha = i / steps
        local newPos = startPos:Lerp(targetCFrame.Position, alpha)
        TweenState.BodyVel.Velocity = (newPos - HRP.Position) * 60
        
        if distance > 50 then
            HRP.CFrame = CFrame.new(HRP.Position:Lerp(targetCFrame.Position, alpha * 0.3), HRP.Position + (targetCFrame.Position - HRP.Position).Unit)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if TweenState.Gen == myGen then
        pcall(function()
            HRP.CFrame = targetCFrame
            if TweenState.BodyVel then TweenState.BodyVel.Velocity = Vector3.zero end
        end)
        if not keepVel and TweenState.BodyVel then
            TweenState.BodyVel:Destroy()
            TweenState.BodyVel = nil
        end
        TweenState.Active = false
    end
end

--============================================================
-- 8. FAST ATTACK (HOẠT ĐỘNG THỰC SỰ)
--============================================================
local function GetEnemies(range)
    range = range or 2000
    local list = {}
    if not HRP then return list end
    local myPos = HRP.Position
    
    for _, mob in ipairs(Enemies:GetChildren()) do
        local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if mobHRP and mobHum and mobHum.Health > 0 then
            local dist = (mobHRP.Position - myPos).Magnitude
            if dist <= range then
                table.insert(list, {mob, mobHRP, dist, mobHum})
            end
        end
    end
    
    table.sort(list, function(a, b) return a[3] < b[3] end)
    return list
end

local function GetEquippedWeapon()
    if not Character then return nil end
    return Character:FindFirstChildOfClass("Tool")
end

local function EquipWeaponType(toolTip)
    if not Humanoid or not Character then return end
    local current = Character:FindFirstChildOfClass("Tool")
    if current and current.ToolTip == toolTip then return end
    
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == toolTip then
            Humanoid:EquipTool(tool)
            task.wait(0.05)
            return tool
        end
    end
end

-- Fast Attack thật sự - gửi remote liên tục
local function FastAttack()
    if not T.FastAttack then return end
    if not Character or not Humanoid or Humanoid.Health <= 0 then return end
    
    local tool = GetEquippedWeapon()
    if not tool then return end
    
    if T.SelectWeapon == "Gun" and tool.ToolTip == "Gun" then
        local remote = tool:FindFirstChild("RemoteEvent")
        local targets = GetEnemies(500)
        if #targets > 0 then
            local targetPos = targets[1][2].Position
            if remote then
                pcall(function() remote:FireServer("TAP", targetPos) end)
            end
            local shootRemote = Net:FindFirstChild("RE/ShootGunEvent")
            if shootRemote then
                pcall(function() shootRemote:FireServer(targetPos, {targets[1][2]}) end)
            end
        end
        return
    end
    
    -- Melee / Sword / Fruit
    local leftClick = tool:FindFirstChild("LeftClickRemote")
    local targets = GetEnemies(200)
    
    if #targets > 0 then
        local target = targets[1][2]
        local dist = targets[1][3]
        
        -- Tween tới mục tiêu nếu quá xa
        if dist > 15 then
            TweenTo(CFrame.new(target.Position + Vector3.new(0, T.PosY or 18, 0)))
        end
        
        if leftClick then
            pcall(function()
                leftClick:FireServer(Vector3.new(0.01, -500, 0.01), 1, true)
            end)
        end
        
        -- RegisterHit cho melee/sword
        local registerHit = Net:FindFirstChild("RE/RegisterHit")
        if registerHit then
            local hits = {}
            for i = 1, math.min(3, #targets) do
                table.insert(hits, {targets[i][1], targets[i][2]})
            end
            pcall(function()
                registerHit:FireServer(target, hits, nil, nil, tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(tick()):sub(-5))
            end)
        end
    end
end

--============================================================
-- 9. BRING MONSTERS
--============================================================
local lastBringUpdate = 0
local function BringMonsters()
    if not T.BringMonster then return end
    if not HRP or not HRP.Parent then return end
    if not Character then return end
    
    local now = tick()
    if now - lastBringUpdate < 0.5 then return end
    lastBringUpdate = now
    
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", T.BringMonsterRadius or 350)
    end)
    
    for _, mob in ipairs(Enemies:GetChildren()) do
        local mobHRP = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if mobHRP and mobHum and mobHum.Health > 0 then
            local dist = (mobHRP.Position - HRP.Position).Magnitude
            if dist <= (T.BringMonsterRadius or 350) and dist > 20 then
                pcall(function()
                    mobHRP.CFrame = CFrame.new(HRP.Position + Vector3.new(math.random(-5,5), 5, math.random(-5,5)))
                end)
            end
        end
    end
end

--============================================================
-- 10. AUTO CHEST (NHANH HƠN - TỐI ƯU)
--============================================================
local function GetNearestChest()
    if not ChestModels then return nil end
    if not HRP or not HRP.Parent then return nil end
    
    local myPos = HRP.Position
    local nearest, nearestDist = nil, math.huge
    
    for _, chest in ipairs(ChestModels:GetChildren()) do
        local root = chest:FindFirstChild("RootPart")
        if root and root.Parent and chest:GetAttribute("IsDisabled") ~= true then
            local d = (root.Position - myPos).Magnitude
            if d < nearestDist then
                nearest, nearestDist = root, d
            end
        end
    end
    return nearest
end

local ChestCounter = 0
local function AutoChestLoop()
    if not T.AutoChest then return end
    if not HRP or not HRP.Parent then return end
    
    local chest = GetNearestChest()
    if chest then
        -- Tween siêu nhanh tới rương
        TweenTo(chest.CFrame + Vector3.new(0, 3, 0))
        ChestCounter = ChestCounter + 1
        task.wait(0.05)
    else
        if ChestCounter > 0 then
            Notify("Chest Farm", "Hết rương trong server. Đã nhặt " .. ChestCounter .. " rương.", 5)
            ChestCounter = 0
        end
        if T.HopIfNoFruit or T.AutoChest then
            -- Không tự hop nếu user không bật
        end
        task.wait(1)
    end
end

--============================================================
-- 11. AUTO NHẶT TRÁI (TÍNH NĂNG MỚI)
--============================================================
local FruitBlacklist = {}
local function GetNearestFruit()
    local myPos = HRP and HRP.Position
    if not myPos then return nil end
    
    local nearest, nearestDist = nil, math.huge
    
    -- Tìm fruit trong Workspace (đã rơi ra)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                local d = (handle.Position - myPos).Magnitude
                if d < nearestDist and not FruitBlacklist[obj] then
                    nearest, nearestDist = obj, d
                end
            end
        end
        if obj:IsA("Model") and obj.Name:find("Fruit") then
            local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
            if handle then
                local d = (handle.Position - myPos).Magnitude
                if d < nearestDist and not FruitBlacklist[obj] then
                    nearest, nearestDist = obj, d
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function AutoFruitLoop()
    if not T.AutoFruitFarm then return end
    if not HRP or not HRP.Parent then return end
    
    local fruit, dist = GetNearestFruit()
    if fruit then
        local handle = fruit:FindFirstChild("Handle") or fruit.PrimaryPart
        if handle then
            if dist > 10 then
                TweenTo(handle.CFrame + Vector3.new(0, 2, 0))
            else
                -- Tới gần, nhặt bằng firetouchinterest
                pcall(function()
                    firetouchinterest(HRP, handle, 0)
                    task.wait(0.05)
                    firetouchinterest(HRP, handle, 1)
                end)
                FruitBlacklist[fruit] = true
                task.delay(2, function() FruitBlacklist[fruit] = nil end)
            end
        end
        task.wait(0.1)
    else
        if T.HopIfNoFruit then
            Notify("Fruit Farm", "Không có trái trong server. Hop sau " .. T.HopDelay .. "s...", 4)
            task.wait(T.HopDelay or 10)
            pcall(function()
                RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
            end)
        end
        task.wait(0.5)
    end
end

--============================================================
-- 12. MACRO COMBO (TÍNH NĂNG MỚI - NGƯỜI DÙNG SETUP)
--============================================================
local MacroRunning = false
local function StopMacro()
    MacroRunning = false
end

local function RunMacro()
    if not T.MacroEnabled then return end
    if MacroRunning then return end
    MacroRunning = true
    
    task.spawn(function()
        while T.MacroEnabled and MacroRunning do
            for _, key in ipairs(T.MacroSkillKeys) do
                if not T.MacroEnabled or not MacroRunning then break end
                
                local keyCode = Enum.KeyCode[key]
                if keyCode then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                        task.wait(T.MacroDelay or 0.3)
                        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                end
                task.wait(T.MacroDelayBetween or 0.15)
            end
            task.wait(0.5)
        end
        MacroRunning = false
    end)
end

--============================================================
-- 13. DANH SÁCH ĐẢO (TWEEN ĐẢO - KHÔNG CHỈ SEA)
--============================================================
local IslandCoords = {
    -- Sea 1
    Sea1 = {
        ["Starter Island"] = Vector3.new(-1053, 5, 4251),
        ["Marine Fortress"] = Vector3.new(-4895, 8, 4350),
        ["Middle Town"] = Vector3.new(-916, 5, 4500),
        ["Jungle"] = Vector3.new(-1610, 36, 149),
        ["Pirate Village"] = Vector3.new(-1160, 5, 3845),
        ["Desert"] = Vector3.new(1055, 5, 4280),
        ["Frozen Village"] = Vector3.new(1200, 30, -1400),
        ["Marine Ford"] = Vector3.new(-5100, 15, -4200),
        ["Skylands"] = Vector3.new(-4880, 720, -3230),
        ["Colosseum"] = Vector3.new(-1500, 5, -2100),
        ["Prison"] = Vector3.new(4850, 5, 710),
        ["Magma Village"] = Vector3.new(-5220, 3, 870),
        ["Underwater City"] = Vector3.new(60500, 4, 1100),
        ["Fountain City"] = Vector3.new(5150, 5, 3000),
        ["Rumble Arena"] = Vector3.new(-6500, 5, 8500),
    },
    -- Sea 2
    Sea2 = {
        ["Kingdom of Rose"] = Vector3.new(0, 0, 0),
        ["Swan Mansion"] = Vector3.new(-245, 73, 300),
        ["Hot and Cold"] = Vector3.new(2500, 8, -1200),
        ["Cursed Ship"] = Vector3.new(912, 125, 32800),
        ["Ice Castle"] = Vector3.new(5630, 25, -6000),
        ["Forgotten Island"] = Vector3.new(-3000, 8, -1000),
        ["Cafe"] = Vector3.new(-380, 73, 260),
        ["Green Zone"] = Vector3.new(-5500, 8, -350),
        ["Graveyard"] = Vector3.new(-9500, 6, 6000),
        ["Snow Mountain"] = Vector3.new(1350, 87, -1300),
        ["Factory"] = Vector3.new(430, 8, -1350),
        ["Cursed Ship (Side)"] = Vector3.new(930, 10, 32800),
    },
    -- Sea 3
    Sea3 = {
        ["Port Town"] = Vector3.new(-260, 6, 5245),
        ["Hydra Island"] = Vector3.new(5660, 1000, 850),
        ["Great Tree"] = Vector3.new(2950, 2280, -7200),
        ["Castle on the Sea"] = Vector3.new(-5100, 314, -3150),
        ["Haunted Castle"] = Vector3.new(-9500, 150, 6000),
        ["Sea of Treats"] = Vector3.new(-1000, 10, -12000),
        ["Peanut Island"] = Vector3.new(1950, 8, -12200),
        ["Tiki Outpost"] = Vector3.new(-16300, 8, 400),
        ["Floating Turtle"] = Vector3.new(-12400, 375, -7500),
        ["Mansion"] = Vector3.new(-12300, 320, -6630),
        ["Kitsune Island"] = Vector3.new(-10000000, 31, 37016),
    },
}

local function GetIslandList()
    if IsSea1 then return IslandCoords.Sea1
    elseif IsSea2 then return IslandCoords.Sea2
    elseif IsSea3 then return IslandCoords.Sea3
    end
    return {}
end

local function GetIslandNames()
    local names = {}
    for k in pairs(GetIslandList()) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

--============================================================
-- 14. ESP (ĐƠN GIẢN - CHỈ CHEST & FRUIT)
--============================================================
local ESPSprites = {}

local function ClearESP()
    for _, obj in pairs(ESPSprites) do
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
    end
    ESPSprites = {}
end

local function CreateESP(parent, text, color)
    local existing = parent:FindFirstChild("DxESP")
    if existing then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DxESP"
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = color or Theme.AccentGlow
    label.TextStrokeTransparency = 0.3
    label.TextSize = 12
    label.Parent = billboard
    
    ESPSprites[parent] = billboard
end

local function UpdateESP()
    if not HRP or not HRP.Parent then return end
    
    if T.ESPChest and ChestModels then
        for _, chest in ipairs(ChestModels:GetChildren()) do
            local root = chest:FindFirstChild("RootPart")
            if root then
                CreateESP(root, "📦 Chest", Theme.Yellow)
            end
        end
    else
        for _, obj in pairs(ESPSprites) do
            if obj.Parent and obj.Parent.Name == "RootPart" then
                obj:Destroy()
                ESPSprites[obj.Parent] = nil
            end
        end
    end
    
    if T.ESPFruit then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Tool") and obj.Name:find("Fruit") then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    CreateESP(handle, "🍎 " .. obj.Name, Theme.Red)
                end
            end
        end
    end
end

--============================================================
-- 15. CÁC HÀM HỖ TRỢ KHÁC
--============================================================
local function ApplyWalkSpeed()
    if Humanoid and T.WalkSpeed then
        pcall(function() Humanoid.WalkSpeed = T.WalkSpeed end)
    end
end

local function ApplyJumpPower()
    if Humanoid and T.JumpPower then
        pcall(function() Humanoid.UseJumpPower = true; Humanoid.JumpPower = T.JumpPower end)
    end
end

local function ApplyInfiniteZoom()
    if T.InfiniteZoom then
        LocalPlayer.CameraMaxZoomDistance = math.huge
    else
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end

local function SendWebhook(title, desc)
    if not T.WebhookEnabled or T.Webhook == "" then return end
    if not (syn and syn.request) and not http_request then return end
    
    local req = syn and syn.request or http_request
    local body = HttpService:JSONEncode({
        content = "",
        embeds = {{
            title = title,
            description = desc,
            color = 3066993,
            footer = { text = "Blox Community VN • Dungdx" },
            timestamp = DateTime.now():ToIsoDate(),
        }},
    })
    
    pcall(function()
        req({
            Url = T.Webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body,
        })
    end)
end

--============================================================
-- 16. TẠO NỘI DUNG CÁC TAB
--============================================================

-- ============ TAB HOME ============
do
    local sec1 = Tabs.Home:AddSection("Tổng quan")
    C:Label(sec1.Frame, "Chào mừng, " .. LocalPlayer.DisplayName .. "!", "User: Dungdx  •  Discord: discord.gg/Hwwa3VYxW6")
    C:Label(sec1.Frame, "Sea hiện tại: " .. (MapAttr or "?"))
    
    local statLbl = C:Label(sec1.Frame, "Level: " .. (Level and Level.Value or "?") .. "  •  Beli: " .. (Beli and Beli.Value or "?"))
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                statLbl:Set("Level: " .. Level.Value .. "  •  Beli: " .. Beli.Value .. "  •  Frags: " .. Fragments.Value)
            end)
        end
    end)
    
    local sec2 = Tabs.Home:AddSection("Bật nhanh")
    C:Toggle(sec2.Frame, "⚡ Fast Attack", T.FastAttack, function(v) T.FastAttack = v end, "Tấn công siêu nhanh")
    C:Toggle(sec2.Frame, "🎒 Auto Chest", T.AutoChest, function(v) T.AutoChest = v end, "Tự động nhặt rương")
    C:Toggle(sec2.Frame, "🍎 Auto Nhặt Trái", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end, "Tự động nhặt trái rơi")
    C:Toggle(sec2.Frame, "🔗 Bring Monster", T.BringMonster, function(v) T.BringMonster = v end, "Kéo quái lại gần")
    C:Toggle(sec2.Frame, "🐌 Lag Fix", T.LagFix, function(v)
        T.LagFix = v
        ApplyLagFix(v)
    end, "Giảm lag đáng kể")
    C:Toggle(sec2.Frame, "🌫️ Xóa Sương Mù", T.RemoveFog, function(v)
        T.RemoveFog = v
        ApplyRemoveFog(v)
    end, "Xóa fog/mây mù")
end

-- ============ TAB FARM ============
do
    local sec1 = Tabs.Farm:AddSection("Auto Farm Level")
    C:Toggle(sec1.Frame, "Auto Farm Quest", T.AutoFarm, function(v) T.AutoFarm = v end, "Farm quái theo quest")
    C:Toggle(sec1.Frame, "Auto Farm Bones", T.AutoFarmBones, function(v) T.AutoFarmBones = v end, "Farm xương (Sea 3)")
    C:Dropdown(sec1.Frame, "Vũ khí", T.SelectWeapon, {"Melee", "Sword", "Blox Fruit", "Gun"}, function(v) T.SelectWeapon = v end)
    C:Slider(sec1.Frame, "Khoảng cách farm", 5, 100, T.PosY, function(v) T.PosY = v end)
    C:Slider(sec1.Frame, "Bring Radius", 50, 500, T.BringMonsterRadius, function(v) T.BringMonsterRadius = v end)
    C:Slider(sec1.Frame, "Tween Speed", 50, 500, T.TweenSpeed, function(v) T.TweenSpeed = v end)
    
    local sec2 = Tabs.Farm:AddSection("Boss Farm")
    local bossList = IsSea1 and {"The Gorilla King", "Yeti", "Warden", "Swan", "Magma Admiral", "Fishman Lord", "Thunder God", "Cyborg"}
        or IsSea2 and {"Diamond", "Jeremy", "Orbitus", "Don Swan", "Tide Keeper"}
        or {"Stone", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen"}
    
    C:Dropdown(sec2.Frame, "Boss", bossList[1], bossList, function(v) T.SelectBoss = v end)
    C:Toggle(sec2.Frame, "Auto Boss", T.AutoFarmBoss, function(v) T.AutoFarmBoss = v end, "Đánh boss đã chọn")
    C:Toggle(sec2.Frame, "Auto Kill All Bosses", T.AutoKillAllBosses, function(v) T.AutoKillAllBosses = v end)
    
    local sec3 = Tabs.Farm:AddSection("Farm Khác")
    C:Toggle(sec3.Frame, "Auto Farm Material", T.AutoMaterial, function(v) T.AutoMaterial = v end, "Farm nguyên liệu")
    C:Dropdown(sec3.Frame, "Loại Material", "Leather + Scrap Metal", {"Leather + Scrap Metal", "Angel Wings", "Magma Ore", "Fish Tail"}, function(v) T.SelectMaterial = v end)
    C:Toggle(sec3.Frame, "Auto Cake Prince", T.AutoFarmPrince, function(v) T.AutoFarmPrince = v end)
    C:Toggle(sec3.Frame, "Auto Dough King", T.AutoDoughKing, function(v) T.AutoDoughKing = v end)
end

-- ============ TAB COMBAT ============
do
    local sec1 = Tabs.Combat:AddSection("Combat Settings")
    C:Toggle(sec1.Frame, "Fast Attack", T.FastAttack, function(v) T.FastAttack = v end, "Bật để đánh siêu nhanh")
    C:Toggle(sec1.Frame, "Auto Attack Gun", T.AutoAttackGun, function(v) T.AutoAttackGun = v end)
    C:Slider(sec1.Frame, "Fast Attack Delay", 0, 1, T.FastAttackDelay, function(v) T.FastAttackDelay = v end, 0.01)
    C:Dropdown(sec1.Frame, "Attack Method", T.AttackMethod, {"Fast Attack", "Legit Attack"}, function(v) T.AttackMethod = v end)
    C:Toggle(sec1.Frame, "Bring Monster", T.BringMonster, function(v) T.BringMonster = v end)
    
    local sec2 = Tabs.Combat:AddSection("Macro Combo")
    C:Toggle(sec2.Frame, "Bật Macro Combo", T.MacroEnabled, function(v)
        T.MacroEnabled = v
        if v then RunMacro() else StopMacro() end
    end, "Tự động bấm combo phím kỹ năng")
    
    C:Slider(sec2.Frame, "Delay giữa phím", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
    C:Slider(sec2.Frame, "Delay combo xong", 0.1, 3, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)
    
    local keysText = C:Textbox(sec2.Frame, "VD: Z,X,C,V,F", function(v)
        local newKeys = {}
        for k in v:gmatch("[^,%s]+") do
            table.insert(newKeys, k:upper())
        end
        if #newKeys > 0 then T.MacroSkillKeys = newKeys end
    end, table.concat(T.MacroSkillKeys, ","))
    C:Label(sec2.Frame, "Phím combo (cách nhau bằng phẩy)")
    
    C:Button(sec2.Frame, "▶️ Chạy thử combo 1 lần", function()
        local savedEnabled = T.MacroEnabled
        T.MacroEnabled = true
        RunMacro()
        task.wait(3)
        T.MacroEnabled = savedEnabled
        StopMacro()
        Notify("Macro", "Đã chạy thử combo!", 3)
    end)
end

-- ============ TAB PLAYER ============
do
    local sec1 = Tabs.Player:AddSection("Di chuyển")
    local wsSlider = C:Slider(sec1.Frame, "Walk Speed", 16, 500, T.WalkSpeed, function(v)
        T.WalkSpeed = v
        ApplyWalkSpeed()
    end)
    local jpSlider = C:Slider(sec1.Frame, "Jump Power", 50, 500, T.JumpPower, function(v)
        T.JumpPower = v
        ApplyJumpPower()
    end)
    C:Toggle(sec1.Frame, "Infinite Zoom", T.InfiniteZoom, function(v)
        T.InfiniteZoom = v
        ApplyInfiniteZoom()
    end)
    C:Toggle(sec1.Frame, "X-Ray Vision", T.XrayVision, function(v)
        T.XrayVision = v
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = v and 0.7 or 0
            end
        end
    end)
    
    local sec2 = Tabs.Player:AddSection("ESP")
    C:Toggle(sec2.Frame, "ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
    C:Toggle(sec2.Frame, "ESP Fruit", T.ESPFruit, function(v) T.ESPFruit = v end)
    C:Button(sec2.Frame, "❌ Xóa toàn bộ ESP", function()
        ClearESP()
        Notify("ESP", "Đã xóa toàn bộ ESP", 3)
    end)
    
    local sec3 = Tabs.Player:AddSection("Nhân vật")
    C:Button(sec3.Frame, "🔄 Reset Nhân Vật", function()
        if Character and Character:FindFirstChild("Head") then
            Character.Head:Destroy()
        end
    end)
    C:Toggle(sec3.Frame, "Remove Observation Effect", T.RemoveObservationEffect, function(v) T.RemoveObservationEffect = v end)
end

-- ============ TAB FRUIT ============
do
    local sec1 = Tabs.Fruit:AddSection("Auto Nhặt Trái")
    C:Toggle(sec1.Frame, "🍎 Auto Nhặt Trái", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end, "Tự động bay tới & nhặt trái rơi")
    C:Toggle(sec1.Frame, "Hop nếu không có trái", T.HopIfNoFruit, function(v) T.HopIfNoFruit = v end)
    C:Slider(sec1.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)
    
    local sec2 = Tabs.Fruit:AddSection("Lưu Trái")
    C:Toggle(sec2.Frame, "Auto Store Fruit", T.AutoStoreFruit, function(v) T.AutoStoreFruit = v end, "Tự động cất trái vào kho")
    C:Toggle(sec2.Frame, "Auto Random Fruit", false, function(v) T.AutoRandomFruit = v end)
    
    local sec3 = Tabs.Fruit:AddSection("Teleport Trái")
    C:Toggle(sec3.Frame, "Tween tới trái gần nhất", T.TweenFruit, function(v) T.TweenFruit = v end)
    C:Button(sec3.Frame, "🍇 Tìm & teleport ngay", function()
        local fruit, dist = GetNearestFruit()
        if fruit then
            local handle = fruit:FindFirstChild("Handle") or fruit.PrimaryPart
            if handle then
                TweenTo(handle.CFrame + Vector3.new(0, 3, 0))
                Notify("Fruit", "Đã tìm thấy: " .. fruit.Name .. " (" .. math.floor(dist) .. "m)", 4)
            end
        else
            Notify("Fruit", "Không có trái nào trong server!", 3)
        end
    end)
end

-- ============ TAB CHEST ============
do
    local sec1 = Tabs.Chest:AddSection("Chest Farm")
    C:Toggle(sec1.Frame, "Auto Chest Farm", T.AutoChest, function(v)
        T.AutoChest = v
        ChestCounter = 0
    end, "Nhặt rương siêu nhanh")
    C:Toggle(sec1.Frame, "Hop khi hết rương", T.AutoHopChest, function(v) T.AutoHopChest = v end)
    C:Slider(sec1.Frame, "Số rương trước khi hop", 1, 50, 10, function(v) T.ChestHopCount = v end)
    
    local sec2 = Tabs.Chest:AddSection("ESP Chest")
    C:Toggle(sec2.Frame, "Hiện ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
    
    local sec3 = Tabs.Chest:AddSection("Thông tin")
    C:Label(sec3.Frame, "Rương đã nhặt: " .. ChestCounter)
end

-- ============ TAB ISLAND ============
do
    local sec1 = Tabs.Island:AddSection("Teleport Đảo")
    local islandNames = GetIslandNames()
    local selectedIsland = islandNames[1] or "None"
    
    C:Dropdown(sec1.Frame, "Chọn đảo", selectedIsland, islandNames, function(v)
        selectedIsland = v
    end)
    
    C:Button(sec1.Frame, "🚀 Teleport tới đảo", function()
        local coords = GetIslandList()[selectedIsland]
        if coords then
            Notify("Teleport", "Đang tới: " .. selectedIsland, 3)
            TweenTo(CFrame.new(coords))
        end
    end)
    
    local sec2 = Tabs.Island:AddSection("Teleport Sea")
    C:Button(sec2.Frame, "🌊 Tới Sea 1", function()
        pcall(function() CommF:InvokeServer("TravelMain") end)
    end)
    C:Button(sec2.Frame, "🏝️ Tới Sea 2", function()
        pcall(function() CommF:InvokeServer("TravelDressrosa") end)
    end)
    C:Button(sec2.Frame, "🏔️ Tới Sea 3", function()
        pcall(function() CommF:InvokeServer("TravelZou") end)
    end)
    
    local sec3 = Tabs.Island:AddSection("Server Hop")
    C:Button(sec3.Frame, "🔄 Rejoin Server", function()
        pcall(function()
            RS.__ServerBrowser:InvokeServer("teleport", game.JobId)
        end)
    end)
    C:Button(sec3.Frame, "🎲 Random Server Hop", function()
        Notify("Hop", "Đang tìm server...", 3)
        task.spawn(function()
            for i = 1, 100 do
                local servers = RS.__ServerBrowser:InvokeServer(i)
                if typeof(servers) == "table" then
                    for jobId, info in pairs(servers) do
                        if info.Count and info.Count < 12 and jobId ~= game.JobId then
                            pcall(function()
                                RS.__ServerBrowser:InvokeServer("teleport", jobId)
                            end)
                            return
                        end
                    end
                end
            end
        end)
    end)
end

-- ============ TAB MACRO ============
do
    local sec1 = Tabs.Macro:AddSection("Combo Macro")
    C:Label(sec1.Frame, "Setup combo kỹ năng", "Nhập các phím cách nhau bằng dấu phẩy. VD: Z,X,C,V,F")
    
    C:Toggle(sec1.Frame, "Bật Macro", T.MacroEnabled, function(v)
        T.MacroEnabled = v
        if v then RunMacro() else StopMacro() end
    end)
    
    C:Textbox(sec1.Frame, "Z,X,C,V,F", function(v)
        local newKeys = {}
        for k in v:gmatch("[^,%s]+") do
            table.insert(newKeys, k:upper())
        end
        if #newKeys > 0 then
            T.MacroSkillKeys = newKeys
            Notify("Macro", "Đã set combo: " .. table.concat(newKeys, " → "), 3)
        end
    end, table.concat(T.MacroSkillKeys, ","))
    
    C:Slider(sec1.Frame, "Thời gian giữ phím (s)", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
    C:Slider(sec1.Frame, "Delay giữa các phím (s)", 0.05, 2, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)
    
    C:Button(sec1.Frame, "▶️ Test Combo", function()
        if not T.MacroEnabled then
            Notify("Macro", "Bật Macro trước!", 3)
            return
        end
        Notify("Macro", "Đang chạy combo...", 2)
    end)
    
    local sec2 = Tabs.Macro:AddSection("Preset Combo")
    C:Button(sec2.Frame, "Preset 1: Z-X-C", function()
        T.MacroSkillKeys = {"Z", "X", "C"}
        Notify("Macro", "Đã nạp preset Z-X-C", 3)
    end)
    C:Button(sec2.Frame, "Preset 2: Z-X-C-V-F", function()
        T.MacroSkillKeys = {"Z", "X", "C", "V", "F"}
        Notify("Macro", "Đã nạp preset đầy đủ", 3)
    end)
    C:Button(sec2.Frame, "Preset 3: Z-Z-X-X (Combo đôi)", function()
        T.MacroSkillKeys = {"Z", "Z", "X", "X"}
        Notify("Macro", "Đã nạp preset combo đôi", 3)
    end)
end

-- ============ TAB PERF ============
do
    local sec1 = Tabs.Perf:AddSection("Tối Ưu Hiệu Năng")
    C:Toggle(sec1.Frame, "⚡ Lag Fix (Bật/Tắt)", T.LagFix, function(v)
        T.LagFix = v
        ApplyLagFix(v)
    end, "Giảm lag mạnh, ổn định 50-60 FPS")
    
    C:Toggle(sec1.Frame, "🌫️ Xóa Sương Mù", T.RemoveFog, function(v)
        T.RemoveFog = v
        ApplyRemoveFog(v)
    end)
    
    C:Button(sec1.Frame, "🧹 Dọn rác bộ nhớ", function()
        pcall(function()
            if collectgarbage then collectgarbage("collect") end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name:find("Slash") or obj.Name:find("Effect")) then
                    obj:Destroy()
                end
            end
        end)
        Notify("Cleaner", "Đã dọn bộ nhớ!", 3)
    end)
    
    local sec2 = Tabs.Perf:AddSection("Render")
    C:Toggle(sec2.Frame, "Tắt hiệu ứng Lighting", false, function(v)
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("PostEffect") then e.Enabled = not v end
        end
    end)
    
    local sec3 = Tabs.Perf:AddSection("FPS Monitor")
    local fpsLbl = C:Label(sec3.Frame, "FPS: --")
    task.spawn(function()
        local frames, lastUpdate = 0, tick()
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            if tick() - lastUpdate >= 1 then
                fpsLbl:Set("FPS: " .. frames .. "  •  Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms")
                frames = 0
                lastUpdate = tick()
            end
        end)
    end)
end

-- ============ TAB MISC ============
do
    local sec1 = Tabs.Misc:AddSection("Anti-AFK")
    C:Toggle(sec1.Frame, "Anti AFK", T.AntiAFK, function(v) T.AntiAFK = v end)
    
    local sec2 = Tabs.Misc:AddSection("Server")
    C:Toggle(sec2.Frame, "Auto Hop 30 phút", T.AutoHop30Min, function(v) T.AutoHop30Min = v end)
    C:Slider(sec2.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)
    
    local sec3 = Tabs.Misc:AddSection("Team")
    C:Button(sec3.Frame, "⚔️ Chọn Team Pirates", function()
        pcall(function() CommF:InvokeServer("SetTeam", "Pirates") end)
    end)
    C:Button(sec3.Frame, "🛡️ Chọn Team Marines", function()
        pcall(function() CommF:InvokeServer("SetTeam", "Marines") end)
    end)
    
    local sec4 = Tabs.Misc:AddSection("Codes")
    C:Button(sec4.Frame, "🎁 Redeem tất cả codes", function()
        Notify("Codes", "Đang redeem codes...", 3)
        task.spawn(function()
            local codes = {"SUB2GAMERROBOT_EXP1", "SUB2OFFICIALNOOBIE", "KITTGAMING", "FUDDSM0NEY", "GAMER_ROBOT_1M"}
            local redeemed = 0
            for _, code in ipairs(codes) do
                local ok = pcall(function()
                    Remotes.Redeem:InvokeServer(code)
                end)
                if ok then redeemed = redeemed + 1 end
                task.wait(0.5)
            end
            Notify("Codes", "Đã thử " .. #codes .. " codes!", 5)
        end)
    end)
end

-- ============ TAB WEBHOOK ============
do
    local sec1 = Tabs.Webhook:AddSection("Discord Webhook")
    C:Label(sec1.Frame, "Gửi thông báo về Discord", "Dán URL webhook của bạn vào đây")
    
    C:Textbox(sec1.Frame, "https://discord.com/api/webhooks/...", function(v)
        T.Webhook = v
    end, T.Webhook)
    
    C:Toggle(sec1.Frame, "Bật Webhook", T.WebhookEnabled, function(v) T.WebhookEnabled = v end)
    
    C:Button(sec1.Frame, "📤 Test Webhook", function()
        if T.Webhook == "" then
            Notify("Webhook", "Chưa nhập URL!", 3)
            return
        end
        SendWebhook("Blox Community VN", "Webhook hoạt động tốt!\nUser: **" .. LocalPlayer.Name .. "**")
        Notify("Webhook", "Đã gửi test!", 3)
    end)
end

-- ============ TAB CREDIT ============
do
    local sec1 = Tabs.Credit:AddSection("Thông tin")
    C:Label(sec1.Frame, "Blox Community VN", "Phiên bản Full Rebuild v3")
    C:Label(sec1.Frame, "Tác giả", "Dungdx")
    C:Label(sec1.Frame, "Discord Server", "discord.gg/Hwwa3VYxW6")
    
    local sec2 = Tabs.Credit:AddSection("Links")
    C:Button(sec2.Frame, "📋 Copy link Discord", function()
        pcall(function() setclipboard("https://discord.gg/Hwwa3VYxW6") end)
        Notify("Credit", "Đã copy link Discord!", 3)
    end)
end

--============================================================
-- 17. VÒNG LẶP CHÍNH (MAIN LOOP)
--============================================================

-- Loop 1: Fast Attack
task.spawn(function()
    while task.wait(T.FastAttackDelay or 0) do
        if T.FastAttack then
            pcall(FastAttack)
        end
    end
end)

-- Loop 2: Bring Monsters
task.spawn(function()
    while task.wait(0.5) do
        if T.BringMonster then
            pcall(BringMonsters)
        end
    end
end)

-- Loop 3: Auto Chest
task.spawn(function()
    while task.wait(0.2) do
        if T.AutoChest then
            pcall(AutoChestLoop)
        end
    end
end)

-- Loop 4: Auto Fruit
task.spawn(function()
    while task.wait(0.3) do
        if T.AutoFruitFarm then
            pcall(AutoFruitLoop)
        end
    end
end)

-- Loop 5: Auto Farm (đơn giản - tấn công quái gần nhất)
task.spawn(function()
    while task.wait(0.5) do
        if T.AutoFarm or T.AutoFarmBones or T.AutoFarmBoss or T.AutoKillAllBosses then
            pcall(function()
                local targets = GetEnemies(T.checknearestdist or 1500)
                if #targets > 0 then
                    local target = targets[1][1]
                    local targetHRP = targets[1][2]
                    local dist = targets[1][3]
                    
                    if dist > 30 then
                        TweenTo(CFrame.new(targetHRP.Position + Vector3.new(0, T.PosY or 18, 0)))
                    end
                    
                    EquipWeaponType(T.SelectWeapon)
                end
            end)
        end
    end
end)

-- Loop 6: ESP Update
task.spawn(function()
    while task.wait(1) do
        if T.ESPChest or T.ESPFruit then
            pcall(UpdateESP)
        end
    end
end)

-- Loop 7: Walk Speed / Jump Power duy trì
task.spawn(function()
    while task.wait(1) do
        if Humanoid then
            pcall(ApplyWalkSpeed)
            pcall(ApplyJumpPower)
        end
    end
end)

-- Loop 8: Auto Store Fruit
task.spawn(function()
    while task.wait(2) do
        if T.AutoStoreFruit then
            pcall(function()
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local name = tool:GetAttribute("OriginalName") or tool.Name:match("^(.-)%-") or tool.Name
                        pcall(function()
                            CommF:InvokeServer("StoreFruit", name, tool)
                        end)
                    end
                end
            end)
        end
    end
end)

-- Loop 9: Anti-AFK
task.spawn(function()
    while task.wait(60) do
        if T.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
        end
    end)
end)

-- Loop 10: Auto Hop 30 phút
local startTime = tick()
task.spawn(function()
    while task.wait(30) do
        if T.AutoHop30Min and tick() - startTime >= 1800 then
            startTime = tick()
            Notify("Hop", "Đã 30 phút, đang hop...", 5)
            pcall(function()
                RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
            end)
        end
    end
end)

-- Loop 11: Auto Lag Fix refresh (mỗi 5s đảm bảo luôn bật)
task.spawn(function()
    while task.wait(5) do
        if T.LagFix then
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
            end)
        end
        if T.RemoveFog then
            pcall(ApplyRemoveFog, true)
        end
    end
end)

--============================================================
-- 18. KHỞI ĐỘNG HOÀN TẤT
--============================================================
task.spawn(function()
    task.wait(1)
    Notify("Blox Community VN", "Đã load thành công!\nTác giả: Dungdx\nDiscord: discord.gg/Hwwa3VYxW6", 8)
    task.wait(2)
    Notify("Hướng dẫn", "Nhấn nút 'Dx' (tròn xanh) để ẩn/hiện UI.\nKéo nút 'Dx' để di chuyển.", 8)
    task.wait(2)
    Notify("Tính năng mới", "✅ Fast Attack hoạt động\n✅ Auto nhặt trái\n✅ Macro combo\n✅ Lag Fix bật/tắt", 8)
end)

print("[Blox Community VN] ✅ Script load HOÀN TẤT! Tác giả: Dungdx")

-- Giữ script chạy
return "Blox Community VN v3 - Loaded by Dungdx"