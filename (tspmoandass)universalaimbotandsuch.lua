local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Enabled = false
local Aimbot_Enabled = false
local Fly_Enabled = false
local ESP_Boxes = {}

local AimKey = Enum.UserInputType.MouseButton2
local AimSmoothness = 0.2
local FlySpeed = 50
local WalkSpeed = 16

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local AimButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local SpeedSlider = Instance.new("TextBox")
local SpeedLabel = Instance.new("TextLabel")
local WalkSpeedSlider = Instance.new("TextBox")
local WalkSpeedLabel = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.Parent = ScreenGui

-- Drag-Funktion
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = Vector2.new(0, 0)

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Vector2.new(Frame.Position.X.Offset, Frame.Position.Y.Offset)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)

local function CreateButton(button, text, posY)
    button.Size = UDim2.new(0, 280, 0, 50)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = Frame
    button.TextScaled = true
    button.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
end

CreateButton(ESPButton, "Toggle ESP", 10)
CreateButton(AimButton, "Toggle Aimbot", 70)
CreateButton(FlyButton, "Toggle Fly", 130)

-- Slider: Fly Speed
SpeedLabel.Size = UDim2.new(0, 280, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 0, 190)
SpeedLabel.Text = "Fly Speed: " .. FlySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 16
SpeedLabel.Parent = Frame

SpeedSlider.Size = UDim2.new(0, 280, 0, 40)
SpeedSlider.Position = UDim2.new(0, 10, 0, 220)
SpeedSlider.Text = tostring(FlySpeed)
SpeedSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Font = Enum.Font.Gotham
SpeedSlider.TextSize = 16
SpeedSlider.Parent = Frame

local speedSliderCorner = Instance.new("UICorner")
speedSliderCorner.CornerRadius = UDim.new(0, 5)
speedSliderCorner.Parent = SpeedSlider

-- Slider: Walk Speed
WalkSpeedLabel.Size = UDim2.new(0, 280, 0, 30)
WalkSpeedLabel.Position = UDim2.new(0, 10, 0, 270)
WalkSpeedLabel.Text = "Walk Speed: " .. WalkSpeed
WalkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Font = Enum.Font.Gotham
WalkSpeedLabel.TextSize = 16
WalkSpeedLabel.Parent = Frame

WalkSpeedSlider.Size = UDim2.new(0, 280, 0, 40)
WalkSpeedSlider.Position = UDim2.new(0, 10, 0, 300)
WalkSpeedSlider.Text = tostring(WalkSpeed)
WalkSpeedSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
WalkSpeedSlider.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
WalkSpeedSlider.BorderSizePixel = 0
WalkSpeedSlider.Font = Enum.Font.Gotham
WalkSpeedSlider.TextSize = 16
WalkSpeedSlider.Parent = Frame

local walkSpeedSliderCorner = Instance.new("UICorner")
walkSpeedSliderCorner.CornerRadius = UDim.new(0, 5)
walkSpeedSliderCorner.Parent = WalkSpeedSlider

-- ESP-Erstellung
local function CreateESP(player)
    if player == LocalPlayer then return end

    local function createBox()
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.fromRGB(255, 0, 0)
        Box.Thickness = 2
        Box.Filled = false
        ESP_Boxes[player] = Box
    end

    createBox()

    player.CharacterAdded:Connect(function()
        if ESP_Boxes[player] then
            ESP_Boxes[player]:Remove()
        end
        createBox()
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent and ESP_Boxes[player] then
            ESP_Boxes[player]:Remove()
            ESP_Boxes[player] = nil
        end
    end)
end

local function UpdateESP()
    if not ESP_Enabled then
        for _, box in pairs(ESP_Boxes) do box.Visible = false end
        return
    end

    for player, Box in pairs(ESP_Boxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                Box.Size = Vector2.new(50, 100)
                Box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                Box.Visible = true
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end
end

local function GetNearestEnemy()
    local nearestPlayer, shortestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

local function AimAtEnemy()
    if not Aimbot_Enabled then return end
    local enemy = GetNearestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("Head") then
        local head = enemy.Character.Head
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            local targetPos = Vector2.new(pos.X, pos.Y)
            local moveTo = mousePos:Lerp(targetPos, AimSmoothness)
            mousemoverel(moveTo.X - mousePos.X, moveTo.Y - mousePos.Y)
        end
    end
end

local function ToggleFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    Fly_Enabled = not Fly_Enabled
    FlyButton.Text = Fly_Enabled and "Fly: ON" or "Fly: OFF"

    if Fly_Enabled then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new()
        bv.Parent = hrp

        coroutine.wrap(function()
            while Fly_Enabled do
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector * FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector * FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector * FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector * FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, FlySpeed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, FlySpeed, 0) end
                bv.Velocity = dir
                RunService.RenderStepped:Wait()
            end
            bv:Destroy()
        end)()
    end
end

-- Charakter-Walkspeed setzen
LocalPlayer.CharacterAdded:Connect(function(character)
    local hum = character:WaitForChild("Humanoid")
    hum.WalkSpeed = WalkSpeed
end)

-- ESP Initialisierung
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(UpdateESP)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimKey and Aimbot_Enabled then
        while UserInputService:IsMouseButtonPressed(AimKey) do
            AimAtEnemy()
            RunService.RenderStepped:Wait()
        end
    end
end)

-- GUI-Buttons
ESPButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ESPButton.Text = ESP_Enabled and "ESP: ON" or "ESP: OFF"
end)

AimButton.MouseButton1Click:Connect(function()
    Aimbot_Enabled = not Aimbot_Enabled
    AimButton.Text = Aimbot_Enabled and "Aimbot: ON" or "Aimbot: OFF"
end)

FlyButton.MouseButton1Click:Connect(ToggleFly)

SpeedSlider.FocusLost:Connect(function()
    local val = tonumber(SpeedSlider.Text)
    if val and val > 0 then
        FlySpeed = val
        SpeedLabel.Text = "Fly Speed: " .. FlySpeed
    else
        SpeedSlider.Text = tostring(FlySpeed)
    end
end)

WalkSpeedSlider.FocusLost:Connect(function()
    local val = tonumber(WalkSpeedSlider.Text)
    if val and val > 0 then
        WalkSpeed = val
        WalkSpeedLabel.Text = "Walk Speed: " .. WalkSpeed
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = WalkSpeed end
        end
    else
        WalkSpeedSlider.Text = tostring(WalkSpeed)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    elseif input.KeyCode == Enum.KeyCode.P then
        ToggleFly()
    end
end)

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = WalkSpeed end
end
