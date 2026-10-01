--[[
  ███████╗██╗     ██╗███╗   ██╗   ██████╗ ██████╗
  ██╔════╝██║     ██║████╗  ██║  ██╔════╝██╔════╝
  █████╗  ██║     ██║██╔██╗ ██║  ██║     ██║     
  ██╔══╝  ██║     ██║██║╚██╗██║  ██║     ██║     
  ██║     ███████╗██║██║ ╚████║  ╚██████╗╚██████╗
  ╚═╝     ╚══════╝╚═╝╚═╝  ╚═══╝   ╚═════╝ ╚═════╝
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, c in pairs(playerGui:GetChildren()) do
    if c:IsA("ScreenGui") and (c.Name=="CheatGui" or c.Name=="BindListGui" or c.Name=="ColorPickerGui" or c.Name=="AspectRatioOverlay" or c.Name=="FlinKeyGui") then c:Destroy() end
end

local state = {
    speedSettingsOpen=false, movementOpen=false, isNoclipEnabled=false, noclipConnection=nil, moonwalkBaseC0=nil,
    isFlyEnabled=false, flyValue=60, flySettingsOpen=false, flyConnection=nil, flyBodyVelocity=nil, flyBodyGyro=nil,
    isSpeedEnabled=false, speedValue=50, currentSection="Rage", isMenuVisible=false,
    isDashEnabled=false, dashDistance=25, dashTime=0.50, dashDirection="Camera", dashSettingsOpen=false, dashConnection=nil,
    dashBindKey=nil, dashBindBtn=nil,
    dashDistanceLabel=nil, dashDistFill=nil, dashDistKnob=nil,
    dashTimeLabel=nil, dashTimeFill=nil, dashTimeKnob=nil, dashDirectionBtn=nil,
    dashBodyVelocity=nil, dashCooldown=false,

    isMoonwalkEnabled=false, moonwalkSwayAmplitude=100, moonwalkSwayInterval=0.20, moonwalkSwaySmoothSpeed=20,
    moonwalkConnection=nil, moonwalkSettingsOpen=false, moonwalkPhase=0,

    isAutoDaggerEnabled=false, autoDaggerSettingsOpen=false,
    autoDaggerRadius=12, autoDaggerDelay=0.1, autoDaggerCooldown=91,
    autoDaggerShowRadius=true, autoDaggerColor=Color3.fromRGB(255,50,50),
    autoDaggerLastFire=0, autoDaggerConnection=nil,
    autoDaggerParryRemote=nil, autoDaggerParryResultRemote=nil,
    autoDaggerCircleParts={}, autoDaggerCircleRadius=0, autoDaggerCircleColor=nil,
    autoDaggerRadiusLabel=nil, autoDaggerRadiusFill=nil, autoDaggerRadiusKnob=nil,
    autoDaggerDelayLabel=nil, autoDaggerDelayFill=nil, autoDaggerDelayKnob=nil,
    autoDaggerCooldownLabel=nil, autoDaggerCooldownFill=nil, autoDaggerCooldownKnob=nil,
    autoDaggerColorRef=nil,

    isFovEnabled=false, fovValue=70, fovSettingsOpen=false, originalFov=70,
    cameraOpen=false, worldOpen=false, isTimeEnabled=false, timeValue=12, timeSettingsOpen=false,
    isAspectEnabled=false, aspectValue=0.75, aspectSettingsOpen=false,
    aspectSliderFill=nil, aspectSliderKnob=nil, aspectNumLabel=nil, aspectConnection=nil,
    aspectPresetRefs={}, aspectBaseCFrame=nil,
    timeSliderFill=nil, timeSliderKnob=nil, timeNumLabel=nil, originalTime=12, timeConnection=nil,
    isFullBrightEnabled=false, originalBrightness=Lighting.Brightness, originalAmbient=Lighting.Ambient, fullBrightConnection=nil,
    isRemoveFogEnabled=false, removeFogConnection=nil, originalFogEnd=100000, originalFogStart=0, originalAtmDensity=nil, originalAtmHaze=nil,
    isEspEnabled=false, espSettingsOpen=false, highlights={}, espConnection=nil,
    espSettings={ShowKiller=true,ShowSurvivor=true,ShowSelf=true,KillerColor=Color3.fromRGB(255,0,0),SurvivorColor=Color3.fromRGB(0,255,0),SelfColor=Color3.fromRGB(0,150,255),FillTransparency=0.3,OutlineTransparency=0.2},
    isAutoSkillcheckEnabled=false, skillcheckQuality="Great", skillcheckConnection=nil, skillcheckCooldown=false, skillcheckCheckConnection=nil, skillcheckSettingsOpen=false,
    isInstaHealEnabled=false, instaHealConnection=nil, instaHealCharacterConnection=nil,
    isRecoveryHealEnabled=false, recoveryHealConnection=nil, recoveryHealCharacterConnection=nil, currentHealth=100, maxHealth=100,
    isGenHighlightEnabled=false, genHighlightConnection=nil, genHighlights={}, genSettings={HighlightColor=Color3.fromRGB(0,255,255)},
    isGateHighlightEnabled=false, gateHighlightConnection=nil, gateHighlights={}, gateSettings={HighlightColor=Color3.fromRGB(255,255,0)},
    isPalletHighlightEnabled=false, palletHighlightConnection=nil, palletHighlights={}, palletSettings={HighlightColor=Color3.fromRGB(255,100,0)},
    isWindowHighlightEnabled=false, windowHighlightConnection=nil, windowHighlights={}, windowSettings={HighlightColor=Color3.fromRGB(0,200,255)},
    isHookHighlightEnabled=false, hookHighlightConnection=nil, hookHighlights={}, hookSettings={HighlightColor=Color3.fromRGB(255,50,200)}, hookToggleRef=nil, hookColorRef=nil,
    Configs={}, CurrentConfig="Default", ConfigFolder=nil, toggleRefs={},
    sliderFill=nil, sliderKnob=nil, speedNumLabel=nil,
    fovSliderFill=nil, fovSliderKnob=nil, fovNumLabel=nil,
    visualContainer=nil, espArrowBtn=nil, espSettingsFrame=nil, selectedConfigName="",
    binds={}, isWaitingForBind=false, waitingBindFeature=nil, waitingBindMode=nil, blockedButtons={}, bindRefs={},
    bindListVisible=false, bindListGui=nil, bindListFrame=nil, isDraggingBindList=false, bindListDragStart=nil, bindListFrameStart=nil, bindListToggleRef=nil,
    isDraggingMenu=false, dragStartPos=nil, frameStartPos=nil,
    keyAuthenticated=false,
    genToggleRef=nil, genColorRef=nil, gateToggleRef=nil, gateColorRef=nil,
    palletToggleRef=nil, palletColorRef=nil, windowToggleRef=nil, windowColorRef=nil,
}

state.ConfigFolder=Instance.new("Folder")
state.ConfigFolder.Name="flin_cc_Configs"
state.ConfigFolder.Parent=playerGui

local Remotes=ReplicatedStorage:FindFirstChild("Remotes")
local GeneratorRemotes=Remotes and Remotes:FindFirstChild("Generator")
local HealingRemotes=Remotes and Remotes:FindFirstChild("Healing")
local SkillCheckEvent=GeneratorRemotes and GeneratorRemotes:FindFirstChild("SkillCheckEvent")
local HealEvent=HealingRemotes and HealingRemotes:FindFirstChild("HealEvent")
local StopHealing=HealingRemotes and HealingRemotes:FindFirstChild("StopHealing")

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj.Name == "parry" and obj:IsA("RemoteEvent") and obj.Parent and obj.Parent.Name == "Parrying Dagger" then
        state.autoDaggerParryRemote = obj
    end
    if obj.Name == "parryResult" and obj:IsA("RemoteEvent") and obj.Parent and obj.Parent.Name == "Parrying Dagger" then
        state.autoDaggerParryResultRemote = obj
    end
end

local function safeJsonEncode(d) local ok,r=pcall(function() return HttpService:JSONEncode(d) end) return ok and r or nil end
local function safeJsonDecode(d) local ok,r=pcall(function() return HttpService:JSONDecode(d) end) return ok and r or nil end

local KeyNames={
    [Enum.KeyCode.Unknown]="?",[Enum.KeyCode.A]="A",[Enum.KeyCode.B]="B",[Enum.KeyCode.C]="C",
    [Enum.KeyCode.D]="D",[Enum.KeyCode.E]="E",[Enum.KeyCode.F]="F",[Enum.KeyCode.G]="G",
    [Enum.KeyCode.H]="H",[Enum.KeyCode.I]="I",[Enum.KeyCode.J]="J",[Enum.KeyCode.K]="K",
    [Enum.KeyCode.L]="L",[Enum.KeyCode.M]="M",[Enum.KeyCode.N]="N",[Enum.KeyCode.O]="O",
    [Enum.KeyCode.P]="P",[Enum.KeyCode.Q]="Q",[Enum.KeyCode.R]="R",[Enum.KeyCode.S]="S",
    [Enum.KeyCode.T]="T",[Enum.KeyCode.U]="U",[Enum.KeyCode.V]="V",[Enum.KeyCode.W]="W",
    [Enum.KeyCode.X]="X",[Enum.KeyCode.Y]="Y",[Enum.KeyCode.Z]="Z",
    [Enum.KeyCode.One]="1",[Enum.KeyCode.Two]="2",[Enum.KeyCode.Three]="3",[Enum.KeyCode.Four]="4",
    [Enum.KeyCode.Five]="5",[Enum.KeyCode.Six]="6",[Enum.KeyCode.Seven]="7",[Enum.KeyCode.Eight]="8",
    [Enum.KeyCode.Nine]="9",[Enum.KeyCode.Zero]="0",
    [Enum.KeyCode.F1]="F1",[Enum.KeyCode.F2]="F2",[Enum.KeyCode.F3]="F3",[Enum.KeyCode.F4]="F4",
    [Enum.KeyCode.F5]="F5",[Enum.KeyCode.F6]="F6",[Enum.KeyCode.F7]="F7",[Enum.KeyCode.F8]="F8",
    [Enum.KeyCode.F9]="F9",[Enum.KeyCode.F10]="F10",[Enum.KeyCode.F11]="F11",[Enum.KeyCode.F12]="F12",
    [Enum.KeyCode.LeftShift]="LShift",[Enum.KeyCode.RightShift]="RShift",
    [Enum.KeyCode.LeftControl]="LCtrl",[Enum.KeyCode.RightControl]="RCtrl",
    [Enum.KeyCode.LeftAlt]="LAlt",[Enum.KeyCode.RightAlt]="RAlt",
    [Enum.KeyCode.Space]="Space",[Enum.KeyCode.Tab]="Tab",[Enum.KeyCode.Return]="Enter",
    [Enum.KeyCode.Escape]="Esc",[Enum.KeyCode.Backspace]="Backspace",[Enum.KeyCode.Delete]="Del",
    [Enum.KeyCode.Insert]="Ins",[Enum.KeyCode.Home]="Home",[Enum.KeyCode.End]="End",
    [Enum.KeyCode.PageUp]="PgUp",[Enum.KeyCode.PageDown]="PgDn",
    [Enum.KeyCode.Up]="↑",[Enum.KeyCode.Down]="↓",[Enum.KeyCode.Left]="←",[Enum.KeyCode.Right]="→",
}
local function GetKeyName(k) return KeyNames[k] or "?" end

local function SetAllButtonsLocked(locked)
    for _,btn in ipairs(state.blockedButtons) do
        if btn and btn.Parent then btn.Visible=not locked; btn.Active=not locked end
    end
end

local function SetupGlobalBindHandler()
    UserInputService.InputBegan:Connect(function(input,gp)
        if input.UserInputType~=Enum.UserInputType.Keyboard then return end
        if state.isWaitingForBind then
            local k=input.KeyCode
            if k~=Enum.KeyCode.Unknown and k~=Enum.KeyCode.Escape and k~=Enum.KeyCode.Insert then
                if state.waitingBindFeature and state.waitingBindFeature.SetBind then
                    state.waitingBindFeature.SetBind(k,state.waitingBindMode)
                end
                state.isWaitingForBind=false; state.waitingBindFeature=nil; state.waitingBindMode=nil
                SetAllButtonsLocked(false)
            end
            return
        end
        local b=state.binds[input.KeyCode]
        if b then
            if b.mode=="toggle" then b.toggleCallback(not b.getState())
            elseif b.mode=="hold" then b.toggleCallback(true)
            elseif b.mode=="action" then b.toggleCallback() end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.Keyboard then return end
        local b=state.binds[input.KeyCode]
        if b and b.mode=="hold" then b.toggleCallback(false) end
    end)
end

local function UpdateBindListContent()
    if not state.bindListFrame then return end
    local s=state.bindListFrame:FindFirstChildOfClass("ScrollingFrame")
    if not s then return end
    for _,ch in pairs(s:GetChildren()) do
        if ch:IsA("Frame") or ch:IsA("TextLabel") or ch:IsA("TextButton") then ch:Destroy() end
    end
    local entries={}
    for k,b in pairs(state.binds) do
        if b and b.target and b.getState then
            table.insert(entries,{key=GetKeyName(k),target=b.target,mode=b.mode or "toggle",active=b.getState() or false})
        end
    end
    table.sort(entries,function(a,b) return a.target<b.target end)
    if #entries==0 then
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,0,0,30); l.BackgroundTransparency=1; l.Text="Нет активных биндов"
        l.TextColor3=Color3.fromRGB(100,100,100); l.TextSize=12; l.Font=Enum.Font.GothamMedium; l.Parent=s
        return
    end
    local n=math.min(#entries,10)
    for i=1,n do
        local e=entries[i]
        local f=Instance.new("Frame")
        f.Size=UDim2.new(1,0,0,28); f.BackgroundColor3=Color3.fromRGB(35,35,35); f.BorderSizePixel=0; f.Parent=s
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
        local ind=Instance.new("Frame")
        ind.Size=UDim2.new(0,8,0,8); ind.Position=UDim2.new(0,8,0.5,-4)
        ind.BackgroundColor3=e.active and Color3.fromRGB(0,255,100) or Color3.fromRGB(80,80,80); ind.BorderSizePixel=0; ind.Parent=f
        Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel")
        nl.Size=UDim2.new(0.4,0,1,0); nl.Position=UDim2.new(0,20,0,0); nl.BackgroundTransparency=1
        nl.Text=e.target; nl.TextColor3=Color3.fromRGB(220,220,220); nl.TextSize=11; nl.Font=Enum.Font.GothamMedium
        nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f
        local kl=Instance.new("TextLabel")
        kl.Size=UDim2.new(0.35,0,1,0); kl.Position=UDim2.new(0.4,0,0,0); kl.BackgroundTransparency=1
        kl.Text="["..e.key.."]"; kl.TextColor3=Color3.fromRGB(255,200,100); kl.TextSize=12; kl.Font=Enum.Font.GothamBold
        kl.TextXAlignment=Enum.TextXAlignment.Center; kl.Parent=f
        local ml=Instance.new("TextLabel")
        ml.Size=UDim2.new(0.2,0,1,0); ml.Position=UDim2.new(0.75,0,0,0); ml.BackgroundTransparency=1
        if e.mode=="hold" then
            ml.Text="Hold"; ml.TextColor3=Color3.fromRGB(100,200,255)
        elseif e.mode=="action" then
            ml.Text="Action"; ml.TextColor3=Color3.fromRGB(100,255,150)
        else
            ml.Text="Toggle"; ml.TextColor3=Color3.fromRGB(255,180,100)
        end
        ml.TextSize=9; ml.Font=Enum.Font.GothamMedium; ml.TextXAlignment=Enum.TextXAlignment.Center; ml.Parent=f
    end
    s.CanvasSize=UDim2.new(0,0,0,n*33+10)
end

local function ForceUpdateBindList()
    if state.bindListVisible and state.bindListFrame then task.defer(UpdateBindListContent) end
end

local function CreateBindListWindow()
    if state.bindListGui then state.bindListGui:Destroy(); state.bindListGui=nil; state.bindListFrame=nil end
    local g=Instance.new("ScreenGui")
    g.Name="BindListGui"; g.Parent=playerGui; g.ResetOnSpawn=false; g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    state.bindListGui=g
    local f=Instance.new("Frame")
    f.Size=UDim2.new(0,250,0,300); f.Position=UDim2.new(0.01,0,0.4,-150)
    f.BackgroundColor3=Color3.fromRGB(20,20,20); f.BorderSizePixel=0; f.Parent=g; f.Active=true
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    state.bindListFrame=f
    local drag=Instance.new("Frame")
    drag.Size=UDim2.new(1,0,0,30); drag.BackgroundColor3=Color3.fromRGB(30,30,30); drag.BorderSizePixel=0; drag.Parent=f; drag.ZIndex=10
    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(1,-35,1,0); t.Position=UDim2.new(0,5,0,0); t.BackgroundTransparency=1
    t.Text="BIND LIST"; t.TextColor3=Color3.fromRGB(255,255,255); t.TextSize=14; t.Font=Enum.Font.GothamBold
    t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=drag
    local cl=Instance.new("TextButton")
    cl.Size=UDim2.new(0,25,0,25); cl.Position=UDim2.new(1,-30,0,2.5); cl.BackgroundColor3=Color3.fromRGB(50,50,50)
    cl.BorderSizePixel=0; cl.Text="X"; cl.TextColor3=Color3.fromRGB(200,200,200); cl.TextSize=12; cl.Font=Enum.Font.GothamBold; cl.Parent=drag
    Instance.new("UICorner",cl).CornerRadius=UDim.new(0,4)
    cl.MouseButton1Click:Connect(function()
        state.bindListVisible=false
        if state.bindListGui then state.bindListGui:Destroy(); state.bindListGui=nil; state.bindListFrame=nil end
        if state.bindListToggleRef then state.bindListToggleRef.SetActive(false) end
    end)
    drag.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            state.isDraggingBindList=true; state.bindListDragStart=input.Position; state.bindListFrameStart=f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if state.isDraggingBindList and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d=input.Position-state.bindListDragStart
            f.Position=UDim2.new(state.bindListFrameStart.X.Scale,state.bindListFrameStart.X.Offset+d.X,state.bindListFrameStart.Y.Scale,state.bindListFrameStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then state.isDraggingBindList=false end
    end)
    local sc=Instance.new("ScrollingFrame")
    sc.Size=UDim2.new(1,-10,1,-40); sc.Position=UDim2.new(0,5,0,35); sc.BackgroundTransparency=1
    sc.Parent=f; sc.ScrollBarThickness=6; sc.CanvasSize=UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; sc.BorderSizePixel=0
    local lay=Instance.new("UIListLayout")
    lay.Parent=sc; lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Padding=UDim.new(0,3)
    UpdateBindListContent()
    return f
end

local function ToggleBindList()
    state.bindListVisible=not state.bindListVisible
    if state.bindListVisible then CreateBindListWindow()
    else
        if state.bindListGui then state.bindListGui:Destroy(); state.bindListGui=nil; state.bindListFrame=nil end
    end
    if state.bindListToggleRef then state.bindListToggleRef.SetActive(state.bindListVisible) end
end

local function GetConfigList()
    local l={}
    for n in pairs(state.Configs) do table.insert(l,n) end
    for _,ch in pairs(state.ConfigFolder:GetChildren()) do
        if ch:IsA("StringValue") and not state.Configs[ch.Name] then table.insert(l,ch.Name) end
    end
    table.sort(l)
    return l
end

local function SaveConfig(name)
    if not name or name=="" then return false end
    local bindsData={}
    for k,b in pairs(state.binds) do bindsData[GetKeyName(k)]={target=b.target,mode=b.mode} end
    local data={
        Name=name,SpeedEnabled=state.isSpeedEnabled,SpeedValue=math.floor(state.speedValue),
        FlyEnabled=state.isFlyEnabled,FlyValue=state.flyValue,
        NoclipEnabled=state.isNoclipEnabled,FovEnabled=state.isFovEnabled,FovValue=math.floor(state.fovValue),
        DashEnabled=state.isDashEnabled, DashDistance=state.dashDistance, DashTime=state.dashTime, DashDirection=state.dashDirection,
        MoonwalkEnabled=state.isMoonwalkEnabled, MoonwalkAmp=state.moonwalkSwayAmplitude, MoonwalkInterval=state.moonwalkSwayInterval, MoonwalkSmooth=state.moonwalkSwaySmoothSpeed,
        AutoDaggerEnabled=state.isAutoDaggerEnabled, AutoDaggerRadius=state.autoDaggerRadius, AutoDaggerDelay=state.autoDaggerDelay, AutoDaggerCooldown=state.autoDaggerCooldown,
        AutoDaggerShowRadius=state.autoDaggerShowRadius,
        AutoDaggerColor={R=math.floor(state.autoDaggerColor.R*255),G=math.floor(state.autoDaggerColor.G*255),B=math.floor(state.autoDaggerColor.B*255)},
        EspEnabled=state.isEspEnabled,ShowKiller=state.espSettings.ShowKiller,ShowSurvivor=state.espSettings.ShowSurvivor,ShowSelf=state.espSettings.ShowSelf,
        KillerColor={R=math.floor(state.espSettings.KillerColor.R*255),G=math.floor(state.espSettings.KillerColor.G*255),B=math.floor(state.espSettings.KillerColor.B*255)},
        SurvivorColor={R=math.floor(state.espSettings.SurvivorColor.R*255),G=math.floor(state.espSettings.SurvivorColor.G*255),B=math.floor(state.espSettings.SurvivorColor.B*255)},
        SelfColor={R=math.floor(state.espSettings.SelfColor.R*255),G=math.floor(state.espSettings.SelfColor.G*255),B=math.floor(state.espSettings.SelfColor.B*255)},
        FillTransparency=state.espSettings.FillTransparency,OutlineTransparency=state.espSettings.OutlineTransparency,
        AutoSkillcheckEnabled=state.isAutoSkillcheckEnabled,SkillcheckQuality=state.skillcheckQuality,InstaHealEnabled=state.isInstaHealEnabled,
        GenHighlightEnabled=state.isGenHighlightEnabled,GenHighlightColor={R=math.floor(state.genSettings.HighlightColor.R*255),G=math.floor(state.genSettings.HighlightColor.G*255),B=math.floor(state.genSettings.HighlightColor.B*255)},
        GateHighlightEnabled=state.isGateHighlightEnabled,GateHighlightColor={R=math.floor(state.gateSettings.HighlightColor.R*255),G=math.floor(state.gateSettings.HighlightColor.G*255),B=math.floor(state.gateSettings.HighlightColor.B*255)},
        PalletHighlightEnabled=state.isPalletHighlightEnabled,PalletHighlightColor={R=math.floor(state.palletSettings.HighlightColor.R*255),G=math.floor(state.palletSettings.HighlightColor.G*255),B=math.floor(state.palletSettings.HighlightColor.B*255)},
        WindowHighlightEnabled=state.isWindowHighlightEnabled,WindowHighlightColor={R=math.floor(state.windowSettings.HighlightColor.R*255),G=math.floor(state.windowSettings.HighlightColor.G*255),B=math.floor(state.windowSettings.HighlightColor.B*255)},
        HookHighlightEnabled=state.isHookHighlightEnabled,HookHighlightColor={R=math.floor(state.hookSettings.HighlightColor.R*255),G=math.floor(state.hookSettings.HighlightColor.G*255),B=math.floor(state.hookSettings.HighlightColor.B*255)},
        Binds=bindsData,BindListEnabled=state.bindListVisible,Timestamp=os.time()
    }
    local json=safeJsonEncode(data)
    if not json then return false end
    state.Configs[name]=data; state.CurrentConfig=name
    local old=state.ConfigFolder:FindFirstChild(name)
    if old then old:Destroy() end
    local v=Instance.new("StringValue")
    v.Name=name; v.Value=json; v.Parent=state.ConfigFolder
    if UpdateConfigList then UpdateConfigList() end
    return true
end

local function LoadConfig(name)
    local cfg=state.Configs[name]
    if not cfg then
        local v=state.ConfigFolder:FindFirstChild(name)
        if v and v:IsA("StringValue") then
            cfg=safeJsonDecode(v.Value)
            if cfg then state.Configs[name]=cfg end
        end
    end
    if not cfg then return false end
    state.CurrentConfig=name
    state.isFlyEnabled=cfg.FlyEnabled or false
    state.flyValue=cfg.FlyValue or 60
    state.isDashEnabled=cfg.DashEnabled or false
    state.dashDistance=cfg.DashDistance or 25
    state.dashTime=cfg.DashTime or 0.50
    state.dashDirection=cfg.DashDirection or "Camera"
    state.isMoonwalkEnabled=cfg.MoonwalkEnabled or false
    state.moonwalkSwayAmplitude=cfg.MoonwalkAmp or 100
    state.moonwalkSwayInterval=cfg.MoonwalkInterval or 0.20
    state.moonwalkSwaySmoothSpeed=cfg.MoonwalkSmooth or 20
    state.isAutoDaggerEnabled=cfg.AutoDaggerEnabled or false
    state.autoDaggerRadius=cfg.AutoDaggerRadius or 12
    state.autoDaggerDelay=cfg.AutoDaggerDelay or 0.1
    state.autoDaggerCooldown=cfg.AutoDaggerCooldown or 91
    state.autoDaggerShowRadius=cfg.AutoDaggerShowRadius~=false
    if cfg.AutoDaggerColor then state.autoDaggerColor=Color3.fromRGB(cfg.AutoDaggerColor.R,cfg.AutoDaggerColor.G,cfg.AutoDaggerColor.B) end
    state.isSpeedEnabled=cfg.SpeedEnabled or false
    state.speedValue=cfg.SpeedValue or 50
    state.isNoclipEnabled=cfg.NoclipEnabled or false
    state.isFovEnabled=cfg.FovEnabled or false
    state.fovValue=cfg.FovValue or 70
    state.isTimeEnabled=cfg.TimeEnabled or false
    state.timeValue=cfg.TimeValue or 12
    state.isFullBrightEnabled=cfg.FullBrightEnabled or false
    state.isAspectEnabled=cfg.AspectEnabled or false
    state.aspectValue=cfg.AspectValue or 0.75
    state.isRemoveFogEnabled=cfg.RemoveFogEnabled or false
    state.isEspEnabled=cfg.EspEnabled or false
    state.espSettings.ShowKiller=cfg.ShowKiller~=false
    state.espSettings.ShowSurvivor=cfg.ShowSurvivor~=false
    state.espSettings.ShowSelf=cfg.ShowSelf~=false
    state.espSettings.FillTransparency=cfg.FillTransparency or 0.3
    state.espSettings.OutlineTransparency=cfg.OutlineTransparency or 0.2
    state.isAutoSkillcheckEnabled=cfg.AutoSkillcheckEnabled or false
    state.skillcheckQuality=cfg.SkillcheckQuality or "Great"
    state.isInstaHealEnabled=cfg.InstaHealEnabled or false
    state.isGenHighlightEnabled=cfg.GenHighlightEnabled or false
    state.isGateHighlightEnabled=cfg.GateHighlightEnabled or false
    state.isPalletHighlightEnabled=cfg.PalletHighlightEnabled or false
    state.isWindowHighlightEnabled=cfg.WindowHighlightEnabled or false
    state.isHookHighlightEnabled=cfg.HookHighlightEnabled or false
    if cfg.GenHighlightColor then state.genSettings.HighlightColor=Color3.fromRGB(cfg.GenHighlightColor.R,cfg.GenHighlightColor.G,cfg.GenHighlightColor.B) end
    if cfg.GateHighlightColor then state.gateSettings.HighlightColor=Color3.fromRGB(cfg.GateHighlightColor.R,cfg.GateHighlightColor.G,cfg.GateHighlightColor.B) end
    if cfg.PalletHighlightColor then state.palletSettings.HighlightColor=Color3.fromRGB(cfg.PalletHighlightColor.R,cfg.PalletHighlightColor.G,cfg.PalletHighlightColor.B) end
    if cfg.WindowHighlightColor then state.windowSettings.HighlightColor=Color3.fromRGB(cfg.WindowHighlightColor.R,cfg.WindowHighlightColor.G,cfg.WindowHighlightColor.B) end
    if cfg.HookHighlightColor then state.hookSettings.HighlightColor=Color3.fromRGB(cfg.HookHighlightColor.R,cfg.HookHighlightColor.G,cfg.HookHighlightColor.B) end
    if cfg.KillerColor then state.espSettings.KillerColor=Color3.fromRGB(cfg.KillerColor.R,cfg.KillerColor.G,cfg.KillerColor.B) end
    if cfg.SurvivorColor then state.espSettings.SurvivorColor=Color3.fromRGB(cfg.SurvivorColor.R,cfg.SurvivorColor.G,cfg.SurvivorColor.B) end
    if cfg.SelfColor then state.espSettings.SelfColor=Color3.fromRGB(cfg.SelfColor.R,cfg.SelfColor.G,cfg.SelfColor.B) end
    if cfg.Binds then
        for kn,bd in pairs(cfg.Binds) do
            local kc
            for ek,nm in pairs(KeyNames) do if nm==kn then kc=ek break end end
            if kc then
                if bd.target == "Dash" then
                    if state.dashBindKey and state.binds[state.dashBindKey] then
                        state.binds[state.dashBindKey] = nil
                    end
                    state.dashBindKey = kc
                    state.binds[kc] = {
                        target = "Dash",
                        mode = "action",
                        toggleCallback = function()
                            if state.isDashEnabled then PerformDash() end
                        end,
                        getState = function() return state.isDashEnabled end
                    }
                    if state.dashBindBtn then
                        state.dashBindBtn.Text = "Bind: " .. GetKeyName(kc)
                    end
                else
                    local ref=state.bindRefs[bd.target:lower():gsub("highlight","")]
                    if ref and ref.SetBind then ref.SetBind(kc,bd.mode) end
                end
            end
        end
    end
    if cfg.BindListEnabled~=nil then
        if cfg.BindListEnabled and not state.bindListVisible then ToggleBindList()
        elseif not cfg.BindListEnabled and state.bindListVisible then ToggleBindList() end
        if state.bindListToggleRef then state.bindListToggleRef.SetActive(cfg.BindListEnabled) end
    end
    local r=state.toggleRefs
    if r.speed then r.speed.SetActive(state.isSpeedEnabled) end
    if r.noclip then r.noclip.SetActive(state.isNoclipEnabled) end
    if r.fov then r.fov.SetActive(state.isFovEnabled) end
    if r.time then r.time.SetActive(state.isTimeEnabled) end
    if r.fullbright then r.fullbright.SetActive(state.isFullBrightEnabled) end
    if r.removefog then r.removefog.SetActive(state.isRemoveFogEnabled) end
    if r.esp then r.esp.SetActive(state.isEspEnabled) end
    if r.skillcheck then r.skillcheck.SetActive(state.isAutoSkillcheckEnabled) end
    if r.instaHeal then r.instaHeal.SetActive(state.isInstaHealEnabled) end
    if r.genhighlight then r.genhighlight.SetActive(state.isGenHighlightEnabled) end
    if r.gatehighlight then r.gatehighlight.SetActive(state.isGateHighlightEnabled) end
    if r.pallethighlight then r.pallethighlight.SetActive(state.isPalletHighlightEnabled) end
    if r.windowhighlight then r.windowhighlight.SetActive(state.isWindowHighlightEnabled) end
    if r.hookhighlight then r.hookhighlight.SetActive(state.isHookHighlightEnabled) end
    if r.aspect then r.aspect.SetActive(state.isAspectEnabled) end
    if r.dash then r.dash.SetActive(state.isDashEnabled) end
    if r.moonwalk then r.moonwalk.SetActive(state.isMoonwalkEnabled) end
    if r.autodagger then r.autodagger.SetActive(state.isAutoDaggerEnabled) end
    if state.genToggleRef then state.genToggleRef(state.isGenHighlightEnabled) end
    if state.gateToggleRef then state.gateToggleRef(state.isGateHighlightEnabled) end
    if state.palletToggleRef then state.palletToggleRef(state.isPalletHighlightEnabled) end
    if state.windowToggleRef then state.windowToggleRef(state.isWindowHighlightEnabled) end
    if state.hookToggleRef then state.hookToggleRef(state.isHookHighlightEnabled) end
    if state.sliderFill and state.sliderKnob and state.speedNumLabel then
        local p=(state.speedValue-20)/80
        state.sliderFill.Size=UDim2.new(p,0,1,0); state.sliderKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.speedNumLabel.Text=tostring(math.floor(state.speedValue))
    end
    if state.fovSliderFill and state.fovSliderKnob and state.fovNumLabel then
        local p=(state.fovValue-40)/80
        state.fovSliderFill.Size=UDim2.new(p,0,1,0); state.fovSliderKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.fovNumLabel.Text=tostring(math.floor(state.fovValue))
    end
    if state.timeSliderFill and state.timeSliderKnob and state.timeNumLabel then
        local p=state.timeValue/24
        state.timeSliderFill.Size=UDim2.new(p,0,1,0); state.timeSliderKnob.Position=UDim2.new(p,-7,0.5,-7)
        local h=math.floor(state.timeValue); local m=math.floor((state.timeValue-h)*60)
        state.timeNumLabel.Text=string.format("%02d:%02d",h,m)
    end
    if state.aspectSliderFill and state.aspectSliderKnob and state.aspectNumLabel then
        local p=(state.aspectValue-0.3)/1.0
        state.aspectSliderFill.Size=UDim2.new(p,0,1,0); state.aspectSliderKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.aspectNumLabel.Text=string.format("%.2f",state.aspectValue)
    end
    if state.dashDistanceLabel and state.dashDistFill and state.dashDistKnob then
        local p=(state.dashDistance-5)/95
        state.dashDistFill.Size=UDim2.new(p,0,1,0)
        state.dashDistKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.dashDistanceLabel.Text=tostring(math.floor(state.dashDistance))
    end
    if state.dashTimeLabel and state.dashTimeFill and state.dashTimeKnob then
        local p=(state.dashTime-0.10)/1.90
        state.dashTimeFill.Size=UDim2.new(p,0,1,0)
        state.dashTimeKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.dashTimeLabel.Text=string.format("%.2f",state.dashTime)
    end
    if state.dashDirectionBtn then
        state.dashDirectionBtn.Text=state.dashDirection
    end
    if state.autoDaggerRadiusFill and state.autoDaggerRadiusKnob and state.autoDaggerRadiusLabel then
        local p=(state.autoDaggerRadius-5)/25
        state.autoDaggerRadiusFill.Size=UDim2.new(p,0,1,0)
        state.autoDaggerRadiusKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.autoDaggerRadiusLabel.Text=tostring(math.floor(state.autoDaggerRadius))
        state.autoDaggerCircleRadius=0
    end
    if state.autoDaggerDelayFill and state.autoDaggerDelayKnob and state.autoDaggerDelayLabel then
        local p=state.autoDaggerDelay/0.5
        state.autoDaggerDelayFill.Size=UDim2.new(p,0,1,0)
        state.autoDaggerDelayKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.autoDaggerDelayLabel.Text=string.format("%.2f",state.autoDaggerDelay)
    end
    if state.autoDaggerCooldownFill and state.autoDaggerCooldownKnob and state.autoDaggerCooldownLabel then
        local p=(state.autoDaggerCooldown-30)/90
        state.autoDaggerCooldownFill.Size=UDim2.new(p,0,1,0)
        state.autoDaggerCooldownKnob.Position=UDim2.new(p,-7,0.5,-7)
        state.autoDaggerCooldownLabel.Text=tostring(math.floor(state.autoDaggerCooldown))
    end
    ApplySpeed()
    if state.isNoclipEnabled then EnableNoclip() else DisableNoclip() end
    ApplyFov()
    if state.isTimeEnabled then EnableTime() else DisableTime() end
    if state.isFullBrightEnabled then EnableFullBright() else DisableFullBright() end
    if state.isAspectEnabled then EnableAspect() else DisableAspect() end
    if state.isRemoveFogEnabled then EnableRemoveFog() else DisableRemoveFog() end
    if state.isEspEnabled then EnableEsp() else DisableEsp() end
    if state.isAutoSkillcheckEnabled then EnableAutoSkillcheck() else DisableAutoSkillcheck() end
    if state.isInstaHealEnabled then EnableInstaHeal() else DisableInstaHeal() end
    if state.isGenHighlightEnabled then EnableGenHighlight() else DisableGenHighlight() end
    if state.isGateHighlightEnabled then EnableGateHighlight() else DisableGateHighlight() end
    if state.isPalletHighlightEnabled then EnablePalletHighlight() else DisablePalletHighlight() end
    if state.isWindowHighlightEnabled then EnableWindowHighlight() else DisableWindowHighlight() end
    if state.isHookHighlightEnabled then EnableHookHighlight() else DisableHookHighlight() end
    if state.isMoonwalkEnabled then EnableMoonwalk() else DisableMoonwalk() end
    if state.isAutoDaggerEnabled then EnableAutoDagger() else DisableAutoDagger() end
    if UpdateConfigList then UpdateConfigList() end
    return true
end

local function ApplySpeed()
    local ch=player.Character
    if ch and ch:FindFirstChild("Humanoid") then
        ch.Humanoid.WalkSpeed=state.isSpeedEnabled and state.speedValue or 16
    end
end

local function ApplyFov()
    local cam=workspace.CurrentCamera
    if cam then cam.FieldOfView=state.isFovEnabled and state.fovValue or state.originalFov end
end

local function ApplyTime()
    if state.isTimeEnabled then Lighting.ClockTime=state.timeValue
    else Lighting.ClockTime=state.originalTime end
end

local function EnableTime()
    if state.timeConnection then return end
    state.isTimeEnabled=true; ApplyTime()
    state.timeConnection=RunService.RenderStepped:Connect(function()
        if state.isTimeEnabled then Lighting.ClockTime=state.timeValue end
    end)
end

local function DisableTime()
    if state.timeConnection then state.timeConnection:Disconnect(); state.timeConnection=nil end
    state.isTimeEnabled=false; ApplyTime()
end

local function ApplyFullBright()
    if state.isFullBrightEnabled then
        Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.GlobalShadows=false
    else
        Lighting.Brightness=state.originalBrightness; Lighting.Ambient=state.originalAmbient
        Lighting.OutdoorAmbient=state.originalAmbient; Lighting.GlobalShadows=true
    end
end

local function EnableFullBright()
    if state.fullBrightConnection then return end
    state.isFullBrightEnabled=true; ApplyFullBright()
    state.fullBrightConnection=RunService.RenderStepped:Connect(function()
        if state.isFullBrightEnabled then
            Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.GlobalShadows=false
        end
    end)
end

local function DisableFullBright()
    if state.fullBrightConnection then state.fullBrightConnection:Disconnect(); state.fullBrightConnection=nil end
    state.isFullBrightEnabled=false; ApplyFullBright()
end

local function ApplyRemoveFog()
    local atm=Lighting:FindFirstChildOfClass("Atmosphere")
    if state.isRemoveFogEnabled then
        Lighting.FogEnd=100000; Lighting.FogStart=0
        if atm then atm.Density=0; atm.Haze=0 end
    else
        Lighting.FogEnd=state.originalFogEnd; Lighting.FogStart=state.originalFogStart
        if atm and state.originalAtmDensity~=nil then atm.Density=state.originalAtmDensity; atm.Haze=state.originalAtmHaze end
    end
end

local function EnableRemoveFog()
    if state.removeFogConnection then return end
    state.isRemoveFogEnabled=true; ApplyRemoveFog()
    state.removeFogConnection=RunService.RenderStepped:Connect(function()
        if state.isRemoveFogEnabled then
            Lighting.FogEnd=100000; Lighting.FogStart=0
            local atm=Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density=0; atm.Haze=0 end
        end
    end)
end

local function DisableRemoveFog()
    if state.removeFogConnection then state.removeFogConnection:Disconnect(); state.removeFogConnection=nil end
    state.isRemoveFogEnabled=false; ApplyRemoveFog()
end

local function ApplyAspect()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if state.isAspectEnabled then
        local k = state.aspectValue
        if k < 0.3 then k = 0.3 end
        if k > 1.30 then k = 1.30 end
        local stretchMatrix = CFrame.new(0,0,0, 1,0,0, 0,k,0, 0,0,1)
        cam.CFrame = cam.CFrame * stretchMatrix
    end
end

local function EnableAspect()
    if state.aspectConnection then return end
    state.isAspectEnabled = true
    state.aspectConnection = RunService.RenderStepped:Connect(function()
        if not state.isAspectEnabled then return end
        local c = workspace.CurrentCamera
        if not c then return end
        local k = state.aspectValue
        if k < 0.3 then k = 0.3 end
        if k > 1.30 then k = 1.30 end
        c.CFrame = c.CFrame * CFrame.new(0,0,0, 1,0,0, 0,k,0, 0,0,1)
    end)
end

local function DisableAspect()
    if state.aspectConnection then
        state.aspectConnection:Disconnect()
        state.aspectConnection = nil
    end
    state.isAspectEnabled = false
end

local function DisableFly()
    if state.flyBodyVelocity then
        pcall(function() state.flyBodyVelocity:Destroy() end)
        state.flyBodyVelocity = nil
    end
    if state.flyBodyGyro then
        pcall(function() state.flyBodyGyro:Destroy() end)
        state.flyBodyGyro = nil
    end
    if state.flyConnection then
        state.flyConnection:Disconnect()
        state.flyConnection = nil
    end
    state.isFlyEnabled = false
end

local function EnableFly()
    DisableFly()
    state.isFlyEnabled = true

    local function setup()
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        bv.P = 1250
        bv.Parent = hrp
        state.flyBodyVelocity = bv

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 3000
        bg.D = 50
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        state.flyBodyGyro = bg
    end

    setup()

    local charConn = player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if state.isFlyEnabled then setup() end
    end)

    local camConn = RunService.RenderStepped:Connect(function()
        if not state.isFlyEnabled then return end
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local lookDir = cam.CFrame.LookVector
        local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
        if flatLook.Magnitude > 0.001 then
            local newCF = CFrame.lookAt(hrp.Position, hrp.Position + flatLook.Unit)
            hrp.CFrame = CFrame.new(hrp.Position) * (newCF - newCF.Position)
        end
    end)

    state.flyConnection = RunService.RenderStepped:Connect(function()
        if not state.isFlyEnabled then return end
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not state.flyBodyVelocity or not state.flyBodyGyro then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local speed = state.flyValue or 60
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        local dir = Vector3.new(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - look end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then dir = dir.Unit end
        state.flyBodyVelocity.Velocity = dir * speed
    end)

    local oldConn = state.flyConnection
    state.flyConnection = {
        Disconnect = function()
            oldConn:Disconnect()
            charConn:Disconnect()
            camConn:Disconnect()
        end
    }
end

local function PerformDash()
    if not state.isDashEnabled then return end
    if state.dashCooldown then return end
    local ch = player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = ch:FindFirstChild("Humanoid")
    if not humanoid then return end

    local dir
    if state.dashDirection == "Movement" then
        local md = humanoid.MoveDirection
        if md.Magnitude < 0.01 then
            dir = hrp.CFrame.LookVector
        else
            dir = md.Unit
        end
    else
        local cam = workspace.CurrentCamera
        if cam then
            dir = cam.CFrame.LookVector
        else
            dir = hrp.CFrame.LookVector
        end
    end
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 0.01 then dir = hrp.CFrame.LookVector end
    dir = dir.Unit

    local distance = state.dashDistance or 25
    local duration = state.dashTime or 0.50
    local speed = distance / duration

    if state.dashBodyVelocity then
        pcall(function() state.dashBodyVelocity:Destroy() end)
        state.dashBodyVelocity = nil
    end
    if state.dashConnection then
        state.dashConnection:Disconnect()
        state.dashConnection = nil
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = dir * speed
    bv.P = 1250
    bv.Parent = hrp
    state.dashBodyVelocity = bv

    state.dashCooldown = true

    local startTime = tick()
    state.dashConnection = RunService.Heartbeat:Connect(function()
        if not bv or not bv.Parent then
            if state.dashConnection then state.dashConnection:Disconnect(); state.dashConnection = nil end
            state.dashBodyVelocity = nil
            state.dashCooldown = false
            return
        end
        if tick() - startTime >= duration then
            bv:Destroy()
            state.dashBodyVelocity = nil
            if state.dashConnection then state.dashConnection:Disconnect(); state.dashConnection = nil end
            state.dashCooldown = false
        end
    end)
end

local function DisableDash()
    if state.dashConnection then
        state.dashConnection:Disconnect()
        state.dashConnection = nil
    end
    if state.dashBodyVelocity then
        pcall(function() state.dashBodyVelocity:Destroy() end)
        state.dashBodyVelocity = nil
    end
    state.dashCooldown = false
end

local function EnableMoonwalk()
    if state.moonwalkConnection then return end
    state.isMoonwalkEnabled = true
    state.moonwalkPhase = 0

    local function setup()
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local humanoid = ch:FindFirstChild("Humanoid")
        if not humanoid then return end

        humanoid.AutoRotate = false

        if state.moonwalkAlignOrient then
            pcall(function() state.moonwalkAlignOrient:Destroy() end)
            state.moonwalkAlignOrient = nil
        end

        local ao = Instance.new("AlignOrientation")
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = hrp:FindFirstChild("RootAttachment") or (function()
            local a = Instance.new("Attachment")
            a.Name = "RootAttachment"
            a.Parent = hrp
            return a
        end)()
        ao.MaxTorque = 1000000
        ao.Responsiveness = 100
        ao.PrimaryAxisOnly = false
        ao.Parent = hrp
        state.moonwalkAlignOrient = ao
    end

    setup()

    local charConn = player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if state.isMoonwalkEnabled then setup() end
    end)

    state.moonwalkConnection = RunService.RenderStepped:Connect(function(dt)
        if not state.isMoonwalkEnabled then return end
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local humanoid = ch:FindFirstChild("Humanoid")
        if not humanoid then return end
        if not state.moonwalkAlignOrient then return end

        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude < 0.01 then return end

        local lookDir = -moveDir
        local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
        if flatLook.Magnitude < 0.001 then return end
        flatLook = flatLook.Unit

        local speed = state.moonwalkSwaySmoothSpeed or 20
        state.moonwalkPhase = state.moonwalkPhase + dt * speed
        local interval = state.moonwalkSwayInterval or 0.20
        local amp = (state.moonwalkSwayAmplitude or 100) / 100 * 30

        local sin = math.sin(state.moonwalkPhase / math.max(interval, 0.01))
        local swayDeg = sin * amp

        local swayRad = math.rad(swayDeg)
        local cosS = math.cos(swayRad)
        local sinS = math.sin(swayRad)
        local swayedX = flatLook.X * cosS - flatLook.Z * sinS
        local swayedZ = flatLook.X * sinS + flatLook.Z * cosS
        local finalLook = Vector3.new(swayedX, 0, swayedZ).Unit

        local targetCF = CFrame.lookAt(hrp.Position, hrp.Position + finalLook)
        state.moonwalkAlignOrient.CFrame = targetCF
    end)

    local oldConn = state.moonwalkConnection
    state.moonwalkConnection = {
        Disconnect = function()
            oldConn:Disconnect()
            charConn:Disconnect()
        end
    }
end

local function DisableMoonwalk()
    if state.moonwalkConnection then
        state.moonwalkConnection:Disconnect()
        state.moonwalkConnection = nil
    end
    state.isMoonwalkEnabled = false

    local ch = player.Character
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp and state.moonwalkAlignOrient then
            pcall(function() state.moonwalkAlignOrient:Destroy() end)
            state.moonwalkAlignOrient = nil
        end
        local humanoid = ch:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

local DAGGER_SEG_LENGTH = 1.0
local DAGGER_SEG_GAP = 0
local DAGGER_SEG_THICK = 0.3

local function GetKillerChar()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and p.Team and p.Team.Name:lower():find("killer") then
                return p.Character
            end
        end
    end
    return nil
end

local function DestroyDaggerCircle()
    for _, p in ipairs(state.autoDaggerCircleParts) do
        pcall(function() p:Destroy() end)
    end
    state.autoDaggerCircleParts = {}
    state.autoDaggerCircleRadius = 0
    state.autoDaggerCircleColor = nil
end

local function BuildDaggerCircle(radius)
    for _, p in ipairs(state.autoDaggerCircleParts) do
        pcall(function() p:Destroy() end)
    end
    state.autoDaggerCircleParts = {}

    local color = state.autoDaggerColor
    local circumference = 2 * math.pi * radius
    local denom = math.max(DAGGER_SEG_LENGTH + DAGGER_SEG_GAP, 0.01)
    local segCount = math.max(8, math.floor(circumference / denom))
    if segCount % 2 ~= 0 then segCount = segCount + 1 end

    local arcPerSeg = (2 * math.pi) / segCount
    local segArc = arcPerSeg * (DAGGER_SEG_LENGTH / denom)

    for i = 1, segCount do
        if i % 2 == 0 then
            local seg = Instance.new("Part")
            seg.Anchored = true
            seg.CanCollide = false
            seg.CanQuery = false
            seg.CanTouch = false
            seg.CastShadow = false
            seg.Material = Enum.Material.Neon
            seg.Color = color
            seg.Transparency = 0.05
            seg.TopSurface = Enum.SurfaceType.Smooth
            seg.BottomSurface = Enum.SurfaceType.Smooth
            seg.Size = Vector3.new(DAGGER_SEG_THICK, 0.15, radius * segArc)
            seg.Parent = workspace
            table.insert(state.autoDaggerCircleParts, seg)
        end
    end

    state.autoDaggerCircleRadius = radius
    state.autoDaggerCircleColor = color
end

local function UpdateDaggerCircle()
    if not state.autoDaggerShowRadius then
        if #state.autoDaggerCircleParts > 0 then
            DestroyDaggerCircle()
        end
        return
    end

    local ch = player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local radius = state.autoDaggerRadius

    if state.autoDaggerCircleRadius ~= radius
        or state.autoDaggerCircleColor ~= state.autoDaggerColor then
        BuildDaggerCircle(radius)
    end

    if #state.autoDaggerCircleParts == 0 then
        BuildDaggerCircle(radius)
    end

    local center = Vector3.new(hrp.Position.X, hrp.Position.Y - 2.8, hrp.Position.Z)
    local segCount = #state.autoDaggerCircleParts
    local totalSlots = segCount * 2

    for idx, seg in ipairs(state.autoDaggerCircleParts) do
        if seg and seg.Parent then
            local slotIndex = idx * 2
            local angle = (slotIndex / totalSlots) * math.pi * 2
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            seg.CFrame = CFrame.new(center + Vector3.new(x, 0, z)) * CFrame.Angles(0, -angle, 0)
            seg.Color = state.autoDaggerColor
        end
    end
end

local function EnableAutoDagger()
    if state.autoDaggerConnection then return end
    state.isAutoDaggerEnabled = true

    if state.autoDaggerParryResultRemote then
        state.autoDaggerParryResultRemote.OnClientEvent:Connect(function(success, cd)
            if typeof(success) == "boolean" and typeof(cd) == "number" then
                state.autoDaggerLastFire = tick()
            end
        end)
    end

    state.autoDaggerConnection = RunService.RenderStepped:Connect(function()
        if not state.isAutoDaggerEnabled then return end

        UpdateDaggerCircle()

        if not state.autoDaggerParryRemote then return end
        if tick() - state.autoDaggerLastFire < state.autoDaggerCooldown then return end

        local killer = GetKillerChar()
        if not killer then return end

        local chasing = killer:GetAttribute("IsChasing") == true
        local chaseMe = killer:GetAttribute("ChaseTargetUserID") == player.UserId
        local stunned = killer:GetAttribute("IsStunned") == true
        if not (chasing and chaseMe and not stunned) then return end

        local me = player.Character
        if not me then return end
        local myHrp = me:FindFirstChild("HumanoidRootPart")
        local kHrp = killer:FindFirstChild("HumanoidRootPart")
        if not myHrp or not kHrp then return end

        local dist = (myHrp.Position - kHrp.Position).Magnitude
        if dist <= state.autoDaggerRadius then
            if state.autoDaggerDelay > 0 then
                task.wait(state.autoDaggerDelay)
            end
            state.autoDaggerParryRemote:FireServer()
            state.autoDaggerLastFire = tick()
        end
    end)
end

local function DisableAutoDagger()
    if state.autoDaggerConnection then
        state.autoDaggerConnection:Disconnect()
        state.autoDaggerConnection = nil
    end
    state.isAutoDaggerEnabled = false
    DestroyDaggerCircle()
end

local function EnableNoclip()
    if state.noclipConnection then return end
    state.isNoclipEnabled = true
    state.noclipConnection = RunService.Stepped:Connect(function()
        local ch = player.Character
        if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    if state.noclipConnection then state.noclipConnection:Disconnect(); state.noclipConnection=nil end
    local ch=player.Character
    if ch then
        for _,p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end
    state.isNoclipEnabled=false
end

local skillcheckActive,skillcheckStart,targetRotation,alreadyPressed=false,0,0,false

local function findSkillcheckGUI() return playerGui:FindFirstChild("SkillCheckPromptGui") end
local function findArrow(gui)
    if not gui then return nil end
    local c=gui:FindFirstChild("Check")
    if c then
        for _,ch in pairs(c:GetChildren()) do
            if ch:IsA("ImageLabel") and ch.Name=="Line" and ch.Visible then return ch end
        end
    end
    return nil
end
local function findGoal(gui)
    if not gui then return nil end
    local c=gui:FindFirstChild("Check")
    if c then
        for _,ch in pairs(c:GetChildren()) do
            if ch:IsA("ImageLabel") and ch.Name=="Goal" and ch.Visible then return ch end
        end
    end
    return nil
end

local function autoSkillcheck()
    if not state.isAutoSkillcheckEnabled or state.skillcheckCooldown then return end
    local gui=findSkillcheckGUI()
    if not gui or not gui.Enabled then skillcheckActive=false; alreadyPressed=false; return end
    local arrow=findArrow(gui); local goal=findGoal(gui)
    if not arrow or not goal then skillcheckActive=false; alreadyPressed=false; return end
    local aR=arrow.Rotation or 0
    local gR=goal.Rotation or 0
    if not skillcheckActive then
        skillcheckActive=true; skillcheckStart=tick(); alreadyPressed=false
        targetRotation=(state.skillcheckQuality=="Great") and gR or ((gR+45)%360)
        return
    end
    if alreadyPressed then return end
    if tick()-skillcheckStart<0.5 then return end
    local d=math.abs(aR-targetRotation)
    if d>180 then d=360-d end
    if d<3 then
        alreadyPressed=true; state.skillcheckCooldown=true; skillcheckActive=false
        pcall(function()
            local vim=game:GetService("VirtualInputManager")
            if vim then
                vim:SendKeyEvent(true,Enum.KeyCode.Space,false,game)
                task.wait(0.05)
                vim:SendKeyEvent(false,Enum.KeyCode.Space,false,game)
            end
        end)
        task.wait(0.3); state.skillcheckCooldown=false
    end
end

function EnableAutoSkillcheck()
    if state.skillcheckConnection then return end
    state.isAutoSkillcheckEnabled=true; skillcheckActive=false; alreadyPressed=false; skillcheckStart=0
    if SkillCheckEvent then
        state.skillcheckCheckConnection=SkillCheckEvent.OnClientEvent:Connect(function()
            local gui=findSkillcheckGUI()
            if gui and gui.Enabled then
                skillcheckActive=false; alreadyPressed=false; skillcheckStart=tick(); state.skillcheckCooldown=false
            end
        end)
    end
    state.skillcheckConnection=RunService.RenderStepped:Connect(autoSkillcheck)
end

function DisableAutoSkillcheck()
    if state.skillcheckConnection then state.skillcheckConnection:Disconnect(); state.skillcheckConnection=nil end
    if state.skillcheckCheckConnection then state.skillcheckCheckConnection:Disconnect(); state.skillcheckCheckConnection=nil end
    state.isAutoSkillcheckEnabled=false; state.skillcheckCooldown=false; skillcheckActive=false; alreadyPressed=false
end

local function HealPlayer()
    if not state.isInstaHealEnabled then return end
    if HealEvent then pcall(function() HealEvent:FireServer() end) end
    pcall(function()
        local ch=player.Character
        if ch then
            local h=ch:FindFirstChild("Humanoid")
            if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
        end
    end)
end

function EnableInstaHeal()
    if state.instaHealConnection then return end
    state.isInstaHealEnabled=true
    local function check()
        local ch=player.Character
        if not ch then return end
        local h=ch:FindFirstChild("Humanoid")
        if not h then return end
        local c,m=h.Health,h.MaxHealth
        if c<m and c<state.currentHealth then HealPlayer() end
        state.currentHealth=c; state.maxHealth=m
    end
    state.instaHealConnection=RunService.Heartbeat:Connect(check)
    state.instaHealCharacterConnection=player.CharacterAdded:Connect(function(ch)
        ch:WaitForChild("Humanoid")
        state.currentHealth=ch.Humanoid.Health; state.maxHealth=ch.Humanoid.MaxHealth
    end)
end

function DisableInstaHeal()
    if state.instaHealConnection then state.instaHealConnection:Disconnect(); state.instaHealConnection=nil end
    if state.instaHealCharacterConnection then state.instaHealCharacterConnection:Disconnect(); state.instaHealCharacterConnection=nil end
    state.isInstaHealEnabled=false
end

local function FireHealEvent(t,v)
    if not HealEvent then return end
    pcall(function() HealEvent:FireServer(t,v) end)
end

local function RecoveryHealAttempt()
    if not state.isRecoveryHealEnabled then return false end
    local ch=player.Character
    if not ch then return false end
    local h=ch:FindFirstChild("Humanoid")
    if not h or h.Health<=0 then return false end
    if h.Health>=h.MaxHealth then return true end
    local target=ch:FindFirstChild("HumanoidRootPart") or ch
    FireHealEvent(target,true); task.wait(0.1)
    for i=1,5 do
        if not state.isRecoveryHealEnabled then return false end
        local hh=ch:FindFirstChild("Humanoid")
        if not hh or hh.Health<=0 then return false end
        if hh.Health>=hh.MaxHealth then return true end
        FireHealEvent(target,true); task.wait(0.1)
    end
    return false
end

function EnableRecoveryHeal()
    if state.recoveryHealConnection then return end
    state.isRecoveryHealEnabled=true
    task.spawn(function()
        local last=0
        while state.isRecoveryHealEnabled do
            local ch=player.Character
            if ch then
                local h=ch:FindFirstChild("Humanoid")
                if h and h.Health>0 then
                    state.currentHealth=h.Health; state.maxHealth=h.MaxHealth
                    if h.Health<h.MaxHealth and h.MoveDirection.Magnitude<0.1 then
                        if tick()-last>0.3 then
                            last=tick(); RecoveryHealAttempt()
                            if StopHealing then pcall(function() StopHealing:FireServer() end) end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
    state.recoveryHealCharacterConnection=player.CharacterAdded:Connect(function(ch)
        ch:WaitForChild("Humanoid")
        state.currentHealth=ch.Humanoid.Health; state.maxHealth=ch.Humanoid.MaxHealth
    end)
end

function DisableRecoveryHeal()
    if state.recoveryHealConnection then state.recoveryHealConnection:Disconnect(); state.recoveryHealConnection=nil end
    if state.recoveryHealCharacterConnection then state.recoveryHealCharacterConnection:Disconnect(); state.recoveryHealCharacterConnection=nil end
    state.isRecoveryHealEnabled=false
end

local GEN_PATHS={{"Gens"},{"Generators"}}
local function getGeneratorParts()
    local parts={}
    local map=workspace:FindFirstChild("Map")
    if not map then return parts end
    local function resolvePath(p)
        local c=map
        for _,n in ipairs(p) do if not c then return nil end c=c:FindFirstChild(n) end
        return c
    end
    local function scan(f)
        for _,ch in pairs(f:GetChildren()) do
            if ch:IsA("BasePart") then
                local p=ch.Parent
                if p and p.Name:lower():find("generator") then table.insert(parts,ch) end
            elseif ch:IsA("Model") or ch:IsA("Folder") then scan(ch) end
        end
    end
    for _,p in ipairs(GEN_PATHS) do
        local f=resolvePath(p)
        if f then scan(f) end
    end
    return parts
end

local function clearGenHighlights()
    for _,h in pairs(state.genHighlights) do pcall(function() h:Destroy() end) end
    state.genHighlights={}
end

local function updateGenHighlight()
    if not state.isGenHighlightEnabled or not state.isEspEnabled then clearGenHighlights(); return end
    for _,part in ipairs(getGeneratorParts()) do
        local ex=state.genHighlights[part]
        if ex then
            if ex.FillColor~=state.genSettings.HighlightColor then
                ex.FillColor=state.genSettings.HighlightColor; ex.OutlineColor=state.genSettings.HighlightColor
            end
        else
            local h=Instance.new("Highlight")
            h.Parent=part; h.FillColor=state.genSettings.HighlightColor; h.FillTransparency=0.4
            h.OutlineColor=state.genSettings.HighlightColor; h.OutlineTransparency=0.2
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Enabled=true
            state.genHighlights[part]=h
        end
    end
end

local function EnableGenHighlight()
    if state.genHighlightConnection then return end
    state.isGenHighlightEnabled=true
    if state.genToggleRef then state.genToggleRef(true) end
    if state.isEspEnabled then updateGenHighlight() end
    state.genHighlightConnection=RunService.RenderStepped:Connect(updateGenHighlight)
end

local function DisableGenHighlight()
    if state.genHighlightConnection then state.genHighlightConnection:Disconnect(); state.genHighlightConnection=nil end
    state.isGenHighlightEnabled=false
    if state.genToggleRef then state.genToggleRef(false) end
    clearGenHighlights()
end

local GATE_PATHS={{}} 
local function getGateTargets()
    local t={}
    local map=workspace:FindFirstChild("Map")
    if not map then return t end
    local function add(obj)
        if not obj then return end
        if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(t,obj) end
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("Model") or d:IsA("BasePart") then table.insert(t,d) end
        end
    end
    local function resolve(p)
        local c=map
        for _,n in ipairs(p) do if not c then return nil end c=c:FindFirstChild(n) end
        return c
    end
    for _,p in ipairs(GATE_PATHS) do
        local f=resolve(p)
        if f then
            for _,ch in ipairs(f:GetChildren()) do
                if ch.Name:lower():find("gate") then
                    local l=ch:FindFirstChild("ExitLever",true)
                    if l then add(l) end
                end
            end
        end
    end
    return t
end

local function clearGateHighlights()
    for o,h in pairs(state.gateHighlights) do pcall(function() h:Destroy() end) end
    state.gateHighlights={}
end

local function updateGateHighlight()
    if not state.isGateHighlightEnabled or not state.isEspEnabled then clearGateHighlights(); return end
    local t=getGateTargets(); local seen={}
    for _,o in ipairs(t) do
        seen[o]=true
        local ex=state.gateHighlights[o]
        if ex and ex.Parent==o then
            if ex.FillColor~=state.gateSettings.HighlightColor then
                ex.FillColor=state.gateSettings.HighlightColor; ex.OutlineColor=state.gateSettings.HighlightColor
            end
        else
            if ex then pcall(function() ex:Destroy() end) end
            local h=Instance.new("Highlight")
            h.Parent=o; h.FillColor=state.gateSettings.HighlightColor; h.FillTransparency=0.4
            h.OutlineColor=state.gateSettings.HighlightColor; h.OutlineTransparency=0.2
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Enabled=true
            state.gateHighlights[o]=h
        end
    end
    for o,h in pairs(state.gateHighlights) do
        if not seen[o] or not o.Parent then pcall(function() h:Destroy() end); state.gateHighlights[o]=nil end
    end
end

local function EnableGateHighlight()
    if state.gateHighlightConnection then return end
    state.isGateHighlightEnabled=true
    if state.gateToggleRef then state.gateToggleRef(true) end
    if state.isEspEnabled then updateGateHighlight() end
    state.gateHighlightConnection=RunService.RenderStepped:Connect(updateGateHighlight)
end

local function DisableGateHighlight()
    if state.gateHighlightConnection then state.gateHighlightConnection:Disconnect(); state.gateHighlightConnection=nil end
    state.isGateHighlightEnabled=false
    if state.gateToggleRef then state.gateToggleRef(false) end
    clearGateHighlights()
end

local PALLET_PATHS={{},{"Pallets"},{"Nature"}}
local palletCache={}
local palletCacheTime=0
local PALLET_CACHE_INTERVAL=0.5

local function rescanPallets()
    local found={}
    local map=workspace:FindFirstChild("Map")
    if not map then return found end
    local function resolve(p)
        local c=map
        for _,n in ipairs(p) do if not c then return nil end c=c:FindFirstChild(n) end
        return c
    end
    for _,p in ipairs(PALLET_PATHS) do
        local f=resolve(p)
        if f then
            for _,d in ipairs(f:GetDescendants()) do
                if d.Name:lower()=="palletwrong" and (d:IsA("Model") or d:IsA("BasePart")) then found[d]=true end
            end
        end
    end
    return found
end

local function clearPalletHighlights()
    for o,h in pairs(state.palletHighlights) do pcall(function() h:Destroy() end) end
    state.palletHighlights={}; palletCache={}; palletCacheTime=0
end

local function updatePalletHighlight()
    if not state.isPalletHighlightEnabled or not state.isEspEnabled then
        if next(state.palletHighlights) then clearPalletHighlights() end
        return
    end
    local now=tick()
    if now-palletCacheTime>PALLET_CACHE_INTERVAL then palletCacheTime=now; palletCache=rescanPallets() end
    local seen={}
    for o in pairs(palletCache) do
        if o and o.Parent then
            seen[o]=true
            local ex=state.palletHighlights[o]
            local valid=ex and ex.Parent==o
            if valid then
                if ex.FillColor~=state.palletSettings.HighlightColor then
                    ex.FillColor=state.palletSettings.HighlightColor; ex.OutlineColor=state.palletSettings.HighlightColor
                end
            else
                if ex then pcall(function() ex:Destroy() end) end
                local h=Instance.new("Highlight")
                h.Parent=o; h.FillColor=state.palletSettings.HighlightColor; h.FillTransparency=0.4
                h.OutlineColor=state.palletSettings.HighlightColor; h.OutlineTransparency=0.2
                h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Enabled=true
                state.palletHighlights[o]=h
            end
        end
    end
    for o,h in pairs(state.palletHighlights) do
        if not seen[o] or not o or not o.Parent then pcall(function() h:Destroy() end); state.palletHighlights[o]=nil end
    end
end

local function EnablePalletHighlight()
    if state.palletHighlightConnection then return end
    state.isPalletHighlightEnabled=true
    if state.palletToggleRef then state.palletToggleRef(true) end
    palletCacheTime=0
    if state.isEspEnabled then updatePalletHighlight() end
    state.palletHighlightConnection=RunService.RenderStepped:Connect(updatePalletHighlight)
end

local function DisablePalletHighlight()
    if state.palletHighlightConnection then state.palletHighlightConnection:Disconnect(); state.palletHighlightConnection=nil end
    state.isPalletHighlightEnabled=false
    if state.palletToggleRef then state.palletToggleRef(false) end
    clearPalletHighlights()
end

local WINDOW_PATHS={{},{"Rooftop"}}
local windowCache={}
local windowCacheTime=0
local WINDOW_CACHE_INTERVAL=0.5

local function rescanWindows()
    local found={}
    local map=workspace:FindFirstChild("Map")
    if not map then return found end
    local function resolve(p)
        local c=map
        for _,n in ipairs(p) do if not c then return nil end c=c:FindFirstChild(n) end
        return c
    end
    for _,p in ipairs(WINDOW_PATHS) do
        local f=resolve(p)
        if f then
            for _,d in ipairs(f:GetDescendants()) do
                if d.Name=="Window" then found[d]=true end
            end
        end
    end
    return found
end

local function clearWindowHighlights()
    for o,l in pairs(state.windowHighlights) do
        for _,a in ipairs(l) do pcall(function() a:Destroy() end) end
    end
    state.windowHighlights={}; windowCache={}; windowCacheTime=0
end

local function updateWindowHighlight()
    if not state.isWindowHighlightEnabled or not state.isEspEnabled then
        if next(state.windowHighlights) then clearWindowHighlights() end
        return
    end
    local now=tick()
    if now-windowCacheTime>WINDOW_CACHE_INTERVAL then windowCacheTime=now; windowCache=rescanWindows() end
    local seen={}
    for o in pairs(windowCache) do
        if o and o.Parent then
            seen[o]=true
            local list=state.windowHighlights[o]
            local valid=false
            if list then
                for _,a in ipairs(list) do if a and a.Parent then valid=true break end end
            end
            if valid then
                for _,a in ipairs(list) do
                    if a and a.Parent and a.Color3~=state.windowSettings.HighlightColor then
                        a.Color3=state.windowSettings.HighlightColor
                    end
                end
            else
                if list then for _,a in ipairs(list) do pcall(function() a:Destroy() end) end end
                local nl={}
                for _,part in ipairs(o:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name=="Bottom" then
                        local a=Instance.new("BoxHandleAdornment")
                        a.Adornee=part; a.Size=part.Size; a.Color3=state.windowSettings.HighlightColor
                        a.Transparency=0.3; a.AlwaysOnTop=true; a.ZIndex=5; a.Parent=part
                        table.insert(nl,a)
                    end
                end
                state.windowHighlights[o]=nl
            end
        end
    end
    for o,l in pairs(state.windowHighlights) do
        if not seen[o] or not o or not o.Parent then
            for _,a in ipairs(l) do pcall(function() a:Destroy() end) end
            state.windowHighlights[o]=nil
        end
    end
end

local function EnableWindowHighlight()
    if state.windowHighlightConnection then return end
    state.isWindowHighlightEnabled=true
    if state.windowToggleRef then state.windowToggleRef(true) end
    windowCacheTime=0
    if state.isEspEnabled then updateWindowHighlight() end
    state.windowHighlightConnection=RunService.RenderStepped:Connect(updateWindowHighlight)
end

local function DisableWindowHighlight()
    if state.windowHighlightConnection then state.windowHighlightConnection:Disconnect(); state.windowHighlightConnection=nil end
    state.isWindowHighlightEnabled=false
    if state.windowToggleRef then state.windowToggleRef(false) end
    clearWindowHighlights()
end

local hookCache = {}
local hookCacheTime = 0
local HOOK_CACHE_INTERVAL = 0.5

local function rescanHooks()
    local found = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return found end
    for _, d in ipairs(map:GetChildren()) do
        if d:IsA("Model") and d.Name:lower() == "hook" then
            found[d] = true
        end
    end
    return found
end

local function clearHookHighlights()
    for obj, h in pairs(state.hookHighlights) do
        pcall(function() h:Destroy() end)
    end
    state.hookHighlights = {}
    hookCache = {}
    hookCacheTime = 0
end

local function updateHookHighlight()
    if not state.isHookHighlightEnabled or not state.isEspEnabled then
        if next(state.hookHighlights) then clearHookHighlights() end
        return
    end
    local now = tick()
    if now - hookCacheTime > HOOK_CACHE_INTERVAL then
        hookCacheTime = now
        hookCache = rescanHooks()
    end
    local seen = {}
    for obj in pairs(hookCache) do
        if obj and obj.Parent then
            seen[obj] = true
            local ex = state.hookHighlights[obj]
            local valid = false
            if ex and ex.Parent == obj then valid = true end
            if valid then
                if ex.FillColor ~= state.hookSettings.HighlightColor then
                    ex.FillColor = state.hookSettings.HighlightColor
                    ex.OutlineColor = state.hookSettings.HighlightColor
                end
            else
                if ex then pcall(function() ex:Destroy() end) end
                local h = Instance.new("Highlight")
                h.Parent = obj
                h.FillColor = state.hookSettings.HighlightColor
                h.FillTransparency = 0.4
                h.OutlineColor = state.hookSettings.HighlightColor
                h.OutlineTransparency = 0.2
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Enabled = true
                state.hookHighlights[obj] = h
            end
        end
    end
    for obj, h in pairs(state.hookHighlights) do
        if not seen[obj] or not obj or not obj.Parent then
            pcall(function() h:Destroy() end)
            state.hookHighlights[obj] = nil
        end
    end
end

local function EnableHookHighlight()
    if state.hookHighlightConnection then return end
    state.isHookHighlightEnabled = true
    if state.hookToggleRef then state.hookToggleRef(true) end
    hookCacheTime = 0
    if state.isEspEnabled then updateHookHighlight() end
    state.hookHighlightConnection = RunService.RenderStepped:Connect(updateHookHighlight)
end

local function DisableHookHighlight()
    if state.hookHighlightConnection then
        state.hookHighlightConnection:Disconnect()
        state.hookHighlightConnection = nil
    end
    state.isHookHighlightEnabled = false
    if state.hookToggleRef then state.hookToggleRef(false) end
    clearHookHighlights()
end

local function getPlayerRole(op)
    local ch=op.Character
    if not ch or not ch:FindFirstChild("Humanoid") or ch.Humanoid.Health<=0 then return "unknown" end
    local t=op.Team
    if not t then return "unknown" end
    local n=t.Name
    if n=="Killer" or n:lower():find("killer") then return "killer"
    elseif n=="Survivors" or n:lower():find("survivor") then return "survivor"
    elseif n=="Spectator" or n:lower():find("spectator") then return "spectator" end
    return "unknown"
end

local function createHighlight(ch,color)
    if not ch or not ch.Parent then return nil end
    local ex=state.highlights[ch]
    if ex then
        if ex.FillColor~=color then ex.FillColor=color; ex.OutlineColor=color end
        ex.FillTransparency=1-state.espSettings.FillTransparency
        ex.OutlineTransparency=1-state.espSettings.OutlineTransparency
        return ex
    end
    local h=Instance.new("Highlight")
    h.Parent=ch; h.FillColor=color; h.FillTransparency=1-state.espSettings.FillTransparency
    h.OutlineColor=color; h.OutlineTransparency=1-state.espSettings.OutlineTransparency
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Enabled=true
    state.highlights[ch]=h
    return h
end

local function clearAllHighlights()
    for _,h in pairs(state.highlights) do pcall(function() h:Destroy() end) end
    state.highlights={}
end

local function updateESP()
    if not state.isEspEnabled then clearAllHighlights(); return end
    if state.espSettings.ShowSelf then
        local sc=player.Character
        if sc and sc:FindFirstChild("Humanoid") and sc.Humanoid.Health>0 then createHighlight(sc,state.espSettings.SelfColor) end
    end
    for _,op in ipairs(Players:GetPlayers()) do
        if op~=player then
            local c=op.Character
            if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health>0 then
                local role=getPlayerRole(op)
                if role=="killer" and state.espSettings.ShowKiller then createHighlight(c,state.espSettings.KillerColor)
                elseif role=="survivor" and state.espSettings.ShowSurvivor then createHighlight(c,state.espSettings.SurvivorColor) end
            end
        end
    end
end

local function EnableEsp()
    if state.espConnection then return end
    state.isEspEnabled=true
    updateESP()
    if state.isGenHighlightEnabled then updateGenHighlight() end
    if state.isGateHighlightEnabled then updateGateHighlight() end
    if state.isPalletHighlightEnabled then updatePalletHighlight() end
    if state.isWindowHighlightEnabled then updateWindowHighlight() end
    if state.isHookHighlightEnabled then updateHookHighlight() end
    state.espConnection=RunService.RenderStepped:Connect(function()
        if state.isEspEnabled then
            updateESP()
            if state.isGenHighlightEnabled then updateGenHighlight() end
            if state.isGateHighlightEnabled then updateGateHighlight() end
            if state.isPalletHighlightEnabled then updatePalletHighlight() end
            if state.isWindowHighlightEnabled then updateWindowHighlight() end
            if state.isHookHighlightEnabled then updateHookHighlight() end
        end
    end)
end

local function DisableEsp()
    if state.espConnection then state.espConnection:Disconnect(); state.espConnection=nil end
    state.isEspEnabled=false
    clearAllHighlights(); clearGenHighlights(); clearGateHighlights()
    clearPalletHighlights(); clearWindowHighlights(); clearHookHighlights()
end

local function HSVToRGB(h,s,v)
    h=h%1
    local r,g,b
    if s==0 then r,g,b=v,v,v
    else
        local i=math.floor(h*6); local f=h*6-i
        local p=v*(1-s); local q=v*(1-s*f); local t=v*(1-s*(1-f))
        if i==0 then r,g,b=v,t,p elseif i==1 then r,g,b=q,v,p
        elseif i==2 then r,g,b=p,v,t elseif i==3 then r,g,b=p,q,v
        elseif i==4 then r,g,b=t,p,v else r,g,b=v,p,q end
    end
    return r,g,b
end

local function RGBToHSV(r,g,b)
    r,g,b=r/255,g/255,b/255
    local mx,mn=math.max(r,g,b),math.min(r,g,b)
    local v=mx; local d=mx-mn
    local s=mx==0 and 0 or d/mx
    local h=0
    if mx~=mn then
        if mx==r then h=(g-b)/d+(g<b and 6 or 0)
        elseif mx==g then h=(b-r)/d+2
        else h=(r-g)/d+4 end
        h=h/6
    end
    return h,s,v
end

do
    local colorPickerOpen = false
    local currentPickerFrame = nil
    local pickerData = {}
    local pickerGuiRef = nil
    local isDraggingPicker = false
    local pickerDragStartPos = nil
    local pickerFrameStartPos = nil

    function OpenColorPicker(title, currentColor, callback)
        if colorPickerOpen and currentPickerFrame then
            currentPickerFrame:Destroy(); currentPickerFrame = nil; colorPickerOpen = false
        end
        colorPickerOpen = true
        local pickerGui = Instance.new("ScreenGui")
        pickerGui.Name = "ColorPickerGui"
        pickerGui.Parent = playerGui
        pickerGui.ResetOnSpawn = false
        pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pickerGuiRef = pickerGui
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.new(0, 400, 0, 420)
        pickerFrame.Position = UDim2.new(0.5, -200, 0.5, -210)
        pickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        pickerFrame.BorderSizePixel = 0
        pickerFrame.Parent = pickerGui
        pickerFrame.ZIndex = 2
        pickerFrame.ClipsDescendants = false
        Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 10)
        currentPickerFrame = pickerFrame
        local dragZone = Instance.new("Frame")
        dragZone.Size = UDim2.new(1, 0, 0, 32)
        dragZone.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        dragZone.BorderSizePixel = 0
        dragZone.Parent = pickerFrame
        dragZone.ZIndex = 10
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -35, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 14
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = dragZone
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 25, 0, 25)
        closeBtn.Position = UDim2.new(1, -30, 0, 3.5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = dragZone
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function()
            pickerGui:Destroy(); colorPickerOpen = false; currentPickerFrame = nil; pickerGuiRef = nil
        end)
        dragZone.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingPicker = true
                pickerDragStartPos = input.Position
                pickerFrameStartPos = pickerFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isDraggingPicker and input.UserInputType == Enum.UserInputType.MouseMovement then
                local d = input.Position - pickerDragStartPos
                pickerFrame.Position = UDim2.new(
                    pickerFrameStartPos.X.Scale, pickerFrameStartPos.X.Offset + d.X,
                    pickerFrameStartPos.Y.Scale, pickerFrameStartPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingPicker = false end
        end)
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1, -20, 0, 1)
        divider.Position = UDim2.new(0, 10, 0, 32)
        divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
        paletteFrame.Position = UDim2.new(0, 10, 0, 42)
        paletteFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        paletteFrame.BorderSizePixel = 1
        paletteFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        paletteFrame.Parent = pickerFrame
        paletteFrame.ClipsDescendants = true
        Instance.new("UICorner", paletteFrame).CornerRadius = UDim.new(0, 4)
        local pixelSize = 4
        local pixelsX = math.floor(paletteSize / pixelSize)
        local pixelsY = math.floor(paletteSize / pixelSize)
        local pixelGrid = {}
        for y = 0, pixelsY - 1 do
            for x = 0, pixelsX - 1 do
                local pixel = Instance.new("Frame")
                pixel.Size = UDim2.new(0, pixelSize, 0, pixelSize)
                pixel.Position = UDim2.new(0, x * pixelSize, 0, y * pixelSize)
                pixel.BorderSizePixel = 0
                pixel.Parent = paletteFrame
                local sat = x / pixelsX
                local val = 1 - (y / pixelsY)
                local r2, g2, b2 = HSVToRGB(currentHue, sat, val)
                pixel.BackgroundColor3 = Color3.fromRGB(math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
                pixelGrid[#pixelGrid + 1] = pixel
            end
        end
        local hueWidth = 25
        local hueFrame = Instance.new("Frame")
        hueFrame.Size = UDim2.new(0, hueWidth, 0, paletteSize)
        hueFrame.Position = UDim2.new(0, paletteSize + 5, 0, 42)
        hueFrame.BorderSizePixel = 1
        hueFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        hueFrame.Parent = pickerFrame
        hueFrame.ClipsDescendants = true
        Instance.new("UICorner", hueFrame).CornerRadius = UDim.new(0, 4)
        for y = 0, paletteSize - 1 do
            local pixel = Instance.new("Frame")
            pixel.Size = UDim2.new(1, 0, 0, 1)
            pixel.Position = UDim2.new(0, 0, 0, y)
            pixel.BorderSizePixel = 0
            pixel.Parent = hueFrame
            local hue2 = y / paletteSize
            local r2, g2, b2 = HSVToRGB(hue2, 1, 1)
            pixel.BackgroundColor3 = Color3.fromRGB(math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
        end
        local function updatePalette(hue)
            for y = 0, pixelsY - 1 do
                for x = 0, pixelsX - 1 do
                    local idx = y * pixelsX + x + 1
                    if idx <= #pixelGrid then
                        local sat = x / pixelsX
                        local val = 1 - (y / pixelsY)
                        local r2, g2, b2 = HSVToRGB(hue, sat, val)
                        pixelGrid[idx].BackgroundColor3 = Color3.fromRGB(math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
                    end
                end
            end
        end
        local selector = Instance.new("Frame")
        selector.Size = UDim2.new(0, 12, 0, 12)
        selector.Position = UDim2.new(currentSat, -6, 1 - currentVal, -6)
        selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        selector.BorderSizePixel = 2
        selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
        selector.Parent = paletteFrame
        selector.ZIndex = 10
        Instance.new("UICorner", selector).CornerRadius = UDim.new(1, 0)
        local hueSelector = Instance.new("Frame")
        hueSelector.Size = UDim2.new(1, 0, 0, 4)
        hueSelector.Position = UDim2.new(0, 0, 0, currentHue * paletteSize)
        hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSelector.BorderSizePixel = 1
        hueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
        hueSelector.Parent = hueFrame
        hueSelector.ZIndex = 10
        local previewFrame = Instance.new("Frame")
        previewFrame.Size = UDim2.new(0, 70, 0, 70)
        previewFrame.Position = UDim2.new(0, paletteSize + hueWidth + 15, 0, 42)
        previewFrame.BackgroundColor3 = currentColor
        previewFrame.BorderSizePixel = 1
        previewFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        previewFrame.Parent = pickerFrame
        Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 4)
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(0, 70, 0, 90)
        infoFrame.Position = UDim2.new(0, paletteSize + hueWidth + 15, 0, 118)
        infoFrame.BackgroundTransparency = 1
        infoFrame.Parent = pickerFrame
        local rgbLabel = Instance.new("TextLabel")
        rgbLabel.Size = UDim2.new(1, 0, 0, 20)
        rgbLabel.BackgroundTransparency = 1
        rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
        rgbLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        rgbLabel.TextSize = 10
        rgbLabel.Font = Enum.Font.GothamMedium
        rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
        rgbLabel.Parent = infoFrame
        local hexLabel = Instance.new("TextLabel")
        hexLabel.Size = UDim2.new(1, 0, 0, 20)
        hexLabel.Position = UDim2.new(0, 0, 0, 22)
        hexLabel.BackgroundTransparency = 1
        hexLabel.Text = string.format("HEX: #%02X%02X%02X", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
        hexLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        hexLabel.TextSize = 10
        hexLabel.Font = Enum.Font.GothamMedium
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left
        hexLabel.Parent = infoFrame
        local function updateFromPalette(posX, posY)
            local cx = math.clamp(posX, 0, paletteSize)
            local cy = math.clamp(posY, 0, paletteSize)
            local sat = cx / paletteSize
            local val = 1 - (cy / paletteSize)
            currentSat = sat; currentVal = val
            selector.Position = UDim2.new(sat, -6, 1 - val, -6)
            local r2, g2, b2 = HSVToRGB(currentHue, sat, val)
            local color = Color3.fromRGB(math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            previewFrame.BackgroundColor3 = color
            rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            hexLabel.Text = string.format("HEX: #%02X%02X%02X", math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            pickerData.selectedColor = color
        end
        local function updateFromHue(posY)
            local cy = math.clamp(posY, 0, paletteSize)
            local hue = cy / paletteSize
            currentHue = hue
            hueSelector.Position = UDim2.new(0, 0, 0, cy - 2)
            updatePalette(hue)
            local r2, g2, b2 = HSVToRGB(hue, currentSat, currentVal)
            local color = Color3.fromRGB(math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            previewFrame.BackgroundColor3 = color
            rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            hexLabel.Text = string.format("HEX: #%02X%02X%02X", math.floor(r2*255), math.floor(g2*255), math.floor(b2*255))
            pickerData.selectedColor = color
        end
        local isDraggingPalette, isDraggingHue = false, false
        paletteFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingPalette = true
                local mp = input.Position; local fp = paletteFrame.AbsolutePosition
                updateFromPalette(mp.X - fp.X, mp.Y - fp.Y)
            end
        end)
        hueFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingHue = true
                local mp = input.Position; local fp = hueFrame.AbsolutePosition
                updateFromHue(mp.Y - fp.Y)
            end
        end)
        local mouseConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if isDraggingPalette then
                    local mp = input.Position; local fp = paletteFrame.AbsolutePosition
                    updateFromPalette(mp.X - fp.X, mp.Y - fp.Y)
                elseif isDraggingHue then
                    local mp = input.Position; local fp = hueFrame.AbsolutePosition
                    updateFromHue(mp.Y - fp.Y)
                end
            end
        end)
        local endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingPalette = false; isDraggingHue = false
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
        okBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        okBtn.BorderSizePixel = 0
        okBtn.Text = "Применить"
        okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        okBtn.TextSize = 13
        okBtn.Font = Enum.Font.GothamBold
        okBtn.Parent = bottomFrame
        Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 4)
        okBtn.MouseButton1Click:Connect(function()
            local sc = pickerData.selectedColor or currentColor
            if callback then callback(sc) end
            if mouseConn then mouseConn:Disconnect() end
            if endConn then endConn:Disconnect() end
            pickerGui:Destroy(); colorPickerOpen = false; currentPickerFrame = nil; pickerGuiRef = nil
        end)
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 100, 1, 0)
        cancelBtn.Position = UDim2.new(0.5, 5, 0, 0)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        cancelBtn.BorderSizePixel = 0
        cancelBtn.Text = "Отмена"
        cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancelBtn.TextSize = 13
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.Parent = bottomFrame
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 4)
        cancelBtn.MouseButton1Click:Connect(function()
            if mouseConn then mouseConn:Disconnect() end
            if endConn then endConn:Disconnect() end
            pickerGui:Destroy(); colorPickerOpen = false; currentPickerFrame = nil; pickerGuiRef = nil
        end)
        pickerData.selectedColor = currentColor
    end
end

local function CreateColorPickerButton(title, yPos, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 28)
    container.Position = UDim2.new(0, 5, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    container.Parent = state.espSettingsFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
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
    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 3)
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.0f, %.0f, %.0f", currentColor.R*255, currentColor.G*255, currentColor.B*255)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = container
    local function updateColor(newColor)
        currentColor = newColor
        colorBtn.BackgroundColor3 = newColor
        valueLabel.Text = string.format("%.0f, %.0f, %.0f", newColor.R*255, newColor.G*255, newColor.B*255)
        if callback then callback(newColor) end
    end
    colorBtn.MouseButton1Click:Connect(function()
        OpenColorPicker(title, currentColor, updateColor)
    end)
    return { GetColor = function() return currentColor end, SetColor = updateColor }
end

local function CreateFeatureFrame(parent, labelText, bindName, toggleCallback, getState)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local featureLabel = Instance.new("TextLabel")
    featureLabel.Size = UDim2.new(0.6, 0, 1, 0)
    featureLabel.Position = UDim2.new(0, 40, 0, 0)
    featureLabel.BackgroundTransparency = 1
    featureLabel.Text = labelText
    featureLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    featureLabel.TextSize = 13
    featureLabel.Font = Enum.Font.GothamMedium
    featureLabel.TextXAlignment = Enum.TextXAlignment.Left
    featureLabel.Parent = frame
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(0, 160, 1, 0)
    bindContainer.Position = UDim2.new(0.7, 0, 0, 0)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = frame
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
    Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 3)
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
    Instance.new("UICorner", toggleBindBtn).CornerRadius = UDim.new(0, 3)
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
    Instance.new("UICorner", bindIndicator).CornerRadius = UDim.new(0, 2)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 50, 0, 22)
    track.Position = UDim2.new(1, -55, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    table.insert(state.blockedButtons, holdBtn)
    table.insert(state.blockedButtons, toggleBindBtn)
    local currentBindKey, currentBindMode = nil, nil
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
        task.defer(ForceUpdateBindList)
    end
    local function OnClick()
        if not state.isWaitingForBind then SetActive(not isActive) end
    end
    frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then OnClick() end end)
    featureLabel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then OnClick() end end)
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then OnClick() end end)
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then OnClick() end end)
    bindContainer.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then OnClick() end end)
    local function SetBind(keyCode, mode)
        for bk, bi in pairs(state.binds) do
            if bi.target == bindName then state.binds[bk] = nil; break end
        end
        if state.binds[keyCode] then state.binds[keyCode] = nil end
        if keyCode and mode then
            currentBindKey = keyCode; currentBindMode = mode
            state.binds[keyCode] = { target = bindName, mode = mode, toggleCallback = SetActive, getState = function() return isActive end }
            task.defer(ForceUpdateBindList)
        else
            currentBindKey = nil; currentBindMode = nil
        end
        UpdateIndicator()
    end
    local function StartBind(mode)
        if state.isWaitingForBind then return end
        state.isWaitingForBind = true
        state.waitingBindMode = mode
        state.waitingBindFeature = { SetBind = SetBind }
        SetAllButtonsLocked(true)
        bindIndicator.Text = "Нажми клавишу..."
        bindIndicator.TextColor3 = Color3.fromRGB(255, 255, 100)
        bindIndicator.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
    end
    holdBtn.MouseButton1Click:Connect(function() StartBind("hold") end)
    toggleBindBtn.MouseButton1Click:Connect(function() StartBind("toggle") end)
    return {
        Frame = frame, SetActive = SetActive, IsActive = function() return isActive end,
        SetBind = SetBind, GetBindKey = function() return currentBindKey end, GetBindMode = function() return currentBindMode end
    }
