local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local TG = "@EroxEggScript"
local STATUS_URL = "https://raw.githubusercontent.com/provokator-hub/Survive-the-Lava-for-Eggs-/refs/heads/main/status.txt"
local CHECK_INTERVAL = 5

local V_MIN, V_MAX, C_MIN, C_MAX = 500, 800, 800, 1100
local S_MIN, S_MAX, L_MIN, L_MAX = 2500, 3000, 3400, 4000
local D_MIN, D_MAX = 4000, 4600
local SPAWN = CFrame.new(0, 10, 0)

local isFly, flySpd, flyConn, bVel = false, 3500, nil, nil
local fTarget, isFollow, fConn = nil, false, nil
local isFarm, isRep, lastFarm, lastClick, kills = false, false, 0, 0, 0
local minX, maxX = 0, 0
local countGui, screenGui, mainFrame, flyBtn, farmBtn, statusTxt, followBtn
local scriptAlive = true

local function clean(n) return n:gsub("Hatch", ""):gsub("Egg", ""):gsub("Part", ""):gsub("_", " "):gsub("^%s*(.-)%s*$", "%1") end
local function getW(w) local n = w:match("([%d%.]+)") if n then return tonumber(n) end return 0 end
local function safePrompt(p) if p then pcall(function() fireproximityprompt(p) end) end end
local function safeTouch(a, b) if a and b then pcall(function() firetouchinterest(a, b, 0) task.wait(0.05) firetouchinterest(a, b, 1) end) end end

local function showOff()
    local pg = player:FindFirstChild("PlayerGui") if not pg then return end
    local g = Instance.new("ScreenGui") g.Name = "Off" g.ResetOnSpawn = false g.Parent = pg
    local f = Instance.new("Frame") f.Size = UDim2.new(0, 420, 0, 260) f.Position = UDim2.new(0.5, -210, 0.5, -130) f.BackgroundColor3 = Color3.fromRGB(18, 18, 22) f.Parent = g
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 14) c.Parent = f
    local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(255, 60, 60) s.Thickness = 1.5 s.Parent = f
    local ic = Instance.new("TextLabel") ic.Size = UDim2.new(0, 64, 0, 64) ic.Position = UDim2.new(0.5, -32, 0, 30) ic.BackgroundColor3 = Color3.fromRGB(60, 0, 0) ic.Text = "🔒" ic.TextSize = 34 ic.TextColor3 = Color3.fromRGB(255,255,255) ic.Parent = f
    local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = ic
    local t = Instance.new("TextLabel") t.Size = UDim2.new(1, -40, 0, 34) t.Position = UDim2.new(0, 20, 0, 104) t.BackgroundTransparency = 1 t.Text = "СКРИПТ ОТКЛЮЧЕН" t.TextColor3 = Color3.fromRGB(255, 80, 80) t.Font = Enum.Font.GothamBold t.TextSize = 22 t.Parent = f
    local st = Instance.new("TextLabel") st.Size = UDim2.new(1, -40, 0, 30) st.Position = UDim2.new(0, 20, 0, 182) st.BackgroundTransparency = 1 st.Text = "Подробности в ТГК " .. TG st.TextColor3 = Color3.fromRGB(0, 220, 255) st.Font = Enum.Font.GothamMedium st.TextSize = 14 st.Parent = f
    local b = Instance.new("TextButton") b.Size = UDim2.new(1, -40, 0, 36) b.Position = UDim2.new(0, 20, 1, -56) b.BackgroundColor3 = Color3.fromRGB(40, 40, 48) b.Text = "ЗАКРЫТЬ" b.TextColor3 = Color3.fromRGB(230,230,230) b.Font = Enum.Font.GothamBold b.Parent = f
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 8) bc.Parent = b
    b.MouseButton1Click:Connect(function() g:Destroy() end)
end

-- ПРОВЕРКА СТАТУСА ПРИ ЗАПУСКЕ
local startupOk, startupRes = pcall(function() return game:HttpGet(STATUS_URL, true) end)
if startupOk and startupRes and #startupRes > 0 then
    local startupCl = startupRes:gsub("%s+", ""):lower()
    if startupCl:find("off") then
        showOff()
        return
    end
