--[[
    Roblox GUI Cheat Script - Violence District
    Открытие/закрытие по клавише Insert.
    Разделы: Rage, Visual, Config.
    Добавлена система биндов (Hold/Toggle)
    Добавлена система Bind List (список всех биндов)
]]

-- Кэшируем сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[flin.cc] Начало загрузки...")

-- ============ СОСТОЯНИЕ ============
local state = {
    isSpeedEnabled = false,
    speedValue = 50,
    currentSection = "Rage",
    isMenuVisible = true,
    speedSettingsOpen = false,
    isNoclipEnabled = false,
    noclipConnection = nil,
    isFovEnabled = false,
    fovValue = 70,
    fovSettingsOpen = false,
    originalFov = 70,
    isFullBrightEnabled = false,
    originalBrightness = Lighting.Brightness,
    originalAmbient = Lighting.Ambient,
    fullBrightConnection = nil,
    isEspEnabled = false,
    espSettingsOpen = false,
    highlights = {},
    espConnection = nil,
    lastPrintTime = 0,
    espSettings = {
        ShowKiller = true,
        ShowSurvivor = true,
        KillerColor = Color3.fromRGB(255, 0, 0),
        SurvivorColor = Color3.fromRGB(0, 255, 0)
    },
    Configs = {},
    CurrentConfig = "Default",
    ConfigFolder = nil,
    toggleRefs = {},
    sliderFill = nil,
    sliderKnob = nil,
    speedNumLabel = nil,
    fovSliderFill = nil,
    fovSliderKnob = nil,
    fovNumLabel = nil,
    visualContainer = nil,
    espArrowBtn = nil,
    espSettingsFrame = nil,
    isActive = false,
    noclipActive = false,
    fovActive = false,
    fullBrightActive = false,
    espActive = false,
    killerShowActive = true,
    survivorShowActive = true,
    selectedConfigName = "",
    -- Система биндов
    binds = {},
    isWaitingForBind = false,
    waitingBindFeature = nil,
    waitingBindMode = nil,
    blockedButtons = {},
    bindRefs = {},
    -- Bind List
    bindListVisible = false,
    bindListGui = nil,
    bindListFrame = nil,
    isDraggingBindList = false,
    bindListDragStart = nil,
    bindListFrameStart = nil,
    bindListToggleRef = nil,
}

-- Создаем папку для конфигов
state.ConfigFolder = Instance.new("Folder")
state.ConfigFolder.Name = "flin_cc_Configs"
state.ConfigFolder.Parent = playerGui

-- ============ БЕЗОПАСНЫЙ JSON ============
local function safeJsonEncode(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        return result
    else
        print("[flin.cc] Ошибка JSONEncode: " .. tostring(result))
        return nil
    end
end

local function safeJsonDecode(data)
    local success, result = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    if success then
        return result
    else
        print("[flin.cc] Ошибка JSONDecode: " .. tostring(result))
        return nil
    end
end

-- ============ СИСТЕМА БИНДОВ ============
local KeyNames = {
    [Enum.KeyCode.Unknown] = "?",
    [Enum.KeyCode.A] = "A",
    [Enum.KeyCode.B] = "B",
    [Enum.KeyCode.C] = "C",
    [Enum.KeyCode.D] = "D",
    [Enum.KeyCode.E] = "E",
    [Enum.KeyCode.F] = "F",
    [Enum.KeyCode.G] = "G",
    [Enum.KeyCode.H] = "H",
    [Enum.KeyCode.I] = "I",
    [Enum.KeyCode.J] = "J",
    [Enum.KeyCode.K] = "K",
    [Enum.KeyCode.L] = "L",
    [Enum.KeyCode.M] = "M",
    [Enum.KeyCode.N] = "N",
    [Enum.KeyCode.O] = "O",
    [Enum.KeyCode.P] = "P",
    [Enum.KeyCode.Q] = "Q",
    [Enum.KeyCode.R] = "R",
    [Enum.KeyCode.S] = "S",
    [Enum.KeyCode.T] = "T",
    [Enum.KeyCode.U] = "U",
    [Enum.KeyCode.V] = "V",
    [Enum.KeyCode.W] = "W",
    [Enum.KeyCode.X] = "X",
    [Enum.KeyCode.Y] = "Y",
    [Enum.KeyCode.Z] = "Z",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.F1] = "F1",
    [Enum.KeyCode.F2] = "F2",
    [Enum.KeyCode.F3] = "F3",
    [Enum.KeyCode.F4] = "F4",
    [Enum.KeyCode.F5] = "F5",
    [Enum.KeyCode.F6] = "F6",
    [Enum.KeyCode.F7] = "F7",
    [Enum.KeyCode.F8] = "F8",
    [Enum.KeyCode.F9] = "F9",
    [Enum.KeyCode.F10] = "F10",
    [Enum.KeyCode.F11] = "F11",
    [Enum.KeyCode.F12] = "F12",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.Space] = "Space",
    [Enum.KeyCode.Tab] = "Tab",
    [Enum.KeyCode.Return] = "Enter",
    [Enum.KeyCode.Escape] = "Esc",
    [Enum.KeyCode.Backspace] = "Backspace",
    [Enum.KeyCode.Delete] = "Del",
    [Enum.KeyCode.Insert] = "Ins",
    [Enum.KeyCode.Home] = "Home",
    [Enum.KeyCode.End] = "End",
    [Enum.KeyCode.PageUp] = "PgUp",
    [Enum.KeyCode.PageDown] = "PgDn",
    [Enum.KeyCode.Up] = "↑",
    [Enum.KeyCode.Down] = "↓",
    [Enum.KeyCode.Left] = "←",
    [Enum.KeyCode.Right] = "→",
}

local function GetKeyName(keyCode)
    return KeyNames[keyCode] or "?"
end

-- Функция блокировки/разблокировки всех кнопок
local function SetAllButtonsLocked(locked)
    for _, btn in ipairs(state.blockedButtons) do
        if btn and btn.Parent then
            btn.Visible = not locked
            btn.Active = not locked
        end
    end
end

-- Глобальный обработчик биндов
local function SetupGlobalBindHandler()
    -- Обработчик нажатия клавиш
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        
        -- Если ожидаем ввод бинда
        if state.isWaitingForBind then
            local keyCode = input.KeyCode
            if keyCode ~= Enum.KeyCode.Unknown and keyCode ~= Enum.KeyCode.Escape and keyCode ~= Enum.KeyCode.Insert then
                if state.waitingBindFeature and state.waitingBindFeature.SetBind then
                    state.waitingBindFeature.SetBind(keyCode, state.waitingBindMode)
                    print("[flin.cc] Бинд установлен! Клавиша: " .. GetKeyName(keyCode) .. " Режим: " .. state.waitingBindMode)
                end
                state.isWaitingForBind = false
                state.waitingBindFeature = nil
                state.waitingBindMode = nil
                -- Разблокируем все кнопки
                SetAllButtonsLocked(false)
            end
            return
        end
        
        -- Обработка активных биндов
        local keyCode = input.KeyCode
        local bindInfo = state.binds[keyCode]
        if bindInfo then
            if bindInfo.mode == "toggle" then
                local currentState = bindInfo.getState()
                bindInfo.toggleCallback(not currentState)
                print("[flin.cc] Бинд Toggle: " .. bindInfo.target .. " -> " .. tostring(not currentState))
            elseif bindInfo.mode == "hold" then
                bindInfo.toggleCallback(true)
                print("[flin.cc] Бинд Hold (нажат): " .. bindInfo.target)
            end
        end
    end)
    
    -- Обработчик отпускания клавиш для Hold
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        
        local keyCode = input.KeyCode
        local bindInfo = state.binds[keyCode]
        if bindInfo and bindInfo.mode == "hold" then
            bindInfo.toggleCallback(false)
            print("[flin.cc] Бинд Hold (отпущен): " .. bindInfo.target)
        end
    end)
end

-- ============ СИСТЕМА BIND LIST ============
local function UpdateBindListContent()
    if not state.bindListFrame then return end
    
    local bindScrollFrame = state.bindListFrame:FindFirstChildOfClass("ScrollingFrame")
    if not bindScrollFrame then return end
    
    -- Очищаем старые элементы
    for _, child in pairs(bindScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Получаем список активных биндов
    local bindEntries = {}
    for keyCode, bindInfo in pairs(state.binds) do
        local keyName = GetKeyName(keyCode)
        local isActive = bindInfo.getState and bindInfo.getState() or false
        table.insert(bindEntries, {
            key = keyName,
            target = bindInfo.target,
            mode = bindInfo.mode,
            active = isActive
        })
    end
    
    -- Сортируем по названию
    table.sort(bindEntries, function(a, b)
        return a.target < b.target
    end)
    
    -- Если нет биндов - ничего не показываем
    if #bindEntries == 0 then
        return
    end
    
    -- Создаем элементы для каждого бинда
    for _, entry in ipairs(bindEntries) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 28)
        itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = bindScrollFrame
        
        Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
        Instance.new("UICorner").Parent = itemFrame
        
        -- Индикатор статуса (ON/OFF)
        local statusIndicator = Instance.new("Frame")
        statusIndicator.Size = UDim2.new(0, 8, 0, 8)
        statusIndicator.Position = UDim2.new(0, 8, 0.5, -4)
        statusIndicator.BackgroundColor3 = entry.active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(80, 80, 80)
        statusIndicator.BorderSizePixel = 0
        statusIndicator.Parent = itemFrame
        
        Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
        Instance.new("UICorner").Parent = statusIndicator
        
        -- Название функции
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 20, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = entry.target
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- Клавиша
        local keyLabel = Instance.new("TextLabel")
        keyLabel.Size = UDim2.new(0.35, 0, 1, 0)
        keyLabel.Position = UDim2.new(0.4, 0, 0, 0)
        keyLabel.BackgroundTransparency = 1
        keyLabel.Text = "[" .. entry.key .. "]"
        keyLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        keyLabel.TextSize = 12
        keyLabel.Font = Enum.Font.GothamBold
        keyLabel.TextXAlignment = Enum.TextXAlignment.Center
        keyLabel.Parent = itemFrame
        
        -- Режим (Hold/Toggle)
        local modeLabel = Instance.new("TextLabel")
        modeLabel.Size = UDim2.new(0.2, 0, 1, 0)
        modeLabel.Position = UDim2.new(0.75, 0, 0, 0)
        modeLabel.BackgroundTransparency = 1
        modeLabel.Text = entry.mode == "hold" and "Hold" or "Toggle"
        modeLabel.TextColor3 = entry.mode == "hold" and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 180, 100)
        modeLabel.TextSize = 9
        modeLabel.Font = Enum.Font.GothamMedium
        modeLabel.TextXAlignment = Enum.TextXAlignment.Center
        modeLabel.Parent = itemFrame
    end
    
    bindScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #bindEntries * 33 + 10)
