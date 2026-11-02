-- ============================================
--  by #provokator
--  tg: @EroxEggScript
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local KILL_SWITCH_URL = "https://raw.githubusercontent.com/provokator-hub/Survive-the-Lava-for-Eggs-/refs/heads/main/status.txt"

local function checkStatus()
    local success, response = pcall(function()
        if request then
            local res = request({Url = KILL_SWITCH_URL, Method = "GET"})
            return res.Body
        else
            return game:HttpGet(KILL_SWITCH_URL)
        end
    end)
    if not success or not response then return true end
    response = string.upper(string.gsub(response, "%s+", ""))
    return response == "ON"
end

if not checkStatus() then
    local err = Instance.new("ScreenGui")
    err.Parent = player:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    frame.Parent = err
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = "❌ ДОСТУП ЗАПРЕЩЕН\nТГ: @EroxEggScript"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 14
    text.TextWrapped = true
    text.Parent = frame
    return
end

-- === ОСНОВНОЙ КОД ===
-- КООРДИНАТЫ ЗОН
local VOLCANO_CENTER = Vector3.new(673, 0, 0)
local VOLCANO_MIN_X, VOLCANO_MAX_X = 500, 800

local COSMIC_CENTER = Vector3.new(947, 0, 0)
local COSMIC_MIN_X, COSMIC_MAX_X = 800, 1100

local SNOW_CENTER = Vector3.new(2728, 0, 0) 
local SNOW_MIN_X, SNOW_MAX_X = 2500, 3000 

local LAST_CENTER = Vector3.new(3603, 0, 0) 
local LAST_MIN_X, LAST_MAX_X = 3400, 4000 

-- ДЕМОНИЧЕСКАЯ ЗОНА
local DEMONIC_CENTER = Vector3.new(4275, 0, -26)
local DEMONIC_MIN_X, DEMONIC_MAX_X = 4000, 4600 

local SPAWN_CFRAME = CFrame.new(0, 10, 0) 

local isFarmEnabled = false
local isRepeating = false
local lastFarmTime = 0
local lastClickTime = 0
local playerKills = 0
local KILLS_REQUIRED = 3 
local TG_TAG = "@EroxEggScript" 

-- СЛЕЖКА И ИНВИЗ
local followTarget = nil
local isFollowing = false
local followConnection = nil
local isGhostMode = false

-- ФЛАЙ
local isFlying = false
local flySpeed = 300 
local flyConnection = nil
local bodyVelocity = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProbokatorMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 40, 0, 40)
hideBtn.Position = UDim2.new(0, 10, 0, 10)
hideBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hideBtn.BorderSizePixel = 2
hideBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Text = "P"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 20
hideBtn.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 580) 
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local isMenuVisible = true
local function toggleMenu()
    isMenuVisible = not isMenuVisible
    mainFrame.Visible = isMenuVisible
end
hideBtn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        toggleMenu()
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "#provokator"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local tgBtn = Instance.new("TextButton")
tgBtn.Size = UDim2.new(1, -10, 0, 25)
tgBtn.Position = UDim2.new(0, 5, 0, 35)
tgBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) 
tgBtn.Text = "📢 ССЫЛКА ТГ"
tgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tgBtn.Font = Enum.Font.SourceSansBold
tgBtn.TextSize = 12
tgBtn.Parent = mainFrame
local tgLinkLabel = Instance.new("TextLabel")
tgLinkLabel.Size = UDim2.new(1, -10, 0, 20)
tgLinkLabel.Position = UDim2.new(0, 5, 0, 60)
tgLinkLabel.BackgroundTransparency = 1
tgLinkLabel.Text = "" 
tgLinkLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
tgLinkLabel.Font = Enum.Font.SourceSansBold
tgLinkLabel.TextSize = 12
tgLinkLabel.Parent = mainFrame
tgBtn.MouseButton1Click:Connect(function() tgLinkLabel.Text = TG_TAG end)

