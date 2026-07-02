-- Orbit UI Bundled Release 
 
package.preload['controls.button'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Button.lua
-- Version: 1.0.0

local Button = {}
Button.__index = Button

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type ButtonOptions = {
	Text: string,
	Callback: () -> (),
}

export type ButtonInstance = {
	Options: ButtonOptions,
	Frame: Frame,
	ButtonFrame: TextButton,
	ThemeConnection: RBXScriptConnection?,
}

function Button.new(options: ButtonOptions, parent: Instance): ButtonInstance
	local self = setmetatable({}, Button) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options

	-- Outer Container
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_ButtonWrapper",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	-- Interactable Button Frame
	self.ButtonFrame = Utility:Create("TextButton", {
		Name = "Button",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
		Parent = self.Frame
	})

	local uiCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.ButtonFrame
	})

	local uiStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.ButtonFrame
	})

	-- Interaction Ripples
	Utility:CreateRipple(self.ButtonFrame, activeTheme.AccentColor)

	-- Hover Visual States
	self.ButtonFrame.MouseEnter:Connect(function()
		Animation:HoverColor(self.ButtonFrame, Theme:GetActiveTheme().BackgroundSecondary)
		Animation:HoverColor(uiStroke, Theme:GetActiveTheme().AccentColor)
	end)

	self.ButtonFrame.MouseLeave:Connect(function()
		Animation:HoverColor(self.ButtonFrame, Theme:GetActiveTheme().BackgroundTertiary)
		Animation:HoverColor(uiStroke, Theme:GetActiveTheme().BorderColor)
	end)

	self.ButtonFrame.MouseButton1Click:Connect(function()
		task.spawn(options.Callback)
	end)

	-- Theme Synchronization
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.ButtonFrame.BackgroundColor3 = updatedTheme.BackgroundTertiary
		self.ButtonFrame.TextColor3 = updatedTheme.TextColor
		uiStroke.Color = updatedTheme.BorderColor
	end)

	return self
end

function Button:SetText(text: string)
	self.ButtonFrame.Text = text
end

function Button:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Button 
end 
 
package.preload['controls.colorpicker'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/ColorPicker.lua
-- Version: 1.0.0

local ColorPicker = {}
ColorPicker.__index = ColorPicker

-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type ColorPickerOptions = {
	Text: string,
	Default: Color3,
	Callback: (Color3) -> (),
}

export type ColorPickerInstance = {
	Value: Color3,
	IsOpen: boolean,
	Options: ColorPickerOptions,
	Frame: Frame,
	Label: TextLabel,
	DisplayButton: TextButton,
	DropdownPanel: Frame,
	SatValCanvas: Frame,
	SatValCursor: Frame,
	HueSlider: Frame,
	HueCursor: Frame,
	ActiveSatValDragging: boolean,
	ActiveHueDragging: boolean,
	CurrentHue: number,
	CurrentSat: number,
	CurrentVal: number,
	ThemeConnection: RBXScriptConnection?,
}

function ColorPicker.new(options: ColorPickerOptions, parent: Instance): ColorPickerInstance
	local self = setmetatable({}, ColorPicker) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options
	self.Value = options.Default or Color3.fromRGB(255, 0, 0)
	self.IsOpen = false
	self.ActiveSatValDragging = false
	self.ActiveHueDragging = false

	local h, s, v = Color3.toHSV(self.Value)
	self.CurrentHue = h
	self.CurrentSat = s
	self.CurrentVal = v

	-- Component Container Outer Wrapper Frame
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_ColorPickerWrapper",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = parent
	})

	self.Label = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Visual status container displaying current selection color
	self.DisplayButton = Utility:Create("TextButton", {
		Name = "DisplayButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 18),
		BackgroundColor3 = self.Value,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Frame
	})

	local displayCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.DisplayButton
	})

	local displayStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.DisplayButton
	})

	-- Floating popout contextual configuration selection sub-panel block
	self.DropdownPanel = Utility:Create("Frame", {
		Name = "PickerDropdown",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 1, 4),
		Size = UDim2.new(0, 150, 0, 0),
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 12,
		Parent = self.DisplayButton
	})

	local dropdownCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.DropdownPanel
	})

	local dropdownStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.DropdownPanel
	})

	-- Saturation and Value 2D Matrix Grid Area Selection Anchor Point Node Block
	self.SatValCanvas = Utility:Create("Frame", {
		Name = "SatValCanvas",
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(0, 114, 0, 114),
		BackgroundColor3 = Color3.fromHSV(self.CurrentHue, 1, 1),
		BorderSizePixel = 0,
		Parent = self.DropdownPanel
	})

	local satImage = Utility:Create("ImageLabel", {
		Name = "SaturationGradient",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4155801252",
		BorderSizePixel = 0,
		Parent = self.SatValCanvas
	})

	local valImage = Utility:Create("ImageLabel", {
		Name = "ValueGradient",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4155801391",
		BorderSizePixel = 0,
		Parent = self.SatValCanvas
	})

	self.SatValCursor = Utility:Create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 6, 0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = self.SatValCanvas
	})

	Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.SatValCursor
	})

	local cursorStroke = Utility:Create("UIStroke", {
		Color = Color3.new(0, 0, 0),
		Thickness = 1,
		Parent = self.SatValCursor
	})

	-- Vertical Hue Selection Rail Strip Slider Track Block Frame Anchor Point Frame Node
	self.HueSlider = Utility:Create("Frame", {
		Name = "HueSlider",
		Position = UDim2.new(0, 130, 0, 8),
		Size = UDim2.new(0, 12, 0, 114),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = self.DropdownPanel
	})

	local hueGradient = Utility:Create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = self.HueSlider
	})

	self.HueCursor = Utility:Create("Frame", {
		Name = "HueCursor",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -2, 0, 0),
		Size = UDim2.new(1, 4, 0, 4),
		BackgroundColor3 = Color3.new(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = self.HueSlider
	})

	local hueCursorStroke = Utility:Create("UIStroke", {
		Color = Color3.new(0, 0, 0),
		Thickness = 1,
		Parent = self.HueCursor
	})

	-- Dynamic positioning layout transformations updating alignment rendering tracking
	local function recalculateColor()
		self.Value = Color3.fromHSV(self.CurrentHue, self.CurrentSat, self.CurrentVal)
		self.DisplayButton.BackgroundColor3 = self.Value
		self.SatValCanvas.BackgroundColor3 = Color3.fromHSV(self.CurrentHue, 1, 1)
		
		self.SatValCursor.Position = UDim2.new(self.CurrentSat, 0, 1 - self.CurrentVal, 0)
		self.HueCursor.Position = UDim2.new(0, -2, self.CurrentHue, 0)
		
		task.spawn(options.Callback, self.Value)
	end

	local function processSatValInteraction(input: InputObject)
		local canvasSize = self.SatValCanvas.AbsoluteSize
		local canvasPos = self.SatValCanvas.AbsolutePosition
		local xPercent = math.clamp((input.Position.X - canvasPos.X) / canvasSize.X, 0, 1)
		local yPercent = math.clamp((input.Position.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
		
		self.CurrentSat = xPercent
		self.CurrentVal = 1 - yPercent
		recalculateColor()
	end

	local function processHueInteraction(input: InputObject)
		local sliderSize = self.HueSlider.AbsoluteSize.Y
		local sliderPos = self.HueSlider.AbsolutePosition.Y
		local yPercent = math.clamp((input.Position.Y - sliderPos) / sliderSize, 0, 1)
		
		self.CurrentHue = yPercent
		recalculateColor()
	end

	-- Input binding interaction streams execution setup hooks mapping
	self.SatValCanvas.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.ActiveSatValDragging = true
			processSatValInteraction(input)
			
			local moveConn: RBXScriptConnection? = nil
			local endConn: RBXScriptConnection? = nil

			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					if self.ActiveSatValDragging then processSatValInteraction(moveInput) end
				end
			end)

			endConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					self.ActiveSatValDragging = false
					if moveConn then moveConn:Disconnect() end
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end)

	self.HueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.ActiveHueDragging = true
			processHueInteraction(input)
			
			local moveConn: RBXScriptConnection? = nil
			local endConn: RBXScriptConnection? = nil

			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					if self.ActiveHueDragging then processHueInteraction(moveInput) end
				end
			end)

			endConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					self.ActiveHueDragging = false
					if moveConn then moveConn:Disconnect() end
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end)

	local function toggleDropdown(state: boolean)
		self.IsOpen = state
		if self.IsOpen then
			self.DropdownPanel.Visible = true
			Animation:ResizeTo(self.DropdownPanel, UDim2.new(0, 150, 0, 130), 0.15)
			Animation:HoverColor(displayStroke, Theme:GetActiveTheme().AccentColor)
		else
			local tween = Animation:ResizeTo(self.DropdownPanel, UDim2.new(0, 150, 0, 0), 0.15)
			Animation:HoverColor(displayStroke, Theme:GetActiveTheme().BorderColor)
			tween.Completed:Connect(function()
				if not self.IsOpen then self.DropdownPanel.Visible = false end
			end)
		end
	end

	self.DisplayButton.MouseButton1Click:Connect(function()
		toggleDropdown(not self.IsOpen)
	end)

	self.DisplayButton.MouseEnter:Connect(function()
		if not self.IsOpen then Animation:HoverColor(displayStroke, Theme:GetActiveTheme().AccentColor) end
	end)

	self.DisplayButton.MouseLeave:Connect(function()
		if not self.IsOpen then Animation:HoverColor(displayStroke, Theme:GetActiveTheme().BorderColor) end
	end)

	recalculateColor()

	-- Live Theme System Engine Updates Integration Map Contexts Linking
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Label.TextColor3 = updatedTheme.TextColor
		displayStroke.Color = self.IsOpen and updatedTheme.AccentColor or updatedTheme.BorderColor
		self.DropdownPanel.BackgroundColor3 = updatedTheme.BackgroundSecondary
		dropdownStroke.Color = updatedTheme.BorderColor
	end)

	return self