end

local function ForceUpdateBindList()
    if state.bindListVisible and state.bindListFrame then
        UpdateBindListContent()
    end
end

local function CreateBindListWindow()
    -- Удаляем старый список если есть
    if state.bindListGui then
        state.bindListGui:Destroy()
        state.bindListGui = nil
        state.bindListFrame = nil
    end
    
    -- Создаем GUI для списка биндов
    state.bindListGui = Instance.new("ScreenGui")
    state.bindListGui.Name = "BindListGui"
    state.bindListGui.Parent = playerGui
    state.bindListGui.ResetOnSpawn = false
    state.bindListGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Основной фрейм (как у основного меню)
    state.bindListFrame = Instance.new("Frame")
    state.bindListFrame.Size = UDim2.new(0, 250, 0, 300)
    state.bindListFrame.Position = UDim2.new(0.01, 0, 0.4, -150)
    state.bindListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    state.bindListFrame.BackgroundTransparency = 0
    state.bindListFrame.BorderSizePixel = 0
    state.bindListFrame.Parent = state.bindListGui
    state.bindListFrame.Active = true
    state.bindListFrame.Visible = true
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    Instance.new("UICorner").Parent = state.bindListFrame
    
    -- Drag зона для списка биндов
    local bindListDragZone = Instance.new("Frame")
    bindListDragZone.Size = UDim2.new(1, 0, 0, 30)
    bindListDragZone.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bindListDragZone.BorderSizePixel = 0
    bindListDragZone.Parent = state.bindListFrame
    bindListDragZone.ZIndex = 10
    
    -- Заголовок списка биндов
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -35, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BIND LIST"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = bindListDragZone
    
    -- Кнопка закрытия (прямоугольник)
    local closeBindListBtn = Instance.new("TextButton")
    closeBindListBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBindListBtn.Position = UDim2.new(1, -30, 0, 2.5)
    closeBindListBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeBindListBtn.BackgroundTransparency = 0
    closeBindListBtn.BorderSizePixel = 0
    closeBindListBtn.Text = "X"
    closeBindListBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBindListBtn.TextSize = 12
    closeBindListBtn.Font = Enum.Font.GothamBold
    closeBindListBtn.Parent = bindListDragZone
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = closeBindListBtn
    
    closeBindListBtn.MouseButton1Click:Connect(function()
        state.bindListVisible = false
        if state.bindListGui then
            state.bindListGui:Destroy()
            state.bindListGui = nil
            state.bindListFrame = nil
        end
        if state.bindListToggleRef then
            state.bindListToggleRef.SetActive(false)
        end
    end)
    
    -- Перетаскивание списка биндов
    bindListDragZone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.isDraggingBindList = true
            state.bindListDragStart = input.Position
            state.bindListFrameStart = state.bindListFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if state.isDraggingBindList and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - state.bindListDragStart
            state.bindListFrame.Position = UDim2.new(
                state.bindListFrameStart.X.Scale,
                state.bindListFrameStart.X.Offset + delta.X,
                state.bindListFrameStart.Y.Scale,
                state.bindListFrameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.isDraggingBindList = false
        end
    end)
    
    -- Контейнер для списка биндов
    local bindScrollFrame = Instance.new("ScrollingFrame")
    bindScrollFrame.Size = UDim2.new(1, -10, 1, -40)
    bindScrollFrame.Position = UDim2.new(0, 5, 0, 35)
    bindScrollFrame.BackgroundTransparency = 1
    bindScrollFrame.Parent = state.bindListFrame
    bindScrollFrame.ScrollBarThickness = 6
    bindScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    bindScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    bindScrollFrame.BorderSizePixel = 0
    
    local bindListLayout = Instance.new("UIListLayout")
    bindListLayout.Parent = bindScrollFrame
    bindListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bindListLayout.Padding = UDim.new(0, 3)
    
    -- Обновляем список
    UpdateBindListContent()
    
    return state.bindListFrame
end

-- Функция переключения списка биндов
local function ToggleBindList()
    state.bindListVisible = not state.bindListVisible
    
    if state.bindListVisible then
        CreateBindListWindow()
    else
        if state.bindListGui then
            state.bindListGui:Destroy()
            state.bindListGui = nil
            state.bindListFrame = nil
        end
    end
    
    if state.bindListToggleRef then
        state.bindListToggleRef.SetActive(state.bindListVisible)
    end
    
    print("[flin.cc] Bind List " .. (state.bindListVisible and "открыт" or "закрыт"))
end

-- ============ ФУНКЦИИ КОНФИГОВ ============
local function GetConfigList()
    local list = {}
    for name, _ in pairs(state.Configs) do
        table.insert(list, name)
    end
    
    for _, child in pairs(state.ConfigFolder:GetChildren()) do
        if child:IsA("StringValue") and not state.Configs[child.Name] then
            table.insert(list, child.Name)
        end
    end
    
    table.sort(list)
    return list
end

local function SaveConfig(name)
    if name == nil or name == "" then
        print("[flin.cc] Ошибка: имя не может быть пустым!")
        return false
    end
    
    -- Сохраняем бинды
    local bindsData = {}
    for keyCode, bindInfo in pairs(state.binds) do
        bindsData[GetKeyName(keyCode)] = {
            target = bindInfo.target,
            mode = bindInfo.mode
        }
    end
    
    local configData = {
        Name = name,
        SpeedEnabled = state.isSpeedEnabled,
        SpeedValue = state.speedValue,
        NoclipEnabled = state.isNoclipEnabled,
        FovEnabled = state.isFovEnabled,
        FovValue = state.fovValue,
        FullBrightEnabled = state.isFullBrightEnabled,
        EspEnabled = state.isEspEnabled,
        ShowKiller = state.espSettings.ShowKiller,
        ShowSurvivor = state.espSettings.ShowSurvivor,
        KillerColor = {
            R = state.espSettings.KillerColor.R,
            G = state.espSettings.KillerColor.G,
            B = state.espSettings.KillerColor.B
        },
        SurvivorColor = {
            R = state.espSettings.SurvivorColor.R,
            G = state.espSettings.SurvivorColor.G,
            B = state.espSettings.SurvivorColor.B
        },
        Binds = bindsData,
        BindListEnabled = state.bindListVisible,
        Timestamp = os.time()
    }
    
    local jsonData = safeJsonEncode(configData)
    if not jsonData then
        print("[flin.cc] Ошибка: не удалось закодировать конфиг!")
        return false
    end
    
    state.Configs[name] = configData
    state.CurrentConfig = name
    
    local old = state.ConfigFolder:FindFirstChild(name)
    if old then old:Destroy() end
    
    local value = Instance.new("StringValue")
    value.Name = name
    value.Value = jsonData
    value.Parent = state.ConfigFolder
    
    print("[flin.cc] Конфиг '" .. name .. "' сохранен!")
    if UpdateConfigList then UpdateConfigList() end
    return true
end

