local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local VOLCANO_MIN_X, VOLCANO_MAX_X = 500, 800
local COSMIC_MIN_X, COSMIC_MAX_X = 800, 1100
local SNOW_MIN_X, SNOW_MAX_X = 2500, 3000
local LAST_MIN_X, LAST_MAX_X = 3400, 4000
local DEMONIC_MIN_X, DEMONIC_MAX_X = 4000, 4600
local SPAWN_CFRAME = CFrame.new(0, 10, 0)
local TG_TAG = "@EroxEggScript"

local isFlying, flySpeed, flyConnection, bodyVelocity = false, 300, nil, nil
local isGhostMode = false
local followTarget, isFollowing, followConnection = nil, false, nil
local isFarmEnabled, isRepeating, lastFarmTime, lastClickTime, playerKills = false, false, 0, 0, 0
local KILLS_REQUIRED = 3

local function cleanName(name)
    name = name:gsub("Hatch", ""):gsub("Egg", ""):gsub("Part", ""):gsub("_", " ")
    return name:gsub("^%s*(.-)%s*$", "%1")
end

local function getWeightValue(w)
    local num = w:match("([%d%.]+)")
    if num then return tonumber(num) end
    return 0
end

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
mainFrame.Size = UDim2.new(0, 260, 0, 560)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local isMenuVisible = true
hideBtn.MouseButton1Click:Connect(function() isMenuVisible = not isMenuVisible mainFrame.Visible = isMenuVisible end)
UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftControl then isMenuVisible = not isMenuVisible mainFrame.Visible = isMenuVisible end end)

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
tgLinkLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
tgLinkLabel.Font = Enum.Font.SourceSansBold
tgLinkLabel.TextSize = 12
tgLinkLabel.Parent = mainFrame
tgBtn.MouseButton1Click:Connect(function() tgLinkLabel.Text = TG_TAG end)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -10, 0, 30)
flyBtn.Position = UDim2.new(0, 5, 0, 85)
flyBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
flyBtn.Text = "ФЛАЙ (БЫСТРЫЙ): ВЫКЛ"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 12
flyBtn.Parent = mainFrame

-- ФАРМ ТЫКВ (ВОЗВРАЩЕН)
local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(1, -10, 0, 30)
farmBtn.Position = UDim2.new(0, 5, 0, 120)
farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmBtn.Text = "ФАРМ ТЫКВ: ВЫКЛ"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.Font = Enum.Font.SourceSansBold
farmBtn.TextSize = 12
farmBtn.Parent = mainFrame

farmBtn.MouseButton1Click:Connect(function()
    isFarmEnabled = not isFarmEnabled
    farmBtn.Text = isFarmEnabled and "ФАРМ ТЫКВ: ВКЛ" or "ФАРМ ТЫКВ: ВЫКЛ"
    farmBtn.BackgroundColor3 = isFarmEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(30, 30, 30)
    playerKills = 0
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        lastClickTime = tick()
        if isFarmEnabled and playerKills < KILLS_REQUIRED then
            playerKills = playerKills + 1
            statusText.Text = "Убито: " .. playerKills .. "/" .. KILLS_REQUIRED
        end
        if isFarmEnabled and playerKills >= KILLS_REQUIRED and not isRepeating then
            isRepeating = true
            task.spawn(function()
                while isRepeating and isFarmEnabled do
                    if tick() - lastClickTime > 0.5 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    task.wait(0.1)
                end
                isRepeating = false
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isFarmEnabled and tick() - lastFarmTime > 0.5 then
        lastFarmTime = tick()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local hrp = c.HumanoidRootPart
            local pf = workspace:FindFirstChild("HalloweenPumpkins")
            if pf then
                for _, p in pairs(pf:GetChildren()) do
                    if p.Name == "Pumpkin" then
                        local pt = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
                        if pt then hrp.CFrame = CFrame.new(pt.Position + Vector3.new(0, 3, 0)) break end
                    end
                end
            end
        end
    end
end)

local function makeZoneBtnFinal(name, col, y, minX, maxX)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 5, 0, y)
    b.BackgroundColor3 = col
    b.Text = "Steal " .. name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.Parent = mainFrame
    b.MouseButton1Click:Connect(function()
        currentMinX = minX
        currentMaxX = maxX
        countGui.Visible = true
    end)
    return b