end

function ColorPicker:SetColor(targetColor: Color3)
	self.Value = targetColor
	local h, s, v = Color3.toHSV(targetColor)
	self.CurrentHue = h
	self.CurrentSat = s
	self.CurrentVal = v

	self.DisplayButton.BackgroundColor3 = self.Value
	self.SatValCanvas.BackgroundColor3 = Color3.fromHSV(self.CurrentHue, 1, 1)
	self.SatValCursor.Position = UDim2.new(self.CurrentSat, 0, 1 - self.CurrentVal, 0)
	self.HueCursor.Position = UDim2.new(0, -2, self.CurrentHue, 0)

	task.spawn(self.Options.Callback, self.Value)
end

function ColorPicker:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return ColorPicker 
end 
 
package.preload['controls.dropdown'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Dropdown.lua
-- Version: 1.0.0

local Dropdown = {}
Dropdown.__index = Dropdown

-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type DropdownOptions = {
	Text: string,
	Items: { string },
	Default: string?,
	Callback: (string) -> (),
}

export type DropdownInstance = {
	Selected: string?,
	IsOpen: boolean,
	Options: DropdownOptions,
	Frame: Frame,
	HeaderButton: TextButton,
	SelectedLabel: TextLabel,
	ArrowIcon: TextLabel,
	ListContainer: Frame,
	ThemeConnection: RBXScriptConnection?,
}

function Dropdown.new(options: DropdownOptions, parent: Instance): DropdownInstance
	local self = setmetatable({}, Dropdown) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options
	self.Selected = options.Default
	self.IsOpen = false

	-- Component Container Outer Wrapper Layout Frame Tracker
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_DropdownWrapper",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = parent
	})

	local inlineLabel = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Toggleable interaction node button row header configuration
	self.HeaderButton = Utility:Create("TextButton", {
		Name = "Header",
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Frame
	})

	local headerCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.HeaderButton
	})

	local headerStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.HeaderButton
	})

	self.SelectedLabel = Utility:Create("TextLabel", {
		Name = "SelectedLabel",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Selected or "Select option...",
		TextColor3 = self.Selected and activeTheme.TextColor or activeTheme.TextMuted,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.HeaderButton
	})

	self.ArrowIcon = Utility:Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = activeTheme.TextMuted,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextAlignment = Enum.TextXAlignment.Center,
		Parent = self.HeaderButton
	})

	-- Popout overlay viewport item scroll alignment list panel box mapping
	self.ListContainer = Utility:Create("Frame", {
		Name = "List",
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 10,
		Parent = self.HeaderButton
	})

	local listCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.ListContainer
	})

	local listStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.ListContainer
	})

	local listScrollingFrame = Utility:Create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = activeTheme.BorderColor,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self.ListContainer
	})

	Utility:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = listScrollingFrame
	})

	Utility:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		Parent = listScrollingFrame
	})

	-- Internal routing execution for context menus visibility adjustments tracking
	local function toggleDropdown(state: boolean)
		self.IsOpen = state
		self.ArrowIcon.Text = self.IsOpen and "▲" or "▼"
		
		if self.IsOpen then
			self.ListContainer.Visible = true
			local calculatedItemsHeight = (#options.Items * 30) + 8
			local maxHeightClamped = math.min(calculatedItemsHeight, 160)
			
			Animation:ResizeTo(self.ListContainer, UDim2.new(1, 0, 0, maxHeightClamped), 0.15)
			Animation:HoverColor(headerStroke, Theme:GetActiveTheme().AccentColor)
		else
			local tween = Animation:ResizeTo(self.ListContainer, UDim2.new(1, 0, 0, 0), 0.15)
			Animation:HoverColor(headerStroke, Theme:GetActiveTheme().BorderColor)
			tween.Completed:Connect(function()
				if not self.IsOpen then
					self.ListContainer.Visible = false
				end
			end)
		end
	end

	self.HeaderButton.MouseButton1Click:Connect(function()
		toggleDropdown(not self.IsOpen)
	end)

	-- Generate inner items selectable button fields mapping array elements list
	for index, itemName in ipairs(options.Items) do
		local itemButton = Utility:Create("TextButton", {
			Name = "Item_" .. itemName,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = activeTheme.BackgroundTertiary,
			BackgroundTransparency = 1,
			Text = itemName,
			TextColor3 = (self.Selected == itemName) and activeTheme.AccentColor or activeTheme.TextColor,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = index,
			AutoButtonColor = false,
			Parent = listScrollingFrame
		})

		Utility:Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = itemButton
		})

		Utility:Create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			Parent = itemButton
		})

		itemButton.MouseEnter:Connect(function()
			Animation:HoverColor(itemButton, Theme:GetActiveTheme().BackgroundTertiary, "BackgroundColor3", 0.1)
			itemButton.BackgroundTransparency = 0
		end)

		itemButton.MouseLeave:Connect(function()
			itemButton.BackgroundTransparency = 1
		end)

		itemButton.MouseButton1Click:Connect(function()
			self.Selected = itemName
			self.SelectedLabel.Text = itemName
			self.SelectedLabel.TextColor3 = Theme:GetActiveTheme().TextColor
			
			-- Update highlight visual alignments on selection change instances safely
			for _, child in ipairs(listScrollingFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child.TextColor3 = (child.Text == itemName) and Theme:GetActiveTheme().AccentColor or Theme:GetActiveTheme().TextColor
				end
			end
			
			toggleDropdown(false)
			task.spawn(options.Callback, itemName)
		end)
	end

	-- Connect structural layout hooks monitoring click alignments changes externally
	self.HeaderButton.MouseEnter:Connect(function()
		if not self.IsOpen then
			Animation:HoverColor(headerStroke, Theme:GetActiveTheme().AccentColor)
		end
	end)

	self.HeaderButton.MouseLeave:Connect(function()
		if not self.IsOpen then
			Animation:HoverColor(headerStroke, Theme:GetActiveTheme().BorderColor)
		end
	end)

	-- Theme engine updates alignment links routing execution updates hookups mapping
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		inlineLabel.TextColor3 = updatedTheme.TextColor
		self.HeaderButton.BackgroundColor3 = updatedTheme.BackgroundTertiary
		headerStroke.Color = self.IsOpen and updatedTheme.AccentColor or updatedTheme.BorderColor
		self.SelectedLabel.TextColor3 = self.Selected and updatedTheme.TextColor or updatedTheme.TextMuted
		self.ArrowIcon.TextColor3 = updatedTheme.TextMuted
		self.ListContainer.BackgroundColor3 = updatedTheme.BackgroundSecondary
		listStroke.Color = updatedTheme.BorderColor
		listScrollingFrame.ScrollBarImageColor3 = updatedTheme.BorderColor
	end)

	return self
