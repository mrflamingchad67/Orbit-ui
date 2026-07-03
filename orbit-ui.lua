local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function GetHUI()
	return gethui and gethui() or CoreGui
end

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function Drag(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Library:CreateWindow(cfg)
	local window = {Minimized = false, Panels = {}}
	
	local gui = Create("ScreenGui", {Name = "MegaHack", ResetOnSpawn = false, Parent = GetHUI()})
	
	local main = Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 1040, 0, 560),
		Position = UDim2.new(0.5, -520, 0.5, -280),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		Parent = gui
	})
	
	local titleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundColor3 = Color3.fromRGB(235, 48, 97),
		BorderSizePixel = 0,
		Parent = main
	})
	
	local titleLabel = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = cfg.Name or "Mega Hack",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.ArialBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = titleBar
	})
	
	local minArrow = Create("TextLabel", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(1, -22, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.ArialBold,
		TextSize = 14,
		Parent = titleBar
	})
	
	Drag(titleBar)
	
	local content = Create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, -18),
		Position = UDim2.new(0, 0, 0, 18),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		Parent = main
	})
	
	local panelsContainer = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = content
	})
	
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = panelsContainer
	})
	
	local originalContentSize = content.Size
	
	minArrow.MouseButton1Click:Connect(function()
		window.Minimized = not window.Minimized
		if window.Minimized then
			TweenService:Create(minArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = 180}):Play()
			TweenService:Create(content, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 0)}):Play()
		else
			TweenService:Create(minArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = 0}):Play()
			TweenService:Create(content, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = originalContentSize}):Play()
		end
	end)
	
	function window:CreatePanel(panelName)
		local panel = {Name = panelName}
		table.insert(window.Panels, panel)
		
		local panelFrame = Create("Frame", {
			Size = UDim2.new(0, 136, 1, 0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
			Parent = panelsContainer,
			LayoutOrder = #window.Panels
		})
		
		local panelHeader = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundColor3 = Color3.fromRGB(235, 48, 97),
			BorderSizePixel = 0,
			Parent = panelFrame
		})
		
		Create("TextLabel", {
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = panelName,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.ArialBold,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = panelHeader
		})
		
		local scroll = Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -18),
			Position = UDim2.new(0, 0, 0, 18),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
			Parent = panelFrame
		})
		
		local list = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = scroll
		})
		
		local function updateScroll()
			scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 6)
		end
		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
		
		function panel:CreateSection(secName)
			local secFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundColor3 = Color3.fromRGB(200, 30, 100),
				BorderSizePixel = 0,
				Parent = scroll
			})
			Create("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "  " .. secName,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = secFrame
			})
			return secFrame
		end
		
		function panel:CreateButton(btnCfg)
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Parent = scroll
			})
			
			local btn = Create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = btnCfg.Name or "Button",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})
			Create("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = btn})
			
			btn.MouseButton1Click:Connect(function()
				if btnCfg.Callback then btnCfg.Callback() end
			end)
			
			return {}
		end
		
		function panel:CreateToggle(togCfg)
			local tog = {Value = togCfg.CurrentValue or false}
			
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Parent = scroll
			})
			
			local label = Create("TextLabel", {
				Size = UDim2.new(1, -24, 1, 0),
				BackgroundTransparency = 1,
				Text = togCfg.Name or "Toggle",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})
			Create("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = label})
			
			local checkBox = Create("TextButton", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -18, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BorderSizePixel = 1,
				BorderColor3 = Color3.fromRGB(70, 70, 70),
				Text = "",
				Parent = row
			})
			
			local check = Create("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = tog.Value and "✔" or "",
				TextColor3 = Color3.fromRGB(0, 255, 100),
				Font = Enum.Font.ArialBold,
				TextSize = 12,
				Parent = checkBox
			})
			
			checkBox.MouseButton1Click:Connect(function()
				tog.Value = not tog.Value
				check.Text = tog.Value and "✔" or ""
				if togCfg.Callback then togCfg.Callback(tog.Value) end
			end)
			
			return tog
		end
		
		function panel:CreateSlider(sCfg)
			local slider = {Value = sCfg.CurrentValue or sCfg.Range[1]}
			
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Parent = scroll
			})
			
			local label = Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				Text = (sCfg.Name or "Slider") .. ": " .. tostring(math.floor(slider.Value)),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})
			Create("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = label})
			
			local barBG = Create("Frame", {
				Size = UDim2.new(1, -12, 0, 3),
				Position = UDim2.new(0, 6, 1, -9),
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				BorderSizePixel = 0,
				Parent = row
			})
			
			local fill = Create("Frame", {
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(235, 48, 97),
				BorderSizePixel = 0,
				Parent = barBG
			})
			
			local knob = Create("Frame", {
				Size = UDim2.new(0, 9, 0, 9),
				Position = UDim2.new(0.5, -4.5, 0.5, -4.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = barBG
			})
			
			local dragging = false
			
			local function update(val)
				val = math.clamp(val, sCfg.Range[1], sCfg.Range[2])
				slider.Value = val
				label.Text = (sCfg.Name or "Slider") .. ": " .. tostring(math.floor(val))
				local percent = (val - sCfg.Range[1]) / (sCfg.Range[2] - sCfg.Range[1])
				fill.Size = UDim2.new(percent, 0, 1, 0)
				knob.Position = UDim2.new(percent, -4.5, 0.5, -4.5)
				if sCfg.Callback then sCfg.Callback(val) end
			end
			
			barBG.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local rel = (inp.Position.X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X
					update(sCfg.Range[1] + (sCfg.Range[2] - sCfg.Range[1]) * rel)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			
			UserInputService.InputChanged:Connect(function(inp)
				if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
					local rel = math.clamp((inp.Position.X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
					update(sCfg.Range[1] + (sCfg.Range[2] - sCfg.Range[1]) * rel)
				end
			end)
			
			update(slider.Value)
			return slider
		end
		
		function panel:CreateDropdown(dCfg)
			local drop = {Value = dCfg.CurrentOption or dCfg.Options[1]}
			
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Parent = scroll
			})
			
			local btn = Create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = (dCfg.Name or "Dropdown") .. ": " .. drop.Value,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})
			Create("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = btn})
			
			local expanded = false
			local optionsContainer = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(28, 28, 28),
				BorderSizePixel = 1,
				BorderColor3 = Color3.fromRGB(60, 60, 60),
				Visible = false,
				ZIndex = 5,
				Parent = row
			})
			
			local optList = Create("UIListLayout", {Padding = UDim.new(0, 1), Parent = optionsContainer})
			
			for _, opt in ipairs(dCfg.Options or {}) do
				local optBtn = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 15),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					Text = opt,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.ArialBold,
					TextSize = 10,
					Parent = optionsContainer
				})
				optBtn.MouseButton1Click:Connect(function()
					drop.Value = opt
					btn.Text = (dCfg.Name or "Dropdown") .. ": " .. opt
					optionsContainer.Visible = false
					expanded = false
					if dCfg.Callback then dCfg.Callback(opt) end
				end)
			end
			
			btn.MouseButton1Click:Connect(function()
				expanded = not expanded
				optionsContainer.Visible = expanded
				optionsContainer.Size = UDim2.new(1, 0, 0, optList.AbsoluteContentSize.Y)
			end)
			
			return drop
		end
		
		function panel:CreateKeybind(kbCfg)
			local kb = {CurrentKey = kbCfg.CurrentKeybind or Enum.KeyCode.F}
			
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Parent = scroll
			})
			
			local label = Create("TextLabel", {
				Size = UDim2.new(0.6, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = kbCfg.Name or "Keybind",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})
			Create("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = label})
			
			local keyBtn = Create("TextButton", {
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0.6, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				Text = kb.CurrentKey.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 10,
				Parent = row
			})
			
			local listening = false
			
			keyBtn.MouseButton1Click:Connect(function()
				listening = true
				keyBtn.Text = "..."
			end)
			
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gp)
				if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
					kb.CurrentKey = input.KeyCode
					keyBtn.Text = input.KeyCode.Name
					listening = false
					if kbCfg.Callback then kbCfg.Callback() end
				end
			end)
			
			return kb
		end
		
		return panel
	end
	
	return window
end

return Library