local function LoadConfig(name)
    local config = state.Configs[name]
    if not config then
        local value = state.ConfigFolder:FindFirstChild(name)
        if value and value:IsA("StringValue") then
            local data = safeJsonDecode(value.Value)
            if data then
                state.Configs[name] = data
                config = data
            end
        end
    end
    
    if not config then
        print("[flin.cc] Конфиг '" .. name .. "' не найден!")
        return false
    end
    
    state.CurrentConfig = name
    state.isSpeedEnabled = config.SpeedEnabled or false
    state.speedValue = config.SpeedValue or 50
    state.isNoclipEnabled = config.NoclipEnabled or false
    state.isFovEnabled = config.FovEnabled or false
    state.fovValue = config.FovValue or 70
    state.isFullBrightEnabled = config.FullBrightEnabled or false
    state.isEspEnabled = config.EspEnabled or false
    state.espSettings.ShowKiller = config.ShowKiller ~= nil and config.ShowKiller or true
    state.espSettings.ShowSurvivor = config.ShowSurvivor ~= nil and config.ShowSurvivor or true
    
    if config.KillerColor then
        state.espSettings.KillerColor = Color3.fromRGB(
            config.KillerColor.R * 255,
            config.KillerColor.G * 255,
            config.KillerColor.B * 255
        )
    end
    if config.SurvivorColor then
        state.espSettings.SurvivorColor = Color3.fromRGB(
            config.SurvivorColor.R * 255,
            config.SurvivorColor.G * 255,
            config.SurvivorColor.B * 255
        )
    end
    
    -- Загружаем бинды
    if config.Binds then
        for keyName, bindData in pairs(config.Binds) do
            local keyCode = nil
            for enumKey, name2 in pairs(KeyNames) do
                if name2 == keyName then
                    keyCode = enumKey
                    break
                end
            end
            if keyCode then
                local target = bindData.target
                if target == "Speed" then
                    if state.bindRefs and state.bindRefs.speed then
                        state.bindRefs.speed.SetBind(keyCode, bindData.mode)
                    end
                elseif target == "Noclip" then
                    if state.bindRefs and state.bindRefs.noclip then
                        state.bindRefs.noclip.SetBind(keyCode, bindData.mode)
                    end
                elseif target == "FOV" then
                    if state.bindRefs and state.bindRefs.fov then
                        state.bindRefs.fov.SetBind(keyCode, bindData.mode)
                    end
                elseif target == "FullBright" then
                    if state.bindRefs and state.bindRefs.fullbright then
                        state.bindRefs.fullbright.SetBind(keyCode, bindData.mode)
                    end
                elseif target == "ESP" then
                    if state.bindRefs and state.bindRefs.esp then
                        state.bindRefs.esp.SetBind(keyCode, bindData.mode)
                    end
                elseif target == "BindList" then
                    if state.bindRefs and state.bindRefs.bindlist then
                        state.bindRefs.bindlist.SetBind(keyCode, bindData.mode)
                    end
                end
            end
        end
    end
    
    -- Загружаем состояние Bind List
    if config.BindListEnabled ~= nil then
        if config.BindListEnabled then
            if not state.bindListVisible then
                ToggleBindList()
            end
        else
            if state.bindListVisible then
                ToggleBindList()
            end
        end
        if state.bindListToggleRef then
            state.bindListToggleRef.SetActive(config.BindListEnabled)
        end
    end
    
    -- Обновляем переключатели
    local refs = state.toggleRefs
    if refs.speed then refs.speed.SetActive(state.isSpeedEnabled) end
    if refs.noclip then refs.noclip.SetActive(state.isNoclipEnabled) end
    if refs.fov then refs.fov.SetActive(state.isFovEnabled) end
    if refs.fullbright then refs.fullbright.SetActive(state.isFullBrightEnabled) end
    if refs.esp then refs.esp.SetActive(state.isEspEnabled) end
    if refs.espManiac then refs.espManiac.SetActive(state.espSettings.ShowKiller) end
    if refs.espSurvivor then refs.espSurvivor.SetActive(state.espSettings.ShowSurvivor) end
    if refs.bindlist then refs.bindlist.SetActive(state.bindListVisible) end
    
    -- Обновляем ползунки
    if state.sliderFill and state.sliderKnob and state.speedNumLabel then
        local percent = (state.speedValue - 20) / 80
        state.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        state.sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
        state.speedNumLabel.Text = tostring(math.round(state.speedValue))
    end
    
    if state.fovSliderFill and state.fovSliderKnob and state.fovNumLabel then
        local percent = (state.fovValue - 40) / 80
        state.fovSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        state.fovSliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
        state.fovNumLabel.Text = tostring(math.round(state.fovValue))
    end
    
    -- Применяем настройки
    ApplySpeed()
    if state.isNoclipEnabled then EnableNoclip() else DisableNoclip() end
    ApplyFov()
    if state.isFullBrightEnabled then EnableFullBright() else DisableFullBright() end
    if state.isEspEnabled then EnableEsp() else DisableEsp() end
    
    if UpdateConfigList then UpdateConfigList() end
    print("[flin.cc] Конфиг '" .. name .. "' загружен!")
    return true
end

local function DeleteConfig(name)
    if name == "Default" then
        print("[flin.cc] Нельзя удалить конфиг по умолчанию!")
        return false
    end
    
    state.Configs[name] = nil
    local value = state.ConfigFolder:FindFirstChild(name)
    if value then value:Destroy() end
    
    if state.CurrentConfig == name then
        state.CurrentConfig = "Default"
        state.isSpeedEnabled = false
        state.speedValue = 50
        state.isNoclipEnabled = false
        state.isFovEnabled = false
        state.fovValue = 70
        state.isFullBrightEnabled = false
        state.isEspEnabled = false
        state.espSettings.ShowKiller = true
        state.espSettings.ShowSurvivor = true
        
        local refs = state.toggleRefs
        if refs.speed then refs.speed.SetActive(false) end
        if refs.noclip then refs.noclip.SetActive(false) end
        if refs.fov then refs.fov.SetActive(false) end
        if refs.fullbright then refs.fullbright.SetActive(false) end
        if refs.esp then refs.esp.SetActive(false) end
        if refs.espManiac then refs.espManiac.SetActive(true) end
        if refs.espSurvivor then refs.espSurvivor.SetActive(true) end
        
        if state.sliderFill and state.sliderKnob and state.speedNumLabel then
            local percent = 0.375
            state.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            state.sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
            state.speedNumLabel.Text = "50"
        end
        
        if state.fovSliderFill and state.fovSliderKnob and state.fovNumLabel then
            local percent = 0.375
            state.fovSliderFill.Size = UDim2.new(percent, 0, 1, 0)
            state.fovSliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
            state.fovNumLabel.Text = "70"
        end
        
        ApplySpeed()
        DisableNoclip()
        ApplyFov()
        DisableFullBright()
        DisableEsp()
    end
    
    if UpdateConfigList then UpdateConfigList() end
    print("[flin.cc] Конфиг '" .. name .. "' удален!")
    return true
end

-- ============ ПРИМЕНЕНИЕ НАСТРОЕК ============
local function ApplySpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = state.isSpeedEnabled and state.speedValue or 16
    end
end

local function ApplyFov()
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = state.isFovEnabled and state.fovValue or state.originalFov
    end
end

-- ============ FULLBRIGHT ============
local function ApplyFullBright()
    if state.isFullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = state.originalBrightness
        Lighting.Ambient = state.originalAmbient
        Lighting.OutdoorAmbient = state.originalAmbient
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
    end
end

local function EnableFullBright()
    if state.fullBrightConnection then return end
    state.isFullBrightEnabled = true
    ApplyFullBright()
    
    state.fullBrightConnection = RunService.RenderStepped:Connect(function()
        if state.isFullBrightEnabled then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end
    end)
    print("[flin.cc] FullBright ВКЛЮЧЕН!")
end

local function DisableFullBright()
    if state.fullBrightConnection then
        state.fullBrightConnection:Disconnect()
        state.fullBrightConnection = nil
    end
    state.isFullBrightEnabled = false
    ApplyFullBright()
    print("[flin.cc] FullBright ВЫКЛЮЧЕН!")
end

-- ============ NOCLIP ============
local function EnableNoclip()
    if state.noclipConnection then return end
    state.noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then                    part.CanCollide = false
                end
            end
        end
    end)
    state.isNoclipEnabled = true
end

local function DisableNoclip()
    if state.noclipConnection then
        state.noclipConnection:Disconnect()
        state.noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    state.isNoclipEnabled = false
end

-- ============ ESP ============
local function getPlayerRole(otherPlayer)
    local character = otherPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        return "unknown"
    end
    return character:FindFirstChild("Highlight-forsurvivor") and "survivor" or "killer"
end

local function createHighlight(character, color)
    if not character or not character.Parent then
        return nil
    end
    
    local existing = state.highlights[character]
    if existing then
        if existing.FillColor ~= color then
            existing.FillColor = color
            existing.OutlineColor = color
        end
        return existing
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    
    state.highlights[character] = highlight
    return highlight
end

local function clearAllHighlights()
    for character, highlight in pairs(state.highlights) do
        pcall(function() highlight:Destroy() end)
    end
    state.highlights = {}
end

local function updateESP()
    if not state.isEspEnabled then
        clearAllHighlights()
        return
    end
    
    local killerCount = 0
    local survivorCount = 0
    local playersList = Players:GetPlayers()
    
    for i = 1, #playersList do
        local otherPlayer = playersList[i]
        if otherPlayer ~= player then
            local character = otherPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local role = getPlayerRole(otherPlayer)
                local color = Color3.fromRGB(255, 255, 255)
                
                if role == "killer" and state.espSettings.ShowKiller then
                    color = state.espSettings.KillerColor
                    killerCount = killerCount + 1
                    createHighlight(character, color)
                elseif role == "survivor" and state.espSettings.ShowSurvivor then
                    color = state.espSettings.SurvivorColor
                    survivorCount = survivorCount + 1
                    createHighlight(character, color)
                end
            end
        end
    end
    
    if state.isEspEnabled and tick() - state.lastPrintTime > 2 then
        print("👥 Маньяк: " .. killerCount .. ", Выжившие: " .. survivorCount)
        state.lastPrintTime = tick()
    end
end

local function EnableEsp()
    if state.espConnection then return end
    state.isEspEnabled = true
    updateESP()
    
    state.espConnection = RunService.RenderStepped:Connect(function()
        if state.isEspEnabled then updateESP() end
    end)
    print("[flin.cc] ESP ВКЛЮЧЕН!")
end

local function DisableEsp()
    if state.espConnection then
        state.espConnection:Disconnect()
        state.espConnection = nil
    end
    state.isEspEnabled = false
    clearAllHighlights()
    print("[flin.cc] ESP ВЫКЛЮЧЕН!")
end

-- ============ HSV ФУНКЦИИ ============
local function HSVToRGB(h, s, v)
    h = h % 1
    local r, g, b
    if s == 0 then
        r, g, b = v, v, v
    else
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - s * f)
        local t = v * (1 - s * (1 - f))
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        else r, g, b = v, p, q end
    end
    return r, g, b
end

local function RGBToHSV(r, g, b)
    r, g, b = r/255, g/255, b/255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local v = max
    local d = max - min
    local s = max == 0 and 0 or d / max
    local h = 0
    if max ~= min then
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