end

function Dropdown:SetSelected(itemName: string)
	local activeTheme = Theme:GetActiveTheme()
	self.Selected = itemName
	self.SelectedLabel.Text = itemName
	self.SelectedLabel.TextColor3 = activeTheme.TextColor
	
	local scroll = self.ListContainer:FindFirstChild("Scroll")
	if scroll then
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child.TextColor3 = (child.Text == itemName) and activeTheme.AccentColor or activeTheme.TextColor
			end
		end
	end
	
	task.spawn(self.Options.Callback, itemName)
end

function Dropdown:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Dropdown 
end 
 
package.preload['controls.keybind'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Keybind.lua
-- Version: 1.0.0

local Keybind = {}
Keybind.__index = Keybind

-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type KeybindOptions = {
	Text: string,
	Default: Enum.KeyCode?,
	Callback: (Enum.KeyCode) -> (),
}

export type KeybindInstance = {
	Value: Enum.KeyCode?,
	IsBinding: boolean,
	Options: KeybindOptions,
	Frame: Frame,
	Label: TextLabel,
	BindButton: TextButton,
	BindLabel: TextLabel,
	InputConnection: RBXScriptConnection?,
	ThemeConnection: RBXScriptConnection?,
}

local AllowedMouseInputs = {
	[Enum.UserInputType.MouseButton1] = Enum.KeyCode.Unknown,
	[Enum.UserInputType.MouseButton2] = Enum.KeyCode.Unknown,
	[Enum.UserInputType.MouseButton3] = Enum.KeyCode.Unknown,
}

function Keybind.new(options: KeybindOptions, parent: Instance): KeybindInstance
	local self = setmetatable({}, Keybind) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options
	self.Value = options.Default or Enum.KeyCode.Unknown
	self.IsBinding = false

	-- Outer layout wrapper block row configuration frame alignment
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_KeybindWrapper",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	-- Primary descriptive label positioning
	self.Label = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -90, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Interaction tracking button capture field alignment block panel
	self.BindButton = Utility:Create("TextButton", {
		Name = "BindButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 80, 0, 24),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Frame
	})

	local buttonCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.BindButton
	})

	local buttonStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.BindButton
	})

	self.BindLabel = Utility:Create("TextLabel", {
		Name = "BindLabel",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Value and self.Value.Name or "None",
		TextColor3 = activeTheme.TextMuted,
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextAlignment = Enum.TextXAlignment.Center,
		Parent = self.BindButton
	})

	-- Start input binding capture processing loops sequence handlers
	local function beginBinding()
		if self.IsBinding then return end
		self.IsBinding = true
		self.BindLabel.Text = "..."
		self.BindLabel.TextColor3 = Theme:GetActiveTheme().AccentColor
		Animation:HoverColor(buttonStroke, Theme:GetActiveTheme().AccentColor)

		if self.InputConnection then self.InputConnection:Disconnect() end

		self.InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local chosenKey = Enum.KeyCode.Unknown
			
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					chosenKey = input.KeyCode
				end
			end

			-- Safely disconnect operational stream fields immediately upon data acquisition matching
			if self.InputConnection then
				self.InputConnection:Disconnect()
				self.InputConnection = nil
			end

			self.Value = chosenKey
			self.IsBinding = false
			self.BindLabel.Text = chosenKey == Enum.KeyCode.Unknown and "None" or chosenKey.Name
			self.BindLabel.TextColor3 = Theme:GetActiveTheme().TextMuted
			Animation:HoverColor(buttonStroke, Theme:GetActiveTheme().BorderColor)

			task.spawn(options.Callback, chosenKey)
		end)
	end

	self.BindButton.MouseButton1Click:Connect(beginBinding)

	-- Hover structural indicator layout assignments implementation mapping context
	self.BindButton.MouseEnter:Connect(function()
		if not self.IsBinding then
			Animation:HoverColor(buttonStroke, Theme:GetActiveTheme().AccentColor)
		end
	end)

	self.BindButton.MouseLeave:Connect(function()
		if not self.IsBinding then
			Animation:HoverColor(buttonStroke, Theme:GetActiveTheme().BorderColor)
		end
	end)

	-- Theme Engine Live update connectivity mapping architecture pipelines safely
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Label.TextColor3 = updatedTheme.TextColor
		self.BindButton.BackgroundColor3 = updatedTheme.BackgroundTertiary
		buttonStroke.Color = self.IsBinding and updatedTheme.AccentColor or updatedTheme.BorderColor
		self.BindLabel.TextColor3 = self.IsBinding and updatedTheme.AccentColor or updatedTheme.TextMuted
	end)

	return self
end

function Keybind:SetKey(key: Enum.KeyCode)
	self.Value = key
	self.BindLabel.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
	task.spawn(self.Options.Callback, key)
end

function Keybind:Destroy()
	if self.InputConnection then
		self.InputConnection:Disconnect()
		self.InputConnection = nil
	end
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Keybind 
end 
 
package.preload['controls.label'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Label.lua
-- Version: 1.0.0

local Label = {}
Label.__index = Label

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))

-- Types
export type LabelOptions = {
	Text: string,
}

export type LabelInstance = {
	Options: LabelOptions,
	Frame: Frame,
	TextLabel: TextLabel,
	ThemeConnection: RBXScriptConnection?,
}

function Label.new(options: LabelOptions, parent: Instance): LabelInstance
	local self = setmetatable({}, Label) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options

	-- Outer structural layout row
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_LabelWrapper",
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	-- Primary UI text element node alignment tracking text content
	self.TextLabel = Utility:Create("TextLabel", {
		Name = "TextLabel",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = self.Frame
	})

	-- Theme Engine connection management routing
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.TextLabel.TextColor3 = updatedTheme.TextColor
	end)

	return self
end

function Label:SetText(text: string)
	self.TextLabel.Text = text
end

function Label:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Label 
end 
 
package.preload['controls.paragraph'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Paragraph.lua
-- Version: 1.0.0

local Paragraph = {}
Paragraph.__index = Paragraph

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))

-- Types
export type ParagraphOptions = {
	Title: string,
	Content: string,
}

export type ParagraphInstance = {
	Options: ParagraphOptions,
	Frame: Frame,
	TitleLabel: TextLabel,
	ContentLabel: TextLabel,
	ThemeConnection: RBXScriptConnection?,
}

function Paragraph.new(options: ParagraphOptions, parent: Instance): ParagraphInstance
	local self = setmetatable({}, Paragraph) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options

	-- Outer block structural frame mapping automatic sizing configuration layout
	self.Frame = Utility:Create("Frame", {
		Name = options.Title .. "_ParagraphWrapper",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Parent = parent
	})

	local uiCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.Frame
	})

	local uiStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.Frame
	})

	local padding = Utility:Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = self.Frame
	})

	-- Block header title indicator alignment layout node element frame text properties
	self.TitleLabel = Utility:Create("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Title,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Body descriptive inline context text content configuration bounds node mapping
	self.ContentLabel = Utility:Create("TextLabel", {
		Name = "ContentLabel",
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = options.Content,
		TextColor3 = activeTheme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = self.Frame
	})

	-- Direct real-time theme changing adaptation signal hook links routing pipeline
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Frame.BackgroundColor3 = updatedTheme.BackgroundTertiary
		uiStroke.Color = updatedTheme.BorderColor
		self.TitleLabel.TextColor3 = updatedTheme.TextColor
		self.ContentLabel.TextColor3 = updatedTheme.TextMuted
	end)

	return self
end

function Paragraph:SetText(title: string, content: string)
	self.TitleLabel.Text = title
	self.ContentLabel.Text = content
end

function Paragraph:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Paragraph 
end 
 