end

local selectTargetBtn = Instance.new("TextButton")
local followBtn = Instance.new("TextButton")
local statusText = Instance.new("TextLabel")
local scanEggs

local countGui = Instance.new("Frame")
countGui.Size = UDim2.new(0, 200, 0, 250)
countGui.Position = UDim2.new(0.5, -100, 0.5, -125)
countGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
countGui.BorderSizePixel = 2
countGui.BorderColor3 = Color3.fromRGB(255, 255, 255)
countGui.Visible = false
countGui.Active = true
countGui.Draggable = true
countGui.Parent = screenGui

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, 0, 0, 30)
cTitle.BackgroundTransparency = 1
cTitle.Text = "Сколько яиц украсть?"
cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cTitle.Font = Enum.Font.SourceSansBold
cTitle.TextSize = 14
cTitle.Parent = countGui

local cClose = Instance.new("TextButton")
cClose.Size = UDim2.new(0, 25, 0, 25)
cClose.Position = UDim2.new(1, -30, 0, 5)
cClose.BackgroundTransparency = 1
cClose.Text = "X"
cClose.TextColor3 = Color3.fromRGB(255, 50, 50)
cClose.Font = Enum.Font.SourceSansBold
cClose.TextSize = 18
cClose.Parent = countGui
cClose.MouseButton1Click:Connect(function() countGui.Visible = false end)

local currentMinX, currentMaxX = 0, 0