-- ============ СОЗДАНИЕ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ГЛОБАЛЬНАЯ ПЕРЕМЕННАЯ mainFrame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 900, 0, 450)
mainFrame.Position = UDim2.new(0.5, -450, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Visible = true

Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
Instance.new("UICorner").Parent = mainFrame

-- ============ ЦВЕТОВАЯ ПАЛИТРА ============
local colorPickerOpen = false
local currentPickerFrame = nil
local pickerData = {}
local pickerGuiRef = nil
local mainGuiBlocked = false

local function OpenColorPicker(title, currentColor, callback)
    if colorPickerOpen and currentPickerFrame then
        currentPickerFrame:Destroy()
        currentPickerFrame = nil
        colorPickerOpen = false
    end
    
    colorPickerOpen = true
    mainFrame.Active = false
    mainFrame.BackgroundTransparency = 0.3
    mainGuiBlocked = true
    
    local pickerGui = Instance.new("ScreenGui")
    pickerGui.Name = "ColorPickerGui"
    pickerGui.Parent = playerGui
    pickerGui.ResetOnSpawn = false
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pickerGuiRef = pickerGui
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.6
    overlay.BorderSizePixel = 0
    overlay.Parent = pickerGui
    overlay.ZIndex = 1
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 400, 0, 420)
    pickerFrame.Position = UDim2.new(0.5, -200, 0.5, -210)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pickerFrame.BackgroundTransparency = 0
    pickerFrame.BorderSizePixel = 2
    pickerFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    pickerFrame.Parent = pickerGui
    pickerFrame.ZIndex = 2
    pickerFrame.ClipsDescendants = false
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    Instance.new("UICorner").Parent = pickerFrame
    
    currentPickerFrame = pickerFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 35)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎨 " .. title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = pickerFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = pickerFrame
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 5)
    Instance.new("UICorner").Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Active = true
        mainFrame.BackgroundTransparency = 0
        mainGuiBlocked = false
        pickerGui:Destroy()
        colorPickerOpen = false
        currentPickerFrame = nil
        pickerGuiRef = nil
    end)
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 2)
    divider.Position = UDim2.new(0, 10, 0, 42)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    divider.BorderSizePixel = 0
    divider.Parent = pickerFrame
    
    local r, g, b = currentColor.R * 255, currentColor.G * 255, currentColor.B * 255
    local h, s, v = RGBToHSV(r, g, b)
    local currentHue = h or 0
    local currentSat = s or 1
    local currentVal = v or 1
    
    local paletteSize = 200
    local paletteFrame = Instance.new("Frame")
    paletteFrame.Size = UDim2.new(0, paletteSize, 0, paletteSize)
    paletteFrame.Position = UDim2.new(0, 10, 0, 52)
    paletteFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    paletteFrame.BackgroundTransparency = 0
    paletteFrame.BorderSizePixel = 1
    paletteFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    paletteFrame.Parent = pickerFrame
    paletteFrame.ClipsDescendants = true
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = paletteFrame
    
    local pixelSize = 4
    local pixelsX = math.floor(paletteSize / pixelSize)
    local pixelsY = math.floor(paletteSize / pixelSize)
    local pixelGrid = {}
    
    for y = 0, pixelsY - 1 do
        for x = 0, pixelsX - 1 do
            local pixel = Instance.new("Frame")
            pixel.Size = UDim2.new(0, pixelSize, 0, pixelSize)
            pixel.Position = UDim2.new(0, x * pixelSize, 0, y * pixelSize)
            pixel.BackgroundTransparency = 0
            pixel.BorderSizePixel = 0
            pixel.Parent = paletteFrame
            
            local sat = x / pixelsX
            local val = 1 - (y / pixelsY)
            local r2, g2, b2 = HSVToRGB(currentHue, sat, val)
            pixel.BackgroundColor3 = Color3.fromRGB(
                math.round(r2 * 255),
                math.round(g2 * 255),
                math.round(b2 * 255)
            )
            
            pixelGrid[#pixelGrid + 1] = pixel
        end
    end
    
    local hueWidth = 25
    local hueFrame = Instance.new("Frame")
    hueFrame.Size = UDim2.new(0, hueWidth, 0, paletteSize)
    hueFrame.Position = UDim2.new(0, paletteSize + 5, 0, 52)
    hueFrame.BackgroundTransparency = 0
    hueFrame.BorderSizePixel = 1
    hueFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    hueFrame.Parent = pickerFrame
    hueFrame.ClipsDescendants = true
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = hueFrame
    
    for y = 0, paletteSize - 1 do
        local pixel = Instance.new("Frame")
        pixel.Size = UDim2.new(1, 0, 0, 1)
        pixel.Position = UDim2.new(0, 0, 0, y)
        pixel.BackgroundTransparency = 0
        pixel.BorderSizePixel = 0
        pixel.Parent = hueFrame
        
        local hue2 = y / paletteSize
        local r2, g2, b2 = HSVToRGB(hue2, 1, 1)
        pixel.BackgroundColor3 = Color3.fromRGB(
            math.round(r2 * 255),
            math.round(g2 * 255),
            math.round(b2 * 255)
        )
    end
    
    local function updatePalette(hue)
        for y = 0, pixelsY - 1 do
            for x = 0, pixelsX - 1 do
                local idx = y * pixelsX + x + 1
                if idx <= #pixelGrid then
                    local sat = x / pixelsX
                    local val = 1 - (y / pixelsY)
                    local r2, g2, b2 = HSVToRGB(hue, sat, val)
                    pixelGrid[idx].BackgroundColor3 = Color3.fromRGB(
                        math.round(r2 * 255),
                        math.round(g2 * 255),
                        math.round(b2 * 255)
                    )
                end
            end
        end
    end
    
    local selector = Instance.new("Frame")
    selector.Size = UDim2.new(0, 12, 0, 12)
    selector.Position = UDim2.new(currentSat, -6, 1 - currentVal, -6)
    selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selector.BackgroundTransparency = 0
    selector.BorderSizePixel = 2
    selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    selector.Parent = paletteFrame
    selector.ZIndex = 10
    
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner").Parent = selector
    
    local hueSelector = Instance.new("Frame")
    hueSelector.Size = UDim2.new(1, 0, 0, 4)
    hueSelector.Position = UDim2.new(0, 0, 0, currentHue * paletteSize)
    hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSelector.BackgroundTransparency = 0
    hueSelector.BorderSizePixel = 1
    hueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hueSelector.Parent = hueFrame
    hueSelector.ZIndex = 10
    
    local previewFrame = Instance.new("Frame")
    previewFrame.Size = UDim2.new(0, 70, 0, 70)
    previewFrame.Position = UDim2.new(0, paletteSize + hueWidth + 5 + 10, 0, 52)
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderSizePixel = 1
    previewFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    previewFrame.Parent = pickerFrame
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = previewFrame
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0, 70, 0, 90)
    infoFrame.Position = UDim2.new(0, paletteSize + hueWidth + 5 + 10, 0, 128)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = pickerFrame
    
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(1, 0, 0, 20)
    rgbLabel.Position = UDim2.new(0, 0, 0, 0)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.Text = string.format("RGB: %d, %d, %d",
        math.round(currentColor.R * 255),
        math.round(currentColor.G * 255),
        math.round(currentColor.B * 255)
    )
    rgbLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rgbLabel.TextSize = 10
    rgbLabel.Font = Enum.Font.GothamMedium
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
    rgbLabel.Parent = infoFrame
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Size = UDim2.new(1, 0, 0, 20)
    hexLabel.Position = UDim2.new(0, 0, 0, 22)
    hexLabel.BackgroundTransparency = 1
    hexLabel.Text = string.format("HEX: #%02X%02X%02X",
        math.round(currentColor.R * 255),
        math.round(currentColor.G * 255),
        math.round(currentColor.B * 255)
    )
    hexLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hexLabel.TextSize = 10
    hexLabel.Font = Enum.Font.GothamMedium
    hexLabel.TextXAlignment = Enum.TextXAlignment.Left
    hexLabel.Parent = infoFrame
    
    local function updateColorFromPalette(posX, posY)
        local clampedX = math.clamp(posX, 0, paletteSize)
        local clampedY = math.clamp(posY, 0, paletteSize)
        
        local sat = clampedX / paletteSize
        local val = 1 - (clampedY / paletteSize)
        
        currentSat = sat
        currentVal = val
        selector.Position = UDim2.new(sat, -6, 1 - val, -6)
        
        local r2, g2, b2 = HSVToRGB(currentHue, sat, val)
        local color = Color3.fromRGB(math.round(r2*255), math.round(g2*255), math.round(b2*255))
        previewFrame.BackgroundColor3 = color
        rgbLabel.Text = string.format("RGB: %d, %d, %d", math.round(r2*255), math.round(g2*255), math.round(b2*255))
        hexLabel.Text = string.format("HEX: #%02X%02X%02X", math.round(r2*255), math.round(g2*255), math.round(b2*255))
        pickerData.selectedColor = color
    end
    
    local function updateColorFromHue(posY)
        local clampedY = math.clamp(posY, 0, paletteSize)
        local hue = clampedY / paletteSize
        currentHue = hue
        hueSelector.Position = UDim2.new(0, 0, 0, clampedY - 2)
        updatePalette(hue)
        
        local r2, g2, b2 = HSVToRGB(hue, currentSat, currentVal)
        local color = Color3.fromRGB(math.round(r2*255), math.round(g2*255), math.round(b2*255))
        previewFrame.BackgroundColor3 = color
        rgbLabel.Text = string.format("RGB: %d, %d, %d", math.round(r2*255), math.round(g2*255), math.round(b2*255))
        hexLabel.Text = string.format("HEX: #%02X%02X%02X", math.round(r2*255), math.round(g2*255), math.round(b2*255))
        pickerData.selectedColor = color
    end
    
    local isDraggingPalette = false
    local isDraggingHue = false
    
    paletteFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingPalette = true
            local mousePos = input.Position
            local framePos = paletteFrame.AbsolutePosition
            local posX = mousePos.X - framePos.X
            local posY = mousePos.Y - framePos.Y
            updateColorFromPalette(posX, posY)
        end
    end)
    
    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            local mousePos = input.Position
            local framePos = hueFrame.AbsolutePosition
            local posY = mousePos.Y - framePos.Y
            updateColorFromHue(posY)
        end
    end)
    
    local mouseConnection
    mouseConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if isDraggingPalette then
                local mousePos = input.Position
                local framePos = paletteFrame.AbsolutePosition
                local posX = mousePos.X - framePos.X
                local posY = mousePos.Y - framePos.Y
                updateColorFromPalette(posX, posY)
            elseif isDraggingHue then
                local mousePos = input.Position
                local framePos = hueFrame.AbsolutePosition
                local posY = mousePos.Y - framePos.Y
                updateColorFromHue(posY)
            end
        end
    end)
    
    local endedConnection
    endedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingPalette = false
            isDraggingHue = false
        end
    end)
    
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, -20, 0, 35)
    bottomFrame.Position = UDim2.new(0, 10, 0, 370)
    bottomFrame.BackgroundTransparency = 1
    bottomFrame.Parent = pickerFrame
    
    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0, 100, 1, 0)
    okBtn.Position = UDim2.new(0.5, -105, 0, 0)
    okBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    okBtn.BackgroundTransparency = 0
    okBtn.BorderSizePixel = 0
    okBtn.Text = "✅ Применить"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.TextSize = 13
    okBtn.Font = Enum.Font.GothamBold
    okBtn.Parent = bottomFrame
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = okBtn
    
    okBtn.MouseButton1Click:Connect(function()
        local selectedColor = pickerData.selectedColor or currentColor
        if callback then callback(selectedColor) end
        mainFrame.Active = true
        mainFrame.BackgroundTransparency = 0
        mainGuiBlocked = false
        if mouseConnection then mouseConnection:Disconnect() end
        if endedConnection then endedConnection:Disconnect() end
        pickerGui:Destroy()
        colorPickerOpen = false
        currentPickerFrame = nil
        pickerGuiRef = nil
    end)
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 100, 1, 0)
    cancelBtn.Position = UDim2.new(0.5, 5, 0, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
    cancelBtn.BackgroundTransparency = 0
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Text = "❌ Отмена"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.TextSize = 13
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Parent = bottomFrame
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = cancelBtn
    
    cancelBtn.MouseButton1Click:Connect(function()
        mainFrame.Active = true
        mainFrame.BackgroundTransparency = 0
        mainGuiBlocked = false
        if mouseConnection then mouseConnection:Disconnect() end
        if endedConnection then endedConnection:Disconnect() end
        pickerGui:Destroy()
        colorPickerOpen = false
        currentPickerFrame = nil
        pickerGuiRef = nil
    end)
    
    pickerData.selectedColor = currentColor
end

-- ============ ФУНКЦИЯ ДЛЯ СОЗДАНИЯ КНОПКИ ВЫБОРА ЦВЕТА ============
local function CreateColorPickerButton(title, yPos, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 28)
    container.Position = UDim2.new(0, 5, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    container.Parent = state.espSettingsFrame
    container.ClipsDescendants = false
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner").Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local currentColor = defaultColor
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 35, 0, 22)
    colorBtn.Position = UDim2.new(0.45, 0, 0.5, -11)
    colorBtn.BackgroundColor3 = currentColor
    colorBtn.BorderSizePixel = 1
    colorBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    colorBtn.Text = ""
    colorBtn.Parent = container
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 3)
    Instance.new("UICorner").Parent = colorBtn
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.0f, %.0f, %.0f", 
        currentColor.R * 255, 
        currentColor.G * 255, 
        currentColor.B * 255
    )
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = container
    
    local function updateColor(newColor)
        currentColor = newColor
        colorBtn.BackgroundColor3 = newColor
        valueLabel.Text = string.format("%.0f, %.0f, %.0f", 
            newColor.R * 255, 
            newColor.G * 255, 
            newColor.B * 255
        )
        if callback then callback(newColor) end
    end
    
    colorBtn.MouseButton1Click:Connect(function()
        OpenColorPicker(title, currentColor, function(newColor)
            updateColor(newColor)
        end)
    end)
    
    return {
        GetColor = function() return currentColor end,
        SetColor = function(color) updateColor(color) end
    }
