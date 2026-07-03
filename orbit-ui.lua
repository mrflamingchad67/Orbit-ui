local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function GetHUI()
	return (gethui and gethui()) or CoreGui
end

local function CreateInstance(class, props)
	local instance = Instance.new(class)
	for k, v in pairs(props or {}) do
		instance[k] = v
	end
	return instance
end

local function Dragify(frame)
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function Library:CreateWindow(config)
	local Window = {
		Name = config.Name or "Mega Hack",
		Minimized = false
	}

	local ScreenGui = CreateInstance("ScreenGui", {
		Name = "MegaHackLibrary",
		ResetOnSpawn = false,
		Parent = GetHUI()
	})

	local MainFrame = CreateInstance("Frame", {
		Name = "MainFrame",
		Size = UDim2.new(0, 1020, 0, 580),
		Position = UDim2.new(0.5, -510, 0.5, -290),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		Parent = ScreenGui
	})

	local TitleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Color3.fromRGB(255, 20, 147),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	local TitleText = CreateInstance("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -80, 1, 0),
		BackgroundTransparency = 1,
		Text = Window.Name,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = TitleBar
	})

	local MinimizeButton = CreateInstance("TextButton", {
		Name = "Minimize",
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -34, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = TitleBar
	})

	Dragify(TitleBar)

	local ContentFrame = CreateInstance("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, -34),
		Position = UDim2.new(0, 0, 0, 34),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	local PanelsFolder = CreateInstance("Frame", {
		Name = "Panels",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = ContentFrame
	})

	local PanelsLayout = CreateInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = PanelsFolder
	})

	local minimizedSize = nil
	local originalSize = MainFrame.Size

	MinimizeButton.MouseButton1Click:Connect(function()
		Window.Minimized = not Window.Minimized
		if Window.Minimized then
			minimizedSize = MainFrame.Size
			TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {Rotation = 180}):Play()
			TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, originalSize.X.Offset, 0, 34)}):Play()
		else
			TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {Rotation = 0}):Play()
			TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = minimizedSize or originalSize}):Play()
		end
	end)

	function Window:CreatePanel(panelConfig)
		local Panel = {
			Name = panelConfig.Name or "Panel"
		}

		local PanelFrame = CreateInstance("Frame", {
			Name = Panel.Name,
			Size = UDim2.new(0, 148, 1, 0),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BorderSizePixel = 0,
			Parent = PanelsFolder,
			LayoutOrder = #PanelsFolder:GetChildren()
		})

		local PanelHeader = CreateInstance("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = Color3.fromRGB(220, 20, 140),
			BorderSizePixel = 0,
			Parent = PanelFrame
		})

		local HeaderText = CreateInstance("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			BackgroundTransparency = 1,
			Text = "- " .. Panel.Name,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = PanelHeader
		})

		local ScrollFrame = CreateInstance("ScrollingFrame", {
			Name = "Scroll",
			Size = UDim2.new(1, 0, 1, -24),
			Position = UDim2.new(0, 0, 0, 24),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
			Parent = PanelFrame
		})

		local ScrollLayout = CreateInstance("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = ScrollFrame
		})

		local function UpdateCanvas()
			ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 4)
		end

		ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
		UpdateCanvas()

		function Panel:CreateButton(btnConfig)
			local ButtonObj = {}

			local BtnFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = ScrollFrame
			})

			local Btn = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = btnConfig.Name or "Button",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = BtnFrame
			})

			local Padding = CreateInstance("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				Parent = Btn
			})

			Btn.MouseButton1Click:Connect(function()
				if btnConfig.Callback then
					btnConfig.Callback()
				end
				Btn.BackgroundTransparency = 0.7
				wait(0.1)
				Btn.BackgroundTransparency = 1
			end)

			return ButtonObj
		end

		function Panel:CreateToggle(togConfig)
			local ToggleObj = {Value = togConfig.CurrentValue or false}

			local TogFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = ScrollFrame
			})

			local TogList = CreateInstance("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 6),
				Parent = TogFrame
			})

			local Label = CreateInstance("TextLabel", {
				Size = UDim2.new(1, -32, 1, 0),
				BackgroundTransparency = 1,
				Text = togConfig.Name or "Toggle",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = TogFrame
			})

			local UIPadding = CreateInstance("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = Label})

			local CheckFrame = CreateInstance("TextButton", {
				Size = UDim2.new(0, 22, 0, 22),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				BorderSizePixel = 0,
				Text = "",
				Parent = TogFrame
			})

			local CheckMark = CreateInstance("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = ToggleObj.Value and "✔" or "",
				TextColor3 = Color3.fromRGB(0, 255, 100),
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				Parent = CheckFrame
			})

			local function UpdateToggle()
				CheckMark.Text = ToggleObj.Value and "✔" or ""
				if togConfig.Callback then
					togConfig.Callback(ToggleObj.Value)
				end
			end

			CheckFrame.MouseButton1Click:Connect(function()
				ToggleObj.Value = not ToggleObj.Value
				UpdateToggle()
			end)

			UpdateToggle()

			return ToggleObj
		end

		function Panel:CreateSlider(sliderConfig)
			local SliderObj = {Value = sliderConfig.CurrentValue or sliderConfig.Range[1]}

			local SliderFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = ScrollFrame
			})

			local Label = CreateInstance("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = (sliderConfig.Name or "Slider") .. ": " .. tostring(SliderObj.Value),
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = SliderFrame
			})

			CreateInstance("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = Label})

			local Bar = CreateInstance("Frame", {
				Size = UDim2.new(1, -12, 0, 6),
				Position = UDim2.new(0, 6, 1, -10),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				BorderSizePixel = 0,
				Parent = SliderFrame
			})

			local Fill = CreateInstance("Frame", {
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 20, 147),
				BorderSizePixel = 0,
				Parent = Bar
			})

			local Knob = CreateInstance("Frame", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0.5, -6, 0.5, -6),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = Bar
			})

			local function UpdateSlider(percent)
				percent = math.clamp(percent, 0, 1)
				Fill.Size = UDim2.new(percent, 0, 1, 0)
				local val = math.floor(sliderConfig.Range[1] + (sliderConfig.Range[2] - sliderConfig.Range[1]) * percent)
				SliderObj.Value = val
				Label.Text = (sliderConfig.Name or "Slider") .. ": " .. tostring(val)
				if sliderConfig.Callback then
					sliderConfig.Callback(val)
				end
			end

			local draggingSlider = false
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = true
					local mousePos = UserInputService:GetMouseLocation()
					local barPos = Bar.AbsolutePosition
					local barSize = Bar.AbsoluteSize
					local percent = (mousePos.X - barPos.X) / barSize.X
					UpdateSlider(percent)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = UserInputService:GetMouseLocation()
					local barPos = Bar.AbsolutePosition
					local barSize = Bar.AbsoluteSize
					local percent = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
					UpdateSlider(percent)
				end
			end)

			-- Initial update
			local initPercent = (SliderObj.Value - sliderConfig.Range[1]) / (sliderConfig.Range[2] - sliderConfig.Range[1])
			UpdateSlider(initPercent)

			return SliderObj
		end

		function Panel:CreateDropdown(dropdownConfig)
			local DropdownObj = {Current = dropdownConfig.CurrentOption}

			local DropFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = ScrollFrame
			})

			local DropButton = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = dropdownConfig.Name .. ": " .. (dropdownConfig.CurrentOption or "Select"),
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = DropFrame
			})

			CreateInstance("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = DropButton})

			local OptionsFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 2),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 1,
				BorderColor3 = Color3.fromRGB(80, 80, 80),
				Visible = false,
				ZIndex = 10,
				Parent = DropFrame
			})

			local OptionsList = CreateInstance("UIListLayout", {Parent = OptionsFrame})

			for _, opt in ipairs(dropdownConfig.Options or {}) do
				local OptBtn = CreateInstance("TextButton", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Text = opt,
					TextColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.GothamSemibold,
					TextSize = 13,
					Parent = OptionsFrame
				})

				OptBtn.MouseButton1Click:Connect(function()
					DropdownObj.Current = opt
					DropButton.Text = dropdownConfig.Name .. ": " .. opt
					OptionsFrame.Visible = false
					if dropdownConfig.Callback then
						dropdownConfig.Callback(opt)
					end
				end)
			end

			DropButton.MouseButton1Click:Connect(function()
				OptionsFrame.Visible = not OptionsFrame.Visible
				OptionsFrame.Size = UDim2.new(1, 0, 0, OptionsList.AbsoluteContentSize.Y)
			end)

			return DropdownObj
		end

		function Panel:CreateKeybind(kbConfig)
			local KBObj = {CurrentKey = kbConfig.CurrentKeybind or Enum.KeyCode.F}

			local KBFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				BorderSizePixel = 0,
				Parent = ScrollFrame
			})

			local KBLabel = CreateInstance("TextLabel", {
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = kbConfig.Name or "Keybind",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = KBFrame
			})

			CreateInstance("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = KBLabel})

			local KeyButton = CreateInstance("TextButton", {
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0.6, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Text = KBObj.CurrentKey.Name,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamSemibold,
				TextSize = 13,
				Parent = KBFrame
			})

			local listening = false

			KeyButton.MouseButton1Click:Connect(function()
				listening = true
				KeyButton.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, gp)
				if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
					KBObj.CurrentKey = input.KeyCode
					KeyButton.Text = input.KeyCode.Name
					listening = false
					if kbConfig.Callback then
						kbConfig.Callback()
					end
				end
			end)

			return KBObj
		end

		return Panel
	end

	return Window
end

return Library