local function startSteal(num)
    countGui.Visible = false
    local c = player.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local hrp = c.HumanoidRootPart
    statusText.Text = "Ищем..."
    local eggs = {}
    for _, o in pairs(workspace:GetDescendants()) do
        if (o.Name:find("Egg") or o.Name:find("Hatch") or o.Name:find("Lamp")) and (o:IsA("Part") or o:IsA("Model")) then
            local pt = o:IsA("Part") and o or o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            if pt and pt.Position.X >= currentMinX and pt.Position.X <= currentMaxX and not o.Name:find("Show") and not o.Name:find("Lamp") then
                local pr = o:FindFirstChild("StealPrompt") or o:FindFirstChildOfClass("ProximityPrompt")
                if pr then
                    local weightVal = 0
                    for _, desc in pairs(o:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text:lower():find("kg") then
                            local numVal = getWeightValue(desc.Text)
                            if numVal > weightVal then weightVal = numVal end
                        end
                    end
                    table.insert(eggs, {obj=o, part=pt, pr=pr, weight=weightVal})
                end
            end
        end
    end
   
    table.sort(eggs, function(a, b) return a.weight > b.weight end)
   
    if #eggs == 0 then statusText.Text = "Пусто." return end
   
    task.spawn(function()
        for i = 1, math.min(num, #eggs) do
            local e = eggs[i]
            statusText.Text = "Яйцо " .. i .. " / " .. num
            hrp.CFrame = CFrame.new(e.part.Position + Vector3.new(0, 3, 0))
            task.wait(0.5)
            pcall(function() fireproximityprompt(e.pr) end)
            pcall(function() firetouchinterest(hrp, e.part, 0) firetouchinterest(hrp, e.part, 1) end)
            for j = 1, 5 do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.03)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.03)
            end
            task.wait(0.5)
        end
        hrp.CFrame = SPAWN_CFRAME
        statusText.Text = "Готово (" .. math.min(num, #eggs) .. ")"
    end)
end

local function makeCountBtn(num, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.Text = tostring(num) .. " шт."
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.Parent = countGui
    b.MouseButton1Click:Connect(function() startSteal(num) end)
end

makeCountBtn(1, 40)
makeCountBtn(2, 80)
makeCountBtn(3, 120)
makeCountBtn(4, 160)
makeCountBtn(5, 200)

local function makeZoneBtnFinal(name, col, y, minX, maxX)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 5, 0, y)
    b.BackgroundColor3 = col
    b.Text = "Steal " .. name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.Parent = mainFrame
    b.MouseButton1Click:Connect(function()
        currentMinX = minX
        currentMaxX = maxX
        countGui.Visible = true
    end)
    return b
end

makeZoneBtnFinal("VolcanoZone", Color3.fromRGB(200, 50, 0), 155, VOLCANO_MIN_X, VOLCANO_MAX_X)
makeZoneBtnFinal("CosmicZone", Color3.fromRGB(50, 50, 150), 190, COSMIC_MIN_X, COSMIC_MAX_X)
makeZoneBtnFinal("SnowZone", Color3.fromRGB(0, 100, 150), 225, SNOW_MIN_X, SNOW_MAX_X)
makeZoneBtnFinal("LastZone", Color3.fromRGB(200, 0, 200), 260, LAST_MIN_X, LAST_MAX_X)
makeZoneBtnFinal("DemonicZone", Color3.fromRGB(150, 0, 0), 295, DEMONIC_MIN_X, DEMONIC_MAX_X)

local checkerBtn = Instance.new("TextButton")
checkerBtn.Size = UDim2.new(1, -10, 0, 30)
checkerBtn.Position = UDim2.new(0, 5, 0, 330)
checkerBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
checkerBtn.Text = "🔍 ЧЕКЕР ЯИЦ (17M+)"
checkerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
checkerBtn.Font = Enum.Font.SourceSansBold
checkerBtn.TextSize = 12
checkerBtn.Parent = mainFrame

selectTargetBtn.Size = UDim2.new(1, -10, 0, 30)
selectTargetBtn.Position = UDim2.new(0, 5, 0, 365)
selectTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
selectTargetBtn.Text = "Выбрать цель"
selectTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectTargetBtn.Font = Enum.Font.SourceSansBold
selectTargetBtn.TextSize = 12
selectTargetBtn.Parent = mainFrame

followBtn.Size = UDim2.new(1, -10, 0, 30)
followBtn.Position = UDim2.new(0, 5, 0, 400)
followBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
followBtn.Text = "Следить + Инвиз: ВЫКЛ"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.Font = Enum.Font.SourceSansBold
followBtn.TextSize = 12
followBtn.Parent = mainFrame

statusText.Size = UDim2.new(1, -10, 0, 25)
statusText.Position = UDim2.new(0, 5, 0, 435)
statusText.BackgroundTransparency = 1
statusText.Text = "Цель: не выбрана"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 11
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

local checkerGui = Instance.new("Frame")
checkerGui.Size = UDim2.new(0, 350, 0, 400)
checkerGui.Position = UDim2.new(0.5, -175, 0.5, -200)
checkerGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
checkerGui.BorderSizePixel = 2
checkerGui.BorderColor3 = Color3.fromRGB(255, 200, 0)
checkerGui.Visible = false
checkerGui.Active = true
checkerGui.Draggable = true
checkerGui.Parent = screenGui

local ccTitle = Instance.new("TextLabel")
ccTitle.Size = UDim2.new(1, 0, 0, 30)
ccTitle.BackgroundColor3 = Color3.fromRGB(40, 30, 0)
ccTitle.Text = "🔍 ЧЕКЕР ЯИЦ (от 17M кг)"
ccTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
ccTitle.Font = Enum.Font.SourceSansBold
ccTitle.TextSize = 14
ccTitle.Parent = checkerGui

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, -10, 0, 30)
refreshBtn.Position = UDim2.new(0, 5, 1, -35)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
refreshBtn.Text = "ОБНОВИТЬ СПИСОК"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 14
refreshBtn.Parent = checkerGui

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -75)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = checkerGui

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 5)

