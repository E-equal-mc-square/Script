-- Universal Game Script UI with DoW, GoG, and H&S modes (Floating Window Upgrade)

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local aimDistance = 250
local excludedPlayers = {}
local activeMode = ""

-- GUI CREATION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UniversalGameScriptUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local FloatingCircle = Instance.new("ImageButton", ScreenGui)
FloatingCircle.Size = UDim2.new(0, 40, 0, 40)
FloatingCircle.Position = UDim2.new(0.05, 0, 0.1, 0)
FloatingCircle.BackgroundTransparency = 1
FloatingCircle.Image = "rbxassetid://3570695787"
FloatingCircle.ImageColor3 = Color3.fromRGB(80, 180, 255)
FloatingCircle.Visible = false
FloatingCircle.ZIndex = 10

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Game Script Panel"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local function createButton(name, posY, callback)
    local button = Instance.new("TextButton", MainFrame)
    button.Text = name
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.AnchorPoint = Vector2.new(0, 0)
    button.MouseButton1Click:Connect(callback)
    return button
end

local Minimized = false
local MinimizeButton = createButton("-", 35, function()
    Minimized = true
    MainFrame.Visible = false
    FloatingCircle.Visible = true
end)

FloatingCircle.MouseButton1Click:Connect(function()
    Minimized = false
    MainFrame.Visible = true
    FloatingCircle.Visible = false
end)

local DoWButton = createButton("DoW Mode", 80, function()
    activeMode = "DoW"
end)

local GoGButton = createButton("GoG Mode", 130, function()
    activeMode = "GoG"
end)

local HnSButton = createButton("H&S Mode", 180, function()
    activeMode = "HnS"
end)

-- PLAYER LIST PANEL FOR GoG
local PlayerListFrame = Instance.new("ScrollingFrame", MainFrame)
PlayerListFrame.Position = UDim2.new(0, 10, 0, 230)
PlayerListFrame.Size = UDim2.new(1, -20, 0, 80)
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Visible = false

local function updatePlayerList()
    PlayerListFrame:ClearAllChildren()
    local y = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerListFrame)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, y)
            btn.Text = excludedPlayers[player] and ("Enable " .. player.Name) or ("Exclude " .. player.Name)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.MouseButton1Click:Connect(function()
                excludedPlayers[player] = not excludedPlayers[player]
                updatePlayerList()
            end)
            y = y + 30
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- ESP FUNCTION
local function createHighlight(target, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.OutlineTransparency = 0.4
    highlight.Parent = target
    return highlight
end

local function isBehindWall(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * aimDistance
    local raycast = workspace:Raycast(origin, direction, RaycastParams.new())
    return raycast and raycast.Instance and not raycast.Instance:IsDescendantOf(target.Parent)
end

-- AUTO AIM (choose nearest visible enemy)
local function getNearestEnemy()
    local closest, distance = nil, aimDistance
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local head = player.Character:FindFirstChild("Head")
            if head and not isBehindWall(head) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if dist < distance then
                    closest = head
                    distance = dist
                end
            end
        end
    end
    return closest
end

-- UI SCRIPT LOGIC
local currentTarget = nil
local highlights = {}
local frameCounter = 0

RunService.RenderStepped:Connect(function()
    frameCounter += 1
    if frameCounter % 2 ~= 0 then return end -- run at ~30 FPS

    PlayerListFrame.Visible = activeMode == "GoG"
    for _, highlight in pairs(highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlights = {}

    if activeMode == "DoW" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head and not isBehindWall(head) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local color = player.Team == LocalPlayer.Team and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                    highlights[player] = createHighlight(player.Character, color)
                end
            end
        end

        currentTarget = getNearestEnemy()
        if currentTarget and currentTarget.Parent then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, currentTarget.Position), 0.2)
        end

    elseif activeMode == "GoG" then
        updatePlayerList()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not excludedPlayers[player] then
                highlights[player] = createHighlight(player.Character, Color3.fromRGB(0,255,0))
            end
        end

    elseif activeMode == "HnS" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                highlights[player] = createHighlight(player.Character, Color3.fromRGB(0,0,255))
            end
        end
    end
end)

print("Universal Game Script UI Loaded — Floating Window Ready!")
