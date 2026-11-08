local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local STATUS_URL = "https://raw.githubusercontent.com/provokator-hub/Survive-the-Lava-for-Eggs-/refs/heads/main/status.txt"

local isFly, flyConn = false, nil
local isFarm, lastFarm, lastClick, kills = false, 0, 0, 0
local minX, maxX = 0, 0
local scriptAlive = true
local touchActive = false

local function safePrompt(p) if p then pcall(function() fireproximityprompt(p) end) end end
local function safeTouch(a, b) if a and b then pcall(function() firetouchinterest(a, b, 0) task.wait(0.05) firetouchinterest(a, b, 1) end) end end

local pg = player:WaitForChild("PlayerGui")

-- ГЛОБАЛЬНЫЙ ФАСТ Е (УБИРАЕТ ЗАДЕРЖКУ У ВСЕХ КНОПОК)
task.spawn(function()
    while scriptAlive do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
        task.wait(2)
    end
end)

-- АНИМАЦИЯ
local intro = Instance.new("ScreenGui")
intro.IgnoreGuiInset = true intro.DisplayOrder = 999 intro.Parent = pg
local bg = Instance.new("Frame") bg.Size = UDim2.new(1,0,1,0) bg.BackgroundColor3 = Color3.fromRGB(5, 5, 10) bg.BackgroundTransparency = 1 bg.Parent = intro

local emojis = {"🎃", "🦇", "👻"}
for i = 1, 15 do
    local e = Instance.new("TextLabel")
    e.Size = UDim2.new(0, 60, 0, 60) e.BackgroundTransparency = 1 e.Text = emojis[math.random(1, #emojis)] e.TextSize = math.random(40, 60) e.TextTransparency = 1
    e.Position = UDim2.new(math.random(5, 95)/100, 0, math.random(5, 95)/100, 0) e.Parent = intro
end

local txt = Instance.new("TextLabel") 
txt.Size = UDim2.new(1,0,0,100) txt.Position = UDim2.new(0,0,0.5,-50) txt.BackgroundTransparency = 1 txt.Text = "Привет, " .. player.DisplayName .. "!" txt.TextColor3 = Color3.fromRGB(255, 180, 80) txt.Font = Enum.Font.GothamBlack txt.TextSize = 45 txt.TextTransparency = 1 txt.Parent = intro

for i = 1, 0, -0.04 do
    bg.BackgroundTransparency = 0.1 + (i * 0.6) txt.TextTransparency = i
    for _, e in pairs(intro:GetChildren()) do if e:IsA("TextLabel") and e ~= txt then e.TextTransparency = i end end
    task.wait(0.01)
end
task.wait(1.5)
for i = 0, 1, 0.04 do
    bg.BackgroundTransparency = 0.7 + (i * 0.3) txt.TextTransparency = i 
    for _, e in pairs(intro:GetChildren()) do if e:IsA("TextLabel") and e ~= txt then e.TextTransparency = i end end
    task.wait(0.01)
end
intro:Destroy()

-- МЕНЮ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Menu" screenGui.ResetOnSpawn = false screenGui.Parent = pg

local hideBtn = Instance.new("TextButton") hideBtn.Size = UDim2.new(0, 44, 0, 44) hideBtn.Position = UDim2.new(0, 12, 0, 12) hideBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 5) hideBtn.Text = "P" hideBtn.TextColor3 = Color3.fromRGB(255, 210, 140) hideBtn.Font = Enum.Font.GothamBold hideBtn.TextSize = 22 hideBtn.Parent = screenGui
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame") mainFrame.Size = UDim2.new(0, 300, 0, 500) mainFrame.Position = UDim2.new(0.5, -150, 0.5, -250) mainFrame.BackgroundColor3 = Color3.fromRGB(14, 10, 22) mainFrame.Active = true mainFrame.Draggable = true mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
local ms = Instance.new("UIStroke") ms.Color = Color3.fromRGB(255, 120, 0) ms.Thickness = 1.5 ms.Transparency = 0.35 ms.Parent = mainFrame

local isOpen = true
hideBtn.MouseButton1Click:Connect(function() isOpen = not isOpen mainFrame.Visible = isOpen end)
UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftControl then isOpen = not isOpen mainFrame.Visible = isOpen end end)