package.preload['controls.slider'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Slider.lua
-- Version: 1.0.0

local Slider = {}
Slider.__index = Slider

-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type SliderOptions = {
	Text: string,
	Min: number,
	Max: number,
	Default: number,
	Callback: (number) -> (),
}

export type SliderInstance = {
	Value: number,
	Options: SliderOptions,
	Frame: Frame,
	Label: TextLabel,
	ValueLabel: TextLabel,
	SliderTrack: Frame,
	SliderFill: Frame,
	SliderThumb: Frame,
	ActiveDragging: boolean,
	ThemeConnection: RBXScriptConnection?,
}

function Slider.new(options: SliderOptions, parent: Instance): SliderInstance
	local self = setmetatable({}, Slider) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options
	self.Value = math.clamp(options.Default or options.Min, options.Min, options.Max)
	self.ActiveDragging = false

	-- Outer structural wrapper frame
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_SliderWrapper",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	-- Primary textual tracking identifier
	self.Label = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -60, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Live readout text node alignment monitoring numeric values
	self.ValueLabel = Utility:Create("TextLabel", {
		Name = "ValueLabel",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 60, 0, 18),
		BackgroundTransparency = 1,
		Text = tostring(self.Value),
		TextColor3 = activeTheme.TextMuted,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = self.Frame
	})

	-- Interactable Track Rail Frame
	self.SliderTrack = Utility:Create("Frame", {
		Name = "Track",
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Parent = self.Frame
	})

	local trackCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.SliderTrack
	})

	local trackStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.SliderTrack
	})

	-- Inner active progress metric fill alignment
	self.SliderFill = Utility:Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = activeTheme.AccentColor,
		BorderSizePixel = 0,
		Parent = self.SliderTrack
	})

	Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.SliderFill
	})

	-- Handle slider interactive thumb anchor node
	self.SliderThumb = Utility:Create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = activeTheme.TextColor,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = self.SliderTrack
	})

	Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.SliderThumb
	})

	local thumbStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		Parent = self.SliderThumb
	})

	-- Dynamic scaling positioning calculations updates
	local function renderPosition()
		local percentage = math.clamp((self.Value - options.Min) / (options.Max - options.Min), 0, 1)
		self.SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
		self.SliderThumb.Position = UDim2.new(percentage, 0, 0.5, 0)
		self.ValueLabel.Text = string.format("%.2f", self.Value):gsub("%.00$", "")
	end

	local function processInteraction(input: InputObject)
		local absoluteSize = self.SliderTrack.AbsoluteSize.X
		local absolutePos = self.SliderTrack.AbsolutePosition.X
		local relativeMouseX = input.Position.X - absolutePos
		local calculatedPercentage = math.clamp(relativeMouseX / absoluteSize, 0, 1)
		
		local rawValue = options.Min + (calculatedPercentage * (options.Max - options.Min))
		self.Value = math.clamp(rawValue, options.Min, options.Max)
		
		renderPosition()
		task.spawn(options.Callback, self.Value)
	end

	-- Input interaction detection engines loop
	self.SliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.ActiveDragging = true
			Animation:HoverColor(trackStroke, Theme:GetActiveTheme().AccentColor)
			processInteraction(input)
			
			local mouseMoveConn: RBXScriptConnection? = nil
			local mouseUpConn: RBXScriptConnection? = nil

			mouseMoveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					if self.ActiveDragging then
						processInteraction(moveInput)
					end
				end
			end)

			mouseUpConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					self.ActiveDragging = false
					Animation:HoverColor(trackStroke, Theme:GetActiveTheme().BorderColor)
					if mouseMoveConn then mouseMoveConn:Disconnect() end
					if mouseUpConn then mouseUpConn:Disconnect() end
				end
			end)
		end
	end)

	-- Hover mapping indicators configuration bounds logic
	self.SliderTrack.MouseEnter:Connect(function()
		if not self.ActiveDragging then
			Animation:HoverColor(trackStroke, Theme:GetActiveTheme().AccentColor)
		end
	end)

	self.SliderTrack.MouseLeave:Connect(function()
		if not self.ActiveDragging then
			Animation:HoverColor(trackStroke, Theme:GetActiveTheme().BorderColor)
		end
	end)

	-- Map initial starting value positional layouts rendering configurations
	renderPosition()

	-- Live runtime theme engine configuration bindings
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Label.TextColor3 = updatedTheme.TextColor
		self.ValueLabel.TextColor3 = updatedTheme.TextMuted
		self.SliderTrack.BackgroundColor3 = updatedTheme.BackgroundTertiary
		trackStroke.Color = updatedTheme.BorderColor
		self.SliderFill.BackgroundColor3 = updatedTheme.AccentColor
		self.SliderThumb.BackgroundColor3 = updatedTheme.TextColor
		thumbStroke.Color = updatedTheme.BorderColor
	end)

	return self
end

function Slider:SetValue(newValue: number)
	self.Value = math.clamp(newValue, self.Options.Min, self.Options.Max)
	local percentage = math.clamp((self.Value - self.Options.Min) / (self.Options.Max - self.Options.Min), 0, 1)
	
	self.SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
	self.SliderThumb.Position = UDim2.new(percentage, 0, 0.5, 0)
	self.ValueLabel.Text = string.format("%.2f", self.Value):gsub("%.00$", "")
	
	task.spawn(self.Options.Callback, self.Value)
end

function Slider:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Slider 
end 
 
package.preload['controls.textbox'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Textbox.lua
-- Version: 1.0.0

local Textbox = {}
Textbox.__index = Textbox

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type TextboxOptions = {
	Text: string,
	Placeholder: string?,
	Default: string?,
	ClearOnFocus: boolean?,
	Callback: (string) -> (),
}

export type TextboxInstance = {
	Text: string,
	Options: TextboxOptions,
	Frame: Frame,
	Label: TextLabel,
	InputBox: TextBox,
	ThemeConnection: RBXScriptConnection?,
}

function Textbox.new(options: TextboxOptions, parent: Instance): TextboxInstance
	local self = setmetatable({}, Textbox) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Options = options
	self.Text = options.Default or ""

	-- Component Container Outer Wrapper Layout Frame Tracker
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_TextboxWrapper",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	self.Label = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})

	-- Interactable Input Box Container Panel
	local inputContainer = Utility:Create("Frame", {
		Name = "InputContainer",
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Parent = self.Frame
	})

	local containerCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = inputContainer
	})

	local containerStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inputContainer
	})

	-- Direct Text Input Engine Node Instance setup
	self.InputBox = Utility:Create("TextBox", {
		Name = "Input",
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Text,
		PlaceholderText = options.Placeholder or "Type here...",
		PlaceholderColor3 = activeTheme.TextMuted,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = (options.ClearOnFocus ~= nil) and options.ClearOnFocus or false,
		ClipsDescendants = true,
		Parent = inputContainer
	})

	-- Text execution routing callbacks map hooks initialization
	self.InputBox.FocusGained:Connect(function()
		Animation:HoverColor(containerStroke, Theme:GetActiveTheme().AccentColor)
	end)

	self.InputBox.FocusLost:Connect(function(enterPressed)
		Animation:HoverColor(containerStroke, Theme:GetActiveTheme().BorderColor)
		self.Text = self.InputBox.Text
		task.spawn(options.Callback, self.Text)
	end)

	-- Hover mapping structural configurations links
	inputContainer.MouseEnter:Connect(function()
		if not self.InputBox:IsFocused() then
			Animation:HoverColor(containerStroke, Theme:GetActiveTheme().AccentColor)
		end
	end)

	inputContainer.MouseLeave:Connect(function()
		if not self.InputBox:IsFocused() then
			Animation:HoverColor(containerStroke, Theme:GetActiveTheme().BorderColor)
		end
	end)

	-- Theme Engine Live Adaptability Hook links connection pipeline routing
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Label.TextColor3 = updatedTheme.TextColor
		inputContainer.BackgroundColor3 = updatedTheme.BackgroundTertiary
		containerStroke.Color = self.InputBox:IsFocused() and updatedTheme.AccentColor or updatedTheme.BorderColor
		self.InputBox.TextColor3 = updatedTheme.TextColor
		self.InputBox.PlaceholderColor3 = updatedTheme.TextMuted
	end)

	return self
end

function Textbox:SetText(text: string)
	self.Text = text
	self.InputBox.Text = text
	task.spawn(self.Options.Callback, self.Text)
end

function Textbox:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Textbox 
end 
 