end

-- ============ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 900, 0, 450)
mainFrame.Position = UDim2.new(0.5, -450, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local dragZone = Instance.new("Frame")
dragZone.Size = UDim2.new(1, 0, 0, 32)
dragZone.BackgroundTransparency = 1
dragZone.Parent = mainFrame
dragZone.ZIndex = 10
dragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.isDraggingMenu = true
        state.dragStartPos = input.Position
        state.frameStartPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if state.isDraggingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - state.dragStartPos
        mainFrame.Position = UDim2.new(
            state.frameStartPos.X.Scale, state.frameStartPos.X.Offset + d.X,
            state.frameStartPos.Y.Scale, state.frameStartPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then state.isDraggingMenu = false end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "flin.cc [Insert]"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 32)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

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

local functionsPanel = Instance.new("ScrollingFrame")
functionsPanel.Size = UDim2.new(1, -300, 1, -45)
functionsPanel.Position = UDim2.new(0, 280, 0, 40)
functionsPanel.BackgroundTransparency = 1
functionsPanel.Parent = mainFrame
functionsPanel.ScrollBarThickness = 6
functionsPanel.BorderSizePixel = 0
functionsPanel.ClipsDescendants = true
functionsPanel.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
functionsPanel.ScrollBarImageTransparency = 0.5

local funcTitle = Instance.new("TextLabel")
funcTitle.Size = UDim2.new(1, 0, 0, 25)
funcTitle.BackgroundTransparency = 1
funcTitle.Text = "RAGE - ФУНКЦИИ"
funcTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
funcTitle.TextSize = 11
funcTitle.Font = Enum.Font.GothamBold
funcTitle.TextXAlignment = Enum.TextXAlignment.Center
funcTitle.Parent = functionsPanel

local functionsLayout = Instance.new("Frame")
functionsLayout.Size = UDim2.new(1, 0, 0, 0)
functionsLayout.Position = UDim2.new(0, 0, 0, 28)
functionsLayout.BackgroundTransparency = 1
functionsLayout.Parent = functionsPanel

local function UpdateFunctionsHeight()
    local totalHeight = 28
    for _, child in pairs(functionsLayout:GetChildren()) do
        if child:IsA("Frame") and child.Visible then
            totalHeight = totalHeight + child.Size.Y.Offset + 3
        end
    end
    totalHeight = totalHeight + 10
    functionsLayout.Size = UDim2.new(1, 0, 0, totalHeight)
    functionsPanel.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
end

local function updateSections()
    for _, child in pairs(functionsLayout:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("Section") then
            child.Visible = (child:GetAttribute("Section") or "Rage") == state.currentSection
        end
    end
    UpdateFunctionsHeight()
end

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
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 1, -6)
    ind.Position = UDim2.new(0, 2, 0, 0.5)
    ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.Parent = btn
    ind.Name = "Indicator"
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
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
        functionsPanel.CanvasPosition = Vector2.new(0, 0)
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

local rageContainer = Instance.new("Frame")
rageContainer.Size = UDim2.new(1, 0, 0, 0)
rageContainer.BackgroundTransparency = 1
rageContainer.Parent = functionsLayout
rageContainer:SetAttribute("Section", "Rage")
rageContainer.Visible = true

local rageLayout = Instance.new("UIListLayout")
rageLayout.Parent = rageContainer
rageLayout.SortOrder = Enum.SortOrder.LayoutOrder
rageLayout.Padding = UDim.new(0, 3)

local function updateRageContainerHeight()
    local h = 0
    for _, c in pairs(rageContainer:GetChildren()) do
        if c:IsA("Frame") and c.Visible and c.Name ~= "RageLayout" then h = h + c.Size.Y.Offset + 3 end
    end
    h = h + 5
    rageContainer.Size = UDim2.new(1, 0, 0, h)
    UpdateFunctionsHeight()
end

-- Movement
local movementFeature = CreateFeatureFrame(rageContainer, "Movement", "MovementToggle", function() end, function() return false end)
state.bindRefs.movement = movementFeature
for _, c in ipairs(movementFeature.Frame:GetChildren()) do
    if c:IsA("Frame") then c.Visible = false end
end

local mf = Instance.new("Frame")
mf.Size = UDim2.new(1, -10, 0, 0)
mf.BackgroundTransparency = 1
mf.Parent = rageContainer
mf.Visible = false
mf.ClipsDescendants = true

local mfLayout = Instance.new("UIListLayout")
mfLayout.Parent = mf
mfLayout.SortOrder = Enum.SortOrder.LayoutOrder
mfLayout.Padding = UDim.new(0, 3)

local function recalcMovement()
    if not state.movementOpen then mf.Size = UDim2.new(1, -10, 0, 0); return end
    local h = 0
    for _, c in ipairs(mf:GetChildren()) do
        if c:IsA("Frame") and c.Visible then h = h + c.Size.Y.Offset + 3 end
    end
    mf.Size = UDim2.new(1, -10, 0, h + 5)
end

local ma = Instance.new("TextButton")
ma.Size = UDim2.new(0, 30, 1, 0)
ma.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ma.BorderSizePixel = 0
ma.Text = "▶"
ma.TextColor3 = Color3.fromRGB(200, 200, 200)
ma.TextSize = 14
ma.Font = Enum.Font.GothamMedium
ma.Parent = movementFeature.Frame
Instance.new("UICorner", ma).CornerRadius = UDim.new(0, 6)
ma.MouseButton1Click:Connect(function()
    state.movementOpen = not state.movementOpen
    mf.Visible = state.movementOpen
    ma.Text = state.movementOpen and "▼" or "▶"
    recalcMovement(); updateRageContainerHeight()
end)

-- Speed Boost
do
    local speedFeature = CreateFeatureFrame(mf, "Speed Boost", "Speed", function(val)
        state.isSpeedEnabled = val; ApplySpeed()
    end, function() return state.isSpeedEnabled end)
    state.toggleRefs.speed = { SetActive = speedFeature.SetActive, IsActive = speedFeature.IsActive }
    state.bindRefs.speed = speedFeature
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, -10, 0, 60)
    sf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sf.BorderSizePixel = 0
    sf.Parent = mf
    sf.Visible = false
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 6)
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.3, 0, 1, 0)
    vl.Position = UDim2.new(0, 10, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = "Скорость:"
    vl.TextColor3 = Color3.fromRGB(200, 200, 200)
    vl.TextSize = 13
    vl.Font = Enum.Font.GothamMedium
    vl.TextXAlignment = Enum.TextXAlignment.Left
    vl.Parent = sf
    state.speedNumLabel = Instance.new("TextLabel")
    state.speedNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
    state.speedNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
    state.speedNumLabel.BackgroundTransparency = 1
    state.speedNumLabel.Text = "50"
    state.speedNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.speedNumLabel.TextSize = 14
    state.speedNumLabel.Font = Enum.Font.GothamBold
    state.speedNumLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.speedNumLabel.Parent = sf
    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0.5, -20, 0, 6)
    tr.Position = UDim2.new(0.45, 0, 0.5, -3)
    tr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tr.BorderSizePixel = 0
    tr.Parent = sf
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
    state.sliderFill = Instance.new("Frame")
    state.sliderFill.Size = UDim2.new(0.375, 0, 1, 0)
    state.sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.sliderFill.BorderSizePixel = 0
    state.sliderFill.Parent = tr
    Instance.new("UICorner", state.sliderFill).CornerRadius = UDim.new(1, 0)
    state.sliderKnob = Instance.new("Frame")
    state.sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    state.sliderKnob.Position = UDim2.new(0.375, -7, 0.5, -7)
    state.sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.sliderKnob.BorderSizePixel = 0
    state.sliderKnob.Parent = tr
    Instance.new("UICorner", state.sliderKnob).CornerRadius = UDim.new(1, 0)
    local function upd(v)
        local c = math.clamp(v, 20, 100)
        state.speedValue = c
        local p = (c - 20) / 80
        state.sliderFill.Size = UDim2.new(p, 0, 1, 0)
        state.sliderKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.speedNumLabel.Text = tostring(math.floor(c))
        if state.isSpeedEnabled then ApplySpeed() end
    end
    local drag = false
    local function fromMouse(input)
        local ts = tr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - tr.AbsolutePosition.X
            upd(20 + math.clamp(mx / ts, 0, 1) * 80)
        end
    end
    tr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    state.sliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouse(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    arrow.BorderSizePixel = 0
    arrow.Text = "▶"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamMedium
    arrow.Parent = speedFeature.Frame
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 6)
    arrow.MouseButton1Click:Connect(function()
        state.speedSettingsOpen = not state.speedSettingsOpen
        sf.Visible = state.speedSettingsOpen
        arrow.Text = state.speedSettingsOpen and "▼" or "▶"
        recalcMovement(); updateRageContainerHeight()
    end)