end

-- ============ ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ФУНКЦИЙ С БИНДАМИ ============
local function CreateFeatureFrame(parent, labelText, bindName, toggleCallback, getState)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    frame.Visible = true
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
    Instance.new("UICorner").Parent = frame
    
    -- Название функции
    local featureLabel = Instance.new("TextLabel")
    featureLabel.Size = UDim2.new(0.6, 0, 1, 0)
    featureLabel.Position = UDim2.new(0, 40, 0, 0)
    featureLabel.BackgroundTransparency = 1
    featureLabel.Text = labelText
    featureLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    featureLabel.TextSize = 13
    featureLabel.Font = Enum.Font.GothamMedium
    featureLabel.TextXAlignment = Enum.TextXAlignment.Left
    featureLabel.TextTruncate = Enum.TextTruncate.None
    featureLabel.Parent = frame
    
    -- Контейнер для биндов
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(0, 160, 1, 0)
    bindContainer.Position = UDim2.new(0.7, 0, 0, 0)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = frame
    bindContainer.ClipsDescendants = false
    
    -- Кнопка Hold
    local holdBtn = Instance.new("TextButton")
    holdBtn.Size = UDim2.new(0, 48, 0, 18)
    holdBtn.Position = UDim2.new(0, 0, 0, 2)
    holdBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    holdBtn.BorderSizePixel = 0
    holdBtn.Text = "Hold"
    holdBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    holdBtn.TextSize = 9
    holdBtn.Font = Enum.Font.GothamMedium
    holdBtn.Parent = bindContainer
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 3)
    Instance.new("UICorner").Parent = holdBtn
    
    -- Кнопка Toggle
    local toggleBindBtn = Instance.new("TextButton")
    toggleBindBtn.Size = UDim2.new(0, 48, 0, 18)
    toggleBindBtn.Position = UDim2.new(0, 52, 0, 2)
    toggleBindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBindBtn.BorderSizePixel = 0
    toggleBindBtn.Text = "Toggle"
    toggleBindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBindBtn.TextSize = 9
    toggleBindBtn.Font = Enum.Font.GothamMedium
    toggleBindBtn.Parent = bindContainer
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 3)
    Instance.new("UICorner").Parent = toggleBindBtn
    
    -- Индикатор бинда
    local bindIndicator = Instance.new("TextLabel")
    bindIndicator.Size = UDim2.new(0, 105, 0, 14)
    bindIndicator.Position = UDim2.new(0, 0, 0, 24)
    bindIndicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bindIndicator.BorderSizePixel = 0
    bindIndicator.Text = "None"
    bindIndicator.TextColor3 = Color3.fromRGB(150, 150, 150)
    bindIndicator.TextSize = 8
    bindIndicator.Font = Enum.Font.GothamMedium
    bindIndicator.TextXAlignment = Enum.TextXAlignment.Center
    bindIndicator.Parent = bindContainer
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 2)
    Instance.new("UICorner").Parent = bindIndicator
    
    -- Переключатель (справа)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 50, 0, 22)
    track.Position = UDim2.new(1, -55, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner").Parent = track
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner").Parent = knob
    
    -- Добавляем кнопки в список блокируемых
    table.insert(state.blockedButtons, holdBtn)
    table.insert(state.blockedButtons, toggleBindBtn)
    
    local currentBindKey = nil
    local currentBindMode = nil
    local isActive = false
    
    local function UpdateIndicator()
        if currentBindKey then
            bindIndicator.Text = GetKeyName(currentBindKey) .. " (" .. (currentBindMode == "hold" and "Hold" or "Toggle") .. ")"
            bindIndicator.TextColor3 = Color3.fromRGB(255, 200, 100)
            bindIndicator.BackgroundColor3 = Color3.fromRGB(40, 40, 30)
        else
            bindIndicator.Text = "None"
            bindIndicator.TextColor3 = Color3.fromRGB(150, 150, 150)
            bindIndicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end
    
    local function SetActive(val)
        isActive = val
        if val then
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        if toggleCallback then toggleCallback(val) end
        -- Обновляем список биндов при изменении состояния
        ForceUpdateBindList()
    end
    
    local function OnClick()
        if not state.isWaitingForBind then
            SetActive(not isActive)
        end
    end
    
    -- Клик по переключателю
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            OnClick()
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            OnClick()
        end
    end)
    
    -- Клик по тексту
    featureLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            OnClick()
        end
    end)
    
    -- Функция SetBind
    local function SetBind(keyCode, mode)
        -- Удаляем старый бинд для этой функции
        for bindKey, bindInfo in pairs(state.binds) do
            if bindInfo.target == bindName then
                state.binds[bindKey] = nil
                break
            end
        end
        
        -- Удаляем старый бинд для этой клавиши
        if state.binds[keyCode] then
            state.binds[keyCode] = nil
        end
        
        if keyCode and mode then
            currentBindKey = keyCode
            currentBindMode = mode
            state.binds[keyCode] = {
                target = bindName,
                mode = mode,
                toggleCallback = function(val)
                    SetActive(val)
                end,
                getState = function()
                    return isActive
                end
            }
            print("[flin.cc] Бинд установлен: " .. bindName .. " -> " .. GetKeyName(keyCode) .. " (" .. mode .. ")")
            
            -- ОБНОВЛЯЕМ СПИСОК БИНДОВ
            ForceUpdateBindList()
        else
            currentBindKey = nil
            currentBindMode = nil
        end
        
        UpdateIndicator()
    end
    
    -- Функции для биндов
    local function StartBind(mode)
        if state.isWaitingForBind then 
            print("[flin.cc] Уже ожидается ввод бинда!")
            return 
        end
        
        state.isWaitingForBind = true
        state.waitingBindMode = mode
        state.waitingBindFeature = {
            SetBind = SetBind
        }
        
        -- Блокируем все кнопки биндов
        SetAllButtonsLocked(true)
        
        bindIndicator.Text = "Нажми клавишу..."
        bindIndicator.TextColor3 = Color3.fromRGB(255, 255, 100)
        bindIndicator.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
        
        print("[flin.cc] Ожидание нажатия клавиши для " .. bindName .. " (" .. mode .. ")")
    end
    
    holdBtn.MouseButton1Click:Connect(function()
        StartBind("hold")
    end)
    
    toggleBindBtn.MouseButton1Click:Connect(function()
        StartBind("toggle")
    end)
    
    return {
        Frame = frame,
        SetActive = SetActive,
        IsActive = function() return isActive end,
        SetBind = SetBind,
        GetBindKey = function() return currentBindKey end,
        GetBindMode = function() return currentBindMode end
    }
end

-- ============ ПРОДОЛЖЕНИЕ СОЗДАНИЯ GUI ============
-- Drag Zone
local dragZone = Instance.new("Frame")
dragZone.Size = UDim2.new(1, 0, 0, 32)
dragZone.BackgroundTransparency = 1
dragZone.Parent = mainFrame
dragZone.ZIndex = 10