package.preload['controls.Toogle'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Controls/Toggle.lua
-- Version: 1.0.0

local Toggle = {}
Toggle.__index = Toggle

-- Modules
local Theme = require(script.Parent.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent.Parent:WaitForChild("Animation"))

-- Types
export type ToggleOptions = {
	Text: string,
	Default: boolean?,
	Callback: (boolean) -> (),
}

export type ToggleInstance = {
	State: boolean,
	Options: ToggleOptions,
	Frame: Frame,
	InteractButton: TextButton,
	Indicator: Frame,
	Label: TextLabel,
	ThemeConnection: RBXScriptConnection?,
}

function Toggle.new(options: ToggleOptions, parent: Instance): ToggleInstance
	local self = setmetatable({}, Toggle) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.State = options.Default or false
	self.Options = options

	-- Outer structural frame
	self.Frame = Utility:Create("Frame", {
		Name = options.Text .. "_ToggleWrapper",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = parent
	})

	-- Primary interactive row overlay
	self.InteractButton = Utility:Create("TextButton", {
		Name = "InteractButton",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Frame
	})

	-- Visual text node label
	self.Label = Utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -45, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Text,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.InteractButton
	})

	-- Desktop switch toggle well
	local track = Utility:Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 18),
		BackgroundColor3 = self.State and activeTheme.AccentColor or activeTheme.BackgroundTertiary,
		BorderSizePixel = 0,
		Parent = self.InteractButton
	})

	local trackCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = track
	})

	local trackStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = track
	})

	-- Dynamic switch pill thumb
	self.Indicator = Utility:Create("Frame", {
		Name = "Indicator",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = activeTheme.TextColor,
		BorderSizePixel = 0,
		Parent = track
	})

	Utility:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.Indicator
	})

	-- State Mutation Routine
	local function updateVisuals()
		local currentTheme = Theme:GetActiveTheme()
		local targetPos = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		local targetColor = self.State and currentTheme.AccentColor or currentTheme.BackgroundTertiary
		
		Animation:SlideTo(self.Indicator, targetPos, 0.15)
		Animation:HoverColor(track, targetColor, "BackgroundColor3", 0.15)
	end

	self.InteractButton.MouseButton1Click:Connect(function()
		self.State = not self.State
		updateVisuals()
		task.spawn(options.Callback, self.State)
	end)

	-- Hover Feedback mapping
	self.InteractButton.MouseEnter:Connect(function()
		Animation:HoverColor(trackStroke, Theme:GetActiveTheme().AccentColor, "Color", 0.15)
	end)

	self.InteractButton.MouseLeave:Connect(function()
		Animation:HoverColor(trackStroke, Theme:GetActiveTheme().BorderColor, "Color", 0.15)
	end)

	-- Theme updates engine integration
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Label.TextColor3 = updatedTheme.TextColor
		track.BackgroundColor3 = self.State and updatedTheme.AccentColor or updatedTheme.BackgroundTertiary
		trackStroke.Color = updatedTheme.BorderColor
		self.Indicator.BackgroundColor3 = updatedTheme.TextColor
	end)

	return self
end

function Toggle:SetState(state: boolean)
	if self.State == state then return end
	self.State = state
	
	local currentTheme = Theme:GetActiveTheme()
	local targetPos = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local targetColor = self.State and currentTheme.AccentColor or currentTheme.BackgroundTertiary
	
	Animation:SlideTo(self.Indicator, targetPos, 0.15)
	track.BackgroundColor3 = targetColor
	task.spawn(self.Options.Callback, self.State)
end

function Toggle:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Frame:Destroy()
end

return Toggle 
end 
 
package.preload['animation'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Animation.lua
-- Version: 1.0.0

local Animation = {}

local TweenService = game:GetService("TweenService")

-- Types
export type Animatable = Instance

-- Standard configuration for desktop utility aesthetic (snappy, smooth)
local STANDARD_DURATION = 0.2
local EASE_OUT_QUAD = TweenInfo.new(STANDARD_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_IN_OUT_CUBIC = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

function Animation:Tween(instance: Animatable, tweenInfo: TweenInfo, properties: { [string]: any }): Tween
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Animation:FadeIn(instance: Animatable, duration: number?): Tween
	local info = duration and TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or EASE_OUT_QUAD
	
	if instance:IsA("Frame") or instance:IsA("GuiObject") then
		local targetTransparency = 0
		if instance:IsA("ScrollingFrame") then
			instance.ScrollBarImageTransparency = 0
		end
		
		-- Look for CanvasGroup specific handling if needed, or handle standard background
		if instance:IsA("CanvasGroup") then
			return self:Tween(instance, info, { GroupTransparency = 0 })
		else
			return self:Tween(instance, info, { BackgroundTransparency = (instance:GetAttribute("TargetBackgroundTransparency") or 0) })
		end
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		return self:Tween(instance, info, { TextTransparency = 0 })
	elseif instance:IsA("UIStroke") then
		return self:Tween(instance, info, { Transparency = 0 })
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		return self:Tween(instance, info, { ImageTransparency = 0 })
	end
	
	return self:Tween(instance, info, { BackgroundTransparency = 0 })
end

function Animation:FadeOut(instance: Animatable, duration: number?): Tween
	local info = duration and TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or EASE_OUT_QUAD
	
	if instance:IsA("CanvasGroup") then
		return self:Tween(instance, info, { GroupTransparency = 1 })
	elseif instance:IsA("Frame") or instance:IsA("GuiObject") then
		if instance:IsA("ScrollingFrame") then
			self:Tween(instance, info, { ScrollBarImageTransparency = 1 })
		end
		return self:Tween(instance, info, { BackgroundTransparency = 1 })
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		return self:Tween(instance, info, { TextTransparency = 1 })
	elseif instance:IsA("UIStroke") then
		return self:Tween(instance, info, { Transparency = 1 })
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		return self:Tween(instance, info, { ImageTransparency = 1 })
	end
	
	return self:Tween(instance, info, { BackgroundTransparency = 1 })
end

function Animation:HoverColor(instance: Animatable, targetColor: Color3, propertyName: string?, duration: number?): Tween
	local info = duration and TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or EASE_OUT_QUAD
	local prop = propertyName or "BackgroundColor3"
	
	return self:Tween(instance, info, { [prop] = targetColor })
end

function Animation:SlideTo(instance: GuiObject, targetPosition: UDim2, duration: number?): Tween
	local info = duration and TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) or EASE_IN_OUT_CUBIC
	return self:Tween(instance, info, { Position = targetPosition })
end

function Animation:ResizeTo(instance: GuiObject, targetSize: UDim2, duration: number?): Tween
	local info = duration and TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) or EASE_IN_OUT_CUBIC
	return self:Tween(instance, info, { Size = targetSize })
end

return Animation 
end 
 