end

-- Noclip
do
    local f = CreateFeatureFrame(mf, "Noclip", "Noclip", function(val)
        if val then EnableNoclip() else DisableNoclip() end
    end, function() return state.isNoclipEnabled end)
    state.toggleRefs.noclip = { SetActive = f.SetActive, IsActive = f.IsActive }
    state.bindRefs.noclip = f
end

-- Fly
do
    local flyFeature = CreateFeatureFrame(mf, "Fly", "Fly", function(val)
        if val then EnableFly() else DisableFly() end
    end, function() return state.isFlyEnabled end)
    state.toggleRefs.fly = { SetActive = flyFeature.SetActive, IsActive = flyFeature.IsActive }
    state.bindRefs.fly = flyFeature

    local fsf = Instance.new("Frame")
    fsf.Size = UDim2.new(1, -10, 0, 60)
    fsf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fsf.BorderSizePixel = 0
    fsf.Parent = mf
    fsf.Visible = false
    Instance.new("UICorner", fsf).CornerRadius = UDim.new(0, 6)

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.3, 0, 1, 0)
    vl.Position = UDim2.new(0, 10, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = "Fly Speed:"
    vl.TextColor3 = Color3.fromRGB(200, 200, 200)
    vl.TextSize = 13
    vl.Font = Enum.Font.GothamMedium
    vl.TextXAlignment = Enum.TextXAlignment.Left
    vl.Parent = fsf

    local flyNumLabel = Instance.new("TextLabel")
    flyNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
    flyNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
    flyNumLabel.BackgroundTransparency = 1
    flyNumLabel.Text = "60"
    flyNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyNumLabel.TextSize = 14
    flyNumLabel.Font = Enum.Font.GothamBold
    flyNumLabel.TextXAlignment = Enum.TextXAlignment.Center
    flyNumLabel.Parent = fsf

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0.5, -20, 0, 6)
    tr.Position = UDim2.new(0.45, 0, 0.5, -3)
    tr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tr.BorderSizePixel = 0
    tr.Parent = fsf
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((60 - 10) / 290, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = tr
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((60 - 10) / 290, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = tr
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function upd(v)
        local c = math.clamp(v, 10, 300)
        state.flyValue = c
        local p = (c - 10) / 290
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -7, 0.5, -7)
        flyNumLabel.Text = tostring(math.floor(c))
    end

    local drag = false
    local function fromMouse(input)
        local ts = tr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - tr.AbsolutePosition.X
            upd(10 + math.clamp(mx / ts, 0, 1) * 290)
        end
    end
    tr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouse(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    arrow.BorderSizePixel = 0
    arrow.Text = "▶"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamMedium
    arrow.Parent = flyFeature.Frame
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 6)
    arrow.MouseButton1Click:Connect(function()
        state.flySettingsOpen = not state.flySettingsOpen
        fsf.Visible = state.flySettingsOpen
        arrow.Text = state.flySettingsOpen and "▼" or "▶"
        recalcMovement(); updateRageContainerHeight()
    end)
end

-- Dash
do
    local dashFeature = CreateFeatureFrame(mf, "Dash", "Dash", function(val)
        state.isDashEnabled = val
        if not val then
            DisableDash()
        end
    end, function() return state.isDashEnabled end)
    state.toggleRefs.dash = { SetActive = dashFeature.SetActive, IsActive = dashFeature.IsActive }
    state.bindRefs.dash = dashFeature

    for _, c in ipairs(dashFeature.Frame:GetChildren()) do
        if c:IsA("Frame") and c.Position.X.Scale == 0.7 then
            c.Visible = false
        end
    end

    local dsf = Instance.new("Frame")
    dsf.Size = UDim2.new(1, -10, 0, 165)
    dsf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dsf.BorderSizePixel = 0
    dsf.Parent = mf
    dsf.Visible = false
    Instance.new("UICorner", dsf).CornerRadius = UDim.new(0, 6)

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(0.3, 0, 0, 30)
    dl.Position = UDim2.new(0, 10, 0, 5)
    dl.BackgroundTransparency = 1
    dl.Text = "Distance:"
    dl.TextColor3 = Color3.fromRGB(200, 200, 200)
    dl.TextSize = 13
    dl.Font = Enum.Font.GothamMedium
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = dsf

    local dashDistLabel = Instance.new("TextLabel")
    dashDistLabel.Size = UDim2.new(0.15, 0, 0, 30)
    dashDistLabel.Position = UDim2.new(0.3, 0, 0, 5)
    dashDistLabel.BackgroundTransparency = 1
    dashDistLabel.Text = "25"
    dashDistLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dashDistLabel.TextSize = 14
    dashDistLabel.Font = Enum.Font.GothamBold
    dashDistLabel.TextXAlignment = Enum.TextXAlignment.Center
    dashDistLabel.Parent = dsf

    local dTr = Instance.new("Frame")
    dTr.Size = UDim2.new(0.5, -20, 0, 6)
    dTr.Position = UDim2.new(0.45, 0, 0, 17)
    dTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dTr.BorderSizePixel = 0
    dTr.Parent = dsf
    Instance.new("UICorner", dTr).CornerRadius = UDim.new(1, 0)

    local dFill = Instance.new("Frame")
    dFill.Size = UDim2.new((25 - 5) / 95, 0, 1, 0)
    dFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dFill.BorderSizePixel = 0
    dFill.Parent = dTr
    Instance.new("UICorner", dFill).CornerRadius = UDim.new(1, 0)

    local dKnob = Instance.new("Frame")
    dKnob.Size = UDim2.new(0, 14, 0, 14)
    dKnob.Position = UDim2.new((25 - 5) / 95, -7, 0.5, -7)
    dKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dKnob.BorderSizePixel = 0
    dKnob.Parent = dTr
    Instance.new("UICorner", dKnob).CornerRadius = UDim.new(1, 0)

    local function updDist(v)
        local c = math.clamp(v, 5, 100)
        state.dashDistance = c
        local p = (c - 5) / 95
        dFill.Size = UDim2.new(p, 0, 1, 0)
        dKnob.Position = UDim2.new(p, -7, 0.5, -7)
        dashDistLabel.Text = tostring(math.floor(c))
    end

    local dragD = false
    local function fromMouseD(input)
        local ts = dTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - dTr.AbsolutePosition.X
            updDist(5 + math.clamp(mx / ts, 0, 1) * 95)
        end
    end
    dTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD = true; fromMouseD(input) end end)
    dKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD = true; fromMouseD(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragD and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseD(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD = false end end)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0.3, 0, 0, 30)
    tl.Position = UDim2.new(0, 10, 0, 30)
    tl.BackgroundTransparency = 1
    tl.Text = "Time:"
    tl.TextColor3 = Color3.fromRGB(200, 200, 200)
    tl.TextSize = 13
    tl.Font = Enum.Font.GothamMedium
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = dsf

    local dashTimeLabel = Instance.new("TextLabel")
    dashTimeLabel.Size = UDim2.new(0.15, 0, 0, 30)
    dashTimeLabel.Position = UDim2.new(0.3, 0, 0, 30)
    dashTimeLabel.BackgroundTransparency = 1
    dashTimeLabel.Text = "0.50"
    dashTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dashTimeLabel.TextSize = 14
    dashTimeLabel.Font = Enum.Font.GothamBold
    dashTimeLabel.TextXAlignment = Enum.TextXAlignment.Center
    dashTimeLabel.Parent = dsf

    local tTr = Instance.new("Frame")
    tTr.Size = UDim2.new(0.5, -20, 0, 6)
    tTr.Position = UDim2.new(0.45, 0, 0, 42)
    tTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tTr.BorderSizePixel = 0
    tTr.Parent = dsf
    Instance.new("UICorner", tTr).CornerRadius = UDim.new(1, 0)

    local tFill = Instance.new("Frame")
    tFill.Size = UDim2.new((0.50 - 0.10) / 1.90, 0, 1, 0)
    tFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tFill.BorderSizePixel = 0
    tFill.Parent = tTr
    Instance.new("UICorner", tFill).CornerRadius = UDim.new(1, 0)

    local tKnob = Instance.new("Frame")
    tKnob.Size = UDim2.new(0, 14, 0, 14)
    tKnob.Position = UDim2.new((0.50 - 0.10) / 1.90, -7, 0.5, -7)
    tKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tKnob.BorderSizePixel = 0
    tKnob.Parent = tTr
    Instance.new("UICorner", tKnob).CornerRadius = UDim.new(1, 0)

    local function updTime(v)
        local c = math.clamp(v, 0.10, 2.00)
        state.dashTime = c
        local p = (c - 0.10) / 1.90
        tFill.Size = UDim2.new(p, 0, 1, 0)
        tKnob.Position = UDim2.new(p, -7, 0.5, -7)
        dashTimeLabel.Text = string.format("%.2f", c)
    end

    local dragT = false
    local function fromMouseT(input)
        local ts = tTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - tTr.AbsolutePosition.X
            updTime(0.10 + math.clamp(mx / ts, 0, 1) * 1.90)
        end
    end
    tTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragT = true; fromMouseT(input) end end)
    tKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragT = true; fromMouseT(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragT and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseT(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragT = false end end)

    local drl = Instance.new("TextLabel")
    drl.Size = UDim2.new(0.3, 0, 0, 30)
    drl.Position = UDim2.new(0, 10, 0, 55)
    drl.BackgroundTransparency = 1
    drl.Text = "Direction:"
    drl.TextColor3 = Color3.fromRGB(200, 200, 200)
    drl.TextSize = 13
    drl.Font = Enum.Font.GothamMedium
    drl.TextXAlignment = Enum.TextXAlignment.Left
    drl.Parent = dsf

    local directionBtn = Instance.new("TextButton")
    directionBtn.Size = UDim2.new(0, 100, 0, 26)
    directionBtn.Position = UDim2.new(0.45, 0, 0, 57)
    directionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    directionBtn.BorderSizePixel = 0
    directionBtn.Text = state.dashDirection or "Camera"
    directionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    directionBtn.TextSize = 12
    directionBtn.Font = Enum.Font.GothamMedium
    directionBtn.Parent = dsf
    Instance.new("UICorner", directionBtn).CornerRadius = UDim.new(0, 4)

    local dirList = Instance.new("Frame")
    dirList.Size = UDim2.new(0, 100, 0, 56)
    dirList.Position = UDim2.new(0.45, 0, 0, 85)
    dirList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dirList.BorderSizePixel = 1
    dirList.BorderColor3 = Color3.fromRGB(60, 60, 60)
    dirList.Visible = false
    dirList.Parent = dsf
    dirList.ZIndex = 10
    Instance.new("UICorner", dirList).CornerRadius = UDim.new(0, 4)

    for i, opt in ipairs({"Camera", "Movement"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.Position = UDim2.new(0, 0, 0, (i - 1) * 28)
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        b.BorderSizePixel = 0
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.TextSize = 11
        b.Font = Enum.Font.GothamMedium
        b.Parent = dirList
        b.ZIndex = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            state.dashDirection = opt
            directionBtn.Text = opt
            dirList.Visible = false
        end)
    end
    directionBtn.MouseButton1Click:Connect(function()
        dirList.Visible = not dirList.Visible
    end)

    local dashBindLabel = Instance.new("TextLabel")
    dashBindLabel.Size = UDim2.new(0.3, 0, 0, 20)
    dashBindLabel.Position = UDim2.new(0, 10, 0, 88)
    dashBindLabel.BackgroundTransparency = 1
    dashBindLabel.Text = "Bind:"
    dashBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dashBindLabel.TextSize = 13
    dashBindLabel.Font = Enum.Font.GothamMedium
    dashBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    dashBindLabel.Parent = dsf

    local dashBindBtn = Instance.new("TextButton")
    dashBindBtn.Size = UDim2.new(0.5, -20, 0, 20)
    dashBindBtn.Position = UDim2.new(0.45, 0, 0, 88)
    dashBindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dashBindBtn.BorderSizePixel = 0
    dashBindBtn.Text = "Bind: None"
    dashBindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    dashBindBtn.TextSize = 11
    dashBindBtn.Font = Enum.Font.GothamMedium
    dashBindBtn.Parent = dsf
    Instance.new("UICorner", dashBindBtn).CornerRadius = UDim.new(0, 4)

    state.dashBindBtn = dashBindBtn

    dashBindBtn.MouseButton1Click:Connect(function()
        if state.isWaitingForBind then return end
        state.isWaitingForBind = true
        state.waitingBindMode = "action"
        state.waitingBindFeature = {
            SetBind = function(keyCode, mode)
                if state.dashBindKey and state.binds[state.dashBindKey] then
                    state.binds[state.dashBindKey] = nil
                end
                if keyCode then
                    state.dashBindKey = keyCode
                    state.binds[keyCode] = {
                        target = "Dash",
                        mode = "action",
                        toggleCallback = function()
                            if state.isDashEnabled then PerformDash() end
                        end,
                        getState = function() return state.isDashEnabled end
                    }
                    dashBindBtn.Text = "Bind: " .. GetKeyName(keyCode)
                    task.defer(ForceUpdateBindList)
                else
                    state.dashBindKey = nil
                    dashBindBtn.Text = "Bind: None"
                end
            end
        }
        SetAllButtonsLocked(true)
        dashBindBtn.Text = "Bind: ..."
        dashBindBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
    end)

    state.dashDistanceLabel = dashDistLabel
    state.dashDistFill = dFill
    state.dashDistKnob = dKnob
    state.dashTimeLabel = dashTimeLabel
    state.dashTimeFill = tFill
    state.dashTimeKnob = tKnob
    state.dashDirectionBtn = directionBtn

    local da = Instance.new("TextButton")
    da.Size = UDim2.new(0, 30, 1, 0)
    da.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    da.BorderSizePixel = 0
    da.Text = "▶"
    da.TextColor3 = Color3.fromRGB(200, 200, 200)
    da.TextSize = 14
    da.Font = Enum.Font.GothamMedium
    da.Parent = dashFeature.Frame
    Instance.new("UICorner", da).CornerRadius = UDim.new(0, 6)
    da.MouseButton1Click:Connect(function()
        state.dashSettingsOpen = not state.dashSettingsOpen
        dsf.Visible = state.dashSettingsOpen
        da.Text = state.dashSettingsOpen and "▼" or "▶"
        recalcMovement(); updateRageContainerHeight()
    end)
end

-- Moonwalk
do
    local mwFeature = CreateFeatureFrame(mf, "Moonwalk", "Moonwalk", function(val)
        if val then EnableMoonwalk() else DisableMoonwalk() end
    end, function() return state.isMoonwalkEnabled end)
    state.toggleRefs.moonwalk = { SetActive = mwFeature.SetActive, IsActive = mwFeature.IsActive }
    state.bindRefs.moonwalk = mwFeature

    local mwf = Instance.new("Frame")
    mwf.Size = UDim2.new(1, -10, 0, 130)
    mwf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mwf.BorderSizePixel = 0
    mwf.Parent = mf
    mwf.Visible = false
    Instance.new("UICorner", mwf).CornerRadius = UDim.new(0, 6)

    local al = Instance.new("TextLabel")
    al.Size = UDim2.new(0.4, 0, 0, 30)
    al.Position = UDim2.new(0, 10, 0, 5)
    al.BackgroundTransparency = 1
    al.Text = "Sway Amplitude:"
    al.TextColor3 = Color3.fromRGB(200, 200, 200)
    al.TextSize = 12
    al.Font = Enum.Font.GothamMedium
    al.TextXAlignment = Enum.TextXAlignment.Left
    al.Parent = mwf

    local ampLabel = Instance.new("TextLabel")
    ampLabel.Size = UDim2.new(0.15, 0, 0, 30)
    ampLabel.Position = UDim2.new(0.4, 0, 0, 5)
    ampLabel.BackgroundTransparency = 1
    ampLabel.Text = "100"
    ampLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ampLabel.TextSize = 13
    ampLabel.Font = Enum.Font.GothamBold
    ampLabel.TextXAlignment = Enum.TextXAlignment.Center
    ampLabel.Parent = mwf

    local aTr = Instance.new("Frame")
    aTr.Size = UDim2.new(0.5, -20, 0, 6)
    aTr.Position = UDim2.new(0.55, 0, 0, 17)
    aTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    aTr.BorderSizePixel = 0
    aTr.Parent = mwf
    Instance.new("UICorner", aTr).CornerRadius = UDim.new(1, 0)

    local aFill = Instance.new("Frame")
    aFill.Size = UDim2.new((100 - 1) / 249, 0, 1, 0)
    aFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    aFill.BorderSizePixel = 0
    aFill.Parent = aTr
    Instance.new("UICorner", aFill).CornerRadius = UDim.new(1, 0)

    local aKnob = Instance.new("Frame")
    aKnob.Size = UDim2.new(0, 14, 0, 14)
    aKnob.Position = UDim2.new((100 - 1) / 249, -7, 0.5, -7)
    aKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    aKnob.BorderSizePixel = 0
    aKnob.Parent = aTr
    Instance.new("UICorner", aKnob).CornerRadius = UDim.new(1, 0)

    local function updAmp(v)
        local c = math.clamp(v, 1, 250)
        state.moonwalkSwayAmplitude = c
        local p = (c - 1) / 249
        aFill.Size = UDim2.new(p, 0, 1, 0)
        aKnob.Position = UDim2.new(p, -7, 0.5, -7)
        ampLabel.Text = tostring(math.floor(c))
    end

    local dragA = false
    local function fromMouseA(input)
        local ts = aTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - aTr.AbsolutePosition.X
            updAmp(1 + math.clamp(mx / ts, 0, 1) * 249)
        end
    end
    aTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = true; fromMouseA(input) end end)
    aKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = true; fromMouseA(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragA and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseA(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = false end end)

    local il = Instance.new("TextLabel")
    il.Size = UDim2.new(0.4, 0, 0, 30)
    il.Position = UDim2.new(0, 10, 0, 40)
    il.BackgroundTransparency = 1
    il.Text = "Sway Interval:"
    il.TextColor3 = Color3.fromRGB(200, 200, 200)
    il.TextSize = 12
    il.Font = Enum.Font.GothamMedium
    il.TextXAlignment = Enum.TextXAlignment.Left
    il.Parent = mwf

    local intLabel = Instance.new("TextLabel")
    intLabel.Size = UDim2.new(0.15, 0, 0, 30)
    intLabel.Position = UDim2.new(0.4, 0, 0, 40)
    intLabel.BackgroundTransparency = 1
    intLabel.Text = "0.20"
    intLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    intLabel.TextSize = 13
    intLabel.Font = Enum.Font.GothamBold
    intLabel.TextXAlignment = Enum.TextXAlignment.Center
    intLabel.Parent = mwf

    local iTr = Instance.new("Frame")
    iTr.Size = UDim2.new(0.5, -20, 0, 6)
    iTr.Position = UDim2.new(0.55, 0, 0, 52)
    iTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    iTr.BorderSizePixel = 0
    iTr.Parent = mwf
    Instance.new("UICorner", iTr).CornerRadius = UDim.new(1, 0)

    local iFill = Instance.new("Frame")
    iFill.Size = UDim2.new((0.20 - 0.01) / 0.99, 0, 1, 0)
    iFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    iFill.BorderSizePixel = 0
    iFill.Parent = iTr
    Instance.new("UICorner", iFill).CornerRadius = UDim.new(1, 0)

    local iKnob = Instance.new("Frame")
    iKnob.Size = UDim2.new(0, 14, 0, 14)
    iKnob.Position = UDim2.new((0.20 - 0.01) / 0.99, -7, 0.5, -7)
    iKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    iKnob.BorderSizePixel = 0
    iKnob.Parent = iTr
    Instance.new("UICorner", iKnob).CornerRadius = UDim.new(1, 0)

    local function updInt(v)
        local c = math.clamp(v, 0.01, 1.00)
        state.moonwalkSwayInterval = c
        local p = (c - 0.01) / 0.99
        iFill.Size = UDim2.new(p, 0, 1, 0)
        iKnob.Position = UDim2.new(p, -7, 0.5, -7)
        intLabel.Text = string.format("%.2f", c)
    end

    local dragI = false
    local function fromMouseI(input)
        local ts = iTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - iTr.AbsolutePosition.X
            updInt(0.01 + math.clamp(mx / ts, 0, 1) * 0.99)
        end
    end
    iTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragI = true; fromMouseI(input) end end)
    iKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragI = true; fromMouseI(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragI and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseI(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragI = false end end)

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(0.4, 0, 0, 30)
    sl.Position = UDim2.new(0, 10, 0, 75)
    sl.BackgroundTransparency = 1
    sl.Text = "Sway Smooth Speed:"
    sl.TextColor3 = Color3.fromRGB(200, 200, 200)
    sl.TextSize = 12
    sl.Font = Enum.Font.GothamMedium
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.Parent = mwf

    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0.15, 0, 0, 30)
    smoothLabel.Position = UDim2.new(0.4, 0, 0, 75)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Text = "20"
    smoothLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    smoothLabel.TextSize = 13
    smoothLabel.Font = Enum.Font.GothamBold
    smoothLabel.TextXAlignment = Enum.TextXAlignment.Center
    smoothLabel.Parent = mwf

    local sTr = Instance.new("Frame")
    sTr.Size = UDim2.new(0.5, -20, 0, 6)
    sTr.Position = UDim2.new(0.55, 0, 0, 87)
    sTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sTr.BorderSizePixel = 0
    sTr.Parent = mwf
    Instance.new("UICorner", sTr).CornerRadius = UDim.new(1, 0)

    local sFill = Instance.new("Frame")
    sFill.Size = UDim2.new((20 - 1) / 99, 0, 1, 0)
    sFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sFill.BorderSizePixel = 0
    sFill.Parent = sTr
    Instance.new("UICorner", sFill).CornerRadius = UDim.new(1, 0)

    local sKnob = Instance.new("Frame")
    sKnob.Size = UDim2.new(0, 14, 0, 14)
    sKnob.Position = UDim2.new((20 - 1) / 99, -7, 0.5, -7)
    sKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sKnob.BorderSizePixel = 0
    sKnob.Parent = sTr
    Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1, 0)

    local function updSmooth(v)
        local c = math.clamp(v, 1, 100)
        state.moonwalkSwaySmoothSpeed = c
        local p = (c - 1) / 99
        sFill.Size = UDim2.new(p, 0, 1, 0)
        sKnob.Position = UDim2.new(p, -7, 0.5, -7)
        smoothLabel.Text = tostring(math.floor(c))
    end

    local dragS = false
    local function fromMouseS(input)
        local ts = sTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - sTr.AbsolutePosition.X
            updSmooth(1 + math.clamp(mx / ts, 0, 1) * 99)
        end
    end
    sTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; fromMouseS(input) end end)
    sKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; fromMouseS(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragS and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseS(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end end)

    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    arrow.BorderSizePixel = 0
    arrow.Text = "▶"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamMedium
    arrow.Parent = mwFeature.Frame
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 6)
    arrow.MouseButton1Click:Connect(function()
        state.moonwalkSettingsOpen = not state.moonwalkSettingsOpen
        mwf.Visible = state.moonwalkSettingsOpen
        arrow.Text = state.moonwalkSettingsOpen and "▼" or "▶"
        recalcMovement(); updateRageContainerHeight()
    end)