local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(1, -10, 0, 25)
infoBtn.Position = UDim2.new(0, 5, 0, 80)
infoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
infoBtn.Text = "ℹ️ Информация"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.Font = Enum.Font.SourceSansBold
infoBtn.TextSize = 12
infoBtn.Parent = mainFrame
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0, 220, 0, 110)
infoFrame.Position = UDim2.new(0.5, -110, 0.5, -55)
infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infoFrame.BorderSizePixel = 2
infoFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
infoFrame.Visible = false
infoFrame.Parent = screenGui
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, -30)
infoText.Position = UDim2.new(0, 5, 0, 5)
infoText.BackgroundTransparency = 1
infoText.Text = "Слежка + Инвиз.\nSteal зоны по 2 яйца.\nФлай: 300 скорость."
infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
infoText.Font = Enum.Font.SourceSans
infoText.TextSize = 12
infoText.TextWrapped = true
infoText.Parent = infoFrame
local closeInfo = Instance.new("TextButton")
closeInfo.Size = UDim2.new(0, 70, 0, 25)
closeInfo.Position = UDim2.new(0.5, -35, 1, -30)
closeInfo.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeInfo.Text = "Закрыть"
closeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
closeInfo.Font = Enum.Font.SourceSansBold
closeInfo.TextSize = 12
closeInfo.Parent = infoFrame
closeInfo.MouseButton1Click:Connect(function() infoFrame.Visible = false end)
infoBtn.MouseButton1Click:Connect(function() infoFrame.Visible = not infoFrame.Visible end)

-- ФЛАЙ (ДОБАВЛЕН)
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -10, 0, 30)
flyBtn.Position = UDim2.new(0, 5, 0, 110)
flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
flyBtn.Text = "ФЛАЙ (БЫСТРЫЙ): ВЫКЛ"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 12
flyBtn.Parent = mainFrame

local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, -10, 0, 30)
farmBtn.Position = UDim2.new(0, 5, 0, 145)
farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmBtn.Text = "ФАРМ: ВЫКЛ"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Font = Enum.Font.SourceSansBold
farmBtn.TextSize = 12
farmBtn.Parent = mainFrame

-- КНОПКИ ЗОН
local volcanoBtn = Instance.new("TextButton")
volcanoBtn.Size = UDim2.new(1, -10, 0, 30)
volcanoBtn.Position = UDim2.new(0, 5, 0, 180)
volcanoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 0)
volcanoBtn.Text = "StealVolcanoZone (2 яйца)"
volcanoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
volcanoBtn.Font = Enum.Font.SourceSansBold
volcanoBtn.TextSize = 12
volcanoBtn.Parent = mainFrame

local cosmicBtn = Instance.new("TextButton")
cosmicBtn.Size = UDim2.new(1, -10, 0, 30)
cosmicBtn.Position = UDim2.new(0, 5, 0, 215)
cosmicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
cosmicBtn.Text = "StealCosmicZone (2 яйца)"
cosmicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cosmicBtn.Font = Enum.Font.SourceSansBold
cosmicBtn.TextSize = 12
cosmicBtn.Parent = mainFrame

local snowZoneBtn = Instance.new("TextButton")
snowZoneBtn.Size = UDim2.new(1, -10, 0, 30)
snowZoneBtn.Position = UDim2.new(0, 5, 0, 250)
snowZoneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
snowZoneBtn.Text = "StealSnowZone (2 яйца)"
snowZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
snowZoneBtn.Font = Enum.Font.SourceSansBold
snowZoneBtn.TextSize = 12
snowZoneBtn.Parent = mainFrame

local lastZoneBtn = Instance.new("TextButton")
lastZoneBtn.Size = UDim2.new(1, -10, 0, 30)
lastZoneBtn.Position = UDim2.new(0, 5, 0, 285)
lastZoneBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
lastZoneBtn.Text = "StealLastZone (2 яйца)"
lastZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lastZoneBtn.Font = Enum.Font.SourceSansBold
lastZoneBtn.TextSize = 12
lastZoneBtn.Parent = mainFrame

local demonicBtn = Instance.new("TextButton")
demonicBtn.Size = UDim2.new(1, -10, 0, 30)
demonicBtn.Position = UDim2.new(0, 5, 0, 320)
demonicBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
demonicBtn.Text = "StealDemonicZone (2 яйца)"
demonicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
demonicBtn.Font = Enum.Font.SourceSansBold
demonicBtn.TextSize = 12
demonicBtn.Parent = mainFrame

local selectTargetBtn = Instance.new("TextButton")
selectTargetBtn.Size = UDim2.new(1, -10, 0, 30)
selectTargetBtn.Position = UDim2.new(0, 5, 0, 355)
selectTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
selectTargetBtn.Text = "Выбрать цель"
selectTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectTargetBtn.Font = Enum.Font.SourceSansBold
selectTargetBtn.TextSize = 12
selectTargetBtn.Parent = mainFrame