local isDraggingMenu = false
local dragStartPos = nil
local frameStartPos = nil

dragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingMenu = true
        dragStartPos = input.Position
        frameStartPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingMenu = false
    end
end)

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "flin.cc [Insert]"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 32)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Панель разделов
local sectionsPanel = Instance.new("Frame")
sectionsPanel.Size = UDim2.new(0, 120, 1, -45)
sectionsPanel.Position = UDim2.new(0, 5, 0, 40)
sectionsPanel.BackgroundTransparency = 1
sectionsPanel.Parent = mainFrame

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 25)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "РАЗДЕЛЫ"
panelTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
panelTitle.TextSize = 11
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextXAlignment = Enum.TextXAlignment.Center
panelTitle.Parent = sectionsPanel

-- Панель функций
local functionsPanel = Instance.new("Frame")
functionsPanel.Size = UDim2.new(1, -300, 1, -45)
functionsPanel.Position = UDim2.new(0, 280, 0, 40)
functionsPanel.BackgroundTransparency = 1
functionsPanel.Parent = mainFrame
functionsPanel.ClipsDescendants = true

local funcTitle = Instance.new("TextLabel")
funcTitle.Size = UDim2.new(1, 0, 0, 25)
funcTitle.BackgroundTransparency = 1
funcTitle.Text = "RAGE - ФУНКЦИИ"
funcTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
funcTitle.TextSize = 11
funcTitle.Font = Enum.Font.GothamBold
funcTitle.TextXAlignment = Enum.TextXAlignment.Center
funcTitle.Parent = functionsPanel

local buttonsContainer = Instance.new("Frame")
buttonsContainer.Size = UDim2.new(1, 0, 1, -30)
buttonsContainer.Position = UDim2.new(0, 0, 0, 28)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = functionsPanel
buttonsContainer.ClipsDescendants = false

local functionsLayout = Instance.new("Frame")
functionsLayout.Size = UDim2.new(1, 0, 0, 200)
functionsLayout.BackgroundTransparency = 1
functionsLayout.Parent = buttonsContainer
functionsLayout.ClipsDescendants = false

local function updateSections()
    for _, child in pairs(functionsLayout:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("Section") then
            child.Visible = (child:GetAttribute("Section") or "Rage") == state.currentSection
        end
    end
end

-- Кнопки разделов
local function createSectionButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = sectionsPanel
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
    Instance.new("UICorner").Parent = btn
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 1, -6)
    ind.Position = UDim2.new(0, 2, 0, 0.5)
    ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.Parent = btn
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = ind
    
    btn.MouseButton1Click:Connect(function()
        state.currentSection = text
        updateSections()
        
        for _, child in pairs(sectionsPanel:GetChildren()) do
            if child:IsA("TextButton") then
                local indicator = child:FindFirstChild("Indicator")
                if indicator then
                    if child == btn then
                        child.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                        child.TextColor3 = Color3.fromRGB(255, 255, 255)
                        indicator.BackgroundTransparency = 0
                    else
                        child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        child.TextColor3 = Color3.fromRGB(200, 200, 200)
                        indicator.BackgroundTransparency = 1
                    end
                end
            end
        end
        
        funcTitle.Text = text:upper() .. " - " .. (text == "Config" and "КОНФИГИ" or "ФУНКЦИИ")
    end)
    
    return btn
end

local rageBtn = createSectionButton("Rage", 30)
local visualBtn = createSectionButton("Visual", 67)
local configBtn = createSectionButton("Config", 104)

rageBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
rageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
local rageInd = rageBtn:FindFirstChild("Indicator")
if rageInd then rageInd.BackgroundTransparency = 0 end

-- ============ RAGE РАЗДЕЛ ============
local rageContainer = Instance.new("Frame")
rageContainer.Size = UDim2.new(1, 0, 0, 0)
rageContainer.BackgroundTransparency = 1
rageContainer.Parent = functionsLayout
rageContainer:SetAttribute("Section", "Rage")
rageContainer.ClipsDescendants = false
rageContainer.Visible = true

local rageLayout = Instance.new("UIListLayout")
rageLayout.Parent = rageContainer
rageLayout.SortOrder = Enum.SortOrder.LayoutOrder
rageLayout.Padding = UDim.new(0, 3)

local function updateRageContainerHeight()
    local height = 0
    for _, child in pairs(rageContainer:GetChildren()) do
        if child:IsA("Frame") and child.Visible and child.Name ~= "RageLayout" then
            height = height + child.Size.Y.Offset + 3
        end
    end
    height = height + 5
    rageContainer.Size = UDim2.new(1, 0, 0, height)
    functionsLayout.Size = UDim2.new(1, 0, 0, height + 10)
end

-- Speed Boost
local speedFeature = CreateFeatureFrame(rageContainer, "Speed Boost", "Speed", function(val)
    state.isSpeedEnabled = val
    ApplySpeed()
end, function() return state.isSpeedEnabled end)

state.toggleRefs.speed = {
    SetActive = speedFeature.SetActive,
    IsActive = speedFeature.IsActive
}

state.bindRefs = state.bindRefs or {}
state.bindRefs.speed = speedFeature

-- Настройки скорости
local speedSettingsFrame = Instance.new("Frame")
speedSettingsFrame.Size = UDim2.new(1, -10, 0, 60)
speedSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedSettingsFrame.BorderSizePixel = 0
speedSettingsFrame.Parent = rageContainer
speedSettingsFrame.Visible = false
speedSettingsFrame.ClipsDescendants = false

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = speedSettingsFrame

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
speedValueLabel.Position = UDim2.new(0, 10, 0, 0)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Text = "Скорость:"
speedValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedValueLabel.TextSize = 13
speedValueLabel.Font = Enum.Font.GothamMedium
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
speedValueLabel.Parent = speedSettingsFrame

state.speedNumLabel = Instance.new("TextLabel")
state.speedNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
state.speedNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
state.speedNumLabel.BackgroundTransparency = 1
state.speedNumLabel.Text = "50"
state.speedNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
state.speedNumLabel.TextSize = 14
state.speedNumLabel.Font = Enum.Font.GothamBold
state.speedNumLabel.TextXAlignment = Enum.TextXAlignment.Center
state.speedNumLabel.Parent = speedSettingsFrame

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(0.5, -20, 0, 6)
sliderTrack.Position = UDim2.new(0.45, 0, 0.5, -3)
sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = speedSettingsFrame

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = sliderTrack

state.sliderFill = Instance.new("Frame")
state.sliderFill.Size = UDim2.new(0.375, 0, 1, 0)
state.sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
state.sliderFill.BorderSizePixel = 0
state.sliderFill.Parent = sliderTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = state.sliderFill

state.sliderKnob = Instance.new("Frame")
state.sliderKnob.Size = UDim2.new(0, 14, 0, 14)
state.sliderKnob.Position = UDim2.new(0.375, -7, 0.5, -7)
state.sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
state.sliderKnob.BorderSizePixel = 0
state.sliderKnob.Parent = sliderTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = state.sliderKnob

local function UpdateSlider(value)
    local clampedValue = math.clamp(value, 20, 100)
    state.speedValue = clampedValue
    local percent = (clampedValue - 20) / 80
    state.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    state.sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
    state.speedNumLabel.Text = tostring(math.round(clampedValue))
    if state.isSpeedEnabled then ApplySpeed() end
end

local isDraggingSlider = false

local function updateSliderFromMouse(input)
    local trackSize = sliderTrack.AbsoluteSize.X
    if trackSize > 0 then
        local mouseX = input.Position.X - sliderTrack.AbsolutePosition.X
        local percent = math.clamp(mouseX / trackSize, 0, 1)
        UpdateSlider(20 + percent * 80)
    end
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = true
        updateSliderFromMouse(input)
    end