end

-- Auto Dagger
do
    local ad = CreateFeatureFrame(rageContainer, "Auto Dagger", "AutoDagger", function(val)
        if val then EnableAutoDagger() else DisableAutoDagger() end
    end, function() return state.isAutoDaggerEnabled end)
    state.toggleRefs.autodagger = { SetActive = ad.SetActive, IsActive = ad.IsActive }
    state.bindRefs.autodagger = ad

    local adf = Instance.new("Frame")
    adf.Size = UDim2.new(1, -10, 0, 200)
    adf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    adf.BorderSizePixel = 0
    adf.Parent = rageContainer
    adf.Visible = false
    Instance.new("UICorner", adf).CornerRadius = UDim.new(0, 6)

    local rl = Instance.new("TextLabel")
    rl.Size = UDim2.new(0.4, 0, 0, 30)
    rl.Position = UDim2.new(0, 10, 0, 5)
    rl.BackgroundTransparency = 1
    rl.Text = "Radius:"
    rl.TextColor3 = Color3.fromRGB(200, 200, 200)
    rl.TextSize = 12
    rl.Font = Enum.Font.GothamMedium
    rl.TextXAlignment = Enum.TextXAlignment.Left
    rl.Parent = adf

    state.autoDaggerRadiusLabel = Instance.new("TextLabel")
    state.autoDaggerRadiusLabel.Size = UDim2.new(0.15, 0, 0, 30)
    state.autoDaggerRadiusLabel.Position = UDim2.new(0.4, 0, 0, 5)
    state.autoDaggerRadiusLabel.BackgroundTransparency = 1
    state.autoDaggerRadiusLabel.Text = "12"
    state.autoDaggerRadiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerRadiusLabel.TextSize = 13
    state.autoDaggerRadiusLabel.Font = Enum.Font.GothamBold
    state.autoDaggerRadiusLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.autoDaggerRadiusLabel.Parent = adf

    local rTr = Instance.new("Frame")
    rTr.Size = UDim2.new(0.5, -20, 0, 6)
    rTr.Position = UDim2.new(0.55, 0, 0, 17)
    rTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    rTr.BorderSizePixel = 0
    rTr.Parent = adf
    Instance.new("UICorner", rTr).CornerRadius = UDim.new(1, 0)

    state.autoDaggerRadiusFill = Instance.new("Frame")
    state.autoDaggerRadiusFill.Size = UDim2.new((12 - 5) / 25, 0, 1, 0)
    state.autoDaggerRadiusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerRadiusFill.BorderSizePixel = 0
    state.autoDaggerRadiusFill.Parent = rTr
    Instance.new("UICorner", state.autoDaggerRadiusFill).CornerRadius = UDim.new(1, 0)

    state.autoDaggerRadiusKnob = Instance.new("Frame")
    state.autoDaggerRadiusKnob.Size = UDim2.new(0, 14, 0, 14)
    state.autoDaggerRadiusKnob.Position = UDim2.new((12 - 5) / 25, -7, 0.5, -7)
    state.autoDaggerRadiusKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerRadiusKnob.BorderSizePixel = 0
    state.autoDaggerRadiusKnob.Parent = rTr
    Instance.new("UICorner", state.autoDaggerRadiusKnob).CornerRadius = UDim.new(1, 0)

    local function updRadius(v)
        local c = math.clamp(v, 5, 30)
        state.autoDaggerRadius = c
        local p = (c - 5) / 25
        state.autoDaggerRadiusFill.Size = UDim2.new(p, 0, 1, 0)
        state.autoDaggerRadiusKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.autoDaggerRadiusLabel.Text = tostring(math.floor(c))
        state.autoDaggerCircleRadius = 0
    end

    local dragR = false
    local function fromMouseR(input)
        local ts = rTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - rTr.AbsolutePosition.X
            updRadius(5 + math.clamp(mx / ts, 0, 1) * 25)
        end
    end
    rTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragR = true; fromMouseR(input) end end)
    state.autoDaggerRadiusKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragR = true; fromMouseR(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragR and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseR(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragR = false end end)

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(0.4, 0, 0, 30)
    dl.Position = UDim2.new(0, 10, 0, 40)
    dl.BackgroundTransparency = 1
    dl.Text = "Delay:"
    dl.TextColor3 = Color3.fromRGB(200, 200, 200)
    dl.TextSize = 12
    dl.Font = Enum.Font.GothamMedium
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = adf

    state.autoDaggerDelayLabel = Instance.new("TextLabel")
    state.autoDaggerDelayLabel.Size = UDim2.new(0.15, 0, 0, 30)
    state.autoDaggerDelayLabel.Position = UDim2.new(0.4, 0, 0, 40)
    state.autoDaggerDelayLabel.BackgroundTransparency = 1
    state.autoDaggerDelayLabel.Text = "0.10"
    state.autoDaggerDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerDelayLabel.TextSize = 13
    state.autoDaggerDelayLabel.Font = Enum.Font.GothamBold
    state.autoDaggerDelayLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.autoDaggerDelayLabel.Parent = adf

    local dTr = Instance.new("Frame")
    dTr.Size = UDim2.new(0.5, -20, 0, 6)
    dTr.Position = UDim2.new(0.55, 0, 0, 52)
    dTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dTr.BorderSizePixel = 0
    dTr.Parent = adf
    Instance.new("UICorner", dTr).CornerRadius = UDim.new(1, 0)

    state.autoDaggerDelayFill = Instance.new("Frame")
    state.autoDaggerDelayFill.Size = UDim2.new(0.10 / 0.5, 0, 1, 0)
    state.autoDaggerDelayFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerDelayFill.BorderSizePixel = 0
    state.autoDaggerDelayFill.Parent = dTr
    Instance.new("UICorner", state.autoDaggerDelayFill).CornerRadius = UDim.new(1, 0)

    state.autoDaggerDelayKnob = Instance.new("Frame")
    state.autoDaggerDelayKnob.Size = UDim2.new(0, 14, 0, 14)
    state.autoDaggerDelayKnob.Position = UDim2.new(0.10 / 0.5, -7, 0.5, -7)
    state.autoDaggerDelayKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerDelayKnob.BorderSizePixel = 0
    state.autoDaggerDelayKnob.Parent = dTr
    Instance.new("UICorner", state.autoDaggerDelayKnob).CornerRadius = UDim.new(1, 0)

    local function updDelay(v)
        local c = math.clamp(v, 0, 0.5)
        state.autoDaggerDelay = c
        local p = c / 0.5
        state.autoDaggerDelayFill.Size = UDim2.new(p, 0, 1, 0)
        state.autoDaggerDelayKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.autoDaggerDelayLabel.Text = string.format("%.2f", c)
    end

    local dragD2 = false
    local function fromMouseD2(input)
        local ts = dTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - dTr.AbsolutePosition.X
            updDelay(math.clamp(mx / ts, 0, 1) * 0.5)
        end
    end
    dTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD2 = true; fromMouseD2(input) end end)
    state.autoDaggerDelayKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD2 = true; fromMouseD2(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragD2 and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseD2(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragD2 = false end end)

    local cl = Instance.new("TextLabel")
    cl.Size = UDim2.new(0.4, 0, 0, 30)
    cl.Position = UDim2.new(0, 10, 0, 75)
    cl.BackgroundTransparency = 1
    cl.Text = "Cooldown:"
    cl.TextColor3 = Color3.fromRGB(200, 200, 200)
    cl.TextSize = 12
    cl.Font = Enum.Font.GothamMedium
    cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.Parent = adf

    state.autoDaggerCooldownLabel = Instance.new("TextLabel")
    state.autoDaggerCooldownLabel.Size = UDim2.new(0.15, 0, 0, 30)
    state.autoDaggerCooldownLabel.Position = UDim2.new(0.4, 0, 0, 75)
    state.autoDaggerCooldownLabel.BackgroundTransparency = 1
    state.autoDaggerCooldownLabel.Text = "91"
    state.autoDaggerCooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerCooldownLabel.TextSize = 13
    state.autoDaggerCooldownLabel.Font = Enum.Font.GothamBold
    state.autoDaggerCooldownLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.autoDaggerCooldownLabel.Parent = adf

    local cTr = Instance.new("Frame")
    cTr.Size = UDim2.new(0.5, -20, 0, 6)
    cTr.Position = UDim2.new(0.55, 0, 0, 87)
    cTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cTr.BorderSizePixel = 0
    cTr.Parent = adf
    Instance.new("UICorner", cTr).CornerRadius = UDim.new(1, 0)

    state.autoDaggerCooldownFill = Instance.new("Frame")
    state.autoDaggerCooldownFill.Size = UDim2.new((91 - 30) / 90, 0, 1, 0)
    state.autoDaggerCooldownFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerCooldownFill.BorderSizePixel = 0
    state.autoDaggerCooldownFill.Parent = cTr
    Instance.new("UICorner", state.autoDaggerCooldownFill).CornerRadius = UDim.new(1, 0)

    state.autoDaggerCooldownKnob = Instance.new("Frame")
    state.autoDaggerCooldownKnob.Size = UDim2.new(0, 14, 0, 14)
    state.autoDaggerCooldownKnob.Position = UDim2.new((91 - 30) / 90, -7, 0.5, -7)
    state.autoDaggerCooldownKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.autoDaggerCooldownKnob.BorderSizePixel = 0
    state.autoDaggerCooldownKnob.Parent = cTr
    Instance.new("UICorner", state.autoDaggerCooldownKnob).CornerRadius = UDim.new(1, 0)

    local function updCooldown(v)
        local c = math.clamp(v, 30, 120)
        state.autoDaggerCooldown = c
        local p = (c - 30) / 90
        state.autoDaggerCooldownFill.Size = UDim2.new(p, 0, 1, 0)
        state.autoDaggerCooldownKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.autoDaggerCooldownLabel.Text = tostring(math.floor(c))
    end

    local dragC = false
    local function fromMouseC(input)
        local ts = cTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - cTr.AbsolutePosition.X
            updCooldown(30 + math.clamp(mx / ts, 0, 1) * 90)
        end
    end
    cTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragC = true; fromMouseC(input) end end)
    state.autoDaggerCooldownKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragC = true; fromMouseC(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragC and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseC(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragC = false end end)

    local srF = Instance.new("Frame")
    srF.Size = UDim2.new(1, -10, 0, 28)
    srF.Position = UDim2.new(0, 5, 0, 110)
    srF.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    srF.BorderSizePixel = 0
    srF.Parent = adf
    Instance.new("UICorner", srF).CornerRadius = UDim.new(0, 4)
    local srL = Instance.new("TextLabel")
    srL.Size = UDim2.new(0.5, 0, 1, 0)
    srL.Position = UDim2.new(0, 10, 0, 0)
    srL.BackgroundTransparency = 1
    srL.Text = "Show Radius"
    srL.TextColor3 = Color3.fromRGB(220, 220, 220)
    srL.TextSize = 12
    srL.Font = Enum.Font.GothamMedium
    srL.TextXAlignment = Enum.TextXAlignment.Left
    srL.Parent = srF
    local srT = Instance.new("Frame")
    srT.Size = UDim2.new(0, 40, 0, 18)
    srT.Position = UDim2.new(1, -45, 0.5, -9)
    srT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    srT.BorderSizePixel = 0
    srT.Parent = srF
    Instance.new("UICorner", srT).CornerRadius = UDim.new(1, 0)
    local srK = Instance.new("Frame")
    srK.Size = UDim2.new(0, 14, 0, 14)
    srK.Position = UDim2.new(1, -16, 0.5, -7)
    srK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    srK.BorderSizePixel = 0
    srK.Parent = srT
    Instance.new("UICorner", srK).CornerRadius = UDim.new(1, 0)
    local function toggleShowRadius()
        state.autoDaggerShowRadius = not state.autoDaggerShowRadius
        if state.autoDaggerShowRadius then
            TweenService:Create(srT, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            TweenService:Create(srK, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(srT, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80,80,80)}):Play()
            TweenService:Create(srK, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            DestroyDaggerCircle()
        end
    end
    srF.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then toggleShowRadius() end end)
    srL.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then toggleShowRadius() end end)
    srT.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then toggleShowRadius() end end)
    srK.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then toggleShowRadius() end end)

    local colF = Instance.new("Frame")
    colF.Size = UDim2.new(1, -10, 0, 28)
    colF.Position = UDim2.new(0, 5, 0, 143)
    colF.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    colF.BorderSizePixel = 0
    colF.Parent = adf
    Instance.new("UICorner", colF).CornerRadius = UDim.new(0, 4)
    local colL = Instance.new("TextLabel")
    colL.Size = UDim2.new(0.5, 0, 1, 0)
    colL.Position = UDim2.new(0, 10, 0, 0)
    colL.BackgroundTransparency = 1
    colL.Text = "Radius Color"
    colL.TextColor3 = Color3.fromRGB(220, 220, 220)
    colL.TextSize = 12
    colL.Font = Enum.Font.GothamMedium
    colL.TextXAlignment = Enum.TextXAlignment.Left
    colL.Parent = colF
    local colB = Instance.new("TextButton")
    colB.Size = UDim2.new(0, 40, 0, 22)
    colB.Position = UDim2.new(1, -45, 0.5, -11)
    colB.BackgroundColor3 = state.autoDaggerColor
    colB.BorderSizePixel = 1
    colB.BorderColor3 = Color3.fromRGB(100,100,100)
    colB.Text = ""
    colB.Parent = colF
    Instance.new("UICorner", colB).CornerRadius = UDim.new(0, 3)
    colB.MouseButton1Click:Connect(function()
        OpenColorPicker("Radius Color", state.autoDaggerColor, function(c)
            state.autoDaggerColor = c
            colB.BackgroundColor3 = c
            state.autoDaggerCircleColor = nil
        end)
    end)

    local ad_arrow = Instance.new("TextButton")
    ad_arrow.Size = UDim2.new(0, 30, 1, 0)
    ad_arrow.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ad_arrow.BorderSizePixel = 0
    ad_arrow.Text = "▶"
    ad_arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    ad_arrow.TextSize = 14
    ad_arrow.Font = Enum.Font.GothamMedium
    ad_arrow.Parent = ad.Frame
    Instance.new("UICorner", ad_arrow).CornerRadius = UDim.new(0, 6)
    ad_arrow.MouseButton1Click:Connect(function()
        state.autoDaggerSettingsOpen = not state.autoDaggerSettingsOpen
        adf.Visible = state.autoDaggerSettingsOpen
        ad_arrow.Text = state.autoDaggerSettingsOpen and "▼" or "▶"
        updateRageContainerHeight()
    end)
