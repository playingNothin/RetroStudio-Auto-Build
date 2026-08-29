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

-- 1. Updated Paths to RetroStudio's new _RetroStudio folder structure
local RetroStudio = ReplicatedStorage:WaitForChild("_RetroStudio")
local Remotes = RetroStudio:WaitForChild("Remotes")

local CreateObjectEvent = Remotes:WaitForChild("CreateObject")
local ObjectPropertyChangeRequestEvent = Remotes:WaitForChild("ObjectPropertyChangeRequested")
-- Fallback in case ChangeHistoryInteractionRequested hasn't been moved yet
local CheckpointEvent = Remotes:FindFirstChild("ChangeHistoryInteractionRequested") or ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ChangeHistoryInteractionRequested")

-- 2. Require HashLib to bypass the InvokeServer security check
local HashLib_m = require(RetroStudio:WaitForChild("HashLib"))

local function Hash(arg)
    return HashLib_m.md5(`\224\182\158{arg}\224\182\158`)
end

print("Fetching UI and Properties...")

-- Safely grab the UI code
local uiSuccess, uiCode = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/UI.lua")
end)
if not uiSuccess or uiCode:find("404: Not Found") then
    return warn("Failed to fetch UI.lua. Is the GitHub repository set to Private?")
end

-- Safely compile the UI code
local uiFunc, compileError = loadstring(uiCode)
if not uiFunc then
    return warn("Syntax error inside UI.lua: " .. tostring(compileError))
end

-- Safely execute the UI code
-- Notice we handle both the ()() and () formats safely here
local uiResult = uiFunc()
local AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound
if type(uiResult) == "function" then
    AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound = uiResult()
else
    AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound = uiResult, nil, nil, nil, nil, nil, nil -- Adjust this depending on what your UI.lua actually returns
end


-- Safely grab the Properties code
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
print("Successfully loaded UI and Properties!")

-- ==========================================
-- BUILDER CONFIGURATION
-- ==========================================
local DELAY_TIME = 0.05 -- Increase this if you get kicked for creating objects too quickly!
local CreatedInstances = 0

local function CreateNewInstance(ClassName, Parent)
    -- YIELD TO PREVENT RATE LIMIT/KICK
    task.wait(DELAY_TIME)

    -- 3. Calculate clock and hash, and pass them as the 3rd and 4th arguments
    local clock = os.clock()
    local securityHash = Hash(clock)

    local Success, Result = pcall(CreateObjectEvent.InvokeServer, CreateObjectEvent, ClassName, Parent, securityHash, clock)
    CreatedInstances = CreatedInstances + 1

    if not Success then
        warn(Result)
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

        local NewObject = CreateNewInstance(Child.ClassName, ServerParent)
        local IsAnchored = Child:GetAttribute("Anchored")

        if IsAnchored ~= nil then
            Child.Anchored = IsAnchored
        end

        -- Check if part requires a SpecialMesh for sub-0.2 stud dimensions
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

        -- Apply properties (override Size with clamped size if using SpecialMesh workaround)
        for _,Property in ipairs(Props) do
            local value = Child[Property]
            if Property == "Size" and needsMesh then
                value = clampedSize
            end
            SetInstanceProperty(NewObject, Property, value)
        end

        -- Instantiate SpecialMesh and scale visual mesh down to target size
        if needsMesh then
            local meshObj = CreateNewInstance("SpecialMesh", NewObject)
            
            local meshType = Enum.MeshType.Brick
            if Child:IsA("WedgePart") then
                meshType = Enum.MeshType.Wedge
            elseif Child:IsA("Part") then
                pcall(function()
                    if Child.Shape == Enum.PartType.Ball then
                        meshType = Enum.MeshType.Sphere
                    elseif Child.Shape == Enum.PartType.Cylinder then
                        meshType = Enum.MeshType.Cylinder
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

    if not Model then return end

    Model.Name = ModelName
    local StartTime = os.clock()
    CreatedInstances = 0
    
    warn('\n\n\nStarting! This may take a while depending on the size of your model.\n\n\nPlease be patient thanks :3\n\n\n')
    --SetCheckpoint()
    ScanModel(Model)
    --SetCheckpoint()
    warn('\n\n\nFinished! Took ' .. math.round((os.clock() - StartTime) * 100) / 100 .. ' seconds to create '.. tostring(CreatedInstances) .. ' instances.\n\n\n')
    
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
-- First attempt: Completely disable the game's idle kick if the executor supports it
local success, err = pcall(function()
    for _, connection in pairs(getconnections(Player.Idled)) do
        connection:Disable()
    end
end)

-- Second attempt: Fallback to the improved VirtualUser clicking method
Player.Idled:Connect(function()
    -- CaptureController helps this register even when tabbed out
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
    
    -- Classic backup movement
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    
    print("Anti-AFK triggered to prevent disconnection.")
end)

return {}