package.preload['config'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Config.lua
-- Version: 1.0.0

local Config = {}

local HttpService = game:GetService("HttpService")

-- Internal Configuration Database Storage Structure
local ConfigRegistry: { [string]: any } = {}
local AutoSaveEnabled = false
local ActiveSaveKey = "MegaUI_DefaultConfig"

function Config:Initialize()
	ConfigRegistry = {}
end

function Config:Set(key: string, value: any)
	ConfigRegistry[key] = value
	
	if AutoSaveEnabled then
		self:Save()
	end
end

function Config:Get(key: string, defaultValue: any): any
	if ConfigRegistry[key] ~= nil then
		return ConfigRegistry[key]
	end
	return defaultValue
end

function Config:EnableAutoSave(saveKey: string?)
	if saveKey then
		ActiveSaveKey = saveKey
	end
	AutoSaveEnabled = true
end

function Config:DisableAutoSave()
	AutoSaveEnabled = false
end

function Config:Save(): boolean
	local success, serializedData = pcall(function()
		return HttpService:JSONEncode(ConfigRegistry)
	end)
	
	if not success or not serializedData then 
		return false 
	end

	local writeSuccess = pcall(function()
		-- Workaround encapsulation allowing secure saving inside custom execution profiles safely
		local successStore, dataStore = pcall(game.GetService, game, "DataStoreService")
		if successStore and dataStore then
			local store = dataStore:GetDataStore("MegaUI_ConfigStorage")
			store:SetAsync(ActiveSaveKey, serializedData)
		end
	end)

	return writeSuccess
end

function Config:Load(): boolean
	local retrievalSuccess, rawSerializedData = pcall(function()
		local successStore, dataStore = pcall(game.GetService, game, "DataStoreService")
		if successStore and dataStore then
			local store = dataStore:GetDataStore("MegaUI_ConfigStorage")
			return store:GetAsync(ActiveSaveKey)
		end
		return nil
	end)

	if not retrievalSuccess or not rawSerializedData or type(rawSerializedData) ~= "string" then
		return false
	end

	local parseSuccess, decodedRegistry = pcall(function()
		return HttpService:JSONDecode(rawSerializedData)
	end)

	if parseSuccess and type(decodedRegistry) == "table" then
		ConfigRegistry = decodedRegistry
		return true
	end

	return false
end

function Config:GetRawRegistry(): { [string]: any }
	return ConfigRegistry
end

return Config 
end 
 
package.preload['icons'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Icons.lua
-- Version: 1.0.0
-- Description: Standard asset tracking mapping dictionary index for desktop utility aesthetics.

local Icons = {
	-- Navigation & Window Architecture Control Elements
	Close = "rbxassetid://10134424329",
	Minimize = "rbxassetid://10134423315",
	ChevronUp = "rbxassetid://10134421453",
	ChevronDown = "rbxassetid://10134421111",
	Search = "rbxassetid://10134426815",
	Settings = "rbxassetid://10134427381",
	
	-- Component Form Elements
	ToggleOn = "rbxassetid://10134431441",
	ToggleOff = "rbxassetid://10134430931",
	Checkmark = "rbxassetid://10134420063",
	DropdownArrow = "rbxassetid://10134421111",
	ColorWheel = "rbxassetid://4155801252",
	Key = "rbxassetid://10134422473",
	
	-- Notification States & Diagnostic Indicators
	Info = "rbxassetid://10134422031",
	Warning = "rbxassetid://10134428711",
	Error = "rbxassetid://10134421715",
	Success = "rbxassetid://10134420063"
}

export type IconType = typeof(Icons)

return Icons 
end 
 
package.preload['notification'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Notification.lua
-- Version: 1.0.0

local Notification = {}

-- Modules
local Theme = require(script.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent:WaitForChild("Animation"))

-- Internal Properties
local NotificationGui: ScreenGui = nil
local LayoutContainer: Frame = nil
local ActiveNotifications = {}

function Notification:Initialize(storageTarget: Instance)
	if NotificationGui then return end

	local activeTheme = Theme:GetActiveTheme()

	NotificationGui = Utility:Create("ScreenGui", {
		Name = "MegaUI_Notifications",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999
	})

	LayoutContainer = Utility:Create("Frame", {
		Name = "NotificationContainer",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 300, 1, -40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = NotificationGui
	})

	Utility:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10),
		Parent = LayoutContainer
	})

	NotificationGui.Parent = storageTarget
end

function Notification:Push(title: string, content: string, duration: number)
	if not LayoutContainer then return end

	local activeTheme = Theme:GetActiveTheme()
	local durationClamped = duration or 5

	-- Core Panel Container Assembly
	local itemFrame = Utility:Create("Frame", {
		Name = "NotificationItem",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Parent = LayoutContainer
	})

	local itemCorner = Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = itemFrame
	})

	local itemStroke = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 1,
		Parent = itemFrame
	})

	local padding = Utility:Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = itemFrame
	})

	local titleLabel = Utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		Parent = itemFrame
	})

	local contentLabel = Utility:Create("TextLabel", {
		Name = "Content",
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = activeTheme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextTransparency = 1,
		Parent = itemFrame
	})

	-- Inward Transition Mechanics
	itemFrame.BackgroundTransparency = 0.2
	Animation:FadeIn(titleLabel, 0.2)
	Animation:FadeIn(contentLabel, 0.2)
	Animation:Tween(itemStroke, TweenInfo.new(0.2), { Transparency = 0 })

	-- Automatic Cleardown Sequencing Lifecycle management 
	task.delay(durationClamped, function()
		if not itemFrame or not itemFrame.Parent then return end
		
		local fadeTween = Animation:Tween(itemFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		Animation:FadeOut(titleLabel, 0.2)
		Animation:FadeOut(contentLabel, 0.2)
		Animation:Tween(itemStroke, TweenInfo.new(0.2), { Transparency = 1 })
		
		fadeTween.Completed:Connect(function()
			itemFrame:Destroy()
		end)
	end)
end

return Notification 
end 
 
package.preload['panel'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Panel.lua
-- Version: 1.0.0

local Panel = {}
-- Setup internal prototype representation
Panel.__index = Panel

-- Modules
local Theme = require(script.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent:WaitForChild("Utility"))

-- Controls Forward Declarations
local Button = require(script.Parent:WaitForChild("Controls"):WaitForChild("Button"))
local Toggle = require(script.Parent:WaitForChild("Controls"):WaitForChild("Toggle"))
local Slider = require(script.Parent:WaitForChild("Controls"):WaitForChild("Slider"))
local Dropdown = require(script.Parent:WaitForChild("Controls"):WaitForChild("Dropdown"))
local Textbox = require(script.Parent:WaitForChild("Controls"):WaitForChild("Textbox"))
local Label = require(script.Parent:WaitForChild("Controls"):WaitForChild("Label"))
local Paragraph = require(script.Parent:WaitForChild("Controls"):WaitForChild("Paragraph"))
local Keybind = require(script.Parent:WaitForChild("Controls"):WaitForChild("Keybind"))
local ColorPicker = require(script.Parent:WaitForChild("Controls"):WaitForChild("ColorPicker"))

-- Types
export type PanelInstance = {
	Name: string,
	Container: ScrollingFrame,
	ThemeConnection: RBXScriptConnection?,
}

function Panel.new(name: string, parentContainer: Frame): PanelInstance
	local self = setmetatable({}, Panel) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	self.Name = name

	-- Scrolling Container Frame
	self.Container = Utility:Create("ScrollingFrame", {
		Name = name .. "_Panel",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = activeTheme.BorderColor,
		ScrollBarImageTransparency = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = parentContainer
	})

	-- Padding and Lists layout initialization
	Utility:Create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = self.Container
	})

	Utility:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = self.Container
	})

	-- Live Theme synchronization mapping
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.Container.ScrollBarImageColor3 = updatedTheme.BorderColor
	end)

	return self
end

function Panel:SetVisible(visible: boolean)
	self.Container.Visible = visible
end

-- Component Factories
function Panel:CreateButton(options: { Text: string, Callback: () -> () }): any
	return Button.new(options, self.Container)
end

function Panel:CreateToggle(options: { Text: string, Default: boolean?, Callback: (boolean) -> () }): any
	return Toggle.new(options, self.Container)
end

function Panel:CreateSlider(options: { Text: string, Min: number, Max: number, Default: number, Callback: (number) -> () }): any
	return Slider.new(options, self.Container)
end

function Panel:CreateDropdown(options: { Text: string, Items: { string }, Default: string?, Callback: (string) -> () }): any
	return Dropdown.new(options, self.Container)
end

function Panel:CreateTextbox(options: { Text: string, Placeholder: string?, Default: string?, ClearOnFocus: boolean?, Callback: (string) -> () }): any
	return Textbox.new(options, self.Container)
end

function Panel:CreateLabel(options: { Text: string }): any
	return Label.new(options, self.Container)
end

function Panel:CreateParagraph(options: { Title: string, Content: string }): any
	return Paragraph.new(options, self.Container)
end

function Panel:CreateKeybind(options: { Text: string, Default: Enum.KeyCode?, Callback: (Enum.KeyCode) -> () }): any
	return Keybind.new(options, self.Container)
end

function Panel:CreateColorPicker(options: { Text: string, Default: Color3, Callback: (Color3) -> () }): any
	return ColorPicker.new(options, self.Container)
end

function Panel:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Container:Destroy()
end

return Panel 
end 
 
