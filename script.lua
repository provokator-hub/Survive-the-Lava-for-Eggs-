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

-- Проверка статуса
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
local flySpeed = 50 -- Скорость по умолчанию
local flyConnection = nil
local bodyVelocity = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProbokatorMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Кнопка скрытия (маленькая, всегда на экране)
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 40, 0, 40)
hideBtn.Position = UDim2.new(0, 10, 0, 10)
hideBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hideBtn.BorderSizePixel = 2
hideBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Text = "P"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextSize = 18
hideBtn.Parent = screenGui

-- Основное меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Логика скрытия/показа
local isMenuVisible = true
hideBtn.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    mainFrame.Visible = isMenuVisible
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "#provokator"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = mainFrame

-- Ссылка ТГ
local tgBtn = Instance.new("TextButton")
tgBtn.Size = UDim2.new(1, -10, 0, 20)
tgBtn.Position = UDim2.new(0, 5, 0, 30)
tgBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) 
tgBtn.Text = "📢 ТГ"
tgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tgBtn.Font = Enum.Font.SourceSansBold
tgBtn.TextSize = 10
tgBtn.Parent = mainFrame

local tgLinkLabel = Instance.new("TextLabel")
tgLinkLabel.Size = UDim2.new(1, -10, 0, 15)
tgLinkLabel.Position = UDim2.new(0, 5, 0, 50)
tgLinkLabel.BackgroundTransparency = 1
tgLinkLabel.Text = "" 
tgLinkLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
tgLinkLabel.Font = Enum.Font.SourceSansBold
tgLinkLabel.TextSize = 10
tgLinkLabel.Parent = mainFrame

tgBtn.MouseButton1Click:Connect(function()
    tgLinkLabel.Text = TG_TAG
end)

-- Инфо
local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(1, -10, 0, 20)
infoBtn.Position = UDim2.new(0, 5, 0, 65)
infoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
infoBtn.Text = "ℹ️ Инфо"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.Font = Enum.Font.SourceSansBold
infoBtn.TextSize = 10
infoBtn.Parent = mainFrame

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0, 200, 0, 100)
infoFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
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

local closeInfo = Instance.new("TextButton")
closeInfo.Size = UDim2.new(0, 60, 0, 20)
closeInfo.Position = UDim2.new(0.5, -30, 1, -25)
closeInfo.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeInfo.Text = "Закрыть"
closeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
closeInfo.Font = Enum.Font.SourceSansBold
closeInfo.TextSize = 10
closeInfo.Parent = infoFrame
closeInfo.MouseButton1Click:Connect(function() infoFrame.Visible = false end)
infoBtn.MouseButton1Click:Connect(function() infoFrame.Visible = not infoFrame.Visible end)

-- Фарм
local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, -10, 0, 25)
farmBtn.Position = UDim2.new(0, 5, 0, 90)
farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmBtn.Text = "ФАРМ: ВЫКЛ"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Font = Enum.Font.SourceSansBold
farmBtn.TextSize = 10
farmBtn.Parent = mainFrame

-- StealSnowZone
local snowZoneBtn = Instance.new("TextButton")
snowZoneBtn.Size = UDim2.new(1, -10, 0, 25)
snowZoneBtn.Position = UDim2.new(0, 5, 0, 120)
snowZoneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
snowZoneBtn.Text = "StealSnowZone"
snowZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
snowZoneBtn.Font = Enum.Font.SourceSansBold
snowZoneBtn.TextSize = 10
snowZoneBtn.Parent = mainFrame

-- ФЛАЙ С ПОДСТРОЙКОЙ
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -10, 0, 25)
flyBtn.Position = UDim2.new(0, 5, 0, 150)
flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
flyBtn.Text = "ФЛАЙ: ВЫКЛ"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 10
flyBtn.Parent = mainFrame

-- ПОЛЗУНОК СКОРОСТИ
local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(1, -10, 0, 20)
speedSlider.Position = UDim2.new(0, 5, 0, 180)
speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedSlider.BorderSizePixel = 1
speedSlider.BorderColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = speedSlider

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 10, 0, 20)
sliderKnob.Position = UDim2.new(0.5, -5, 0, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Text = ""
sliderKnob.Parent = speedSlider

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 15)
speedLabel.Position = UDim2.new(0, 0, 0, -15)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 10
speedLabel.Parent = speedSlider

-- Логика ползунка
local isDragging = false
sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local barAbsPos = speedSlider.AbsolutePosition.X
        local barAbsSize = speedSlider.AbsoluteSize.X
        
        local relativeX = math.clamp(mouseX - barAbsPos, 0, barAbsSize)
        local percent = relativeX / barAbsSize
        
        sliderKnob.Position = UDim2.new(percent, -5, 0, 0)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        
        flySpeed = math.floor(percent * 100) + 1
        speedLabel.Text = "Скорость: " .. flySpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Статус и выгрузка
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 20)
statusText.Position = UDim2.new(0, 5, 0, 210)
statusText.BackgroundTransparency = 1
statusText.Text = "Статус: Готов"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 9
statusText.TextWrapped = true
statusText.Parent = mainFrame

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 20)
unloadBtn.Position = UDim2.new(0, 5, 1, -25)
unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
unloadBtn.Text = "ВЫГРУЗИТЬ"
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.TextSize = 10
unloadBtn.Parent = mainFrame

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

-- Остальные функции
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
closeBtn.Size = UDim2.new(1, 0, 0, 15)
closeBtn.Position = UDim2.new(0, 0, 1, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeBtn.Text = "Закрыть"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 9
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function() 
    stopFly()
    screenGui:Destroy() 
end)