end

local function killScript()
    if not scriptAlive then return end
    scriptAlive = false
    isFarm, isFollow, isFly = false, false, false
    if fConn then fConn:Disconnect() end
    if flyConn then flyConn:Disconnect() end
    if bVel then bVel:Destroy() end
    if screenGui then screenGui:Destroy() end
    showOff()
end

local function checkStatusAndKill()
    local ok, res = pcall(function() return game:HttpGet(STATUS_URL, true) end)
    if ok and res and #res > 0 then
        local cl = res:gsub("%s+", ""):lower()
        if cl:find("off") then
            killScript()
            return true
        end
    end
    return false
end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 44, 0, 44)
hideBtn.Position = UDim2.new(0, 12, 0, 12)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 5)
hideBtn.Text = "P"
hideBtn.TextColor3 = Color3.fromRGB(255, 210, 140)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 22
hideBtn.Parent = screenGui
local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(1, 0) hc.Parent = hideBtn

mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 760)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -380)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 10, 22)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 16) mc.Parent = mainFrame
local ms = Instance.new("UIStroke") ms.Color = Color3.fromRGB(255, 120, 0) ms.Thickness = 1.5 ms.Transparency = 0.35 ms.Parent = mainFrame

local isVis = true
local function toggle() isVis = not isVis mainFrame.Visible = isVis end
hideBtn.MouseButton1Click:Connect(toggle)
UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftControl then toggle() end end)

local tl = Instance.new("TextLabel") tl.Size = UDim2.new(1, -70, 0, 26) tl.Position = UDim2.new(0, 16, 0, 12) tl.BackgroundTransparency = 1 tl.Text = "🎃 #provokator" tl.TextColor3 = Color3.fromRGB(255, 210, 140) tl.Font = Enum.Font.GothamBold tl.TextSize = 18 tl.TextXAlignment = Enum.TextXAlignment.Left tl.Parent = mainFrame
local sb = Instance.new("TextLabel") sb.Size = UDim2.new(1, -70, 0, 16) sb.Position = UDim2.new(0, 16, 0, 36) sb.BackgroundTransparency = 1 sb.Text = "Halloween • Rocket Way" sb.TextColor3 = Color3.fromRGB(180, 150, 200) sb.Font = Enum.Font.Gotham sb.TextSize = 11 sb.TextXAlignment = Enum.TextXAlignment.Left sb.Parent = mainFrame

local function makeBtn(t, y, h, col, txtCol, click)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -32, 0, h) b.Position = UDim2.new(0, 16, 0, y) b.BackgroundColor3 = col b.Text = t b.TextColor3 = txtCol b.Font = Enum.Font.GothamBold b.TextSize = 13 b.TextXAlignment = Enum.TextXAlignment.Left b.Parent = mainFrame
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = b
    local p = Instance.new("UIPadding") p.PaddingLeft = UDim.new(0, 14) p.Parent = b
    if click then b.MouseButton1Click:Connect(click) end
    return b
end
local function makeLbl(t, y)
    local l = Instance.new("TextLabel") l.Size = UDim2.new(1, -32, 0, 18) l.Position = UDim2.new(0, 16, 0, y) l.BackgroundTransparency = 1 l.Text = t l.TextColor3 = Color3.fromRGB(255, 160, 80) l.Font = Enum.Font.GothamBold l.TextSize = 11 l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = mainFrame
end

makeLbl("СТАТУС", 64)
local statLbl = Instance.new("TextLabel") statLbl.Size = UDim2.new(1, -32, 0, 18) statLbl.Position = UDim2.new(0, 16, 0, 116) statLbl.BackgroundTransparency = 1 statLbl.Text = "Проверка каждые 5 сек" statLbl.TextColor3 = Color3.fromRGB(180, 160, 200) statLbl.Font = Enum.Font.Gotham statLbl.TextSize = 11 statLbl.TextXAlignment = Enum.TextXAlignment.Left statLbl.Parent = mainFrame

