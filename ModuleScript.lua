local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService('UserInputService')
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local FartSounds = {
    "rbxassetid://1995953620",
    "rbxassetid://4858245620",
    "rbxassetid://4761049714",
    "rbxassetid://5673473298",
    "rbxassetid://174658105",
    "rbxassetid://5316091696",
    "rbxassetid://4376814302"
}

if game.PlaceId ~= 5846387555 then
    local message = Instance.new('Message', workspace)
    message.Text = "Hey, you're in the wrong place. This only works in studio mode."
    return
end

do
    local OldUI = CoreGui:FindFirstChild("AutoBuildGui")
    if OldUI then
        OldUI:Destroy()
    end
end

warn('Script Loaded')

local RetroStudio = ReplicatedStorage:WaitForChild("_RetroStudio")
local Remotes = RetroStudio:WaitForChild("Remotes")

local CreateObjectEvent = Remotes:WaitForChild("CreateObject")
local ObjectPropertyChangeRequestEvent = Remotes:WaitForChild("ObjectPropertyChangeRequested")
local CheckpointEvent = Remotes:FindFirstChild("ChangeHistoryInteractionRequested") or ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ChangeHistoryInteractionRequested")

local HashLib_m = require(RetroStudio:WaitForChild("HashLib"))

local function Hash(arg)
    return HashLib_m.md5(`\224\182\158{arg}\224\182\158`)
end

print("Fetching UI and Properties...")

local uiSuccess, uiCode = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/UI.lua")
end)
if not uiSuccess or uiCode:find("404: Not Found") then
    return warn("Failed to fetch UI.lua. Is the GitHub repository set to Private?")
end

local uiFunc, compileError = loadstring(uiCode)
if not uiFunc then
    return warn("Syntax error inside UI.lua: " .. tostring(compileError))
end

local uiResult = uiFunc()
local AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound, LogContainer
if type(uiResult) == "function" then
    AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound, LogContainer = uiResult()
else
    AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound, LogContainer = uiResult, nil, nil, nil, nil, nil, nil, nil
end

local propSuccess, propCode = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/Properties.lua")
end)
if not propSuccess or propCode:find("404: Not Found") then
    return warn("Failed to fetch Properties.lua. Is the GitHub repository set to Private?")
end

local propFunc, propCompileError = loadstring(propCode)
if not propFunc then
    return warn("Syntax error inside Properties.lua: " .. tostring(propCompileError))
end

local Properties = propFunc()

-- ==========================================
-- LOGGING SYSTEM
-- ==========================================
local UIListLayout = LogContainer and LogContainer:FindFirstChildOfClass("UIListLayout")

local function WriteLog(text, textColor)
    textColor = textColor or Color3.fromRGB(255, 255, 255)
    
    if not LogContainer then
        print("[Auto-Build] " .. text)
        return
    end

    local LogEntry = Instance.new("TextLabel")
    LogEntry.Name = "LogEntry"
    LogEntry.BackgroundTransparency = 1
    LogEntry.Size = UDim2.new(1, 0, 0, 16)
    LogEntry.Font = Enum.Font.Code
    LogEntry.TextSize = 12
    LogEntry.TextColor3 = textColor
    LogEntry.TextXAlignment = Enum.TextXAlignment.Left
    LogEntry.TextWrapped = true
    LogEntry.Text = text
    LogEntry.Parent = LogContainer

    task.spawn(function()
        task.wait()
        if UIListLayout then
            LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end
        LogContainer.CanvasPosition = Vector2.new(0, 99999)
    end)
end

