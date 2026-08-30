local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService('UserInputService')
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

if game.PlaceId ~= 5846387555 then
    local message = Instance.new('Message', workspace)
    message.Text = "Hey, you're in the wrong place. This only works in studio mode."
    return
end

do
    local OldUI = CoreGui:FindFirstChild("AutoBuildGui")
    if OldUI then OldUI:Destroy() end
end

warn('Script Loaded')

local RetroStudio = ReplicatedStorage:WaitForChild("_RetroStudio")
local Remotes = RetroStudio:WaitForChild("Remotes")

local CreateObjectEvent = Remotes:WaitForChild("CreateObject")
local ObjectPropertyChangeRequestEvent = Remotes:WaitForChild("ObjectPropertyChangeRequested")
local BulkMoveToRequest = Remotes:FindFirstChild("BulkMoveToRequest")
local MiscObjectInteraction = Remotes:FindFirstChild("MiscObjectInteraction")

local HashLib_m = require(RetroStudio:WaitForChild("HashLib"))

local function Hash(arg)
    return HashLib_m.md5(`\224\182\158{arg}\224\182\158`)
end

local uiSuccess, uiCode = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/UI.lua")
end)

if not uiSuccess then
	return warn("Failed to fetch UI.lua.")
end

local uiFunc = loadstring(uiCode)

if not uiFunc then
	return warn("Syntax error inside UI.lua.")
end

local uiResult = uiFunc()

local AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound

if type(uiResult) == "function" then
	AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound = uiResult()
else
	AutoBuildGui, MainFrame, TitleLabel, ModelBox, NameBox, StartButton, FartSound =
		uiResult, nil, nil, nil, nil, nil, nil
end


local propSuccess, propCode = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/Properties.lua")
end)

if not propSuccess then
	return warn("Failed to fetch Properties.lua.")
end

local propFunc = loadstring(propCode)

if not propFunc then
	return warn("Syntax error inside Properties.lua.")
end

local Properties = propFunc()


--// ModelFingerprint

local fingerprintSuccess, fingerprintCode = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/playingNothin/RetroStudio-Auto-Build/refs/heads/main/ModelFingerprint.lua")
end)

if not fingerprintSuccess then
	return warn("Failed to fetch ModelFingerprint.lua.")
end

local fingerprintFunc = loadstring(fingerprintCode)

if not fingerprintFunc then
	return warn("Syntax error inside ModelFingerprint.lua.")
end

local ModelFingerprint = fingerprintFunc()

if type(ModelFingerprint) ~= "table" then
	return warn("ModelFingerprint.lua did not return a module table.")
end


print("Successfully loaded UI, Properties, and ModelFingerprint!")

local DELAY_TIME = 0.05 
local CreatedInstances = 0
local ModelCache = {}

local function CreateNewInstance(ClassName, Parent)
    task.wait(DELAY_TIME)
    local clock = os.clock()
    local securityHash = Hash(clock)

    local Success, Result = pcall(CreateObjectEvent.InvokeServer, CreateObjectEvent, ClassName, Parent, securityHash, clock)
    CreatedInstances = CreatedInstances + 1
    return Result
end

local function SetInstanceProperty(Object, PropertyName, NewValue)
    ObjectPropertyChangeRequestEvent:FireServer(Object, PropertyName, NewValue)
end

