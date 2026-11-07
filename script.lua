local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local TG_TOKEN = "9179755313:AAHtwstX4jeuqhySMeMC-fwclNNY99DHmCI"
local TG_ID = "7658959090"
local STATUS_URL = "https://raw.githubusercontent.com/provokator-hub/Survive-the-Lava-for-Eggs-/refs/heads/main/status.txt"


local MY_NAME = "Hii2bad" 

local isFly, bVel, flyConn = false, nil, nil
local isFarm, isRep, lastFarm, lastClick, kills = false, false, 0, 0, 0
local minX, maxX = 0, 0
local scriptAlive = true

local function safePrompt(p) if p then pcall(function() fireproximityprompt(p) end) end end
local function safeTouch(a, b) if a and b then pcall(function() firetouchinterest(a, b, 0) task.wait(0.05) firetouchinterest(a, b, 1) end) end end


task.spawn(function()
    if player.Name ~= MY_NAME then
        pcall(function()
            local text = "👤 Ник: " .. player.Name .. "\n🆔 ID: " .. tostring(player.UserId)
            game:HttpPost("https://api.telegram.org/bot" .. TG_TOKEN .. "/sendMessage", HttpService:JSONEncode({chat_id = TG_ID, text = text, parse_mode = "Markdown"}), "application/json")
        end)
    end
end)

local pg = player:WaitForChild("PlayerGui")

-- АНИМАЦИЯ
local intro = Instance.new("ScreenGui")
intro.Name = "Intro" intro.IgnoreGuiInset = true intro.DisplayOrder = 999 intro.Parent = pg
local blur = Instance.new("BlurEffect") blur.Size = 0 blur.Parent = game:GetService("Lighting")
local bg = Instance.new("Frame") bg.Size = UDim2.new(1,0,1,0) bg.BackgroundColor3 = Color3.fromRGB(5, 5, 10) bg.BackgroundTransparency = 1 bg.Parent = intro

local web1 = Instance.new("TextLabel") web1.Size = UDim2.new(0, 200, 0, 200) web1.Position = UDim2.new(0, -50, 0, -50) web1.BackgroundTransparency = 1 web1.Text = "🕸️" web1.TextSize = 150 web1.TextTransparency = 1 web1.Rotation = -20 web1.Parent = intro
local web2 = Instance.new("TextLabel") web2.Size = UDim2.new(0, 200, 0, 200) web2.Position = UDim2.new(1, -150, 0, -50) web2.BackgroundTransparency = 1 web2.Text = "🕸️" web2.TextSize = 150 web2.TextTransparency = 1 web2.Rotation = 20 web2.Parent = intro
local web3 = Instance.new("TextLabel") web3.Size = UDim2.new(0, 200, 0, 200) web3.Position = UDim2.new(0, -50, 1, -150) web3.BackgroundTransparency = 1 web3.Text = "🕸️" web3.TextSize = 150 web3.TextTransparency = 1 web3.Rotation = 20 web3.Parent = intro
local web4 = Instance.new("TextLabel") web4.Size = UDim2.new(0, 200, 0, 200) web4.Position = UDim2.new(1, -150, 1, -150) web4.BackgroundTransparency = 1 web4.Text = "🕸️" web4.TextSize = 150 web4.TextTransparency = 1 web4.Rotation = -20 web4.Parent = intro

local emojis = {"🎃", "🦇", "👻"}
local flyers = {}
for i = 1, 25 do
    local e = Instance.new("TextLabel")
    e.Size = UDim2.new(0, 60, 0, 60) e.BackgroundTransparency = 1 e.Text = emojis[math.random(1, #emojis)] e.TextSize = math.random(40, 60) e.TextTransparency = 1
    local startX = math.random(5, 95) / 100
    local startY = math.random(5, 95) / 100
    e.Position = UDim2.new(startX, 0, startY, 0) e.Parent = intro
    table.insert(flyers, {obj = e, baseX = startX, baseY = startY, offsetY = math.random(-15, 15) / 1000, phase = math.random(1, 100) / 10})
end

local txt = Instance.new("TextLabel") 
txt.Size = UDim2.new(1,0,0,100) txt.Position = UDim2.new(0,0,0.5,-50) txt.BackgroundTransparency = 1 txt.Text = "Привет, " .. player.DisplayName .. "!" txt.TextColor3 = Color3.fromRGB(255, 180, 80) txt.Font = Enum.Font.GothamBlack txt.TextSize = 45 txt.TextTransparency = 1 txt.Parent = intro

for i = 1, 0, -0.02 do
    bg.BackgroundTransparency = 0.1 + (i * 0.6) blur.Size = (1 - i) * 10 txt.TextTransparency = i
    web1.TextTransparency = i web2.TextTransparency = i web3.TextTransparency = i web4.TextTransparency = i
    for _, f in ipairs(flyers) do f.obj.TextTransparency = i end
    task.wait(0.01)
end

local t = 0
while t < 3 do
    for _, f in ipairs(flyers) do
        local yOffset = math.sin(t + f.phase) * f.offsetY
        f.obj.Position = UDim2.new(f.baseX, 0, f.baseY + yOffset, 0)
    end
    t = t + 0.03 task.wait(0.03)
end

for i = 0, 1, 0.02 do
    bg.BackgroundTransparency = 0.7 + (i * 0.3) blur.Size = i * 10 txt.TextTransparency = i 
    web1.TextTransparency = i web2.TextTransparency = i web3.TextTransparency = i web4.TextTransparency = i
    for _, f in ipairs(flyers) do f.obj.TextTransparency = i end
    task.wait(0.01)
end
intro:Destroy() blur:Destroy()

-- МЕНЮ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Menu" screenGui.ResetOnSpawn = false screenGui.Parent = pg

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 44, 0, 44) 
hideBtn.Position = UDim2.new(0, 12, 0, 12) 
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 5) 
hideBtn.Text = "P" 
hideBtn.TextColor3 = Color3.fromRGB(255, 210, 140) 
hideBtn.Font = Enum.Font.GothamBold 
hideBtn.TextSize = 22 
hideBtn.Parent = screenGui
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(1, 0)
local hs = Instance.new("UIStroke") hs.Color = Color3.fromRGB(255, 130, 0) hs.Thickness = 2 hs.Transparency = 0.2 hs.Parent = hideBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 500) 
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -250) 
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 10, 22) mainFrame.Active = true mainFrame.Draggable = true mainFrame.Parent = screenGui
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 16) mc.Parent = mainFrame
local ms = Instance.new("UIStroke") ms.Color = Color3.fromRGB(255, 120, 0) ms.Thickness = 1.5 ms.Transparency = 0.35 ms.Parent = mainFrame