WriteLog("Successfully loaded UI and Properties!", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- BUILDER CONFIGURATION
-- ==========================================
local DELAY_TIME = 0.05
local CreatedInstances = 0

local function CreateNewInstance(ClassName, Parent)
    task.wait(DELAY_TIME)

    local clock = os.clock()
    local securityHash = Hash(clock)

    local Success, Result = pcall(CreateObjectEvent.InvokeServer, CreateObjectEvent, ClassName, Parent, securityHash, clock)
    CreatedInstances = CreatedInstances + 1

    if not Success then
        WriteLog("ERROR: " .. tostring(Result), Color3.fromRGB(255, 50, 50))
    end

    return Result
end

local function SetInstanceProperty(Object, PropertyName, NewValue)
    ObjectPropertyChangeRequestEvent:FireServer(Object, PropertyName, NewValue)
end

local function SetCheckpoint()
    if CheckpointEvent then
        CheckpointEvent:FireServer("AddCheckpoint")
    end
end

local function ScanModel(Model, ServerParent)
    if not ServerParent then
        ServerParent = CreateNewInstance(Model.ClassName, workspace)
        task.spawn(SetInstanceProperty, ServerParent, "Name", Model.Name)
    end

    for _,Child in ipairs(Model:GetChildren()) do
        local Props = Properties[Child.ClassName]
        
        if not Props then
            continue
        end

        local targetClassName = Child.ClassName
        if targetClassName == "Part" then
            pcall(function()
                if tostring(Child.Shape):find("Wedge") then
                    targetClassName = "WedgePart"
                end
            end)
        end

        local NewObject = CreateNewInstance(targetClassName, ServerParent)
        local IsAnchored = Child:GetAttribute("Anchored")

        if IsAnchored ~= nil then
            Child.Anchored = IsAnchored
        end

        local needsMesh = false
        local clampedSize = nil
        local hasExistingMesh = Child:FindFirstChildOfClass("SpecialMesh") or Child:FindFirstChildOfClass("DataModelMesh")

        if Child:IsA("BasePart") then
            SetInstanceProperty(NewObject, "FormFactor", "Custom")
            
            if not hasExistingMesh and (Child.Size.X < 0.2 or Child.Size.Y < 0.2 or Child.Size.Z < 0.2) then
                needsMesh = true
                clampedSize = Vector3.new(
                    math.max(0.2, Child.Size.X),
                    math.max(0.2, Child.Size.Y),
                    math.max(0.2, Child.Size.Z)
                )
            end
        end

        for _,Property in ipairs(Props) do
            local value = Child[Property]
            if Property == "Size" and needsMesh then
                value = clampedSize
            end
            
            if targetClassName == "WedgePart" and Property == "Shape" then
                continue
            end
            
            SetInstanceProperty(NewObject, Property, value)
        end

        if needsMesh then
            local meshObj = CreateNewInstance("SpecialMesh", NewObject)
            
            local meshType = Enum.MeshType.Brick
            if targetClassName == "WedgePart" or Child:IsA("WedgePart") then
                meshType = Enum.MeshType.Wedge
            elseif targetClassName == "Part" then
                pcall(function()
                    if Child.Shape == Enum.PartType.Ball then
                        meshType = Enum.MeshType.Sphere
                    elseif Child.Shape == Enum.PartType.Cylinder then
                        meshType = Enum.MeshType.Cylinder
                    elseif tostring(Child.Shape):find("Wedge") then
                        meshType = Enum.MeshType.Wedge
                    end
                end)
            end

            local scaleVector = Vector3.new(
                Child.Size.X / clampedSize.X,
                Child.Size.Y / clampedSize.Y,
                Child.Size.Z / clampedSize.Z
            )

            SetInstanceProperty(meshObj, "MeshType", meshType)
            SetInstanceProperty(meshObj, "Scale", scaleVector)
        end

        if IsAnchored ~= nil then
            Child.Anchored = true
        end

        ScanModel(Child, NewObject)
    end
end

local function GetAssets(AssetId)
    local Model = game:GetObjects("rbxassetid://"..AssetId)

    if not Model then return end

    Model = Model[1]

    for _,Object in ipairs(Model:GetDescendants()) do
        pcall(function()
            Object:SetAttribute("Anchored", Object.Anchored)
            Object.Anchored = true
        end)
    end

    return Model
end

local function Start(AssetId, ModelName)
    local Model = GetAssets(AssetId)

    if not Model then 
        WriteLog("Failed to load Asset ID: " .. tostring(AssetId), Color3.fromRGB(255, 50, 50))
        return 
    end

    Model.Name = ModelName
    local StartTime = os.clock()
    CreatedInstances = 0
    
    WriteLog("Starting! This may take a while...", Color3.fromRGB(255, 255, 50))
    ScanModel(Model)
    
    local TotalTime = math.round((os.clock() - StartTime) * 100) / 100
    WriteLog("Finished! Took " .. TotalTime .. "s to create " .. tostring(CreatedInstances) .. " instances.", Color3.fromRGB(50, 255, 255))
    
    Model:Destroy()
end

local function Init()
    local AssetId = tonumber(ModelBox.Text) or 0
    local ModelName = tostring(NameBox.Text) or 'Model'
    Start(AssetId, ModelName)
end

StartButton.Activated:Connect(Init)

UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Insert then
        AutoBuildGui.Enabled = not AutoBuildGui.Enabled
    end
end)

-- ==========================================
-- ANTI-AFK SYSTEM
-- ==========================================
local success, err = pcall(function()
    for _, connection in pairs(getconnections(Player.Idled)) do
        connection:Disable()
    end
end)

Player.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
    
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    
    WriteLog("Anti-AFK triggered to prevent disconnection.", Color3.fromRGB(150, 150, 150))
end)

return {}