local tl = Instance.new("TextLabel") tl.Size = UDim2.new(1, -70, 0, 26) tl.Position = UDim2.new(0, 16, 0, 12) tl.BackgroundTransparency = 1 tl.Text = "🎃 #provokator" tl.TextColor3 = Color3.fromRGB(255, 210, 140) tl.Font = Enum.Font.GothamBold tl.TextSize = 18 tl.TextXAlignment = Enum.TextXAlignment.Left tl.Parent = mainFrame

local function makeBtn(t, y, h, col, txtCol, click)
    local b = Instance.new("TextButton") b.Size = UDim2.new(1, -32, 0, h) b.Position = UDim2.new(0, 16, 0, y) b.BackgroundColor3 = col b.Text = t b.TextColor3 = txtCol b.Font = Enum.Font.GothamBold b.TextSize = 13 b.TextXAlignment = Enum.TextXAlignment.Left b.Parent = mainFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local p = Instance.new("UIPadding") p.PaddingLeft = UDim.new(0, 14) p.Parent = b
    if click then b.MouseButton1Click:Connect(click) end
    return b
end

UIS.InputBegan:Connect(function(input, g)
    if g then return end
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and isFly then
        touchActive = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchActive = false
    end
end)

-- ФЛАЙ
local MAX_SPEED = 3500
local ctrl = {f = 0, b = 0, l = 0, r = 0}

local function toggleFly(state)
    isFly = state
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    if isFly then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = char.HumanoidRootPart.CFrame
        
        flyConn = RunService.Heartbeat:Connect(function()
            if not isFly then return end
            ctrl = {f = 0, b = 0, l = 0, r = 0}
            if UIS:IsKeyDown(Enum.KeyCode.W) then ctrl.f = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then ctrl.b = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then ctrl.l = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then ctrl.r = 1 end
            if touchActive then ctrl.f = 1 end
            
            local cam = workspace.CurrentCamera
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.Velocity = ((cam.CFrame.LookVector * (ctrl.f + ctrl.b)) + ((cam.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - cam.CFrame.p)) * MAX_SPEED
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = cam.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50), 0, 0)
        end)
        
        spawn(function()
            while isFly do task.wait(1) end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if hum then hum.PlatformStand = false end
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
    end
end

flyBtn = makeBtn("✈  ФЛАЙ (3500): ВЫКЛ", 70, 36, Color3.fromRGB(60, 20, 90), Color3.fromRGB(230, 200, 255), function()
    toggleFly(not isFly)
    flyBtn.Text = isFly and "✈  ФЛАЙ (3500): ВКЛ" or "✈  ФЛАЙ (3500): ВЫКЛ"
end)

farmBtn = makeBtn("🎃  ФАРМ ТЫКВ: ВЫКЛ", 114, 36, Color3.fromRGB(50, 30, 20), Color3.fromRGB(255, 200, 140), function()
    isFarm = not isFarm farmBtn.Text = isFarm and "🎃  ФАРМ ТЫКВ: ВКЛ" or "🎃  ФАРМ ТЫКВ: ВЫКЛ" kills = 0
end)

RunService.Heartbeat:Connect(function()
    if isFarm and tick() - lastFarm > 0.5 then
        lastFarm = tick() local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local pf = workspace:FindFirstChild("HalloweenPumpkins")
            if pf then for _, p in pairs(pf:GetChildren()) do if p.Name == "Pumpkin" then local pt = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart") if pt then c.HumanoidRootPart.CFrame = CFrame.new(pt.Position + Vector3.new(0, 3, 0)) break end end end end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        lastClick = tick()
        if isFarm then
            if kills < 3 then kills = kills + 1 elseif kills >= 3 then
                task.spawn(function()
                    while isFarm do
                        if tick() - lastClick > 0.5 then VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1) task.wait(0.01) VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) end
                        task.wait(0.1)
                    end
                end)
            end
        end
    end
end)

local countGui = Instance.new("Frame")
countGui.Size = UDim2.new(0, 200, 0, 250) countGui.Position = UDim2.new(0.5, -100, 0.5, -125) countGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20) countGui.Visible = false countGui.Active = true countGui.Draggable = true countGui.Parent = screenGui
Instance.new("UICorner", countGui).CornerRadius = UDim.new(0, 10)
local cT = Instance.new("TextLabel") cT.Size = UDim2.new(1, 0, 0, 30) cT.BackgroundTransparency = 1 cT.Text = "Сколько яиц украсть?" cT.TextColor3 = Color3.fromRGB(255, 255, 255) cT.Font = Enum.Font.GothamBold cT.TextSize = 14 cT.Parent = countGui
local cC = Instance.new("TextButton") cC.Size = UDim2.new(0, 25, 0, 25) cC.Position = UDim2.new(1, -30, 0, 5) cC.BackgroundTransparency = 1 cC.Text = "X" cC.TextColor3 = Color3.fromRGB(255, 50, 50) cC.Font = Enum.Font.GothamBold cC.TextSize = 18 cC.Parent = countGui
cC.MouseButton1Click:Connect(function() countGui.Visible = false end)

