-- Universal Game Script UI with DoW, GoG, and H&S modes

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
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    return button
end

local Minimized = false
local MinimizeButton = createButton("-", 35, function()
    Minimized = not Minimized
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child:IsA("TextButton") and child ~= MinimizeButton then
            child.Visible = not Minimized
        end
    end
    -- Circular transition effect
    local tween = TweenService:Create(
        MinimizeButton,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {
            Rotation = Minimized and 180 or 0,
            Size = Minimized and UDim2.new(0, 40, 0, 40) or UDim2.new(1, -20, 0, 40),
            BackgroundColor3 = Minimized and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        }
    )
    tween:Play()
    MinimizeButton.Text = Minimized and "+" or "-"
end)
MinimizeButton.Rotation = 0

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
    local targetPos = target.Position
    local ray = Ray.new(origin, (targetPos - origin).Unit * aimDistance)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit and hit:IsDescendantOf(target.Parent) == false
end

-- AUTO AIM
local function getNearestEnemy()
    local closest, distance = nil, aimDistance
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local head = player.Character:FindFirstChild("Head")
            if head then
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

RunService.RenderStepped:Connect(function()
    PlayerListFrame.Visible = activeMode == "GoG"
    if activeMode == "DoW" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    if highlights[player] then highlights[player]:Destroy() end
                    local color = player.Team == LocalPlayer.Team and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                    if player.Team ~= LocalPlayer.Team and isBehindWall(head) then
                        color = Color3.fromRGB(0,255,0)
                    end
                    highlights[player] = createHighlight(player.Character, color)
                end
            end
        end
        currentTarget = getNearestEnemy()
        if currentTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
        end

    elseif activeMode == "GoG" then
        updatePlayerList()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not excludedPlayers[player] then
                if highlights[player] then highlights[player]:Destroy() end
                highlights[player] = createHighlight(player.Character, Color3.fromRGB(0,255,0))
            elseif highlights[player] then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
        end

    elseif activeMode == "HnS" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if highlights[player] then highlights[player]:Destroy() end
                highlights[player] = createHighlight(player.Character, Color3.fromRGB(0,0,255))
            end
        end
    end
end)

print("Universal Game Script UI Loaded — Upgraded Edition!")