end

-- Auto Skillcheck
do
    local sc = CreateFeatureFrame(rageContainer, "Auto Skillcheck", "Skillcheck", function(val)
        if val then EnableAutoSkillcheck() else DisableAutoSkillcheck() end
    end, function() return state.isAutoSkillcheckEnabled end)
    state.toggleRefs.skillcheck = { SetActive = sc.SetActive, IsActive = sc.IsActive }
    state.bindRefs.skillcheck = sc
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, -10, 0, 50)
    sf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sf.BorderSizePixel = 0
    sf.Parent = rageContainer
    sf.Visible = false
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 6)
    local ql = Instance.new("TextLabel")
    ql.Size = UDim2.new(0.4, 0, 1, 0)
    ql.Position = UDim2.new(0, 10, 0, 0)
    ql.BackgroundTransparency = 1
    ql.Text = "Качество:"
    ql.TextColor3 = Color3.fromRGB(200, 200, 200)
    ql.TextSize = 12
    ql.Font = Enum.Font.GothamMedium
    ql.TextXAlignment = Enum.TextXAlignment.Left
    ql.Parent = sf
    local qb = Instance.new("TextButton")
    qb.Size = UDim2.new(0.35, 0, 1, 0)
    qb.Position = UDim2.new(0.45, 0, 0, 0)
    qb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    qb.BorderSizePixel = 0
    qb.Text = state.skillcheckQuality
    qb.TextColor3 = Color3.fromRGB(255, 255, 255)
    qb.TextSize = 11
    qb.Font = Enum.Font.GothamMedium
    qb.Parent = sf
    Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 4)
    local qlist = Instance.new("Frame")
    qlist.Size = UDim2.new(0.35, 0, 0, 60)
    qlist.Position = UDim2.new(0.45, 0, 1, 2)
    qlist.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    qlist.BorderSizePixel = 1
    qlist.BorderColor3 = Color3.fromRGB(60, 60, 60)
    qlist.Visible = false
    qlist.Parent = sf
    qlist.ZIndex = 10
    Instance.new("UICorner", qlist).CornerRadius = UDim.new(0, 4)
    for i, opt in ipairs({"Good", "Great"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.Position = UDim2.new(0, 0, 0, (i-1) * 28)
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        b.BorderSizePixel = 0
        b.Text = opt
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.TextSize = 11
        b.Font = Enum.Font.GothamMedium
        b.Parent = qlist
        b.ZIndex = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            state.skillcheckQuality = opt
            qb.Text = opt
            qlist.Visible = false
        end)
    end
    qb.MouseButton1Click:Connect(function() qlist.Visible = not qlist.Visible end)
    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    arrow.BorderSizePixel = 0
    arrow.Text = "▶"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamMedium
    arrow.Parent = sc.Frame
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 6)
    arrow.MouseButton1Click:Connect(function()
        state.skillcheckSettingsOpen = not state.skillcheckSettingsOpen
        sf.Visible = state.skillcheckSettingsOpen
        arrow.Text = state.skillcheckSettingsOpen and "▼" or "▶"
        updateRageContainerHeight()
    end)
