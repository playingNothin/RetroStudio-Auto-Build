-- Services:
local CoreGui = game:GetService('CoreGui')

-- Instances:
local AutoBuildGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local StartButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local AssetID = Instance.new("TextBox")
local UICorner_3 = Instance.new("UICorner")
local ModelName = Instance.new("TextBox")
local UICorner_4 = Instance.new("UICorner")
local LogContainer = Instance.new("ScrollingFrame")
local LogCorner = Instance.new("UICorner")
local LogLayout = Instance.new("UIListLayout")
local FartSound = Instance.new('Sound')

--Properties:
AutoBuildGui.Name = "AutoBuildGui"
AutoBuildGui.Parent = CoreGui
AutoBuildGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = AutoBuildGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 189, 0, 300) -- Expanded height for logs
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Size = UDim2.new(0, 189, 0, 18)
Title.Font = Enum.Font.GothamBlack
Title.Text = "RetroStudio"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

UICorner.Parent = MainFrame

AssetID.Name = "AssetID"
AssetID.Parent = MainFrame
AssetID.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AssetID.BorderSizePixel = 0
AssetID.Position = UDim2.new(0, 14, 0, 30)
AssetID.Size = UDim2.new(0, 161, 0, 30)
AssetID.ClearTextOnFocus = false
AssetID.Font = Enum.Font.GothamSemibold
AssetID.PlaceholderText = "Asset ID..."
AssetID.Text = ""
AssetID.TextColor3 = Color3.fromRGB(255, 255, 255)
AssetID.TextSize = 14.000

UICorner_3.Parent = AssetID

ModelName.Name = "ModelName"
ModelName.Parent = MainFrame
ModelName.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ModelName.BorderSizePixel = 0
ModelName.Position = UDim2.new(0, 14, 0, 65)
ModelName.Size = UDim2.new(0, 161, 0, 30)
ModelName.ClearTextOnFocus = false
ModelName.Font = Enum.Font.GothamSemibold
ModelName.PlaceholderText = "Model Name..."
ModelName.Text = ""
ModelName.TextColor3 = Color3.fromRGB(255, 255, 255)
ModelName.TextSize = 14.000

UICorner_4.Parent = ModelName

StartButton.Name = "StartButton"
StartButton.Parent = MainFrame
StartButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StartButton.BorderSizePixel = 0
StartButton.Position = UDim2.new(0, 14, 0, 105)
StartButton.Size = UDim2.new(0, 161, 0, 27)
StartButton.Font = Enum.Font.GothamBlack
StartButton.Text = "AUTO BUILD"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 14.000

UICorner_2.Parent = StartButton

LogContainer.Name = "LogContainer"
LogContainer.Parent = MainFrame
LogContainer.Active = true
LogContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LogContainer.BorderSizePixel = 0
LogContainer.Position = UDim2.new(0, 14, 0, 140)
LogContainer.Size = UDim2.new(0, 161, 0, 145)
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogContainer.ScrollBarThickness = 4

LogCorner.Parent = LogContainer

LogLayout.Name = "LogLayout"
LogLayout.Parent = LogContainer
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder

FartSound.Name = "FartSound"
FartSound.Parent = CoreGui
FartSound.Volume = (math.random(1, 10)/math.random(1, 10))

return function()
	return AutoBuildGui, MainFrame, Title, AssetID, ModelName, StartButton, FartSound, LogContainer
end
