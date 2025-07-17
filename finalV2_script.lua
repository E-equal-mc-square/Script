-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local aimDistance = 250
local excludedPlayers = {}
local AimEnabled = false
local WallbangEnabled = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DogsOfWarAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Aim Button
local ToggleAimBtn = Instance.new("TextButton")
ToggleAimBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleAimBtn.Position = UDim2.new(0.01, 0, 0.25, 0)
ToggleAimBtn.Text = "Auto Aim [OFF]"
ToggleAimBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleAimBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleAimBtn.TextScaled = true
ToggleAimBtn.BorderSizePixel = 0
ToggleAimBtn.Parent = ScreenGui

ToggleAimBtn.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    ToggleAimBtn.Text = "Auto Aim [" .. (AimEnabled and "ON" or "OFF") .. "]"
end)

-- Wallbang Button
local WallbangBtn = Instance.new("TextButton")
WallbangBtn.Size = UDim2.new(0, 120, 0, 40)
WallbangBtn.Position = UDim2.new(0.01, 0, 0.35, 0)
WallbangBtn.Text = "Wallbang [OFF]"
WallbangBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
WallbangBtn.TextColor3 = Color3.new(1, 1, 1)
WallbangBtn.TextScaled = true
WallbangBtn.BorderSizePixel = 0
WallbangBtn.Parent = ScreenGui

WallbangBtn.MouseButton1Click:Connect(function()
    WallbangEnabled = not WallbangEnabled
    WallbangBtn.Text = "Wallbang [" .. (WallbangEnabled and "ON" or "OFF") .. "]"
end)

-- damageCharacter Finder
local damageCharacter = nil
for i, v in pairs(getgc(true)) do
    if typeof(v) == "function" and islclosure(v) then
        local info = debug.getinfo(v)
        if info.name == "damageCharacter" then
            damageCharacter = v
            break
        end
    end
end

-- Visibility Check
local function isVisible(character)
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin).Unit * aimDistance

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, raycastParams)
    return result and result.Instance and result.Instance:IsDescendantOf(character)
end

-- Get Closest Visible Target (showing "!")
local function getClosestVisibleTarget()
    local closest, shortestDistance = nil, aimDistance + 1
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not excludedPlayers[player.Name] and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                local head = char:FindFirstChild("Head")
                local alert = head and head:FindFirstChild("EnemyAlert")
                if humanoid and humanoid.Health > 0 and head and alert then
                    local dist = (head.Position - Camera.CFrame.Position).Magnitude
                    if dist < shortestDistance then
                        closest = head
                        shortestDistance = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Get Closest Enemy (any, including behind walls)
local function getClosestEnemy()
    local closest, shortestDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("Head") then
                local dist = (Camera.CFrame.Position - char.Head.Position).Magnitude
                if dist < shortestDist then
                    closest = char
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

-- ESP Highlighting (unchanged)
local function refreshESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and head then
                if char:FindFirstChild("ESP_Highlight") then
                    char.ESP_Highlight:Destroy()
                end
                local hl = Instance.new("Highlight")
                hl.Name = "ESP_Highlight"
                if player.Team == LocalPlayer.Team then
                    hl.FillColor = Color3.fromRGB(0, 0, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 0, 255)
                else
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                end
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = char
                hl.Parent = char

                -- Enemy alert (!)
                local alertGui = head:FindFirstChild("EnemyAlert")
                if player.Team ~= LocalPlayer.Team and isVisible(char) then
                    if not alertGui then
                        alertGui = Instance.new("BillboardGui")
                        alertGui.Name = "EnemyAlert"
                        alertGui.Size = UDim2.new(0, 50, 0, 50)
                        alertGui.StudsOffset = Vector3.new(0, 2.5, 0)
                        alertGui.AlwaysOnTop = true
                        alertGui.Parent = head

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = "!"
                        textLabel.TextColor3 = Color3.new(1, 0, 0)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.ArialBold
                        textLabel.Parent = alertGui
                    end
                elseif alertGui then
                    alertGui:Destroy()
                end
            end
        end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    refreshESP()

    if AimEnabled then
        local targetHead = nil
        if WallbangEnabled then
            -- Wallbang ON: prefer visible target, else closest behind wall
            targetHead = getClosestVisibleTarget()
            if not targetHead then
                local enemyChar = getClosestEnemy()
                if enemyChar then
                    targetHead = enemyChar:FindFirstChild("Head")
                end
            end
        else
            -- Wallbang OFF: only visible target
            targetHead = getClosestVisibleTarget()
        end

        if targetHead and Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end

    if WallbangEnabled and damageCharacter then
        local enemy = getClosestEnemy()
        if enemy then
            pcall(function()
                damageCharacter(enemy)
            end)
        end
    end
end)