makeBtn("🔄  ПРОВЕРИТЬ СЕЙЧАС", 84, 30, Color3.fromRGB(40, 80, 60), Color3.fromRGB(180, 255, 200), function()
    statLbl.Text = "Читаю GitHub..." statLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
    task.spawn(function()
        local ok, res = pcall(function() return game:HttpGet(STATUS_URL, true) end)
        if not ok or not res or #res == 0 then statLbl.Text = "❌ Ошибка чтения" statLbl.TextColor3 = Color3.fromRGB(255, 120, 120) return end
        local cl = res:gsub("%s+", ""):lower()
        if cl:find("off") then
            statLbl.Text = "⛔ Статус: OFF" statLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
            killScript()
        elseif cl:find("on") then statLbl.Text = "✅ Статус: ON" statLbl.TextColor3 = Color3.fromRGB(120, 255, 120)
        else statLbl.Text = "⚠ Нет on/off" statLbl.TextColor3 = Color3.fromRGB(255, 200, 0) end
    end)
end)

makeLbl("СВЯЗЬ", 144)
local tgBtn = makeBtn("📢  ССЫЛКА НА ТЕЛЕГРАМ", 164, 30, Color3.fromRGB(40, 60, 110), Color3.fromRGB(180, 220, 255))
local tgLbl = Instance.new("TextLabel") tgLbl.Size = UDim2.new(1, -32, 0, 18) tgLbl.Position = UDim2.new(0, 16, 0, 196) tgLbl.BackgroundTransparency = 1 tgLbl.Text = "" tgLbl.TextColor3 = Color3.fromRGB(0, 220, 255) tgLbl.Font = Enum.Font.GothamBold tgLbl.TextSize = 12 tgLbl.TextXAlignment = Enum.TextXAlignment.Left tgLbl.Parent = mainFrame
tgBtn.MouseButton1Click:Connect(function() tgLbl.Text = TG end)

makeLbl("ВОЗМОЖНОСТИ", 224)
flyBtn = makeBtn("✈  ФЛАЙ (3500): ВЫКЛ", 244, 36, Color3.fromRGB(60, 20, 90), Color3.fromRGB(230, 200, 255))
farmBtn = makeBtn("🎃  ФАРМ ТЫКВ: ВЫКЛ", 288, 36, Color3.fromRGB(50, 30, 20), Color3.fromRGB(255, 200, 140))

statusTxt = Instance.new("TextLabel") statusTxt.Size = UDim2.new(1, -32, 0, 20) statusTxt.Position = UDim2.new(0, 16, 0, 330) statusTxt.BackgroundTransparency = 1 statusTxt.Text = "Цель: не выбрана" statusTxt.TextColor3 = Color3.fromRGB(180, 160, 200) statusTxt.Font = Enum.Font.Gotham statusTxt.TextSize = 11 statusTxt.TextXAlignment = Enum.TextXAlignment.Left statusTxt.Parent = mainFrame

makeLbl("КРАЖА ЯИЦ", 360)
local zDefs = {
    {n = "Вулкан", c = Color3.fromRGB(200, 60, 0), a = V_MIN, b = V_MAX},
    {n = "Космос", c = Color3.fromRGB(60, 60, 160), a = C_MIN, b = C_MAX},
    {n = "Снег", c = Color3.fromRGB(0, 110, 160), a = S_MIN, b = S_MAX},
    {n = "Последняя", c = Color3.fromRGB(160, 0, 160), a = L_MIN, b = L_MAX},
    {n = "Демон", c = Color3.fromRGB(150, 0, 0), a = D_MIN, b = D_MAX}
}
for i, z in ipairs(zDefs) do
    makeBtn("🎯  КРАСТЬ: " .. z.n, 380 + (i - 1) * 34, 30, z.c, Color3.fromRGB(255, 255, 255), function()
        if checkStatusAndKill() then return end
        minX, maxX = z.a, z.b if countGui then countGui.Visible = true end
    end)
end