-- БЫСТРАЯ КРАЖА (0.15 СЕК)
local function startSteal(num)
    countGui.Visible = false
    local c = player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local hrp = c.HumanoidRootPart
    local eggs = {}
    
    for _, o in pairs(workspace:GetDescendants()) do
        if (o.Name:find("Egg") or o.Name:find("Hatch")) and (o:IsA("Part") or o:IsA("Model")) then
            local pt = o:IsA("Part") and o or o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            if pt and pt.Position.X >= minX and pt.Position.X <= maxX then
                local pr = o:FindFirstChild("StealPrompt") or o:FindFirstChildOfClass("ProximityPrompt")
                if pr then table.insert(eggs, {o=o, p=pt, r=pr}) end
            end
        end
    end
    
    if #eggs == 0 then return end
    
    task.spawn(function()
        for i = 1, math.min(num, #eggs) do
            local e = eggs[i]
            hrp.CFrame = CFrame.new(e.p.Position + Vector3.new(0, 3, 0))
            task.wait(0.15) 
            pcall(function() e.r.HoldDuration = 0 end)
            safePrompt(e.r) 
            safeTouch(hrp, e.p)
            pcall(function() 
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.02)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) 
            end)
        end
        hrp.CFrame = CFrame.new(0, 10, 0)
    end)
end

for i = 1, 5 do
    local b = Instance.new("TextButton") b.Size = UDim2.new(1, -20, 0, 30) b.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * 40) b.BackgroundColor3 = Color3.fromRGB(60, 60, 60) b.Text = tostring(i) .. " шт." b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Font = Enum.Font.GothamBold b.TextSize = 14 b.Parent = countGui
    b.MouseButton1Click:Connect(function() startSteal(i) end)
end

local function makeLbl(t, y)
    local l = Instance.new("TextLabel") l.Size = UDim2.new(1, -32, 0, 18) l.Position = UDim2.new(0, 16, 0, y) l.BackgroundTransparency = 1 l.Text = t l.TextColor3 = Color3.fromRGB(255, 160, 80) l.Font = Enum.Font.GothamBold l.TextSize = 11 l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = mainFrame
end
makeLbl("КРАЖА ЯИЦ", 164)

local zDefs = {
    {n = "Вулкан", c = Color3.fromRGB(200, 60, 0), a = 500, b = 800},
    {n = "Космос", c = Color3.fromRGB(60, 60, 160), a = 800, b = 1100},
    {n = "Снег", c = Color3.fromRGB(0, 110, 160), a = 2500, b = 3000},
    {n = "Последняя", c = Color3.fromRGB(160, 0, 160), a = 3400, b = 4000},
    {n = "Демон", c = Color3.fromRGB(150, 0, 0), a = 4000, b = 4600}
}
for i, z in ipairs(zDefs) do
    makeBtn("🎯  КРАСТЬ: " .. z.n, 184 + (i - 1) * 34, 30, z.c, Color3.fromRGB(255, 255, 255), function()
        minX, maxX = z.a, z.b 
        countGui.Visible = true 
    end)
end

makeLbl("УПРАВЛЕНИЕ", 370)
local unloadBtn = makeBtn("⛔  ВЫГРУЗИТЬ СКРИПТ", 390, 32, Color3.fromRGB(80, 15, 15), Color3.fromRGB(255, 180, 180), function()
    scriptAlive = false
    if flyConn then flyConn:Disconnect() end
    if screenGui then screenGui:Destroy() end
end)

task.spawn(function()
    while scriptAlive do
        task.wait(5)
        if not scriptAlive then break end
        local success, res = pcall(function() return game:HttpGet(STATUS_URL, true) end)
        if success and res and #res > 0 then
            if res:gsub("%s+", ""):lower():find("off") then
                scriptAlive = false
                if flyConn then flyConn:Disconnect() end
                if screenGui then screenGui:Destroy() end
                break
            end
        end
    end
end)

print("Загружено!")