end)
state.sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = true
        updateSliderFromMouse(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSliderFromMouse(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = false
    end
end)

-- Стрелка для раскрытия настроек скорости
local arrowBtn = Instance.new("TextButton")
arrowBtn.Size = UDim2.new(0, 30, 1, 0)
arrowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
arrowBtn.BorderSizePixel = 0
arrowBtn.Text = "▶"
arrowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
arrowBtn.TextSize = 14
arrowBtn.Font = Enum.Font.GothamMedium
arrowBtn.Parent = speedFeature.Frame

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = arrowBtn

local function toggleSpeedSettings()
    state.speedSettingsOpen = not state.speedSettingsOpen
    speedSettingsFrame.Visible = state.speedSettingsOpen
    arrowBtn.Text = state.speedSettingsOpen and "▼" or "▶"
    updateRageContainerHeight()
end

arrowBtn.MouseButton1Click:Connect(toggleSpeedSettings)

-- Noclip
local noclipFeature = CreateFeatureFrame(rageContainer, "Noclip", "Noclip", function(val)
    if val then EnableNoclip() else DisableNoclip() end
end, function() return state.isNoclipEnabled end)

state.toggleRefs.noclip = {
    SetActive = noclipFeature.SetActive,
    IsActive = noclipFeature.IsActive
}
state.bindRefs.noclip = noclipFeature

task.wait(0.1)
updateRageContainerHeight()

-- ============ VISUAL РАЗДЕЛ ============
state.visualContainer = Instance.new("Frame")
state.visualContainer.Size = UDim2.new(1, 0, 0, 0)
state.visualContainer.BackgroundTransparency = 1
state.visualContainer.Parent = functionsLayout
state.visualContainer:SetAttribute("Section", "Visual")
state.visualContainer.ClipsDescendants = false
state.visualContainer.Visible = false

local visualLayout = Instance.new("UIListLayout")
visualLayout.Parent = state.visualContainer
visualLayout.SortOrder = Enum.SortOrder.LayoutOrder
visualLayout.Padding = UDim.new(0, 3)

local function updateVisualContainerHeight()
    local height = 0
    for _, child in pairs(state.visualContainer:GetChildren()) do
        if child:IsA("Frame") and child.Visible and child.Name ~= "VisualLayout" then
            height = height + child.Size.Y.Offset + 3
        end
    end
    height = height + 5
    state.visualContainer.Size = UDim2.new(1, 0, 0, height)
end

-- FOV
local fovFeature = CreateFeatureFrame(state.visualContainer, "FOV Changer", "FOV", function(val)
    state.isFovEnabled = val
    ApplyFov()
end, function() return state.isFovEnabled end)

state.toggleRefs.fov = {
    SetActive = fovFeature.SetActive,
    IsActive = fovFeature.IsActive
}
state.bindRefs.fov = fovFeature

-- Настройки FOV
local fovSettingsFrame = Instance.new("Frame")
fovSettingsFrame.Size = UDim2.new(1, -10, 0, 60)
fovSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
fovSettingsFrame.BorderSizePixel = 0
fovSettingsFrame.Parent = state.visualContainer
fovSettingsFrame.Visible = false
fovSettingsFrame.ClipsDescendants = false

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = fovSettingsFrame

local fovValueLabel = Instance.new("TextLabel")
fovValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
fovValueLabel.Position = UDim2.new(0, 10, 0, 0)
fovValueLabel.BackgroundTransparency = 1
fovValueLabel.Text = "FOV:"
fovValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fovValueLabel.TextSize = 13
fovValueLabel.Font = Enum.Font.GothamMedium
fovValueLabel.TextXAlignment = Enum.TextXAlignment.Left
fovValueLabel.Parent = fovSettingsFrame

state.fovNumLabel = Instance.new("TextLabel")
state.fovNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
state.fovNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
state.fovNumLabel.BackgroundTransparency = 1
state.fovNumLabel.Text = "70"
state.fovNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
state.fovNumLabel.TextSize = 14
state.fovNumLabel.Font = Enum.Font.GothamBold
state.fovNumLabel.TextXAlignment = Enum.TextXAlignment.Center
state.fovNumLabel.Parent = fovSettingsFrame

local fovSliderTrack = Instance.new("Frame")
fovSliderTrack.Size = UDim2.new(0.5, -20, 0, 6)
fovSliderTrack.Position = UDim2.new(0.45, 0, 0.5, -3)
fovSliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fovSliderTrack.BorderSizePixel = 0
fovSliderTrack.Parent = fovSettingsFrame

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = fovSliderTrack

state.fovSliderFill = Instance.new("Frame")
state.fovSliderFill.Size = UDim2.new(0.375, 0, 1, 0)
state.fovSliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
state.fovSliderFill.BorderSizePixel = 0
state.fovSliderFill.Parent = fovSliderTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = state.fovSliderFill

state.fovSliderKnob = Instance.new("Frame")
state.fovSliderKnob.Size = UDim2.new(0, 14, 0, 14)
state.fovSliderKnob.Position = UDim2.new(0.375, -7, 0.5, -7)
state.fovSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
state.fovSliderKnob.BorderSizePixel = 0
state.fovSliderKnob.Parent = fovSliderTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = state.fovSliderKnob

local function UpdateFovSlider(value)
    local clampedValue = math.clamp(value, 40, 120)
    state.fovValue = clampedValue
    local percent = (clampedValue - 40) / 80
    state.fovSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    state.fovSliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
    state.fovNumLabel.Text = tostring(math.round(clampedValue))
    if state.isFovEnabled then ApplyFov() end
end

local isDraggingFovSlider = false

local function updateFovSliderFromMouse(input)
    local trackSize = fovSliderTrack.AbsoluteSize.X
    if trackSize > 0 then
        local mouseX = input.Position.X - fovSliderTrack.AbsolutePosition.X
        local percent = math.clamp(mouseX / trackSize, 0, 1)
        UpdateFovSlider(40 + percent * 80)
    end
end

fovSliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingFovSlider = true
        updateFovSliderFromMouse(input)
    end
end)
state.fovSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingFovSlider = true
        updateFovSliderFromMouse(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingFovSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateFovSliderFromMouse(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingFovSlider = false
    end
end)

-- Стрелка для FOV
local fovArrowBtn = Instance.new("TextButton")
fovArrowBtn.Size = UDim2.new(0, 30, 1, 0)
fovArrowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fovArrowBtn.BorderSizePixel = 0
fovArrowBtn.Text = "▶"
fovArrowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
fovArrowBtn.TextSize = 14
fovArrowBtn.Font = Enum.Font.GothamMedium
fovArrowBtn.Parent = fovFeature.Frame

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = fovArrowBtn

local function toggleFovSettings()
    state.fovSettingsOpen = not state.fovSettingsOpen
    fovSettingsFrame.Visible = state.fovSettingsOpen
    fovArrowBtn.Text = state.fovSettingsOpen and "▼" or "▶"
    updateVisualContainerHeight()
end

fovArrowBtn.MouseButton1Click:Connect(toggleFovSettings)

-- FullBright
local fullBrightFeature = CreateFeatureFrame(state.visualContainer, "FullBright", "FullBright", function(val)
    if val then EnableFullBright() else DisableFullBright() end
end, function() return state.isFullBrightEnabled end)

state.toggleRefs.fullbright = {
    SetActive = fullBrightFeature.SetActive,
    IsActive = fullBrightFeature.IsActive
}
state.bindRefs.fullbright = fullBrightFeature

-- ESP
local espFeature = CreateFeatureFrame(state.visualContainer, "ESP (Highlight)", "ESP", function(val)
    if val then EnableEsp() else DisableEsp() end
end, function() return state.isEspEnabled end)

state.toggleRefs.esp = {
    SetActive = espFeature.SetActive,
    IsActive = espFeature.IsActive
}
state.bindRefs.esp = espFeature

-- Настройки ESP
state.espSettingsFrame = Instance.new("Frame")
state.espSettingsFrame.Size = UDim2.new(1, -10, 0, 160)
state.espSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
state.espSettingsFrame.BorderSizePixel = 0
state.espSettingsFrame.Parent = state.visualContainer
state.espSettingsFrame.Visible = false
state.espSettingsFrame.ClipsDescendants = false

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = state.espSettingsFrame

-- Кнопки выбора цвета
CreateColorPickerButton("Killer Color", 5, Color3.fromRGB(255, 0, 0), function(color)
    state.espSettings.KillerColor = color
    if state.isEspEnabled then updateESP() end
end)

CreateColorPickerButton("Survivor Color", 38, Color3.fromRGB(0, 255, 0), function(color)
    state.espSettings.SurvivorColor = color
    if state.isEspEnabled then updateESP() end
end)

-- Show Killer
local killerToggleFrame = Instance.new("Frame")
killerToggleFrame.Size = UDim2.new(1, -10, 0, 28)
killerToggleFrame.Position = UDim2.new(0, 5, 0, 71)
killerToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
killerToggleFrame.BorderSizePixel = 0
killerToggleFrame.Parent = state.espSettingsFrame

Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
Instance.new("UICorner").Parent = killerToggleFrame

local killerToggleLabel = Instance.new("TextLabel")
killerToggleLabel.Size = UDim2.new(0.5, 0, 1, 0)
killerToggleLabel.Position = UDim2.new(0, 10, 0, 0)
killerToggleLabel.BackgroundTransparency = 1
killerToggleLabel.Text = "Show Killer"
killerToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
killerToggleLabel.TextSize = 12
killerToggleLabel.Font = Enum.Font.GothamMedium
killerToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
killerToggleLabel.Parent = killerToggleFrame

local killerToggleTrack = Instance.new("Frame")
killerToggleTrack.Size = UDim2.new(0, 40, 0, 18)
killerToggleTrack.Position = UDim2.new(1, -45, 0.5, -9)
killerToggleTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
killerToggleTrack.BorderSizePixel = 0
killerToggleTrack.Parent = killerToggleFrame

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = killerToggleTrack

local killerToggleKnob = Instance.new("Frame")
killerToggleKnob.Size = UDim2.new(0, 14, 0, 14)
killerToggleKnob.Position = UDim2.new(1, -16, 0.5, -7)
killerToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
killerToggleKnob.BorderSizePixel = 0
killerToggleKnob.Parent = killerToggleTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = killerToggleKnob

local function setKillerShowActive(val)
    state.killerShowActive = val
    state.espSettings.ShowKiller = val
    if val then
        TweenService:Create(killerToggleTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(killerToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
    else
        TweenService:Create(killerToggleTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        TweenService:Create(killerToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
    end
    if state.isEspEnabled then updateESP() end
end

local function onKillerShowClick()
    setKillerShowActive(not state.killerShowActive)
end

killerToggleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onKillerShowClick() end
end)
killerToggleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onKillerShowClick() end
end)
killerToggleTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onKillerShowClick() end
end)
killerToggleKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onKillerShowClick() end
end)

state.toggleRefs.espManiac = {
    SetActive = setKillerShowActive,
    IsActive = function() return state.killerShowActive end
}

-- Show Survivor
local survivorToggleFrame = Instance.new("Frame")
survivorToggleFrame.Size = UDim2.new(1, -10, 0, 28)
survivorToggleFrame.Position = UDim2.new(0, 5, 0, 104)
survivorToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
survivorToggleFrame.BorderSizePixel = 0
survivorToggleFrame.Parent = state.espSettingsFrame

Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
Instance.new("UICorner").Parent = survivorToggleFrame

local survivorToggleLabel = Instance.new("TextLabel")
survivorToggleLabel.Size = UDim2.new(0.5, 0, 1, 0)
survivorToggleLabel.Position = UDim2.new(0, 10, 0, 0)
survivorToggleLabel.BackgroundTransparency = 1
survivorToggleLabel.Text = "Show Survivor"
survivorToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
survivorToggleLabel.TextSize = 12
survivorToggleLabel.Font = Enum.Font.GothamMedium
survivorToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
survivorToggleLabel.Parent = survivorToggleFrame

local survivorToggleTrack = Instance.new("Frame")
survivorToggleTrack.Size = UDim2.new(0, 40, 0, 18)
survivorToggleTrack.Position = UDim2.new(1, -45, 0.5, -9)
survivorToggleTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
survivorToggleTrack.BorderSizePixel = 0
survivorToggleTrack.Parent = survivorToggleFrame

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = survivorToggleTrack

local survivorToggleKnob = Instance.new("Frame")
survivorToggleKnob.Size = UDim2.new(0, 14, 0, 14)
survivorToggleKnob.Position = UDim2.new(1, -16, 0.5, -7)
survivorToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
survivorToggleKnob.BorderSizePixel = 0
survivorToggleKnob.Parent = survivorToggleTrack

Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
Instance.new("UICorner").Parent = survivorToggleKnob

local function setSurvivorShowActive(val)
    state.survivorShowActive = val
    state.espSettings.ShowSurvivor = val
    if val then
        TweenService:Create(survivorToggleTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(survivorToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
    else
        TweenService:Create(survivorToggleTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        TweenService:Create(survivorToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
    end
    if state.isEspEnabled then updateESP() end
end

local function onSurvivorShowClick()
    setSurvivorShowActive(not state.survivorShowActive)
end

survivorToggleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onSurvivorShowClick() end
end)
survivorToggleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onSurvivorShowClick() end
end)
survivorToggleTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onSurvivorShowClick() end
end)
survivorToggleKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onSurvivorShowClick() end
end)

state.toggleRefs.espSurvivor = {
    SetActive = setSurvivorShowActive,
    IsActive = function() return state.survivorShowActive end
}

-- Стрелка для ESP
state.espArrowBtn = Instance.new("TextButton")
state.espArrowBtn.Size = UDim2.new(0, 30, 1, 0)
state.espArrowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
state.espArrowBtn.BorderSizePixel = 0
state.espArrowBtn.Text = "▶"
state.espArrowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
state.espArrowBtn.TextSize = 14
state.espArrowBtn.Font = Enum.Font.GothamMedium
state.espArrowBtn.Parent = espFeature.Frame

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = state.espArrowBtn

local function toggleEspSettings()
    state.espSettingsOpen = not state.espSettingsOpen
    state.espSettingsFrame.Visible = state.espSettingsOpen
    state.espArrowBtn.Text = state.espSettingsOpen and "▼" or "▶"
    updateVisualContainerHeight()
end

state.espArrowBtn.MouseButton1Click:Connect(toggleEspSettings)

-- ============ BIND LIST (ДОБАВЛЯЕМ В VISUAL) ============
-- Bind List функция
local bindListFeature = CreateFeatureFrame(state.visualContainer, "Bind List", "BindList", function(val)
    if val then
        if not state.bindListVisible then
            ToggleBindList()
        end
    else
        if state.bindListVisible then
            ToggleBindList()
        end
    end
end, function() return state.bindListVisible end)

state.bindListToggleRef = {
    SetActive = bindListFeature.SetActive,
    IsActive = function() return state.bindListVisible end
}

state.toggleRefs.bindlist = {
    SetActive = bindListFeature.SetActive,
    IsActive = function() return state.bindListVisible end
}
state.bindRefs.bindlist = bindListFeature

updateVisualContainerHeight()

-- ============ CONFIG РАЗДЕЛ ============
local configFrame = Instance.new("Frame")
configFrame.Size = UDim2.new(1, -10, 0, 250)
configFrame.BackgroundTransparency = 1
configFrame.Parent = functionsLayout
configFrame.Visible = false
configFrame:SetAttribute("Section", "Config")

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, 0, 0, 30)
nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
nameBox.BorderSizePixel = 0
nameBox.Text = ""
nameBox.PlaceholderText = "Введите имя конфига..."
nameBox.TextColor3 = Color3.fromRGB(200, 200, 200)
nameBox.TextSize = 13
nameBox.Font = Enum.Font.GothamMedium
nameBox.Parent = configFrame

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
Instance.new("UICorner").Parent = nameBox