local followBtn = Instance.new("TextButton")
followBtn.Size = UDim2.new(1, -10, 0, 30)
followBtn.Position = UDim2.new(0, 5, 0, 390)
followBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
followBtn.Text = "Следить + Инвиз: ВЫКЛ"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.Font = Enum.Font.SourceSansBold
followBtn.TextSize = 12
followBtn.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 25)
statusText.Position = UDim2.new(0, 5, 0, 425)
statusText.BackgroundTransparency = 1
statusText.Text = "Цель: не выбрана"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 11
statusText.TextWrapped = true
statusText.Parent = mainFrame

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 25)
unloadBtn.Position = UDim2.new(0, 5, 1, -30)
unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
unloadBtn.Text = "ВЫГРУЗИТЬ"
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.TextSize = 12
unloadBtn.Parent = mainFrame

-- ЛОГИКА ФЛАЯ
local function stopFly()
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    isFlying = false
    flyBtn.Text = "ФЛАЙ (БЫСТРЫЙ): ВЫКЛ"
    flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
end

flyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if isFlying then
        flyBtn.Text = "ФЛАЙ (БЫСТРЫЙ): ВКЛ"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        flyConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then
                bodyVelocity.Velocity = moveDir.Unit * flySpeed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        stopFly()
    end
end)

-- ЛОГИКА ИНВИЗА
local function enableGhostMode()
    isGhostMode = true
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.7
            part.CanCollide = false
        end
    end
end

local function disableGhostMode()
    isGhostMode = false
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end
end

-- ЛОГИКА СЛЕЖКИ
local function stopFollowing()
    isFollowing = false
    followBtn.Text = "Следить + Инвиз: ВЫКЛ"
    followBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    if followConnection then followConnection:Disconnect() end
    disableGhostMode()
end

selectTargetBtn.MouseButton1Click:Connect(function()
    local listGui = Instance.new("ScreenGui")
    listGui.Parent = player:WaitForChild("PlayerGui")
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0, 200, 0, 200)
    listFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    listFrame.BorderSizePixel = 2
    listFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.Parent = listGui
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = listFrame
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, (count-1)*30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.Parent = listFrame
            btn.MouseButton1Click:Connect(function()
                followTarget = plr
                statusText.Text = "Цель: " .. plr.Name
                listGui:Destroy()
                stopFollowing()
            end)
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, count*30)
end)

followBtn.MouseButton1Click:Connect(function()
    if followTarget == nil then
        statusText.Text = "Сначала выбери цель!"
        return
    end
    isFollowing = not isFollowing
    if isFollowing then
        followBtn.Text = "Следить + Инвиз: ВКЛ"
        followBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        enableGhostMode()
        followConnection = RunService.Heartbeat:Connect(function()
            if not isFollowing or not followTarget then return end
            local char = player.Character
            local targetChar = followTarget.Character
            if char and char:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local hum = targetChar:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    pcall(function()
                        firetouchinterest(char.HumanoidRootPart, targetChar.HumanoidRootPart, 0)
                        firetouchinterest(char.HumanoidRootPart, targetChar.HumanoidRootPart, 1)
                    end)
                else
                    statusText.Text = "Цель мертва."
                    stopFollowing()
                end
            end
        end)
    else
        stopFollowing()
    end
end)

-- ФАРМ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        lastClickTime = tick()
        if isFarmEnabled and playerKills < KILLS_REQUIRED then
            playerKills = playerKills + 1
            statusText.Text = "Убито: " .. playerKills .. "/" .. KILLS_REQUIRED
            if playerKills >= KILLS_REQUIRED then statusText.Text = "Разблокировано!" end
        end
        if isFarmEnabled and playerKills >= KILLS_REQUIRED and not isRepeating then
            isRepeating = true
            task.spawn(function()
                while isRepeating and isFarmEnabled do
                    if tick() - lastClickTime > 0.5 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        task.wait(0.1)
                    end
                    task.wait(0.05)
                end
                isRepeating = false
            end)
        end
    end
end)

