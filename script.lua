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

-- Функция проверки статуса
local function checkStatus()
    local success, response = pcall(function()
        if request then
            local res = request({Url = KILL_SWITCH_URL, Method = "GET"})
            return res.Body
        else
            return game:HttpGet(KILL_SWITCH_URL)
        end
    end)
    
    if not success or not response then
        warn("⚠️ Ошибка проверки GitHub. Скрипт запущен в аварийном режиме.")
        return true 
    end
    
    response = string.upper(string.gsub(response, "%s+", ""))
    if response == "ON" then
        return true
    end
    return false
end

-- ПРОВЕРКА
if not checkStatus() then
    local err = Instance.new("ScreenGui")
    err.Name = "LicenseError"
    err.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(0.5, -150, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    frame.Parent = err

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = "❌ ДОСТУП ЗАПРЕЩЕН\nСкрипт отключен владельцем.\n\nПодробнее в ТГ: @EroxEggScript"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 16
    text.TextWrapped = true
    text.Parent = frame

    return
end

-- === ОСНОВНОЙ КОД ===
local SNOW_CENTER = Vector3.new(2728, 0, 0) 
local SPAWN_CFRAME = CFrame.new(0, 10, 0) 
local MIN_X = 2200 
local MAX_X = 3000 

local isFarmEnabled = false
local isRepeating = false
local lastFarmTime = 0
local lastClickTime = 0
local playerKills = 0
local KILLS_REQUIRED = 3 
local TG_TAG = "@EroxEggScript" 

-- ФЛАЙ
local isFlying = false
local flySpeed = 3
local flyConnection = nil
local bodyVelocity = nil

-- GUI (УМЕНЬШЕНО ДЛЯ ТЕЛЕФОНА)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProbokatorStealSnowZone"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 260) -- Уменьшено
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "#provokator"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.TextWrapped = true
title.Parent = mainFrame

local tgBtn = Instance.new("TextButton")
tgBtn.Size = UDim2.new(1, -10, 0, 25)
tgBtn.Position = UDim2.new(0, 5, 0, 35)
tgBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) 
tgBtn.BorderSizePixel = 1
tgBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
tgBtn.Text = "📢 ССЫЛКА ТГ"
tgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tgBtn.Font = Enum.Font.SourceSansBold
tgBtn.TextSize = 10
tgBtn.Parent = mainFrame

local tgLinkLabel = Instance.new("TextLabel")
tgLinkLabel.Size = UDim2.new(1, -10, 0, 15)
tgLinkLabel.Position = UDim2.new(0, 5, 0, 60)
tgLinkLabel.BackgroundTransparency = 1
tgLinkLabel.Text = "" 
tgLinkLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
tgLinkLabel.Font = Enum.Font.SourceSansBold
tgLinkLabel.TextSize = 11
tgLinkLabel.Parent = mainFrame

local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(1, -10, 0, 25)
infoBtn.Position = UDim2.new(0, 5, 0, 80)
infoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
infoBtn.BorderSizePixel = 1
infoBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.Text = "ℹ️ ИНФО"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.Font = Enum.Font.SourceSansBold
infoBtn.TextSize = 10
infoBtn.Parent = mainFrame

local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, -10, 0, 30)
farmBtn.Position = UDim2.new(0, 5, 0, 110)
farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmBtn.BorderSizePixel = 1
farmBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Text = "ФАРМ: ВЫКЛ"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Font = Enum.Font.SourceSansBold
farmBtn.TextSize = 11
farmBtn.Parent = mainFrame

local snowZoneBtn = Instance.new("TextButton")
snowZoneBtn.Size = UDim2.new(1, -10, 0, 30)
snowZoneBtn.Position = UDim2.new(0, 5, 0, 145)
snowZoneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
snowZoneBtn.BorderSizePixel = 1
snowZoneBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
snowZoneBtn.Text = "StealSnowZone (Дивайн)"
snowZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
snowZoneBtn.Font = Enum.Font.SourceSansBold
snowZoneBtn.TextSize = 11
snowZoneBtn.Parent = mainFrame