local btnPanel = Instance.new("Frame")
btnPanel.Size = UDim2.new(1, 0, 0, 35)
btnPanel.Position = UDim2.new(0, 0, 0, 35)
btnPanel.BackgroundTransparency = 1
btnPanel.Parent = configFrame

local function createConfigBtn(text, xPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, -3, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = btnPanel
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
    Instance.new("UICorner").Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local configListFrame = Instance.new("Frame")
configListFrame.Size = UDim2.new(1, 0, 1, -80)
configListFrame.Position = UDim2.new(0, 0, 0, 75)
configListFrame.BackgroundTransparency = 1
configListFrame.Parent = configFrame

local configScroll = Instance.new("ScrollingFrame")
configScroll.Size = UDim2.new(1, 0, 1, 0)
configScroll.BackgroundTransparency = 1
configScroll.Parent = configListFrame
configScroll.ScrollBarThickness = 6
configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
configScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local configListLayout = Instance.new("UIListLayout")
configListLayout.Parent = configScroll
configListLayout.SortOrder = Enum.SortOrder.LayoutOrder
configListLayout.Padding = UDim.new(0, 3)

function UpdateConfigList()
    for _, child in pairs(configScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local configs = GetConfigList()
    
    if not table.find(configs, "Default") then
        SaveConfig("Default")
        configs = GetConfigList()
    end
    
    for _, name in ipairs(configs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.BorderSizePixel = 0
        btn.Text = name .. (name == state.CurrentConfig and " ✓" or "")
        btn.TextColor3 = name == state.CurrentConfig and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = configScroll
        
        Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
        Instance.new("UICorner").Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            state.selectedConfigName = name
            nameBox.Text = name
            
            for _, child in pairs(configScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            print("[flin.cc] Выбран конфиг: " .. name)
        end)
    end
    
    configFrame.Size = UDim2.new(1, -10, 0, math.max(200, #configs * 35 + 100))
end

createConfigBtn("💾 Сохранить", 0, Color3.fromRGB(60, 60, 60), function()
    local name = nameBox.Text
    if name == "" then
        print("[flin.cc] Введите имя конфига!")
        return
    end
    SaveConfig(name)
    nameBox.Text = ""
    state.selectedConfigName = ""
end)

createConfigBtn("📂 Загрузить", 0.25, Color3.fromRGB(60, 60, 60), function()
    local name = nameBox.Text
    if name == "" then
        print("[flin.cc] Введите имя конфига!")
        return
    end
    LoadConfig(name)
end)

createConfigBtn("🗑 Удалить", 0.5, Color3.fromRGB(60, 60, 60), function()
    local name = nameBox.Text
    if name == "" then
        print("[flin.cc] Введите имя конфига!")
        return
    end
    DeleteConfig(name)
    nameBox.Text = ""
    state.selectedConfigName = ""
end)

createConfigBtn("✏ Переимен.", 0.75, Color3.fromRGB(60, 60, 60), function()
    local oldName = nameBox.Text
    if oldName == "" then
        print("[flin.cc] Выберите конфиг из списка!")
        return
    end
    if oldName == "Default" then
        print("[flin.cc] Нельзя переименовать Default!")
        return
    end
    
    local newName = oldName .. "_new"
    print("[flin.cc] Переименование из '" .. oldName .. "' в '" .. newName .. "'")
    
    local config = state.Configs[oldName]
    if config then
        state.Configs[newName] = config
        state.Configs[newName].Name = newName
        state.Configs[oldName] = nil
        
        local old = state.ConfigFolder:FindFirstChild(oldName)
        if old then old:Destroy() end
        
        local new = Instance.new("StringValue")
        new.Name = newName
        new.Value = safeJsonEncode(config)
        new.Parent = state.ConfigFolder
        
        if state.CurrentConfig == oldName then
            state.CurrentConfig = newName
        end
        
        UpdateConfigList()
        nameBox.Text = ""
        state.selectedConfigName = ""
        print("[flin.cc] Конфиг переименован в: " .. newName)
    end
end)

-- Настройка глобального обработчика биндов
SetupGlobalBindHandler()

-- Камера
RunService.RenderStepped:Connect(function()
    local char = player.Character
    
    if state.isSpeedEnabled and char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= state.speedValue then
            humanoid.WalkSpeed = state.speedValue
        end
    end
    
    if state.isFovEnabled then
        local camera = workspace.CurrentCamera
        if camera and camera.FieldOfView ~= state.fovValue then
            camera.FieldOfView = state.fovValue
        end
    end
    
    local camera = workspace.CurrentCamera
    if camera and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local lookVector = camera.CFrame.LookVector
            local targetPos = root.Position + Vector3.new(0, 2.5, 0)
            local camPos = targetPos - lookVector * 8
            camera.CFrame = CFrame.new(camPos, camPos + lookVector)
        end
    end
end)

-- Управление меню
local function toggleMenu()
    state.isMenuVisible = not state.isMenuVisible
    mainFrame.Visible = state.isMenuVisible
    
    if state.isMenuVisible then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    end
    
    print("[flin.cc] Меню " .. (state.isMenuVisible and "открыто" or "закрыто"))
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

-- Отслеживание камеры
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = state.isFovEnabled and state.fovValue or state.originalFov
    end
end)

-- Авто-восстановление
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    char.Humanoid.WalkSpeed = state.isSpeedEnabled and state.speedValue or 16
    if state.isNoclipEnabled then EnableNoclip() end
    task.wait(0.1)
    ApplyFov()
    if state.isFullBrightEnabled then ApplyFullBright() end
    if state.isEspEnabled then EnableEsp() end
end)

-- Запуск
task.wait(0.5)

local camera = workspace.CurrentCamera
if camera then
    state.originalFov = camera.FieldOfView
end

state.originalBrightness = Lighting.Brightness
state.originalAmbient = Lighting.Ambient

SaveConfig("Default")
UpdateConfigList()

ApplySpeed()
ApplyFov()
DisableFullBright()
DisableEsp()

task.wait(0.3)
state.isMenuVisible = true
mainFrame.Visible = true
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
UserInputService.MouseIconEnabled = true

print("[flin.cc] ========================================")
print("[flin.cc] Скрипт успешно загружен!")
print("[flin.cc] Нажмите Insert для закрытия/открытия")
print("[flin.cc] ========================================")
