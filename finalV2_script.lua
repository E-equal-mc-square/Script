-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local aimDistance = 250
local excludedPlayers = {}
local AimEnabled = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DogsOfWarAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleBtn.Position = UDim2.new(0.01, 0, 0.25, 0)
ToggleBtn.Text = "Auto Aim [OFF]"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    ToggleBtn.Text = "Auto Aim [" .. (AimEnabled and "ON" or "OFF") .. "]"
end)

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

-- Find Closest Visible Target (Only if showing "!")
local function getClosestTarget()
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

-- ESP Highlighting
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

-- Add Jump Button (with 190 jump power = 90 + 100)
local function addJumpButton()
    local jumpBtn = Instance.new("TextButton")
    jumpBtn.Size = UDim2.new(0, 80, 0, 80)
    jumpBtn.Position = UDim2.new(1, -90, 1, -90)
    jumpBtn.AnchorPoint = Vector2.new(0, 0)
    jumpBtn.Text = "Jump"
    jumpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    jumpBtn.TextColor3 = Color3.new(1, 1, 1)
    jumpBtn.TextScaled = true
    jumpBtn.BorderSizePixel = 0
    jumpBtn.Parent = ScreenGui

    jumpBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            local originalJumpPower = humanoid.JumpPower
            humanoid.JumpPower = 190 -- updated jump power
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.delay(0.5, function()
                if humanoid then
                    humanoid.JumpPower = originalJumpPower
                end
            end)
        end
    end)
end
addJumpButton()

-- Main Loop
RunService.RenderStepped:Connect(function()
    refreshESP()
    if AimEnabled then
        local targetHead = getClosestTarget()
        if targetHead and Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)