package.preload['theme'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Theme.lua
-- Version: 1.0.0

local Theme = {}

-- Types
export type ThemeConfig = {
	TextColor: Color3,
	TextMuted: Color3,
	BackgroundPrimary: Color3,
	BackgroundSecondary: Color3,
	BackgroundTertiary: Color3,
	AccentColor: Color3,
	AccentHover: Color3,
	BorderColor: Color3,
	BorderMuted: Color3,
	CornerRadius: number,
}

export type ThemeType = "Dark" | "Light"

-- Internal State
local ActiveThemeName: ThemeType = "Dark"
local ActiveTheme: ThemeConfig = nil
local ThemeChangedSignal = Instance.new("BindableEvent")

local Themes: { [ThemeType]: ThemeConfig } = {
	Dark = {
		TextColor = Color3.fromRGB(240, 240, 245),
		TextMuted = Color3.fromRGB(150, 150, 165),
		BackgroundPrimary = Color3.fromRGB(15, 14, 20),
		BackgroundSecondary = Color3.fromRGB(22, 21, 28),
		BackgroundTertiary = Color3.fromRGB(28, 27, 36),
		AccentColor = Color3.fromRGB(120, 60, 220),
		AccentHover = Color3.fromRGB(140, 80, 240),
		BorderColor = Color3.fromRGB(45, 42, 58),
		BorderMuted = Color3.fromRGB(35, 33, 45),
		CornerRadius = 4,
	},
	Light = {
		TextColor = Color3.fromRGB(25, 25, 30),
		TextMuted = Color3.fromRGB(110, 110, 125),
		BackgroundPrimary = Color3.fromRGB(245, 245, 250),
		BackgroundSecondary = Color3.fromRGB(235, 235, 242),
		BackgroundTertiary = Color3.fromRGB(225, 225, 232),
		AccentColor = Color3.fromRGB(100, 40, 200),
		AccentHover = Color3.fromRGB(120, 60, 220),
		BorderColor = Color3.fromRGB(200, 200, 215),
		BorderMuted = Color3.fromRGB(215, 215, 228),
		CornerRadius = 4,
	},
}

-- Public API
function Theme:Initialize()
	if ActiveTheme then return end
	ActiveTheme = Themes[ActiveThemeName]
end

function Theme:SetTheme(themeName: ThemeType)
	if not Themes[themeName] then return end
	if ActiveThemeName == themeName then return end
	
	ActiveThemeName = themeName
	ActiveTheme = Themes[themeName]
	ThemeChangedSignal:Fire(ActiveTheme)
end

function Theme:GetActiveTheme(): ThemeConfig
	if not ActiveTheme then
		Theme:Initialize()
	end
	return ActiveTheme
end

function Theme:GetThemeName(): ThemeType
	return ActiveThemeName
end

function Theme:GetChangedSignal(): RBXScriptSignal
	return ThemeChangedSignal.Event
end

return Theme 
end 
 
package.preload['utility'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Utility.lua
-- Version: 1.0.0

local Utility = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Types
export type Connection = {
	Disconnect: (self: Connection) -> (),
}

-- Utility Functions
function Utility:Create(className: string, properties: { [string]: any }, children: { Instance }?): Instance
	local instance = Instance.new(className)
	
	for property, value in pairs(properties) do
		instance[property] = value
	end
	
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	
	return instance
end

function Utility:MakeDraggable(dragFrame: Frame, targetFrame: Frame)
	local dragging = false
	local dragInput: InputObject? = nil
	local dragStart: Vector3 = Vector3.new()
	local startPos: UDim2 = UDim2.new()

	local function update(input: InputObject)
		local delta = input.Position - dragStart
		targetFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	local inputBeganConn = dragFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position

			local inputChangedConn: RBXScriptConnection? = nil
			local inputEndedConn: RBXScriptConnection? = nil

			inputChangedConn = UserInputService.InputChanged:Connect(function(changedInput)
				if changedInput == dragInput or changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
					if dragging then
						update(changedInput)
					end
				end
			end)

			inputEndedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if inputChangedConn then inputChangedConn:Disconnect() end
					if inputEndedConn then inputEndedConn:Disconnect() end
				end
			end)
		end
	end)

	dragFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
end

function Utility:CreateRipple(button: GuiButton, rippleColor: Color3)
	button.ClipsDescendants = true
	
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = input.Position
			local buttonAbsolutePos = button.AbsolutePosition
			local relativeX = mousePos.X - buttonAbsolutePos.X
			local relativeY = mousePos.Y - buttonAbsolutePos.Y

			local ripple = Instance.new("Frame")
			ripple.Name = "RippleEffect"
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.BackgroundColor3 = rippleColor
			ripple.BackgroundTransparency = 0.6
			ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
			ripple.Size = UDim2.new(0, 0, 0, 0)
			
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = ripple
			
			ripple.Parent = button

			local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
			local tween = TweenService:Create(ripple, tweenInfo, {
				Size = UDim2.new(0, maxSize, 0, maxSize),
				BackgroundTransparency = 1
			})
			
			tween.Completed:Connect(function()
				ripple:Destroy()
			end)
			
			tween:Play()
		end
	end)
end

function Utility:GetTextBounds(text: string, font: Font, fontSize: number, maxWidth: number?): Vector2
	local textService = game:GetService("TextService")
	local success, result = pcall(function()
		return textService:GetTextSize(text, fontSize, font.Family, Vector2.new(maxWidth or 9999, 9999))
	end)
	if success then
		return result
	else
		return Vector2.new(100, 20)
	end
end

return Utility 
end 
 
package.preload['window'] = function() 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: Window.lua
-- Version: 1.0.0

local Window = {}
Window.__index = Window

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Modules
local Theme = require(script.Parent:WaitForChild("Theme"))
local Utility = require(script.Parent:WaitForChild("Utility"))
local Animation = require(script.Parent:WaitForChild("Animation"))
local Panel = require(script.Parent:WaitForChild("Panel"))

-- Types
export type WindowOptions = {
	Title: string,
	Width: number,
	Height: number,
	MinConstraints: Vector2,
}

export type WindowInstance = {
	Title: string,
	Options: WindowOptions,
	Instance: ScreenGui,
	MainFrame: Frame,
	SidebarFrame: Frame,
	ContainerFrame: Frame,
	Panels: { [any]: any },
	ActivePanel: any?,
	ThemeConnection: RBXScriptConnection?,
}

-- Constructor
function Window.new(options: WindowOptions, storageTarget: Instance): WindowInstance
	local self = setmetatable({}, Window) :: any
	
	local activeTheme = Theme:GetActiveTheme()
	
	self.Options = options
	self.Title = options.Title
	self.Panels = {}
	self.ActivePanel = nil

	-- Root UI creation
	self.Instance = Utility:Create("ScreenGui", {
		Name = "MegaUI_" .. options.Title,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100
	})
	
	-- Main Outer Canvas
	self.MainFrame = Utility:Create("Frame", {
		Name = "MainFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, options.Width, 0, options.Height),
		BackgroundColor3 = activeTheme.BackgroundPrimary,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.Instance
	})
	
	Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = self.MainFrame
	})
	
	local mainBorder = Utility:Create("UIStroke", {
		Color = activeTheme.BorderColor,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 0,
		Parent = self.MainFrame
	})

	-- Title Bar
	local titleBar = Utility:Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = titleBar
	})
	
	-- Prevent rounded bottom artifacts on the title bar
	Utility:Create("Frame", {
		Name = "TitleBarBottomMask",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		Parent = titleBar
	})

	local titleLabel = Utility:Create("TextLabel", {
		Name = "TitleText",
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Title,
		TextColor3 = activeTheme.TextColor,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})

	-- Window Control Buttons (Close / Minimize styling)
	local closeButton = Utility:Create("TextButton", {
		Name = "CloseButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = activeTheme.TextMuted,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		Parent = titleBar
	})
	
	Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeButton
	})

	-- Setup Draggable Window behavior
	Utility:MakeDraggable(titleBar, self.MainFrame)

	-- Window Split Structure (Sidebar and Dashboard Body)
	local contentArea = Utility:Create("Frame", {
		Name = "ContentArea",
		Position = UDim2.new(0, 0, 0, 32),
		Size = UDim2.new(1, 0, 1, -32),
		BackgroundTransparency = 1,
		Parent = self.MainFrame
	})

	self.SidebarFrame = Utility:Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 180, 1, 0),
		BackgroundColor3 = activeTheme.BackgroundSecondary,
		BorderSizePixel = 0,
		Parent = contentArea
	})
	
	local sidebarBorder = Utility:Create("Frame", {
		Name = "SidebarBorder",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = activeTheme.BorderColor,
		BorderSizePixel = 0,
		Parent = self.SidebarFrame
	})

	local sidebarLayout = Utility:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = self.SidebarFrame
	})

	Utility:Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = self.SidebarFrame
	})

	self.ContainerFrame = Utility:Create("Frame", {
		Name = "Container",
		Position = UDim2.new(0, 180, 0, 0),
		Size = UDim2.new(1, -180, 1, 0),
		BackgroundTransparency = 1,
		Parent = contentArea
	})

	-- Resizer Widget (Bottom-Right Interaction anchor)
	local resizeHandle = Utility:Create("Frame", {
		Name = "ResizeHandle",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = self.MainFrame
	})

	-- Functional logic for Window Interactions
	closeButton.MouseEnter:Connect(function()
		Animation:HoverColor(closeButton, Color3.fromRGB(220, 50, 50))
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	
	closeButton.MouseLeave:Connect(function()
		Animation:HoverColor(closeButton, Color3.fromRGB(255, 255, 255), "BackgroundColor3")
		closeButton.BackgroundTransparency = 1
		closeButton.TextColor3 = Theme:GetActiveTheme().TextMuted
	end)

	closeButton.MouseButton1Click:Connect(function()
		self:Destroy()
	end)

	-- Window Resizing Logistics
	local dynamicResizing = false
	local initialSize = Vector2.new()
	local clickAnchor = Vector2.new()

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dynamicResizing = true
			initialSize = Vector2.new(self.MainFrame.AbsoluteSize.X, self.MainFrame.AbsoluteSize.Y)
			clickAnchor = input.Position
			
			local resizeChanged: RBXScriptConnection? = nil
			local resizeEnded: RBXScriptConnection? = nil

			resizeChanged = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					if dynamicResizing then
						local delta = moveInput.Position - clickAnchor
						local finalX = math.max(options.MinConstraints.X, initialSize.X + delta.X)
						local finalY = math.max(options.MinConstraints.Y, initialSize.Y + delta.Y)
						self.MainFrame.Size = UDim2.new(0, finalX, 0, finalY)
					end
				end
			end)

			resizeEnded = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					dynamicResizing = false
					if resizeChanged then resizeChanged:Disconnect() end
					if resizeEnded then resizeEnded:Disconnect() end
				end
			end)
		end
	end)

	-- Dynamic Re-theming Adaptability
	self.ThemeConnection = Theme:GetChangedSignal():Connect(function(updatedTheme)
		self.MainFrame.BackgroundColor3 = updatedTheme.BackgroundPrimary
		mainBorder.Color = updatedTheme.BorderColor
		titleBar.BackgroundColor3 = updatedTheme.BackgroundSecondary
		titleBar.TitleBarBottomMask.BackgroundColor3 = updatedTheme.BackgroundSecondary
		titleLabel.TextColor3 = updatedTheme.TextColor
		closeButton.TextColor3 = updatedTheme.TextMuted
		self.SidebarFrame.BackgroundColor3 = updatedTheme.BackgroundSecondary
		sidebarBorder.BackgroundColor3 = updatedTheme.BorderColor
	end)

	self.Instance.Parent = storageTarget
	return self