makeLbl("ИНСТРУМЕНТЫ", 558)
makeBtn("🔍  ЧЕКЕР ЯИЦ (17M+)", 578, 34, Color3.fromRGB(120, 90, 0), Color3.fromRGB(255, 230, 160))
local selTargetBtn = makeBtn("👤  ВЫБРАТЬ ЦЕЛЬ", 618, 34, Color3.fromRGB(30, 80, 40), Color3.fromRGB(180, 255, 200))
followBtn = makeBtn("👻  СЛЕДИТЬ + ИНВИЗ: ВЫКЛ", 658, 34, Color3.fromRGB(90, 50, 10), Color3.fromRGB(255, 210, 160))

makeLbl("УПРАВЛЕНИЕ", 700)
local unloadBtn = makeBtn("⛔  ВЫГРУЗИТЬ СКРИПТ", 720, 32, Color3.fromRGB(80, 15, 15), Color3.fromRGB(255, 180, 180))

countGui = Instance.new("Frame")
countGui.Size = UDim2.new(0, 200, 0, 250) countGui.Position = UDim2.new(0.5, -100, 0.5, -125) countGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20) countGui.Visible = false countGui.Active = true countGui.Draggable = true countGui.Parent = screenGui
local ct = Instance.new("TextLabel") ct.Size = UDim2.new(1, 0, 0, 30) ct.BackgroundTransparency = 1 ct.Text = "Сколько яиц украсть?" ct.TextColor3 = Color3.fromRGB(255, 255, 255) ct.Font = Enum.Font.GothamBold ct.TextSize = 14 ct.Parent = countGui
local cc = Instance.new("TextButton") cc.Size = UDim2.new(0, 25, 0, 25) cc.Position = UDim2.new(1, -30, 0, 5) cc.BackgroundTransparency = 1 cc.Text = "X" cc.TextColor3 = Color3.fromRGB(255, 50, 50) cc.Font = Enum.Font.GothamBold cc.TextSize = 18 cc.Parent = countGui
cc.MouseButton1Click:Connect(function() countGui.Visible = false end)

local function startSteal(num)
    countGui.Visible = false
    local c = player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local hrp = c.HumanoidRootPart statusTxt.Text = "Ищем..."
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
    if #eggs == 0 then statusTxt.Text = "Пусто." return end
    task.spawn(function()
        for i = 1, math.min(num, #eggs) do
            if not scriptAlive then return end
            local e = eggs[i]
            statusTxt.Text = "Яйцо " .. i .. " / " .. num
            hrp.CFrame = CFrame.new(e.p.Position + Vector3.new(0, 3, 0))
            task.wait(0.5) safePrompt(e.r) safeTouch(hrp, e.p)
            for j = 1, 5 do pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) task.wait(0.03) VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) task.wait(0.03) end) end
            task.wait(0.5)
        end
        hrp.CFrame = SPAWN statusTxt.Text = "Готово (" .. math.min(num, #eggs) .. ")"
    end)
end

for i = 1, 5 do
    local b = Instance.new("TextButton") b.Size = UDim2.new(1, -20, 0, 30) b.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * 40) b.BackgroundColor3 = Color3.fromRGB(60, 60, 60) b.Text = tostring(i) .. " шт." b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Font = Enum.Font.GothamBold b.TextSize = 14 b.Parent = countGui
    b.MouseButton1Click:Connect(function() 
        if checkStatusAndKill() then return end
        startSteal(i) 
    end)
end

