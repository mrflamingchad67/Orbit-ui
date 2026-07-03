-- Create the Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegaHackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Create the Header Frame
local headerFrame = Instance.new("Frame")
headerFrame.Name = "HeaderFrame"
headerFrame.Size = UDim2.new(0, 260, 0, 32) 
headerFrame.Position = UDim2.new(0.5, -130, 0.4, 0) 
headerFrame.BackgroundColor3 = Color3.fromRGB(235, 48, 97) 
headerFrame.BorderSizePixel = 0
headerFrame.Parent = screenGui

-- "Mega Hack" Text Label (Perfectly Bold & Auto-Centered)
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 1, 0) -- Fills the frame so it remains perfectly centered
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Mega Hack"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 21 -- Made text big
titleLabel.Font = Enum.Font.ArialBold -- Reliable fallback that supports extreme bolding naturally

titleLabel.TextXAlignment = Enum.TextXAlignment.Center 
titleLabel.TextYAlignment = Enum.TextYAlignment.Center 
titleLabel.ZIndex = 1 
titleLabel.Parent = headerFrame

-- Minimize Button Box (Flush edge boundary alignment)
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
minimizeBtn.ZIndex = 2 
minimizeBtn.Parent = headerFrame

----------------------------------------------------------------
-- INSTANT HOVER LOGIC
----------------------------------------------------------------
minimizeBtn.MouseEnter:Connect(function()
	minimizeBtn.BackgroundTransparency = 0.85 
end)

minimizeBtn.MouseLeave:Connect(function()
	minimizeBtn.BackgroundTransparency = 1
end)

-- Click Connection
minimizeBtn.MouseButton1Click:Connect(function()
	print("Minimize clicked!")
end)