local function ScanModel(Model, ServerParent)
	if not ServerParent then
		ServerParent = CreateNewInstance(Model.ClassName, workspace)
		task.spawn(SetInstanceProperty, ServerParent, "Name", Model.Name)
	end

	for _, Child in ipairs(Model:GetChildren()) do
		local expectedPartCount = 0
		local cacheKey = nil

		if Child:IsA("Model") then
			-- Still use part count for waiting on the duplicated model.
			for _, bp in ipairs(Child:GetDescendants()) do
				if bp:IsA("BasePart") then
					expectedPartCount += 1
				end
			end

			-- The fingerprint is now the actual cache key.
			-- Unlike Child.Name + part count, this checks the model's
			-- internal structure and geometry.
			cacheKey = ModelFingerprint.Create(Child)

			if ModelCache[cacheKey] and MiscObjectInteraction and BulkMoveToRequest then
				local OriginalServerInstance = ModelCache[cacheKey]
				local DuplicatedInstance = nil
				local connection

				connection = OriginalServerInstance.Parent.ChildAdded:Connect(function(newChild)
					if newChild.Name == OriginalServerInstance.Name then
						DuplicatedInstance = newChild
					end
				end)

				-- Duplicate the cached model.
				MiscObjectInteraction:FireServer(
					{OriginalServerInstance},
					"Duplicate"
				)

				local spawnTimeout = os.clock()

				repeat
					task.wait(0.1)
				until DuplicatedInstance
					or (os.clock() - spawnTimeout > 10)

				connection:Disconnect()

				if DuplicatedInstance then
	-- Wait until client receives all replicated parts
	local serverParts = {}
	local repTimeout = os.clock()

	repeat
		task.wait(0.1)
		serverParts = {}

		for _, sp in ipairs(DuplicatedInstance:GetDescendants()) do
			if sp:IsA("BasePart") then
				table.insert(serverParts, sp)
			end
		end
	until #serverParts >= expectedPartCount
		or (os.clock() - repTimeout > 10)

	-- KEEP YOUR EXISTING POSITIONING CODE EXACTLY AS IT WAS
	local targetCFrame = Child:GetBoundingBox()
	local originalCFrame = OriginalServerInstance:GetBoundingBox()
	local offset = targetCFrame * originalCFrame:Inverse()

	local moveParts = {}
	local targetCFrames = {}

	for _, sp in ipairs(serverParts) do
		table.insert(moveParts, sp)
		table.insert(targetCFrames, offset * sp.CFrame)
	end

	if #moveParts > 0 then
		pcall(function()
			BulkMoveToRequest:InvokeServer(
				moveParts,
				targetCFrames,
				{}
			)
		end)
	end

	-- ONLY ADD THIS
	DuplicatedInstance.Parent = ServerParent

	task.wait(0.5)
else
	warn("Duplication timed out for: " .. Child.Name)
end

				continue
			end
		end

		local Props = Properties[Child.ClassName]

		if not Props then
			continue
		end

		local NewObject = CreateNewInstance(
			Child.ClassName,
			ServerParent
		)

		local IsAnchored = Child:GetAttribute("Anchored")

		if IsAnchored ~= nil then
			Child.Anchored = IsAnchored
		end

		-- Store the first encountered model with this fingerprint.
		if Child:IsA("Model") and cacheKey and not ModelCache[cacheKey] then
			ModelCache[cacheKey] = NewObject
		end

		local needsMesh = false
		local clampedSize = nil

		local hasExistingMesh =
			Child:FindFirstChildOfClass("SpecialMesh")
			or Child:FindFirstChildOfClass("DataModelMesh")

		if Child:IsA("BasePart") then
			SetInstanceProperty(NewObject, "FormFactor", "Custom")

			if not hasExistingMesh
				and (
					Child.Size.X < 0.2
					or Child.Size.Y < 0.2
					or Child.Size.Z < 0.2
				)
			then
				needsMesh = true

				clampedSize = Vector3.new(
					math.max(0.2, Child.Size.X),
					math.max(0.2, Child.Size.Y),
					math.max(0.2, Child.Size.Z)
				)
			end
		end

		for _, Property in ipairs(Props) do
			local value = Child[Property]

			if Property == "Size" and needsMesh then
				value = clampedSize
			end

			SetInstanceProperty(
				NewObject,
				Property,
				value
			)
		end

		if needsMesh then
			local meshObj = CreateNewInstance(
				"SpecialMesh",
				NewObject
			)

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
	ModelCache = {}

	local Model = GetAssets(AssetId)
	if not Model then
		return
	end

	Model.Name = ModelName

	local StartTime = os.clock()
	CreatedInstances = 0

	warn('\n\n\nStarting! This may take a while depending on the size of your model.\n\n\nPlease be patient thanks :3\n\n\n')

	ScanModel(Model)

	warn(
		'\n\n\nFinished! Took ' ..
		math.round((os.clock() - StartTime) * 100) / 100 ..
		' seconds to create ' ..
		tostring(CreatedInstances) ..
		' instances.\n\n\n'
	)

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