end

-- Instance Management API
function Window:CreatePanel(options: { Name: string }): any
	local cleanOptions = options or {}
	cleanOptions.Name = cleanOptions.Name or "Tab Panel"

	local activeTheme = Theme:GetActiveTheme()

	-- Sidebar Tab Button UI
	local panelButton = Utility:Create("TextButton", {
		Name = cleanOptions.Name .. "_Tab",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = activeTheme.BackgroundTertiary,
		BackgroundTransparency = 1,
		Text = cleanOptions.Name,
		TextColor3 = activeTheme.TextMuted,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.SidebarFrame
	})

	Utility:Create("UICorner", {
		CornerRadius = UDim.new(0, activeTheme.CornerRadius),
		Parent = panelButton
	})

	Utility:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		Parent = panelButton
	})

	local newPanel = Panel.new(cleanOptions.Name, self.ContainerFrame)
	self.Panels[cleanOptions.Name] = {
		Panel = newPanel,
		Button = panelButton
	}

	-- Select active panel if none initialized
	if not self.ActivePanel then
		self:SelectPanel(cleanOptions.Name)
	end

	-- Connect Panel Navigation Click
	panelButton.MouseButton1Click:Connect(function()
		self:SelectPanel(cleanOptions.Name)
	end)

	panelButton.MouseEnter:Connect(function()
		if self.ActivePanel ~= cleanOptions.Name then
			Animation:HoverColor(panelButton, activeTheme.BackgroundTertiary, "BackgroundColor3")
			panelButton.BackgroundTransparency = 0.5
		end
	end)

	panelButton.MouseLeave:Connect(function()
		if self.ActivePanel ~= cleanOptions.Name then
			panelButton.BackgroundTransparency = 1
		end
	end)

	return newPanel
end

function Window:SelectPanel(panelName: string)
	local target = self.Panels[panelName]
	if not target then return end

	local activeTheme = Theme:GetActiveTheme()

	-- Deactivate operational panels
	for name, bundle in pairs(self.Panels) do
		if name ~= panelName then
			bundle.Panel:SetVisible(false)
			bundle.Button.TextColor3 = activeTheme.TextMuted
			bundle.Button.BackgroundTransparency = 1
		end
	end

	-- Activate requested selection
	self.ActivePanel = panelName
	target.Panel:SetVisible(true)
	target.Button.TextColor3 = activeTheme.TextColor
	target.Button.BackgroundColor3 = activeTheme.AccentColor
	target.Button.BackgroundTransparency = 0
end

function Window:Destroy()
	if self.ThemeConnection then
		self.ThemeConnection:Disconnect()
		self.ThemeConnection = nil
	end
	self.Instance:Destroy()
end

return Window 
end 
 
-- Main Entry Point 
--!strict
-- MegaUI: A production-quality, desktop-utility UI library for Roblox.
-- File: init.lua
-- Version: 1.0.0
-- Style: Dark desktop utility, purple accents, clean architecture.

local MegaUI = {}
MegaUI.__index = MegaUI

-- Types
export type ThemeConfig = {
	TextColor: Color3,
	TextMuted: Color3,
	BackgroundPrimary: Color3,
	BackgroundSecondary: Color3,
	BackgroundTertiary: Color3,
	AccentColor: Color3,
	AccentHover: Color3,
	BorderColor: Color3,
	BorderMuted: Color3,
	CornerRadius: number,
}

export type WindowOptions = {
	Title: string,
	Width: number?,
	Height: number?,
	MinConstraints: Vector2?,
}

export type Window = {
	Title: string,
	Instance: ScreenGui,
	MainFrame: Frame,
	CreatePanel: (self: Window, options: any) -> any,
	Destroy: (self: Window) -> (),
}

-- Module References
local Theme = require(script:WaitForChild("Theme"))
local Utility = require(script:WaitForChild("Utility"))
local Animation = require(script:WaitForChild("Animation"))
local WindowModule = require(script:WaitForChild("Window"))
local Notification = require(script:WaitForChild("Notification"))
local Config = require(script:WaitForChild("Config"))

-- Core State
local IsInitialized = false
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Verify execution environment safely
local function GetUIFolder(): Instance
	local success, result = pcall(function()
		return CoreGui:FindFirstChild("MegaUI_Storage") or Instance.new("Folder")
	end)
	if success and result then
		if not result.Parent then
			result.Name = "MegaUI_Storage"
			result.Parent = CoreGui
		end
		return result
	else
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local folder = playerGui:FindFirstChild("MegaUI_Storage")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "MegaUI_Storage"
			folder.Parent = playerGui
		end
		return folder
	end
end

local TargetStorage = GetUIFolder()

-- Public API
function MegaUI:Initialize()
	if IsInitialized then return end
	IsInitialized = true
	
	-- Initialize internal sub-systems
	Theme:Initialize()
	Notification:Initialize(TargetStorage)
	Config:Initialize()
end

function MegaUI:CreateWindow(options: WindowOptions): Window
	if not IsInitialized then
		MegaUI:Initialize()
	end

	local cleanOptions = options or {}
	cleanOptions.Title = cleanOptions.Title or "MegaUI Application"
	cleanOptions.Width = cleanOptions.Width or 800
	cleanOptions.Height = cleanOptions.Height or 500
	cleanOptions.MinConstraints = cleanOptions.MinConstraints or Vector2.new(400, 300)

	local newWindow = WindowModule.new(cleanOptions, TargetStorage)
	return newWindow
end

function MegaUI:Notify(options: { Title: string, Content: string, Duration: number? })
	if not IsInitialized then
		MegaUI:Initialize()
	end
	Notification:Push(options.Title, options.Content, options.Duration or 5)
end

function MegaUI:SetTheme(themeName: "Dark" | "Light")
	Theme:SetTheme(themeName)
end

function MegaUI:GetTheme(): ThemeConfig
	return Theme:GetActiveTheme()
end

return MegaUI 