-- КНОПКА ФЛАЙ
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -10, 0, 30)
flyBtn.Position = UDim2.new(0, 5, 0, 180)
flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
flyBtn.BorderSizePixel = 1
flyBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Text = "ФЛАЙ: ВЫКЛ"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 11
flyBtn.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 25)
statusText.Position = UDim2.new(0, 5, 0, 215)
statusText.BackgroundTransparency = 1
statusText.Text = "Статус: Готов"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 10
statusText.TextWrapped = true
statusText.Parent = mainFrame

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 20)
unloadBtn.Position = UDim2.new(0, 5, 1, -25)
unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
unloadBtn.BorderSizePixel = 1
unloadBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Text = "ВЫГРУЗИТЬ"
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.TextSize = 10
unloadBtn.Parent = mainFrame

-- Ссылка
tgBtn.MouseButton1Click:Connect(function()
    tgLinkLabel.Text = TG_TAG
end)

-- Инфо
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0, 200, 0, 120)
infoFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infoFrame.BorderSizePixel = 2
infoFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
infoFrame.Visible = false
infoFrame.Parent = screenGui

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, -30)
infoText.Position = UDim2.new(0, 5, 0, 5)
infoText.BackgroundTransparency = 1
infoText.Text = "Фарм работает после 3 убийств тыкв."
infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
infoText.Font = Enum.Font.SourceSans
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.Parent = infoFrame

local closeInfoBtn = Instance.new("TextButton")
closeInfoBtn.Size = UDim2.new(0, 60, 0, 20)
closeInfoBtn.Position = UDim2.new(0.5, -30, 1, -25)
closeInfoBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeInfoBtn.Text = "Закрыть"
closeInfoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeInfoBtn.Font = Enum.Font.SourceSansBold
closeInfoBtn.TextSize = 10
closeInfoBtn.Parent = infoFrame

closeInfoBtn.MouseButton1Click:Connect(function()
    infoFrame.Visible = false
end)

infoBtn.MouseButton1Click:Connect(function()
    infoFrame.Visible = not infoFrame.Visible
end)

-- ФЛАЙ ЛОГИКА
local function stopFly()
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    isFlying = false
    flyBtn.Text = "ФЛАЙ: ВЫКЛ"
    flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
end

flyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if isFlying then
        flyBtn.Text = "ФЛАЙ: ВКЛ"
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

-- Фарм
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        lastClickTime = tick()
        if isFarmEnabled and playerKills < KILLS_REQUIRED then
            playerKills = playerKills + 1
            statusText.Text = "Убито: " .. playerKills .. "/" .. KILLS_REQUIRED
            if playerKills >= KILLS_REQUIRED then
                statusText.Text = "Разблокировано!"
            end
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
                    if part then
                        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                        statusText.Text = "Убей: " .. (KILLS_REQUIRED - playerKills)
                        return
                    end
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
                    statusText.Text = "Бьем..."
                    return
                end
            end
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("spider") or obj.Name:lower():find("boss")) then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                if part.Position.X >= MIN_X and part.Position.X <= MAX_X then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    statusText.Text = "Бьем моба..."
                    return
                end
            end
        end
    end
end

local function StealSnowZone()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    hrp.CFrame = CFrame.new(SNOW_CENTER + Vector3.new(0, 10, 0))
    task.wait(0.2)

    local biggestEgg = nil
    local maxVolume = 0
    local targetPart = nil
    local targetPrompt = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Egg" and (obj:IsA("Part") or obj:IsA("Model")) then
            local prompt = obj:FindFirstChild("StealPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then prompt = child break end
                end
            end
            if prompt then
                local part = nil
                if obj:IsA("Part") then part = obj
                elseif obj:IsA("Model") then part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end
                if part then
                    local posX = part.Position.X
                    if posX >= MIN_X and posX <= MAX_X then
                        local size = part.Size
                        local volume = size.X * size.Y * size.Z
                        if volume > maxVolume then
                            maxVolume = volume
                            biggestEgg = obj
                            targetPart = part
                            targetPrompt = prompt
                        end
                    end
                end
            end
        end
    end

    if targetPart and targetPrompt then
        hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
        task.wait(0.2)

        for i = 1, 15 do
            if not targetPart or not targetPart.Parent then break end
            pcall(function() fireproximityprompt(targetPrompt) end)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.05)
        end

        hrp.CFrame = SPAWN_CFRAME
        statusText.Text = "Украли!"
    else
        statusText.Text = "В Снегу пусто."
    end
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

snowZoneBtn.MouseButton1Click:Connect(function()
    statusText.Text = "Ищем Дивайн..."
    StealSnowZone()
end)

unloadBtn.MouseButton1Click:Connect(function()
    isFarmEnabled = false
    isRepeating = false
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
    stopFly()
    screenGui:Destroy() 
end)
