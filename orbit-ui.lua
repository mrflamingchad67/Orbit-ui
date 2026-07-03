local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

function Library:CreateWindow(Options)

    local Window = {}
    Window.Columns = {}

    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local Gui = Instance.new("ScreenGui")
    Gui.Name = HttpService:GenerateGUID(false)
    Gui.ResetOnSpawn = false
    Gui.Parent = PlayerGui

    ------------------------------------------------
    -- Main
    ------------------------------------------------

    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(1200,650)
    Main.Position = UDim2.new(.5,-600,.5,-325)
    Main.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Main.BorderSizePixel = 0
    Main.Parent = Gui

    ------------------------------------------------
    -- Header
    ------------------------------------------------

    local Header = Instance.new("Frame")
    Header.Size = UDim2.fromOffset(260,18)
    Header.BackgroundColor3 = Color3.fromRGB(235,48,97)
    Header.BorderSizePixel = 0
    Header.Parent = Main

    ------------------------------------------------
    -- Minimize
    ------------------------------------------------

    local Minimize = Instance.new("TextButton")
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.fromOffset(18,18)
    Minimize.Position = UDim2.fromOffset(0,0)
    Minimize.BackgroundTransparency = 1
    Minimize.BorderSizePixel = 0
    Minimize.Text = ">"
    Minimize.Font = Enum.Font.ArialBold
    Minimize.TextSize = 10
    Minimize.TextColor3 = Color3.new(1,1,1)
    Minimize.Rotation = 90 -- Expanded
    Minimize.Parent = Header

    local TweenService = game:GetService("TweenService")
    local Open = true

    Minimize.MouseButton1Click:Connect(function()
        Open = not Open

        TweenService:Create(
            Minimize,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Rotation = Open and 90 or 0
            }
        ):Play()

    -- Collapse/expand body here
end)

    ------------------------------------------------
    -- Title
    ------------------------------------------------

    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,-36,1,0)
    Title.Position = UDim2.fromOffset(18,0)
    Title.TextSize = 10
    Title.Font = Enum.Font.ArialBold
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.TextYAlignment = Enum.TextYAlignment.Center

    ------------------------------------------------
    -- Body
    ------------------------------------------------

    local Body = Instance.new("Frame")
    Body.Position = UDim2.fromOffset(0,18)
    Body.Size = UDim2.fromOffset(260,0)
    Body.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Body.BorderSizePixel = 0
    Body.Parent = Main
    Body.ClipsDescendants = true
    Body:TweenSize(
        UDim2.fromOffset(260,ContentHeight),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        .15,
        true
    )

    ------------------------------------------------
    -- Column Holder
    ------------------------------------------------

    local Holder = Instance.new("Frame")
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.new(1,0,1,0)
    Holder.Parent = Body

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0,2)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Parent = Holder

    ------------------------------------------------
    -- Dragging
    ------------------------------------------------

    local Drag
    local DragStart
    local StartPos

    Header.InputBegan:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then

            Drag = true
            DragStart = Input.Position
            StartPos = Main.Position

            Input.Changed:Connect(function()

                if Input.UserInputState == Enum.UserInputState.End then

                    Drag = false

                end

            end)

        end

    end)

    UIS.InputChanged:Connect(function(Input)

        if Drag and Input.UserInputType == Enum.UserInputType.MouseMovement then

            local Delta = Input.Position - DragStart

            Main.Position = UDim2.new(

                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,

                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y

            )

        end

    end)

    ------------------------------------------------
    -- Minimize
    ------------------------------------------------

    local Open = true

    Minimize.MouseButton1Click:Connect(function()

        Open = not Open

        Body.Visible = Open

        if Open then
            Main.Size = UDim2.fromOffset(1200,650)
        else
            Main.Size = UDim2.fromOffset(1200,18)
        end

    end)
    

    ------------------------------------------------
    -- Layout
    ------------------------------------------------

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,2)
    Layout.Parent = Body
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        ContentHeight = Layout.AbsoluteContentSize.Y

    end)

    ------------------------------------------------
    -- Button
    ------------------------------------------------
    
    ------------------------------------------------
    -- Window API
    ------------------------------------------------

    function Window:AddColumn(Name)

        -- Part 2

    end

    Window.Gui = Gui
    Window.Holder = Holder

    return Window

end

return Library