end

task.wait(0.1)
updateRageContainerHeight()

-- Recovery Heal
do
    local f = CreateFeatureFrame(rageContainer, "Recovery Heal", "RecoveryHeal", function(val)
        if val then EnableRecoveryHeal() else DisableRecoveryHeal() end
    end, function() return state.isRecoveryHealEnabled end)
    state.toggleRefs.recoveryHeal = { SetActive = f.SetActive, IsActive = f.IsActive }
    state.bindRefs.recoveryHeal = f
end

-- Insta Heal
do
    local f = CreateFeatureFrame(rageContainer, "Insta Heal", "InstaHeal", function(val)
        if val then EnableInstaHeal() else DisableInstaHeal() end
    end, function() return state.isInstaHealEnabled end)
    state.toggleRefs.instaHeal = { SetActive = f.SetActive, IsActive = f.IsActive }
    state.bindRefs.instaHeal = f
end

-- VISUAL
state.visualContainer = Instance.new("Frame")
state.visualContainer.Size = UDim2.new(1, 0, 0, 0)
state.visualContainer.BackgroundTransparency = 1
state.visualContainer.Parent = functionsLayout
state.visualContainer:SetAttribute("Section", "Visual")
state.visualContainer.Visible = false

local visualLayout = Instance.new("UIListLayout")
visualLayout.Parent = state.visualContainer
visualLayout.SortOrder = Enum.SortOrder.LayoutOrder
visualLayout.Padding = UDim.new(0, 3)

local function updateVisualContainerHeight()
    local h = 0
    for _, c in pairs(state.visualContainer:GetChildren()) do
        if c:IsA("Frame") and c.Visible and c.Name ~= "VisualLayout" then h = h + c.Size.Y.Offset + 3 end
    end
    h = h + 5
    state.visualContainer.Size = UDim2.new(1, 0, 0, h)
    UpdateFunctionsHeight()
end

