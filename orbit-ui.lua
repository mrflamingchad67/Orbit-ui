local Library = {}
Library.__index = Library

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(options)
	local windowTitle = options.Name or "Mega Hack"
	
	-- Main Screen Container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = HttpService:GenerateGUID(false)
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	-- Header Topbar Frame (Width trimmed down to 260px)
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "HeaderFrame"
	headerFrame.Size = UDim2.new(0, 260, 0, 32) 
	headerFrame.Position = UDim2.new(0.5, -130, 0.4, -15) 
	headerFrame.BackgroundColor3 = Color3.fromRGB(235, 48, 97) 
	headerFrame.BorderSizePixel = 0
	headerFrame.ZIndex = 2
	headerFrame.Parent = screenGui
	
	-- Dragging Logic Engine (Makes the full panel draggable smoothly)
	local dragging, dragInput, dragStart, startPos
	headerFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = headerFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	headerFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseBehavior then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			headerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Window Title Label (Perfect Auto-Center Layout using Scale 1)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 1, 0) -- Fills the width so any width change auto-centers text automatically
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = windowTitle
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 20
	titleLabel.Font = Enum.Font.ArialBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center 
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center 
	titleLabel.ZIndex = 2 
	titleLabel.Parent = headerFrame
	
	-- Flush-Corner Minimize Button Box (No left margin gaps, instant dark overlay on hover)
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.Size = UDim2.new(0, 40, 1, 0) 
	minimizeBtn.Position = UDim2.new(0, 0, 0, 0) 
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
	minimizeBtn.BackgroundTransparency = 1 
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Text = "—"
	minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeBtn.TextSize = 14 
	minimizeBtn.Font = Enum.Font.ArialBold
	minimizeBtn.TextXAlignment = Enum.TextXAlignment.Center 
	minimizeBtn.TextYAlignment = Enum.TextYAlignment.Center
	minimizeBtn.ZIndex = 3 
	minimizeBtn.Parent = headerFrame
	
	-- Main Content Background Body Frame (Your Panel Container)
	local containerFrame = Instance.new("Frame")
	containerFrame.Name = "ContainerFrame"
	containerFrame.Size = UDim2.new(1, 0, 0, 150) 
	containerFrame.Position = UDim2.new(0, 0, 1, 0) 
	containerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22) 
	containerFrame.BorderSizePixel = 0
	containerFrame.ZIndex = 1
	containerFrame.Parent = headerFrame
	
	-- Automatic Sorting Stack List Layout (Buttons added later will clean-stack automatically)
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.Parent = containerFrame
	
	-- Spacing padding interior border
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.Parent = containerFrame
	
	-- Toggle Visibility Action Logic
	local open = true
	minimizeBtn.MouseEnter:Connect(function() minimizeBtn.BackgroundTransparency = 0.85 end)
	minimizeBtn.MouseLeave:Connect(function() minimizeBtn.BackgroundTransparency = 1 end)
	minimizeBtn.MouseButton1Click:Connect(function()
		open = not open
		containerFrame.Visible = open
	end)
	
	-- Empty handler ready for your future function extensions!
	local WindowHandler = {}
	return WindowHandler
end

return Library
