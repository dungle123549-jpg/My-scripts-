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