-- Camera
do
    local cam = CreateFeatureFrame(state.visualContainer, "Camera", "CameraToggle", function() end, function() return false end)
    state.bindRefs.camera = cam
    for _, c in ipairs(cam.Frame:GetChildren()) do
        if c:IsA("Frame") then c.Visible = false end
    end
    local cf = Instance.new("Frame")
    cf.Size = UDim2.new(1, -10, 0, 0)
    cf.BackgroundTransparency = 1
    cf.Parent = state.visualContainer
    cf.Visible = false
    cf.ClipsDescendants = true
    local cl = Instance.new("UIListLayout")
    cl.Parent = cf
    cl.SortOrder = Enum.SortOrder.LayoutOrder
    cl.Padding = UDim.new(0, 3)
    local fov = CreateFeatureFrame(cf, "FOV Changer", "FOV", function(val)
        state.isFovEnabled = val; ApplyFov()
    end, function() return state.isFovEnabled end)
    state.toggleRefs.fov = { SetActive = fov.SetActive, IsActive = fov.IsActive }
    state.bindRefs.fov = fov
    local fsf = Instance.new("Frame")
    fsf.Size = UDim2.new(1, -10, 0, 60)
    fsf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fsf.BorderSizePixel = 0
    fsf.Parent = cf
    fsf.Visible = false
    Instance.new("UICorner", fsf).CornerRadius = UDim.new(0, 6)
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.3, 0, 1, 0)
    vl.Position = UDim2.new(0, 10, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = "FOV:"
    vl.TextColor3 = Color3.fromRGB(200, 200, 200)
    vl.TextSize = 13
    vl.Font = Enum.Font.GothamMedium
    vl.TextXAlignment = Enum.TextXAlignment.Left
    vl.Parent = fsf
    state.fovNumLabel = Instance.new("TextLabel")
    state.fovNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
    state.fovNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
    state.fovNumLabel.BackgroundTransparency = 1
    state.fovNumLabel.Text = "70"
    state.fovNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.fovNumLabel.TextSize = 14
    state.fovNumLabel.Font = Enum.Font.GothamBold
    state.fovNumLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.fovNumLabel.Parent = fsf
    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0.5, -20, 0, 6)
    tr.Position = UDim2.new(0.45, 0, 0.5, -3)
    tr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tr.BorderSizePixel = 0
    tr.Parent = fsf
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
    state.fovSliderFill = Instance.new("Frame")
    state.fovSliderFill.Size = UDim2.new(0.375, 0, 1, 0)
    state.fovSliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.fovSliderFill.BorderSizePixel = 0
    state.fovSliderFill.Parent = tr
    Instance.new("UICorner", state.fovSliderFill).CornerRadius = UDim.new(1, 0)
    state.fovSliderKnob = Instance.new("Frame")
    state.fovSliderKnob.Size = UDim2.new(0, 14, 0, 14)
    state.fovSliderKnob.Position = UDim2.new(0.375, -7, 0.5, -7)
    state.fovSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.fovSliderKnob.BorderSizePixel = 0
    state.fovSliderKnob.Parent = tr
    Instance.new("UICorner", state.fovSliderKnob).CornerRadius = UDim.new(1, 0)
    local function upd(v)
        local c = math.clamp(v, 40, 120)
        state.fovValue = c
        local p = (c - 40) / 80
        state.fovSliderFill.Size = UDim2.new(p, 0, 1, 0)
        state.fovSliderKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.fovNumLabel.Text = tostring(math.floor(c))
    end
    local drag = false
    local function fromMouse(input)
        local ts = tr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - tr.AbsolutePosition.X
            upd(40 + math.clamp(mx / ts, 0, 1) * 80)
        end
    end
    tr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    state.fovSliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouse(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    local function recalc()
        if not state.cameraOpen then cf.Size = UDim2.new(1, -10, 0, 0); return end
        local h = 0
        for _, c in ipairs(cf:GetChildren()) do
            if c:IsA("Frame") and c.Visible then h = h + c.Size.Y.Offset + 3 end
        end
        cf.Size = UDim2.new(1, -10, 0, h + 5)
    end
    local fa = Instance.new("TextButton")
    fa.Size = UDim2.new(0, 30, 1, 0)
    fa.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fa.BorderSizePixel = 0
    fa.Text = "▶"
    fa.TextColor3 = Color3.fromRGB(200, 200, 200)
    fa.TextSize = 14
    fa.Font = Enum.Font.GothamMedium
    fa.Parent = fov.Frame
    Instance.new("UICorner", fa).CornerRadius = UDim.new(0, 6)
    fa.MouseButton1Click:Connect(function()
        state.fovSettingsOpen = not state.fovSettingsOpen
        fsf.Visible = state.fovSettingsOpen
        fa.Text = state.fovSettingsOpen and "▼" or "▶"
        recalc(); updateVisualContainerHeight()
    end)

    local aspectFeature = CreateFeatureFrame(cf, "Aspect Ratio", "Aspect", function(val)
        if val then EnableAspect() else DisableAspect() end
    end, function() return state.isAspectEnabled end)
    state.toggleRefs.aspect = { SetActive = aspectFeature.SetActive, IsActive = aspectFeature.IsActive }
    state.bindRefs.aspect = aspectFeature
    state.aspectToggleRef = aspectFeature.SetActive

    local asf = Instance.new("Frame")
    asf.Size = UDim2.new(1, -10, 0, 90)
    asf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    asf.BorderSizePixel = 0
    asf.Parent = cf
    asf.Visible = false
    Instance.new("UICorner", asf).CornerRadius = UDim.new(0, 6)

    local avl = Instance.new("TextLabel")
    avl.Size = UDim2.new(0.3, 0, 0, 30)
    avl.Position = UDim2.new(0, 10, 0, 0)
    avl.BackgroundTransparency = 1
    avl.Text = "Aspect:"
    avl.TextColor3 = Color3.fromRGB(200, 200, 200)
    avl.TextSize = 13
    avl.Font = Enum.Font.GothamMedium
    avl.TextXAlignment = Enum.TextXAlignment.Left
    avl.Parent = asf

    state.aspectNumLabel = Instance.new("TextLabel")
    state.aspectNumLabel.Size = UDim2.new(0.15, 0, 0, 30)
    state.aspectNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
    state.aspectNumLabel.BackgroundTransparency = 1
    state.aspectNumLabel.Text = string.format("%.2f", state.aspectValue)
    state.aspectNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.aspectNumLabel.TextSize = 14
    state.aspectNumLabel.Font = Enum.Font.GothamBold
    state.aspectNumLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.aspectNumLabel.Parent = asf

    local aTr = Instance.new("Frame")
    aTr.Size = UDim2.new(0.5, -20, 0, 6)
    aTr.Position = UDim2.new(0.45, 0, 0, 12)
    aTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    aTr.BorderSizePixel = 0
    aTr.Parent = asf
    Instance.new("UICorner", aTr).CornerRadius = UDim.new(1, 0)

    state.aspectSliderFill = Instance.new("Frame")
    state.aspectSliderFill.Size = UDim2.new((state.aspectValue - 0.3) / 1.0, 0, 1, 0)
    state.aspectSliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.aspectSliderFill.BorderSizePixel = 0
    state.aspectSliderFill.Parent = aTr
    Instance.new("UICorner", state.aspectSliderFill).CornerRadius = UDim.new(1, 0)

    state.aspectSliderKnob = Instance.new("Frame")
    state.aspectSliderKnob.Size = UDim2.new(0, 14, 0, 14)
    state.aspectSliderKnob.Position = UDim2.new((state.aspectValue - 0.3) / 1.0, -7, 0.5, -7)
    state.aspectSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.aspectSliderKnob.BorderSizePixel = 0
    state.aspectSliderKnob.Parent = aTr
    Instance.new("UICorner", state.aspectSliderKnob).CornerRadius = UDim.new(1, 0)

    local function updAspect(v)
        local c = math.clamp(v, 0.3, 1.30)
        state.aspectValue = c
        local p = (c - 0.3) / 1.0
        state.aspectSliderFill.Size = UDim2.new(p, 0, 1, 0)
        state.aspectSliderKnob.Position = UDim2.new(p, -7, 0.5, -7)
        state.aspectNumLabel.Text = string.format("%.2f", c)
    end

    local dragA = false
    local function fromMouseA(input)
        local ts = aTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - aTr.AbsolutePosition.X
            updAspect(0.3 + math.clamp(mx / ts, 0, 1) * 1.0)
        end
    end
    aTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = true; fromMouseA(input) end end)
    state.aspectSliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = true; fromMouseA(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragA and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseA(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragA = false end end)

    local presets = {
        {name="Wide",  val=0.65},
        {name="Wide+", val=0.50},
        {name="Norm",  val=1.00},
        {name="Narrow",val=1.20},
        {name="Max",   val=1.30},
    }
    local presetRow = Instance.new("Frame")
    presetRow.Size = UDim2.new(1, -10, 0, 26)
    presetRow.Position = UDim2.new(0, 5, 0, 55)
    presetRow.BackgroundTransparency = 1
    presetRow.Parent = asf
    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Padding = UDim.new(0, 3)
    presetLayout.Parent = presetRow
    for i, p in ipairs(presets) do
        local pb = Instance.new("TextButton")
        pb.Size = UDim2.new(0, 52, 1, 0)
        pb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        pb.BorderSizePixel = 0
        pb.Text = p.name
        pb.TextColor3 = Color3.fromRGB(200, 200, 200)
        pb.TextSize = 10
        pb.Font = Enum.Font.GothamMedium
        pb.LayoutOrder = i
        pb.Parent = presetRow
        Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 4)
        pb.MouseButton1Click:Connect(function()
            updAspect(p.val)
            for _, c in ipairs(presetRow:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundColor3 = (c == pb) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
                end
            end
        end)
    end

    local aa = Instance.new("TextButton")
    aa.Size = UDim2.new(0, 30, 1, 0)
    aa.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    aa.BorderSizePixel = 0
    aa.Text = "▶"
    aa.TextColor3 = Color3.fromRGB(200, 200, 200)
    aa.TextSize = 14
    aa.Font = Enum.Font.GothamMedium
    aa.Parent = aspectFeature.Frame
    Instance.new("UICorner", aa).CornerRadius = UDim.new(0, 6)
    aa.MouseButton1Click:Connect(function()
        state.aspectSettingsOpen = not state.aspectSettingsOpen
        asf.Visible = state.aspectSettingsOpen
        aa.Text = state.aspectSettingsOpen and "▼" or "▶"
        recalc(); updateVisualContainerHeight()
    end)

    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(0, 30, 1, 0)
    ca.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ca.BorderSizePixel = 0
    ca.Text = "▶"
    ca.TextColor3 = Color3.fromRGB(200, 200, 200)
    ca.TextSize = 14
    ca.Font = Enum.Font.GothamMedium
    ca.Parent = cam.Frame
    Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 6)
    ca.MouseButton1Click:Connect(function()
        state.cameraOpen = not state.cameraOpen
        cf.Visible = state.cameraOpen
        ca.Text = state.cameraOpen and "▼" or "▶"
        recalc(); updateVisualContainerHeight()
    end)
end

-- World
do
    local world = CreateFeatureFrame(state.visualContainer, "World", "WorldToggle", function() end, function() return false end)
    state.bindRefs.world = world
    for _, c in ipairs(world.Frame:GetChildren()) do
        if c:IsA("Frame") then c.Visible = false end
    end
    local wf = Instance.new("Frame")
    wf.Size = UDim2.new(1, -10, 0, 0)
    wf.BackgroundTransparency = 1
    wf.Parent = state.visualContainer
    wf.Visible = false
    wf.ClipsDescendants = true
    local wl = Instance.new("UIListLayout")
    wl.Parent = wf
    wl.SortOrder = Enum.SortOrder.LayoutOrder
    wl.Padding = UDim.new(0, 3)
    local timeF = CreateFeatureFrame(wf, "Time Changer", "Time", function(val)
        if val then EnableTime() else DisableTime() end
    end, function() return state.isTimeEnabled end)
    state.toggleRefs.time = { SetActive = timeF.SetActive, IsActive = timeF.IsActive }
    state.bindRefs.time = timeF
    local tsf = Instance.new("Frame")
    tsf.Size = UDim2.new(1, -10, 0, 60)
    tsf.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tsf.BorderSizePixel = 0
    tsf.Parent = wf
    tsf.Visible = false
    Instance.new("UICorner", tsf).CornerRadius = UDim.new(0, 6)
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.3, 0, 1, 0)
    vl.Position = UDim2.new(0, 10, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = "Время:"
    vl.TextColor3 = Color3.fromRGB(200, 200, 200)
    vl.TextSize = 13
    vl.Font = Enum.Font.GothamMedium
    vl.TextXAlignment = Enum.TextXAlignment.Left
    vl.Parent = tsf
    state.timeNumLabel = Instance.new("TextLabel")
    state.timeNumLabel.Size = UDim2.new(0.15, 0, 1, 0)
    state.timeNumLabel.Position = UDim2.new(0.3, 0, 0, 0)
    state.timeNumLabel.BackgroundTransparency = 1
    state.timeNumLabel.Text = "12:00"
    state.timeNumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    state.timeNumLabel.TextSize = 14
    state.timeNumLabel.Font = Enum.Font.GothamBold
    state.timeNumLabel.TextXAlignment = Enum.TextXAlignment.Center
    state.timeNumLabel.Parent = tsf
    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0.5, -20, 0, 6)
    tr.Position = UDim2.new(0.45, 0, 0.5, -3)
    tr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tr.BorderSizePixel = 0
    tr.Parent = tsf
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
    state.timeSliderFill = Instance.new("Frame")
    state.timeSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    state.timeSliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.timeSliderFill.BorderSizePixel = 0
    state.timeSliderFill.Parent = tr
    Instance.new("UICorner", state.timeSliderFill).CornerRadius = UDim.new(1, 0)
    state.timeSliderKnob = Instance.new("Frame")
    state.timeSliderKnob.Size = UDim2.new(0, 14, 0, 14)
    state.timeSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
    state.timeSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    state.timeSliderKnob.BorderSizePixel = 0
    state.timeSliderKnob.Parent = tr
    Instance.new("UICorner", state.timeSliderKnob).CornerRadius = UDim.new(1, 0)
    local function upd(v)
        local c = math.clamp(v, 0, 24)
        state.timeValue = c
        local p = c / 24
        state.timeSliderFill.Size = UDim2.new(p, 0, 1, 0)
        state.timeSliderKnob.Position = UDim2.new(p, -7, 0.5, -7)
        local h = math.floor(c); local m = math.floor((c - h) * 60)
        state.timeNumLabel.Text = string.format("%02d:%02d", h, m)
        if state.isTimeEnabled then ApplyTime() end
    end
    local drag = false
    local function fromMouse(input)
        local ts = tr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - tr.AbsolutePosition.X
            upd(math.clamp(mx / ts, 0, 1) * 24)
        end
    end
    tr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    state.timeSliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; fromMouse(input) end end)
    UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouse(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    local ta = Instance.new("TextButton")
    ta.Size = UDim2.new(0, 30, 1, 0)
    ta.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ta.BorderSizePixel = 0
    ta.Text = "▶"
    ta.TextColor3 = Color3.fromRGB(200, 200, 200)
    ta.TextSize = 14
    ta.Font = Enum.Font.GothamMedium
    ta.Parent = timeF.Frame
    Instance.new("UICorner", ta).CornerRadius = UDim.new(0, 6)
    ta.MouseButton1Click:Connect(function()
        state.timeSettingsOpen = not state.timeSettingsOpen
        tsf.Visible = state.timeSettingsOpen
        ta.Text = state.timeSettingsOpen and "▼" or "▶"
        if state.worldOpen then
            local h = 0
            for _, c in ipairs(wf:GetChildren()) do
                if c:IsA("Frame") and c.Visible then h = h + c.Size.Y.Offset + 3 end
            end
            wf.Size = UDim2.new(1, -10, 0, h + 5)
        end
        updateVisualContainerHeight()
    end)
    local fb = CreateFeatureFrame(wf, "FullBright", "FullBright", function(val)
        if val then EnableFullBright() else DisableFullBright() end
    end, function() return state.isFullBrightEnabled end)
    state.toggleRefs.fullbright = { SetActive = fb.SetActive, IsActive = fb.IsActive }
    state.bindRefs.fullbright = fb
    local fog = CreateFeatureFrame(wf, "Remove Fog", "RemoveFog", function(val)
        if val then EnableRemoveFog() else DisableRemoveFog() end
    end, function() return state.isRemoveFogEnabled end)
    state.toggleRefs.removefog = { SetActive = fog.SetActive, IsActive = fog.IsActive }
    state.bindRefs.removefog = fog
    local wa = Instance.new("TextButton")
    wa.Size = UDim2.new(0, 30, 1, 0)
    wa.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    wa.BorderSizePixel = 0
    wa.Text = "▶"
    wa.TextColor3 = Color3.fromRGB(200, 200, 200)
    wa.TextSize = 14
    wa.Font = Enum.Font.GothamMedium
    wa.Parent = world.Frame
    Instance.new("UICorner", wa).CornerRadius = UDim.new(0, 6)
    wa.MouseButton1Click:Connect(function()
        state.worldOpen = not state.worldOpen
        wf.Visible = state.worldOpen
        wa.Text = state.worldOpen and "▼" or "▶"
        if state.worldOpen then
            local h = 0
            for _, c in ipairs(wf:GetChildren()) do
                if c:IsA("Frame") and c.Visible then h = h + c.Size.Y.Offset + 3 end
            end
            wf.Size = UDim2.new(1, -10, 0, h + 5)
        else
            wf.Size = UDim2.new(1, -10, 0, 0)
        end
        updateVisualContainerHeight()
    end)
end

-- ESP
do
    local esp = CreateFeatureFrame(state.visualContainer, "ESP (Highlight)", "ESP", function(val)
        if val then EnableEsp() else DisableEsp() end
    end, function() return state.isEspEnabled end)
    state.toggleRefs.esp = { SetActive = esp.SetActive, IsActive = esp.IsActive }
    state.bindRefs.esp = esp
    state.espSettingsFrame = Instance.new("Frame")
    state.espSettingsFrame.Size = UDim2.new(1, -10, 0, 599)
    state.espSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    state.espSettingsFrame.BorderSizePixel = 0
    state.espSettingsFrame.Parent = state.visualContainer
    state.espSettingsFrame.Visible = false
    Instance.new("UICorner", state.espSettingsFrame).CornerRadius = UDim.new(0, 6)
    CreateColorPickerButton("Killer Color", 5, Color3.fromRGB(255, 0, 0), function(color)
        state.espSettings.KillerColor = color
        if state.isEspEnabled then updateESP() end
    end)
    CreateColorPickerButton("Survivor Color", 38, Color3.fromRGB(0, 255, 0), function(color)
        state.espSettings.SurvivorColor = color
        if state.isEspEnabled then updateESP() end
    end)
    CreateColorPickerButton("Self Color", 71, Color3.fromRGB(0, 150, 255), function(color)
        state.espSettings.SelfColor = color
        if state.isEspEnabled then updateESP() end
    end)
    local ftF = Instance.new("Frame")
    ftF.Size = UDim2.new(1, -10, 0, 28)
    ftF.Position = UDim2.new(0, 5, 0, 104)
    ftF.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ftF.BorderSizePixel = 0
    ftF.Parent = state.espSettingsFrame
    Instance.new("UICorner", ftF).CornerRadius = UDim.new(0, 4)
    local ftL = Instance.new("TextLabel")
    ftL.Size = UDim2.new(0.35, 0, 1, 0)
    ftL.Position = UDim2.new(0, 8, 0, 0)
    ftL.BackgroundTransparency = 1
    ftL.Text = "Заливка:"
    ftL.TextColor3 = Color3.fromRGB(220, 220, 220)
    ftL.TextSize = 11
    ftL.Font = Enum.Font.GothamMedium
    ftL.TextXAlignment = Enum.TextXAlignment.Left
    ftL.Parent = ftF
    local ftV = Instance.new("TextLabel")
    ftV.Size = UDim2.new(0.15, 0, 1, 0)
    ftV.Position = UDim2.new(0.35, 0, 0, 0)
    ftV.BackgroundTransparency = 1
    ftV.Text = string.format("%.0f%%", state.espSettings.FillTransparency * 100)
    ftV.TextColor3 = Color3.fromRGB(255, 255, 255)
    ftV.TextSize = 12
    ftV.Font = Enum.Font.GothamBold
    ftV.TextXAlignment = Enum.TextXAlignment.Center
    ftV.Parent = ftF
    local ftTr = Instance.new("Frame")
    ftTr.Size = UDim2.new(0.4, -10, 0, 6)
    ftTr.Position = UDim2.new(0.55, 0, 0.5, -3)
    ftTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ftTr.BorderSizePixel = 0
    ftTr.Parent = ftF
    Instance.new("UICorner", ftTr).CornerRadius = UDim.new(1, 0)
    local ftFill = Instance.new("Frame")
    ftFill.Size = UDim2.new(state.espSettings.FillTransparency, 0, 1, 0)
    ftFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ftFill.BorderSizePixel = 0
    ftFill.Parent = ftTr
    Instance.new("UICorner", ftFill).CornerRadius = UDim.new(1, 0)
    local ftKnob = Instance.new("Frame")
    ftKnob.Size = UDim2.new(0, 14, 0, 14)
    ftKnob.Position = UDim2.new(state.espSettings.FillTransparency, -7, 0.5, -7)
    ftKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ftKnob.BorderSizePixel = 0
    ftKnob.Parent = ftTr
    Instance.new("UICorner", ftKnob).CornerRadius = UDim.new(1, 0)
    local function updFT(v)
        local c = math.clamp(v, 0, 1)
        state.espSettings.FillTransparency = c
        ftFill.Size = UDim2.new(c, 0, 1, 0)
        ftKnob.Position = UDim2.new(c, -7, 0.5, -7)
        ftV.Text = string.format("%.0f%%", c * 100)
        if state.isEspEnabled then updateESP() end
    end
    local dragFT = false
    local function fromMouseFT(input)
        local ts = ftTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - ftTr.AbsolutePosition.X
            updFT(math.clamp(mx / ts, 0, 1))
        end
    end
    ftTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragFT = true; fromMouseFT(input) end end)
    ftKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragFT = true; fromMouseFT(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragFT and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseFT(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragFT = false end end)
    local otF = Instance.new("Frame")
    otF.Size = UDim2.new(1, -10, 0, 28)
    otF.Position = UDim2.new(0, 5, 0, 137)
    otF.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    otF.BorderSizePixel = 0
    otF.Parent = state.espSettingsFrame
    Instance.new("UICorner", otF).CornerRadius = UDim.new(0, 4)
    local otL = Instance.new("TextLabel")
    otL.Size = UDim2.new(0.35, 0, 1, 0)
    otL.Position = UDim2.new(0, 8, 0, 0)
    otL.BackgroundTransparency = 1
    otL.Text = "Контур:"
    otL.TextColor3 = Color3.fromRGB(220, 220, 220)
    otL.TextSize = 11
    otL.Font = Enum.Font.GothamMedium
    otL.TextXAlignment = Enum.TextXAlignment.Left
    otL.Parent = otF
    local otV = Instance.new("TextLabel")
    otV.Size = UDim2.new(0.15, 0, 1, 0)
    otV.Position = UDim2.new(0.35, 0, 0, 0)
    otV.BackgroundTransparency = 1
    otV.Text = string.format("%.0f%%", state.espSettings.OutlineTransparency * 100)
    otV.TextColor3 = Color3.fromRGB(255, 255, 255)
    otV.TextSize = 12
    otV.Font = Enum.Font.GothamBold
    otV.TextXAlignment = Enum.TextXAlignment.Center
    otV.Parent = otF
    local otTr = Instance.new("Frame")
    otTr.Size = UDim2.new(0.4, -10, 0, 6)
    otTr.Position = UDim2.new(0.55, 0, 0.5, -3)
    otTr.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    otTr.BorderSizePixel = 0
    otTr.Parent = otF
    Instance.new("UICorner", otTr).CornerRadius = UDim.new(1, 0)
    local otFill = Instance.new("Frame")
    otFill.Size = UDim2.new(state.espSettings.OutlineTransparency, 0, 1, 0)
    otFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    otFill.BorderSizePixel = 0
    otFill.Parent = otTr
    Instance.new("UICorner", otFill).CornerRadius = UDim.new(1, 0)
    local otKnob = Instance.new("Frame")
    otKnob.Size = UDim2.new(0, 14, 0, 14)
    otKnob.Position = UDim2.new(state.espSettings.OutlineTransparency, -7, 0.5, -7)
    otKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    otKnob.BorderSizePixel = 0
    otKnob.Parent = otTr
    Instance.new("UICorner", otKnob).CornerRadius = UDim.new(1, 0)
    local function updOT(v)
        local c = math.clamp(v, 0, 1)
        state.espSettings.OutlineTransparency = c
        otFill.Size = UDim2.new(c, 0, 1, 0)
        otKnob.Position = UDim2.new(c, -7, 0.5, -7)
        otV.Text = string.format("%.0f%%", c * 100)
        if state.isEspEnabled then updateESP() end
    end
    local dragOT = false
    local function fromMouseOT(input)
        local ts = otTr.AbsoluteSize.X
        if ts > 0 then
            local mx = input.Position.X - otTr.AbsolutePosition.X
            updOT(math.clamp(mx / ts, 0, 1))
        end
    end
    otTr.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragOT = true; fromMouseOT(input) end end)
    otKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragOT = true; fromMouseOT(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragOT and input.UserInputType == Enum.UserInputType.MouseMovement then fromMouseOT(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragOT = false end end)
    local function makeToggle(yPos, labelText, initial, onChange)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -10, 0, 28)
        f.Position = UDim2.new(0, 5, 0, yPos)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        f.BorderSizePixel = 0
        f.Parent = state.espSettingsFrame
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = labelText
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.TextSize = 12
        l.Font = Enum.Font.GothamMedium
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        local t = Instance.new("Frame")
        t.Size = UDim2.new(0, 40, 0, 18)
        t.Position = UDim2.new(1, -45, 0.5, -9)
        t.BackgroundColor3 = initial and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 80)
        t.BorderSizePixel = 0
        t.Parent = f
        Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
        local k = Instance.new("Frame")
        k.Size = UDim2.new(0, 14, 0, 14)
        k.Position = initial and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        k.BorderSizePixel = 0
        k.Parent = t
        Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
        local function set(val)
            if val then
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(k, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
            else
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
                TweenService:Create(k, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            end
            if onChange then onChange(val) end
        end
        local function click()
            set(not state.espSettings[labelText:gsub("Show ",""):gsub(" ","")])
        end
        f.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        l.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        t.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        k.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        return { set = set, get = function() return state.espSettings[labelText:gsub("Show ",""):gsub(" ","")] end }
    end
    state.espKillerRef = makeToggle(170, "Show Killer", state.espSettings.ShowKiller, function(val)
        state.espSettings.ShowKiller = val
        if state.isEspEnabled then updateESP() end
    end)
    state.espSurvivorRef = makeToggle(203, "Show Survivor", state.espSettings.ShowSurvivor, function(val)
        state.espSettings.ShowSurvivor = val
        if state.isEspEnabled then updateESP() end
    end)
    state.espSelfRef = makeToggle(236, "Show Self", state.espSettings.ShowSelf, function(val)
        state.espSettings.ShowSelf = val
        if state.isEspEnabled then updateESP() end
    end)
    state.toggleRefs.espKiller = { SetActive = state.espKillerRef.set, IsActive = state.espKillerRef.get }
    state.toggleRefs.espSurvivor = { SetActive = state.espSurvivorRef.set, IsActive = state.espSurvivorRef.get }
    state.toggleRefs.espSelf = { SetActive = state.espSelfRef.set, IsActive = state.espSelfRef.get }

    local function makeColorRow(yPos, labelText, defaultColor, settingsKey, getColor)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -10, 0, 28)
        container.Position = UDim2.new(0, 5, 0, yPos)
        container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        container.BorderSizePixel = 0
        container.Parent = state.espSettingsFrame
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 35, 0, 22)
        colorBtn.Position = UDim2.new(0.45, 0, 0.5, -11)
        colorBtn.BackgroundColor3 = defaultColor
        colorBtn.BorderSizePixel = 1
        colorBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
        colorBtn.Text = ""
        colorBtn.Parent = container
        Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 3)
        local valueL = Instance.new("TextLabel")
        valueL.Size = UDim2.new(0.3, 0, 1, 0)
        valueL.Position = UDim2.new(0.6, 0, 0, 0)
        valueL.BackgroundTransparency = 1
        valueL.Text = string.format("%.0f, %.0f, %.0f", defaultColor.R*255, defaultColor.G*255, defaultColor.B*255)
        valueL.TextColor3 = Color3.fromRGB(200, 200, 200)
        valueL.TextSize = 10
        valueL.Font = Enum.Font.GothamMedium
        valueL.TextXAlignment = Enum.TextXAlignment.Left
        valueL.Parent = container
        colorBtn.MouseButton1Click:Connect(function()
            OpenColorPicker(labelText, getColor(), function(color)
                settingsKey.HighlightColor = color
                colorBtn.BackgroundColor3 = color
                valueL.Text = string.format("%.0f, %.0f, %.0f", color.R*255, color.G*255, color.B*255)
            end)
        end)
    end

    local function buildToggle(yPos, labelText, flagName, colorSettings, colorDefaults, setFn, enableFn, disableFn)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -10, 0, 28)
        f.Position = UDim2.new(0, 5, 0, yPos)
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        f.BorderSizePixel = 0
        f.Parent = state.espSettingsFrame
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = labelText
        l.TextColor3 = Color3.fromRGB(220, 220, 220)
        l.TextSize = 12
        l.Font = Enum.Font.GothamMedium
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        local t = Instance.new("Frame")
        t.Size = UDim2.new(0, 40, 0, 18)
        t.Position = UDim2.new(1, -45, 0.5, -9)
        t.BackgroundColor3 = state[flagName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 80)
        t.BorderSizePixel = 0
        t.Parent = f
        Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
        local k = Instance.new("Frame")
        k.Size = UDim2.new(0, 14, 0, 14)
        k.Position = state[flagName] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        k.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        k.BorderSizePixel = 0
        k.Parent = t
        Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
        local toggleRef = function(val)
            if val then
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(k, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
            else
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
                TweenService:Create(k, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            end
        end
        state[flagName.."Ref"] = toggleRef
        local function click()
            state[flagName] = not state[flagName]
            toggleRef(state[flagName])
            if state[flagName] then
                if state.isEspEnabled then enableFn() end
            else
                disableFn()
            end
        end
        f.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        l.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        t.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        k.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then click() end end)
        return toggleRef, f
    end
    state.genToggleRef, state.bindRefs.genhighlight = buildToggle(269, "Show Generators", "isGenHighlightEnabled", state.genSettings, nil, nil, EnableGenHighlight, DisableGenHighlight)
    state.toggleRefs.genhighlight = { SetActive = state.genToggleRef, IsActive = function() return state.isGenHighlightEnabled end }
    makeColorRow(302, "Gen Color", state.genSettings.HighlightColor, state.genSettings, function() return state.genSettings.HighlightColor end)
    state.gateToggleRef, state.bindRefs.gatehighlight = buildToggle(335, "Show Gates", "isGateHighlightEnabled", state.gateSettings, nil, nil, EnableGateHighlight, DisableGateHighlight)
    state.toggleRefs.gatehighlight = { SetActive = state.gateToggleRef, IsActive = function() return state.isGateHighlightEnabled end }
    makeColorRow(368, "Gate Color", state.gateSettings.HighlightColor, state.gateSettings, function() return state.gateSettings.HighlightColor end)
    state.palletToggleRef, state.bindRefs.pallethighlight = buildToggle(401, "Show Pallets", "isPalletHighlightEnabled", state.palletSettings, nil, nil, EnablePalletHighlight, DisablePalletHighlight)
    state.toggleRefs.pallethighlight = { SetActive = state.palletToggleRef, IsActive = function() return state.isPalletHighlightEnabled end }
    makeColorRow(434, "Pallet Color", state.palletSettings.HighlightColor, state.palletSettings, function() return state.palletSettings.HighlightColor end)
    state.windowToggleRef, state.bindRefs.windowhighlight = buildToggle(467, "Show Windows", "isWindowHighlightEnabled", state.windowSettings, nil, nil, EnableWindowHighlight, DisableWindowHighlight)
    state.toggleRefs.windowhighlight = { SetActive = state.windowToggleRef, IsActive = function() return state.isWindowHighlightEnabled end }
    makeColorRow(500, "Window Color", state.windowSettings.HighlightColor, state.windowSettings, function() return state.windowSettings.HighlightColor end)
    state.hookToggleRef, state.bindRefs.hookhighlight = buildToggle(533, "Show Hooks", "isHookHighlightEnabled", state.hookSettings, nil, nil, EnableHookHighlight, DisableHookHighlight)
    state.toggleRefs.hookhighlight = { SetActive = state.hookToggleRef, IsActive = function() return state.isHookHighlightEnabled end }
    makeColorRow(566, "Hook Color", state.hookSettings.HighlightColor, state.hookSettings, function() return state.hookSettings.HighlightColor end)

    state.espArrowBtn = Instance.new("TextButton")
    state.espArrowBtn.Size = UDim2.new(0, 30, 1, 0)
    state.espArrowBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    state.espArrowBtn.BorderSizePixel = 0
    state.espArrowBtn.Text = "▶"
    state.espArrowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    state.espArrowBtn.TextSize = 14
    state.espArrowBtn.Font = Enum.Font.GothamMedium
    state.espArrowBtn.Parent = esp.Frame
    Instance.new("UICorner", state.espArrowBtn).CornerRadius = UDim.new(0, 6)
    state.espArrowBtn.MouseButton1Click:Connect(function()
        state.espSettingsOpen = not state.espSettingsOpen
        state.espSettingsFrame.Visible = state.espSettingsOpen
        state.espArrowBtn.Text = state.espSettingsOpen and "▼" or "▶"
        updateVisualContainerHeight()
    end)
end

-- Bind List
do
    local bl = CreateFeatureFrame(state.visualContainer, "Bind List", "BindList", function(val)
        if val then
            if not state.bindListVisible then ToggleBindList() end
        else
            if state.bindListVisible then ToggleBindList() end
        end
    end, function() return state.bindListVisible end)
    state.bindListToggleRef = { SetActive = bl.SetActive, IsActive = function() return state.bindListVisible end }
    state.toggleRefs.bindlist = { SetActive = bl.SetActive, IsActive = function() return state.bindListVisible end }
    state.bindRefs.bindlist = bl
end

updateVisualContainerHeight()

-- Config
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
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)