local function farmLogic()
    if not isFarmEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if playerKills < KILLS_REQUIRED then
        local pumpkinsFolder = workspace:FindFirstChild("HalloweenPumpkins")
        if pumpkinsFolder then
            for _, pumpkin in pairs(pumpkinsFolder:GetChildren()) do
                if pumpkin.Name == "Pumpkin" then
                    local part = pumpkin.PrimaryPart or pumpkin:FindFirstChildWhichIsA("BasePart")
                    if part then hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) return end
                end
            end
        end
        return
    end
    local pumpkinsFolder = workspace:FindFirstChild("HalloweenPumpkins")
    if pumpkinsFolder then
        for _, pumpkin in pairs(pumpkinsFolder:GetChildren()) do
            if pumpkin.Name == "Pumpkin" then
                local part = pumpkin.PrimaryPart or pumpkin:FindFirstChildWhichIsA("BasePart")
                if part then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    pcall(function() firetouchinterest(hrp, part, 0); firetouchinterest(hrp, part, 1) end)
                    local prompt = pumpkin:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then pcall(function() fireproximityprompt(prompt) end) end
                    return
                end
            end
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("spider") or obj.Name:lower():find("boss")) then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part and part.Position.X >= SNOW_MIN_X and part.Position.X <= LAST_MAX_X then
                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                return
            end
        end
    end
end

-- ВОРОВСТВО 2 ЯИЦ
local function stealTwoEggsInZone(zoneCenter, minX, maxX)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    statusText.Text = "Ищем яйца..."
    
    local eggsInZone = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Egg" and (obj:IsA("Part") or obj:IsA("Model")) then
            local prompt = obj:FindFirstChild("StealPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local part = obj:IsA("Part") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part and part.Position.X >= minX and part.Position.X <= maxX then
                    table.insert(eggsInZone, {obj = obj, part = part, prompt = prompt})
                end
            end
        end
    end

    if #eggsInZone == 0 then
        statusText.Text = "В зоне пусто."
        return
    end

    local eggsToSteal = {}
    table.insert(eggsToSteal, eggsInZone[1])
    if #eggsInZone >= 2 then
        table.insert(eggsToSteal, eggsInZone[2])
    end

    for i, eggData in ipairs(eggsToSteal) do
        statusText.Text = "Берем яйцо " .. i
        hrp.CFrame = CFrame.new(eggData.part.Position + Vector3.new(0, 3, 0))
        task.wait(0.3) 
        pcall(function() fireproximityprompt(eggData.prompt) end)
        pcall(function() firetouchinterest(hrp, eggData.part, 0); firetouchinterest(hrp, eggData.part, 1) end)
        for j = 1, 5 do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.03)
        end
        task.wait(0.2)
    end

    hrp.CFrame = SPAWN_CFRAME
    statusText.Text = "Собрали " .. #eggsToSteal .. " яиц!"
end

RunService.Heartbeat:Connect(function()
    if isFarmEnabled and tick() - lastFarmTime > 0.5 then
        lastFarmTime = tick()
        farmLogic()
    end
end)

farmBtn.MouseButton1Click:Connect(function()
    isFarmEnabled = not isFarmEnabled
    if isFarmEnabled then
        playerKills = 0
        farmBtn.Text = "ФАРМ: ВКЛ"
        farmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        statusText.Text = "Убей 3 тыквы!"
    else
        farmBtn.Text = "ФАРМ: ВЫКЛ"
        farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        statusText.Text = "Фарм выкл."
        isRepeating = false
    end
end)

volcanoBtn.MouseButton1Click:Connect(function() statusText.Text = "Ищем в Вулкане..." stealTwoEggsInZone(VOLCANO_CENTER, VOLCANO_MIN_X, VOLCANO_MAX_X) end)
cosmicBtn.MouseButton1Click:Connect(function() statusText.Text = "Ищем в Космосе..." stealTwoEggsInZone(COSMIC_CENTER, COSMIC_MIN_X, COSMIC_MAX_X) end)
snowZoneBtn.MouseButton1Click:Connect(function() statusText.Text = "Ищем в Морозной..." stealTwoEggsInZone(SNOW_CENTER, SNOW_MIN_X, SNOW_MAX_X) end)
lastZoneBtn.MouseButton1Click:Connect(function() statusText.Text = "Ищем в Призрачной..." stealTwoEggsInZone(LAST_CENTER, LAST_MIN_X, LAST_MAX_X) end)
demonicBtn.MouseButton1Click:Connect(function() statusText.Text = "Ищем в Демонической..." stealTwoEggsInZone(DEMONIC_CENTER, DEMONIC_MIN_X, DEMONIC_MAX_X) end)

unloadBtn.MouseButton1Click:Connect(function()
    isFarmEnabled = false
    isRepeating = false
    stopFollowing()
    stopFly()
    screenGui:Destroy()
    print("[#provokator] Скрипт выгружен.")
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, 0, 0, 20)
closeBtn.Position = UDim2.new(0, 0, 1, -20)
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeBtn.Text = "Закрыть"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 10
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function() 
    stopFollowing()
    stopFly()
    screenGui:Destroy() 
end)