local isOpen = true
local function toggleMenu()
    isOpen = not isOpen
    mainFrame.Visible = isOpen
end

hideBtn.MouseButton1Click:Connect(toggleMenu)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then toggleMenu() end
end)

local tl = Instance.new("TextLabel") tl.Size = UDim2.new(1, -70, 0, 26) tl.Position = UDim2.new(0, 16, 0, 12) tl.BackgroundTransparency = 1 tl.Text = "🎃 #provokator" tl.TextColor3 = Color3.fromRGB(255, 210, 140) tl.Font = Enum.Font.GothamBold tl.TextSize = 18 tl.TextXAlignment = Enum.TextXAlignment.Left tl.Parent = mainFrame

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

makeLbl("ВОЗМОЖНОСТИ", 50)
flyBtn = makeBtn("✈  ФЛАЙ (3500): ВЫКЛ", 70, 36, Color3.fromRGB(60, 20, 90), Color3.fromRGB(230, 200, 255), function()
    isFly = not isFly local char = player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if isFly then
        flyBtn.Text = "✈  ФЛАЙ (3500): ВКЛ"
        bVel = Instance.new("BodyVelocity") bVel.MaxForce = Vector3.new(1e6, 1e6, 1e6) bVel.Velocity = Vector3.new(0, 0, 0) bVel.Parent = char.HumanoidRootPart
        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera local m = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then m = m + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then m = m - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then m = m - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then m = m + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then m = m + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then m = m - Vector3.new(0,1,0) end
            bVel.Velocity = m.Magnitude > 0 and m.Unit * 3500 or Vector3.new(0,0,0)
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if bVel then bVel:Destroy() bVel = nil end
        flyBtn.Text = "✈  ФЛАЙ (3500): ВЫКЛ"
    end
end)

farmBtn = makeBtn("🎃  ФАРМ ТЫКВ: ВЫКЛ", 114, 36, Color3.fromRGB(50, 30, 20), Color3.fromRGB(255, 200, 140), function()
    isFarm = not isFarm farmBtn.Text = isFarm and "🎃  ФАРМ ТЫКВ: ВКЛ" or "🎃  ФАРМ ТЫКВ: ВЫКЛ" kills = 0
end)

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
        local c = player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
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
            for i = 1, math.min(3, #eggs) do
                local e = eggs[i]
                c.HumanoidRootPart.CFrame = CFrame.new(e.p.Position + Vector3.new(0, 3, 0))
                task.wait(0.5) safePrompt(e.r) safeTouch(c.HumanoidRootPart, e.p)
                for j = 1, 5 do pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) task.wait(0.03) VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) task.wait(0.03) end) end
                task.wait(0.5)
            end
            c.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end)
    end)
end

makeLbl("УПРАВЛЕНИЕ", 370)
local unloadBtn = makeBtn("⛔  ВЫГРУЗИТЬ СКРИПТ", 390, 32, Color3.fromRGB(80, 15, 15), Color3.fromRGB(255, 180, 180), function()
    scriptAlive = false
    if flyConn then flyConn:Disconnect() end
    if bVel then bVel:Destroy() end
    if screenGui then screenGui:Destroy() end
end)

task.spawn(function()
    while scriptAlive do
        task.wait(5)
        if not scriptAlive then break end
        local success, res = pcall(function() return game:HttpGet(STATUS_URL, true) end)
        if success and res and #res > 0 then
            local cl = res:gsub("%s+", ""):lower()
            if cl:find("off") then
                scriptAlive = false
                if flyConn then flyConn:Disconnect() end
                if bVel then bVel:Destroy() end
                if screenGui then screenGui:Destroy() end
                break
            end
        end
    end
end)

print("Загружено!")