local btnPanel = Instance.new("Frame")
btnPanel.Size = UDim2.new(1, 0, 0, 35)
btnPanel.Position = UDim2.new(0, 0, 0, 35)
btnPanel.BackgroundTransparency = 1
btnPanel.Parent = configFrame

local function createConfigBtn(text, xPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, -3, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = btnPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
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
        if child:IsA("TextButton") then child:Destroy() end
    end
    local configs = GetConfigList()
    if not table.find(configs, "Default") then
        SaveConfig("Default")
        configs = GetConfigList()
    end
    local maxDisplay = 5
    local count = 0
    for _, name in ipairs(configs) do
        if count >= maxDisplay then break end
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
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            state.selectedConfigName = name
            nameBox.Text = name
            for _, child in pairs(configScroll:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        end)
        count = count + 1
    end
    configFrame.Size = UDim2.new(1, -10, 0, math.max(200, math.min(#configs, maxDisplay) * 35 + 100))
    UpdateFunctionsHeight()
end

createConfigBtn("Сохранить", 0, function()
    local name = nameBox.Text
    if name == "" then return end
    SaveConfig(name)
    nameBox.Text = ""
    state.selectedConfigName = ""
end)

createConfigBtn("Загрузить", 0.25, function()
    local name = nameBox.Text
    if name == "" then return end
    LoadConfig(name)
end)

createConfigBtn("Удалить", 0.5, function()
    local name = nameBox.Text
    if name == "" then return end
    if state.ConfigFolder:FindFirstChild(name) then
        state.ConfigFolder:FindFirstChild(name):Destroy()
    end
    state.Configs[name] = nil
    if state.CurrentConfig == name then state.CurrentConfig = "Default" end
    UpdateConfigList()
    nameBox.Text = ""
    state.selectedConfigName = ""
end)

createConfigBtn("Переимен.", 0.75, function()
    local oldName = nameBox.Text
    if oldName == "" or oldName == "Default" then return end
    local newName = oldName .. "_new"
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
        if state.CurrentConfig == oldName then state.CurrentConfig = newName end
        UpdateConfigList()
        nameBox.Text = ""
        state.selectedConfigName = ""
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    local mp = UserInputService:GetMouseLocation()
    local sd = input.Position.Z
    local ss = 30
    if state.isMenuVisible and mainFrame then
        local fp = mainFrame.AbsolutePosition
        local fs = mainFrame.AbsoluteSize
        if mp.X >= fp.X and mp.X <= fp.X + fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y + fs.Y then
            functionsPanel.CanvasPosition = Vector2.new(functionsPanel.CanvasPosition.X, functionsPanel.CanvasPosition.Y - sd * ss)
            return
        end
    end
    if state.bindListVisible and state.bindListFrame then
        local fp = state.bindListFrame.AbsolutePosition
        local fs = state.bindListFrame.AbsoluteSize
        if mp.X >= fp.X and mp.X <= fp.X + fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y + fs.Y then
            for _, child in pairs(state.bindListFrame:GetDescendants()) do
                if child:IsA("ScrollingFrame") and child.Visible then
                    child.CanvasPosition = Vector2.new(child.CanvasPosition.X, child.CanvasPosition.Y - sd * ss)
                end
            end
            return
        end
    end
end)

SetupGlobalBindHandler()

RunService.RenderStepped:Connect(function()
    local ch = player.Character
    if state.isSpeedEnabled and ch then
        local h = ch:FindFirstChild("Humanoid")
        if h and h.WalkSpeed ~= state.speedValue then h.WalkSpeed = state.speedValue end
    end
    if state.isFovEnabled and not state.isAspectEnabled then
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= state.fovValue then cam.FieldOfView = state.fovValue end
    end
end)

local function toggleMenu()
    if not state.keyAuthenticated then return end
    state.isMenuVisible = not state.isMenuVisible
    mainFrame.Visible = state.isMenuVisible
    if state.isMenuVisible then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then toggleMenu() end
end)

ContextActionService:BindActionAtPriority(
    "BlockEscapeMenu",
    function(_, istate, _)
        if istate == Enum.UserInputState.Begin then
            if state.isMenuVisible then toggleMenu() end
            return Enum.ContextActionResult.Sink
        end
    end,
    false, 9999, Enum.KeyCode.Escape
)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if state.isAspectEnabled then
        ApplyAspect()
    else
        cam.FieldOfView = state.isFovEnabled and state.fovValue or state.originalFov
    end
end)

player.CharacterAdded:Connect(function(ch)
    ch:WaitForChild("Humanoid")
    ch.Humanoid.WalkSpeed = state.isSpeedEnabled and state.speedValue or 16
    if state.isNoclipEnabled then EnableNoclip() end
    task.wait(0.1)
    ApplyFov()
    if state.isTimeEnabled then EnableTime() end
    if state.isFullBrightEnabled then EnableFullBright() end
    if state.isRemoveFogEnabled then EnableRemoveFog() end
    if state.isEspEnabled then EnableEsp() end
    if state.isAutoSkillcheckEnabled then EnableAutoSkillcheck() end
    if state.isInstaHealEnabled then EnableInstaHeal() end
    if state.isRecoveryHealEnabled then EnableRecoveryHeal() end
    if state.isGenHighlightEnabled and state.isEspEnabled then EnableGenHighlight() end
    if state.isGateHighlightEnabled and state.isEspEnabled then EnableGateHighlight() end
    if state.isPalletHighlightEnabled and state.isEspEnabled then EnablePalletHighlight() end
    if state.isWindowHighlightEnabled and state.isEspEnabled then EnableWindowHighlight() end
    if state.isHookHighlightEnabled and state.isEspEnabled then EnableHookHighlight() end
    DisableDash()
    DisableMoonwalk()
    DestroyDaggerCircle()
end)

task.wait(0.5)
state.originalBrightness = Lighting.Brightness
state.originalAmbient = Lighting.Ambient
state.originalTime = Lighting.ClockTime
state.originalFogEnd = Lighting.FogEnd
state.originalFogStart = Lighting.FogStart
local atm = Lighting:FindFirstChildOfClass("Atmosphere")
if atm then
    state.originalAtmDensity = atm.Density
    state.originalAtmHaze = atm.Haze
end

SaveConfig("Default")
UpdateConfigList()
ApplySpeed()
ApplyFov()
DisableTime()
DisableFullBright()
DisableRemoveFog()
DisableAspect()
DisableEsp()
DisableAutoSkillcheck()
DisableInstaHeal()
DisableRecoveryHeal()
DisableGenHighlight()
DisableGateHighlight()
DisablePalletHighlight()
DisableWindowHighlight()
DisableHookHighlight()
DisableDash()
DisableMoonwalk()
DisableAutoDagger()

-- ==================== KEYAUTH SYSTEM ====================
-- 🔑 Настройки KeyAuth (замени на свои значения из keyauth.cc)
local KEYAUTH_NAME    = "FlinPlay"           -- имя приложения
local KEYAUTH_OWNERID = "g6HInbRZtT"      -- Owner ID из настроек аккаунта
local KEYAUTH_VERSION = "1.0"              -- версия приложения

-- ✅ АКТУАЛЬНЫЙ API (1.3) — type передаётся в query-параметре
local KeyAuthAPI = "https://keyauth.win/api/1.3/"

local sessionId = game:GetService("HttpService"):GenerateGUID(false)
local hwid = "UNKNOWN"
pcall(function()
    hwid = game:GetService("RbxAnalyticsService"):GetClientId()
end)
if hwid == "UNKNOWN" or not hwid then
    hwid = "TEST_HWID_" .. tostring(player.UserId)
end

local KeyAuth = {
    initialized = false,
    authenticated = false,
    userData = nil,
}

-- Универсальный запрос к KeyAuth
local function kapi(endpoint, data)
    local params = "type=" .. endpoint
    -- sessionid добавляется ВО ВСЕ запросы, КРОМЕ init
    if endpoint ~= "init" then
        params = params .. "&sessionid=" .. sessionId
        params = params .. "&name=" .. KEYAUTH_NAME
        params = params .. "&ownerid=" .. KEYAUTH_OWNERID
    end
    if data then
        for k, v in pairs(data) do
            params = params .. "&" .. k .. "=" .. tostring(v)
        end
    end

    local url = KeyAuthAPI .. "?" .. params

    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success then
        return { success = false, message = "Ошибка сети: " .. tostring(response) }
    end

    local ok, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)

    if not ok then
        return { success = false, message = "Ошибка парсинга ответа" }
    end
    return decoded
end

-- Инициализация (без sessionid!)
local function keyauthInit()
    local res = kapi("init", {
        ver = KEYAUTH_VERSION,
        name = KEYAUTH_NAME,
        ownerid = KEYAUTH_OWNERID,
    })
    if res.success then
        KeyAuth.initialized = true
        -- ⚠️ Важно: сервер возвращает НОВЫЙ sessionid — используем его
        if res.sessionid and res.sessionid ~= "" then
            sessionId = res.sessionid
        end
        return true
    end
    return false, res.message or "Init failed"
end

-- Проверка лицензии
local function keyauthLicense(key)
    local res = kapi("license", {
        key = key,
        hwid = hwid,
    })
    if res.success then
        KeyAuth.authenticated = true
        KeyAuth.userData = res.info or {}
        return true
    end
    return false, res.message or "Invalid license"
end

-- Проверка статуса (для периодической валидации)
local function keyauthCheck()
    local res = kapi("check", { hwid = hwid })
    return res.success == true
end

-- ============ Key GUI ============
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "FlinKeyGui"
keyGui.Parent = playerGui
keyGui.ResetOnSpawn = false
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.DisplayOrder = 1000000

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 400, 0, 300)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2
stroke.Transparency = 0.3
stroke.Parent = keyFrame

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, 0, 0, 50)
kTitle.BackgroundTransparency = 1
kTitle.Text = "FLIN.CC"
kTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
kTitle.TextSize = 28
kTitle.Font = Enum.Font.GothamBlack
kTitle.Parent = keyFrame

local kSub = Instance.new("TextLabel")
kSub.Size = UDim2.new(1, 0, 0, 20)
kSub.Position = UDim2.new(0, 0, 0, 45)
kSub.BackgroundTransparency = 1
kSub.Text = "Введите лицензионный ключ"
kSub.TextColor3 = Color3.fromRGB(150, 150, 150)
kSub.TextSize = 12
kSub.Font = Enum.Font.GothamMedium
kSub.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -60, 0, 40)
keyInput.Position = UDim2.new(0, 30, 0, 85)
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
keyInput.Text = ""
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
keyInput.TextSize = 14
keyInput.Font = Enum.Font.GothamBold
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(60, 60, 60)
inputStroke.Thickness = 1
inputStroke.Parent = keyInput

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -60, 0, 40)
statusLabel.Position = UDim2.new(0, 30, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextWrapped = true
statusLabel.Parent = keyFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -60, 0, 42)
submitBtn.Position = UDim2.new(0, 30, 0, 180)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
submitBtn.BorderSizePixel = 0
submitBtn.Text = "АКТИВИРОВАТЬ"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize = 14
submitBtn.Font = Enum.Font.GothamBold
submitBtn.Parent = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

local buyBtn = Instance.new("TextButton")
buyBtn.Size = UDim2.new(1, -60, 0, 30)
buyBtn.Position = UDim2.new(0, 30, 0, 230)
buyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
buyBtn.BorderSizePixel = 0
buyBtn.Text = "Купить ключ → keyauth.cc"
buyBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
buyBtn.TextSize = 11
buyBtn.Font = Enum.Font.GothamMedium
buyBtn.Parent = keyFrame
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

buyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://keyauth.cc")
    end)
end)

submitBtn.MouseEnter:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 180, 230)}):Play()
end)
submitBtn.MouseLeave:Connect(function()
    TweenService:Create(submitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 200)}):Play()
end)

local isProcessing = false

local function onKeySuccess()
    statusLabel.Text = "✓ Ключ принят! Загрузка..."
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    task.wait(0.8)
    if keyGui then keyGui:Destroy() end
    state.keyAuthenticated = true
    state.isMenuVisible = true
    mainFrame.Visible = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    task.defer(function()
        if UpdateConfigList then UpdateConfigList() end
    end)
end

local function trySubmit()
    if isProcessing then return end
    local input = keyInput.Text
    if input == "" then
        statusLabel.Text = "Введите ключ!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    isProcessing = true
    submitBtn.Text = "ПРОВЕРКА..."
    submitBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    statusLabel.Text = "Соединение с сервером..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)

    -- Инициализация (один раз)
    if not KeyAuth.initialized then
        local ok, err = keyauthInit()
        if not ok then
            statusLabel.Text = "Ошибка init: " .. tostring(err)
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            submitBtn.Text = "АКТИВИРОВАТЬ"
            submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            isProcessing = false
            return
        end
    end

    -- Проверка лицензии
    local ok, err = keyauthLicense(input)
    if ok then
        onKeySuccess()
    else
        statusLabel.Text = "❌ " .. tostring(err)
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        submitBtn.Text = "АКТИВИРОВАТЬ"
        submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        local origPos = keyFrame.Position
        for i = 1, 6 do
            keyFrame.Position = origPos + UDim2.new(0, (i % 2 == 0) and 8 or -8, 0, 0)
            task.wait(0.03)
        end
        keyFrame.Position = origPos
        isProcessing = false
    end
end

submitBtn.MouseButton1Click:Connect(trySubmit)
keyInput.FocusLost:Connect(function(enter)
    if enter then trySubmit() end
end)

task.defer(function()
    if keyInput and keyInput.Parent then
        keyInput:CaptureFocus()
    end
end)

-- Периодическая проверка (каждые 5 минут)
task.spawn(function()
    while task.wait(300) do
        if KeyAuth.authenticated then
            local ok = keyauthCheck()
            if not ok then
                pcall(function() if keyGui then keyGui:Destroy() end end)
                if mainFrame then mainFrame.Visible = false end
                state.keyAuthenticated = false
                state.isMenuVisible = false
                local n = Instance.new("ScreenGui", playerGui)
                local lbl = Instance.new("TextLabel", n)
                lbl.Size = UDim2.new(0, 400, 0, 60)
                lbl.Position = UDim2.new(0.5, -200, 0.5, -30)
                lbl.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
                lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                lbl.Text = "Сессия истекла. Перезапустите скрипт."
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 14
                lbl.Parent = n
                break
            end
        end
    end
end)