scanEggs = function()
    for _, c in pairs(scrollFrame:GetChildren()) do if c:IsA("TextLabel") or c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end end
    local eggs, seen = {}, {}
    task.wait(0.3)
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name:find("Egg") or obj.Name:find("Hatch")) and (obj:IsA("Part") or obj:IsA("Model")) then
            local pt = obj:IsA("Part") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pt and pt.Position.X > 300 and not obj.Name:find("Show") and not obj.Name:find("Lamp") then
                local weight, mut = "?", "Нет"
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("IntValue") then
                        local n = child.Name:lower()
                        if n:find("weight") or n:find("kg") or n:find("mass") then weight = tostring(child.Value) .. " kg" end
                        if n:find("mutation") or n:find("rarity") or n:find("type") then mut = tostring(child.Value) end
                    end
                end
                local longestLen = 0
                for _, desc in pairs(obj:GetDescendants()) do
                    if desc:IsA("TextLabel") then
                        local txt = desc.Text
                        if txt:lower():find("kg") then
                            local numLen = #txt:gsub("%D", "")
                            if numLen > longestLen then
                                longestLen = numLen
                                weight = txt
                            end
                        end
                        local txtLower = txt:lower()
                        if txtLower:find("epic") or txtLower:find("legend") or txtLower:find("common") or txtLower:find("rare") or txtLower:find("mythic") or txtLower:find("godly") or txtLower:find("uncommon") or txtLower:find("cosmic") or txtLower:find("secret") or txtLower:find("divine") then
                            mut = txt
                        end
                    end
                end
                local cleanNameStr = cleanName(obj.Name)
                local val = getWeightValue(weight)
                if val >= 17000000 then
                    local key = cleanNameStr .. weight .. mut
                    if not seen[key] then
                        seen[key] = true
                        table.insert(eggs, {name=cleanNameStr, weight=weight, mut=mut, pos=pt.Position, sortVal=val, obj=obj})
                    end
                end
            end
        end
    end

    table.sort(eggs, function(a, b) return a.sortVal < b.sortVal end)

    if #eggs == 0 then
        local nf = Instance.new("TextLabel")
        nf.Size = UDim2.new(1, 0, 0, 40)
        nf.BackgroundTransparency = 1
        nf.Text = "Яиц от 17M кг не найдено.\nПодойди ближе и нажми Обновить."
        nf.TextColor3 = Color3.fromRGB(255, 255, 255)
        nf.Font = Enum.Font.SourceSansBold
        nf.TextSize = 12
        nf.TextWrapped = true
        nf.Parent = scrollFrame
        return
    end
   
    for _, e in ipairs(eggs) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 35)
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        row.Parent = scrollFrame
       
        local r = Instance.new("TextLabel")
        r.Size = UDim2.new(0.7, 0, 1, 0)
        r.BackgroundTransparency = 1
        r.Text = e.name .. "\nВес: " .. e.weight .. " | Мутация: " .. e.mut
        r.TextColor3 = Color3.fromRGB(255, 255, 255)
        r.Font = Enum.Font.SourceSansBold
        r.TextSize = 12
        r.TextXAlignment = Enum.TextXAlignment.Left
        r.TextWrapped = true
        r.Parent = row

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
        tpBtn.Position = UDim2.new(0.73, 0, 0.1, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        tpBtn.Text = "ТП"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Font = Enum.Font.SourceSansBold
        tpBtn.TextSize = 12
        tpBtn.Parent = row

        tpBtn.MouseButton1Click:Connect(function()
            local c = player.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            local hrp = c.HumanoidRootPart
            statusText.Text = "Крадём " .. e.name .. "..."
            tpBtn.Text = "ЖДИ"
            tpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.spawn(function()
                hrp.CFrame = CFrame.new(e.pos + Vector3.new(0, 3, 0))
                task.wait(0.7)
                local pr = e.obj:FindFirstChild("StealPrompt") or e.obj:FindFirstChildOfClass("ProximityPrompt")
                if pr then pcall(function() fireproximityprompt(pr) end) end
                pcall(function() firetouchinterest(hrp, e.obj, 0) firetouchinterest(hrp, e.obj, 1) end)
                for j = 1, 5 do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                end
                task.wait(0.4)
                hrp.CFrame = SPAWN_CFRAME
                statusText.Text = "Украдено: " .. e.name
                tpBtn.Text = "ТП"
                tpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            end)
        end)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #eggs * 40)
end

checkerBtn.MouseButton1Click:Connect(function() checkerGui.Visible = not checkerGui.Visible if checkerGui.Visible then task.wait(0.5) scanEggs() end end)
refreshBtn.MouseButton1Click:Connect(scanEggs)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        checkerGui.Visible = not checkerGui.Visible
        if checkerGui.Visible then task.wait(0.5) scanEggs() end
    end
end)

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
            local cam = workspace.CurrentCamera
            local m = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then m -= Vector3.new(0, 1, 0) end
            bodyVelocity.Velocity = m.Magnitude > 0 and m.Unit * flySpeed or Vector3.new(0, 0, 0)
        end)
    else stopFly() end