flyBtn.MouseButton1Click:Connect(function()
    if checkStatusAndKill() then return end
    isFly = not isFly local char = player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if isFly then
        flyBtn.Text = "✈  ФЛАЙ (3500): ВКЛ"
        bVel = Instance.new("BodyVelocity") bVel.MaxForce = Vector3.new(1e6, 1e6, 1e6) bVel.Velocity = Vector3.new(0, 0, 0) bVel.Parent = char.HumanoidRootPart
        flyConn = RunService.RenderStepped:Connect(function()
            if not bVel or not bVel.Parent then return end
            local cam = workspace.CurrentCamera local m = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then m = m + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then m = m - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then m = m - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then m = m + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then m = m + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then m = m - Vector3.new(0, 1, 0) end
            bVel.Velocity = m.Magnitude > 0 and m.Unit * flySpd or Vector3.new(0, 0, 0)
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if bVel then bVel:Destroy() bVel = nil end
        flyBtn.Text = "✈  ФЛАЙ (3500): ВЫКЛ"
    end
end)

farmBtn.MouseButton1Click:Connect(function()
    if checkStatusAndKill() then return end
    isFarm = not isFarm farmBtn.Text = isFarm and "🎃  ФАРМ ТЫКВ: ВКЛ" or "🎃  ФАРМ ТЫКВ: ВЫКЛ" kills = 0
end)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        lastClick = tick()
        if isFarm and kills < 3 then kills = kills + 1 statusTxt.Text = "Убито: " .. kills .. "/3" end
        if isFarm and kills >= 3 and not isRep then
            isRep = true
            task.spawn(function()
                while isRep and isFarm do
                    if tick() - lastClick > 0.5 then VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1) task.wait(0.01) VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) end
                    task.wait(0.1)
                end
                isRep = false
            end)
        end
    end
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

selTargetBtn.MouseButton1Click:Connect(function()
    if checkStatusAndKill() then return end
    local g = Instance.new("ScreenGui") g.Parent = player:WaitForChild("PlayerGui")
    local f = Instance.new("ScrollingFrame") f.Size = UDim2.new(0, 200, 0, 200) f.Position = UDim2.new(0.5, -100, 0.5, -100) f.BackgroundColor3 = Color3.fromRGB(20, 20, 20) f.Parent = g
    local l = Instance.new("UIListLayout") l.Parent = f
    local cnt = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            cnt = cnt + 1
            local b = Instance.new("TextButton") b.Size = UDim2.new(1, -10, 0, 25) b.Position = UDim2.new(0, 5, 0, (cnt - 1) * 30) b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) b.Text = p.Name b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Parent = f
            b.MouseButton1Click:Connect(function() fTarget = p statusTxt.Text = "Цель: " .. p.Name g:Destroy() if isFollow then followBtn.MouseButton1Click() end end)
        end
    end
    f.CanvasSize = UDim2.new(0, 0, 0, cnt * 30)
end)

followBtn.MouseButton1Click:Connect(function()
    if checkStatusAndKill() then return end
    if not fTarget then statusTxt.Text = "Выбери цель!" return end
    isFollow = not isFollow
    if isFollow then
        followBtn.Text = "👻  СЛЕДИТЬ + ИНВИЗ: ВКЛ"
        local c = player.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0.7 p.CanCollide = false end end end
        fConn = RunService.Heartbeat:Connect(function()
            if not isFollow or not fTarget then return end
            local c2, t = player.Character, fTarget.Character
            if c2 and c2:FindFirstChild("HumanoidRootPart") and t and t:FindFirstChild("HumanoidRootPart") then
                local h = t:FindFirstChild("Humanoid")
                if h and h.Health > 0 then c2.HumanoidRootPart.CFrame = t.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) else statusTxt.Text = "Мертв" followBtn.MouseButton1Click() end
            end
        end)
    else
        followBtn.Text = "👻  СЛЕДИТЬ + ИНВИЗ: ВЫКЛ"
        if fConn then fConn:Disconnect() fConn = nil end
        local c = player.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 p.CanCollide = true end end end
    end
end)

unloadBtn.MouseButton1Click:Connect(function()
    killScript()
end)

task.spawn(function()
    while scriptAlive do
        task.wait(CHECK_INTERVAL)
        if not scriptAlive then break end
        local ok, res = pcall(function() return game:HttpGet(STATUS_URL, true) end)
        if ok and res and #res > 0 then
            local cl = res:gsub("%s+", ""):lower()
            if cl:find("off") then
                killScript()
                break
            end
        end
    end
end)

print("[#provokator] Меню загружено! Автопроверка каждые 5 сек.")