end)

local function enableGhost() isGhostMode = true local c = player.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0.7 p.CanCollide = false end end end end
local function disableGhost() isGhostMode = false local c = player.Character if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 p.CanCollide = true end end end end
local function stopFollow() isFollowing = false followBtn.Text = "Следить + Инвиз: ВЫКЛ" followBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0) if followConnection then followConnection:Disconnect() end disableGhost() end

selectTargetBtn.MouseButton1Click:Connect(function()
    local g = Instance.new("ScreenGui") g.Parent = player:WaitForChild("PlayerGui")
    local f = Instance.new("ScrollingFrame") f.Size = UDim2.new(0, 200, 0, 200) f.Position = UDim2.new(0.5, -100, 0.5, -100) f.BackgroundColor3 = Color3.fromRGB(20, 20, 20) f.Parent = g
    local l = Instance.new("UIListLayout") l.Parent = f
    local cnt = 0
    for _, p in pairs(Players:GetPlayers()) do if p ~= player then cnt = cnt + 1
        local b = Instance.new("TextButton") b.Size = UDim2.new(1, -10, 0, 25) b.Position = UDim2.new(0, 5, 0, (cnt-1)*30) b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) b.Text = p.Name b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Parent = f
        b.MouseButton1Click:Connect(function() followTarget = p statusText.Text = "Цель: " .. p.Name g:Destroy() stopFollow() end)
    end end
    f.CanvasSize = UDim2.new(0, 0, 0, cnt*30)
end)

followBtn.MouseButton1Click:Connect(function()
    if not followTarget then statusText.Text = "Выбери цель!" return end
    isFollowing = not isFollowing
    if isFollowing then
        followBtn.Text = "Следить + Инвиз: ВКЛ" followBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0) enableGhost()
        followConnection = RunService.Heartbeat:Connect(function()
            if not isFollowing or not followTarget then return end
            local c, t = player.Character, followTarget.Character
            if c and c:FindFirstChild("HumanoidRootPart") and t and t:FindFirstChild("HumanoidRootPart") then
                local h = t:FindFirstChild("Humanoid")
                if h and h.Health > 0 then c.HumanoidRootPart.CFrame = t.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) else statusText.Text = "Мертв" stopFollow() end
            end
        end)
    else stopFollow() end
end)

unloadBtn.MouseButton1Click:Connect(function() isFarmEnabled, isFollowing, isFlying = false, false, false stopFollow() stopFly() screenGui:Destroy() end)
