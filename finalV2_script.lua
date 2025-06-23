-- 🌟 Glowing V2 Game Panel by Charlotte 💜
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Clear old UI
if CoreGui:FindFirstChild("FinalV2_UI") then CoreGui.FinalV2_UI:Destroy() end

local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "FinalV2_UI"

local Frame = Instance.new("Frame", UI)
Frame.Size = UDim2.new(0, 160, 0, 150)
Frame.Position = UDim2.new(0, 20, 0, 30)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
Frame.Draggable = true
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Frame).Color = Color3.fromRGB(120, 0, 255)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "✨ Game Panel"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(200, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local function createButton(name, y, callback)
    local B = Instance.new("TextButton", Frame)
    B.Size = UDim2.new(1, -20, 0, 30)
    B.Position = UDim2.new(0, 10, 0, y)
    B.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
    B.Text = name
    B.TextColor3 = Color3.new(1, 1, 1)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 14
    Instance.new("UICorner", B)
    B.MouseButton1Click:Connect(callback)
end

-- Helper for social buttons
local function createSocialButton(parent, text, pos, url)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 140, 0, 25)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70, 0, 100)
    btn.TextColor3 = Color3.fromRGB(200, 180, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        -- Open link in default browser (will only work if your environment supports)
        if syn and syn.request then
            syn.request({Url = url, Method = "GET"})
        elseif http and http.request then
            http.request({Url = url, Method = "GET"})
        else
            print("Open URL:", url)
        end
    end)
    return btn
end

-- ===== DoW Panel =====
local function launchDoW()
    UI:Destroy()
    local aimUI = Instance.new("ScreenGui", CoreGui)
    aimUI.Name = "DoW_UI"

    local Frame = Instance.new("Frame", aimUI)
    Frame.Size = UDim2.new(0, 300, 0, 250)
    Frame.Position = UDim2.new(0, 30, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Frame.Draggable = true
    Frame.Active = true
    Instance.new("UICorner", Frame)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(160, 0, 255)

    local function label(text, pos)
        local L = Instance.new("TextLabel", Frame)
        L.Size = UDim2.new(1, -20, 0, 20)
        L.Position = pos
        L.Text = text
        L.TextColor3 = Color3.fromRGB(190, 160, 255)
        L.Font = Enum.Font.Gotham
        L.TextSize = 14
        L.BackgroundTransparency = 1
        L.TextXAlignment = Enum.TextXAlignment.Left
        return L
    end

    local aiming = false
    local aimDistance = 200
    local targets = {}
    local currentIndex = 1

    -- Clear old highlights on refresh
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local highlight = p.Character:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
        end
    end

    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and not p.Character:FindFirstChildOfClass("Highlight") then
                local h = Instance.new("Highlight", p.Character)
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0.3
                h.FillColor = (p.Team == LocalPlayer.Team) and Color3.new(0, 0.5, 1) or Color3.new(1, 0, 0)
            end
        end
    end)

    local function isVisible(targetHead)
        local origin = Camera.CFrame.Position
        local direction = (targetHead.Position - origin).Unit * 999
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = workspace:Raycast(origin, direction, raycastParams)
        return raycastResult and raycastResult.Instance:IsDescendantOf(targetHead.Parent)
    end

    local function updateTargets()
    targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then -- only alive players
                local dist = (Camera.CFrame.Position - p.Character.Head.Position).Magnitude
                if dist <= aimDistance then
                    local ray = Ray.new(Camera.CFrame.Position, (p.Character.Head.Position - Camera.CFrame.Position).Unit * dist)
                    local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
                    if hitPart and hitPart:IsDescendantOf(p.Character) then
                        table.insert(targets, p)
                    end
                end
            end
        end
    end
end


    local function aimAt(p)
        if p and p.Character and p.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position)
        end
    end

    RunService.RenderStepped:Connect(function()
        if aiming and #targets > 0 then
            aimAt(targets[currentIndex])
        end
    end)

    label("Aiming Distance (50-400):", UDim2.new(0, 10, 0, 10))

    local input = Instance.new("TextBox", Frame)
    input.Size = UDim2.new(0, 80, 0, 25)
    input.Position = UDim2.new(0, 10, 0, 35)
    input.PlaceholderText = "200"
    input.Text = tostring(aimDistance)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input)
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val and val >= 50 and val <= 400 then
            aimDistance = val
        else
            input.Text = tostring(aimDistance)
        end
        updateTargets()
    end)

    local toggle = Instance.new("TextButton", Frame)
    toggle.Size = UDim2.new(0, 130, 0, 30)
    toggle.Position = UDim2.new(0, 10, 0, 70)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    toggle.Text = "Aiming: OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    Instance.new("UICorner", toggle)
    toggle.MouseButton1Click:Connect(function()
        aiming = not aiming
        toggle.Text = "Aiming: " .. (aiming and "ON" or "OFF")
        if aiming then updateTargets() end
    end)

    local function createCtrlButton(text, pos, func)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(0, 130, 0, 30)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(func)
    end

    createCtrlButton("🎯 Nearest", UDim2.new(0, 10, 0, 110), function()
    updateTargets()
    if #targets > 0 then
        -- Sort targets by distance from camera to head
        table.sort(targets, function(a, b)
            local da = (Camera.CFrame.Position - a.Character.Head.Position).Magnitude
            local db = (Camera.CFrame.Position - b.Character.Head.Position).Magnitude
            return da < db
        end)
        currentIndex = 1
        aimAt(targets[currentIndex])
    end
end)


    createCtrlButton("⏮️ Previous", UDim2.new(0, 160, 0, 110), function()
        updateTargets()
        if #targets > 0 then
            currentIndex = (currentIndex - 2) % #targets + 1
            aimAt(targets[currentIndex])
        end
    end)

    createCtrlButton("⏭️ Next", UDim2.new(0, 160, 0, 150), function()
        updateTargets()
        if #targets > 0 then
            currentIndex = currentIndex % #targets + 1
            aimAt(targets[currentIndex])
        end
    end)

    -- Minimize / Maximize button with rotation
    local minimized = false
    local minBtn = Instance.new("TextButton", Frame)
    minBtn.Size = UDim2.new(0, 35, 0, 25)
    minBtn.Position = UDim2.new(1, -45, 0, 5)
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", minBtn)

    local tweenService = game:GetService("TweenService")
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            for _, child in pairs(Frame:GetChildren()) do
                if child ~= minBtn and child ~= Title then
                    child.Visible = false
                end
            end
            Frame.Size = UDim2.new(0, 300, 0, 35)
            local tween = tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 90})
            tween:Play()
        else
            for _, child in pairs(Frame:GetChildren()) do
                child.Visible = true
            end
            Frame.Size = UDim2.new(0, 300, 0, 250)
            local tween = tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 0})
            tween:Play()
        end
    end)

    -- Developer credits and social buttons
    label("Made for Natan by Charlotte 💜", UDim2.new(0, 10, 0, 190))
    label("👨‍💻 Dev: E = mc² (Kilometres)", UDim2.new(0, 10, 0, 210))

    local tgBtn = createSocialButton(Frame, "Telegram @E_equal_mc_square", UDim2.new(0, 10, 0, 230), "https://t.me/E_equal_mc_square")
    local ttBtn = createSocialButton(Frame, "TikTok @e_equal_mc_square", UDim2.new(0, 10, 0, 265), "https://www.tiktok.com/@e_equal_mc_square?_t=8q2fpL5llSO&_r=1")
end

-- ===== Gun of Ground Panel =====
local function launchGoG()
    UI:Destroy()
    local gogUI = Instance.new("ScreenGui", CoreGui)
    gogUI.Name = "GoG_UI"

    local Frame = Instance.new("Frame", gogUI)
    Frame.Size = UDim2.new(0, 320, 0, 300)
    Frame.Position = UDim2.new(0, 30, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Frame.Draggable = true
    Frame.Active = true
    Instance.new("UICorner", Frame)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(160, 0, 255)

    local playersList = Instance.new("ScrollingFrame", Frame)
    playersList.Size = UDim2.new(1, -20, 0, 180)
    playersList.Position = UDim2.new(0, 10, 0, 10)
    playersList.BackgroundColor3 = Color3.fromRGB(35, 10, 60)
    playersList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playersList.ScrollBarThickness = 6
    Instance.new("UICorner", playersList)

    local aiming = false
    local aimDistance = 200
    local targets = {}
    local currentIndex = 1
    local ignored = {}

    local function updateList()
        playersList:ClearAllChildren()
        local yPos = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                local frame = Instance.new("Frame", playersList)
                frame.Size = UDim2.new(1, 0, 0, 30)
                frame.Position = UDim2.new(0, 0, 0, yPos)
                frame.BackgroundColor3 = Color3.fromRGB(50, 0, 70)
                Instance.new("UICorner", frame)

                local nameLbl = Instance.new("TextLabel", frame)
                nameLbl.Text = p.Name
                nameLbl.TextColor3 = Color3.new(1, 1, 1)
                nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = Enum.Font.Gotham
                nameLbl.TextSize = 14
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                local health = p.Character.Humanoid.Health
                local healthLbl = Instance.new("TextLabel", frame)
                healthLbl.Text = "HP: " .. math.floor(health)
                healthLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
                healthLbl.Size = UDim2.new(0.4, -10, 1, 0)
                healthLbl.Position = UDim2.new(0.6, 5, 0, 0)
                healthLbl.BackgroundTransparency = 1
                healthLbl.Font = Enum.Font.GothamBold
                healthLbl.TextSize = 14
                healthLbl.TextXAlignment = Enum.TextXAlignment.Right

                local btn = Instance.new("TextButton", frame)
                btn.Size = UDim2.new(0, 40, 0, 20)
                btn.Position = UDim2.new(1, -45, 0, 5)
                btn.Text = (ignored[p] and "✔" or "✘")
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 18
                btn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
                btn.TextColor3 = Color3.new(1, 1, 1)
                Instance.new("UICorner", btn)

                btn.MouseButton1Click:Connect(function()
                    ignored[p] = not ignored[p]
                    btn.Text = (ignored[p] and "✔" or "✘")
                    updateTargets()
                end)

                yPos = yPos + 35
            end
        end
        playersList.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end

    local function updateTargets()
        targets = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not ignored[p] and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (Camera.CFrame.Position - p.Character.Head.Position).Magnitude
                if dist <= aimDistance then
                    table.insert(targets, p)
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if aiming and #targets > 0 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targets[currentIndex].Character.Head.Position)
        end
    end)

    local function label(text, pos)
        local L = Instance.new("TextLabel", Frame)
        L.Size = UDim2.new(1, -20, 0, 20)
        L.Position = pos
        L.Text = text
        L.TextColor3 = Color3.fromRGB(190, 160, 255)
        L.Font = Enum.Font.Gotham
        L.TextSize = 14
        L.BackgroundTransparency = 1
        L.TextXAlignment = Enum.TextXAlignment.Left
    end

    label("Aiming Distance (50-400):", UDim2.new(0, 10, 0, 195))
    local input = Instance.new("TextBox", Frame)
    input.Size = UDim2.new(0, 80, 0, 25)
    input.Position = UDim2.new(0, 10, 0, 220)
    input.Text = tostring(aimDistance)
    input.Font = Enum.Font.Gotham
    input.TextColor3 = Color3.new(1, 1, 1)
    input.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    Instance.new("UICorner", input)
    input.FocusLost:Connect(function()
        local v = tonumber(input.Text)
        if v and v <= 400 and v >= 50 then
            aimDistance = v
        else
            input.Text = tostring(aimDistance)
        end
        updateTargets()
    end)

    local toggle = Instance.new("TextButton", Frame)
    toggle.Size = UDim2.new(0, 130, 0, 30)
    toggle.Position = UDim2.new(0, 100, 0, 220)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    toggle.Text = "Aiming: OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    Instance.new("UICorner", toggle)
    toggle.MouseButton1Click:Connect(function()
        aiming = not aiming
        toggle.Text = "Aiming: " .. (aiming and "ON" or "OFF")
        if aiming then updateTargets() end
    end)

    local function aim(p) Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position) end

    local function btn(txt, pos, act)
        local b = Instance.new("TextButton", Frame)
        b.Size = UDim2.new(0, 130, 0, 30)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(act)
        return b
    end

    btn("🎯 Nearest", UDim2.new(0, 10, 0, 260), function()
        updateTargets()
        if #targets > 0 then
            currentIndex = 1
            aim(targets[currentIndex])
        end
    end)
    btn("⏮️ Previous", UDim2.new(0, 160, 0, 260), function()
        updateTargets()
        if #targets > 0 then
            currentIndex = (currentIndex - 2) % #targets + 1
            aim(targets[currentIndex])
        end
    end)
    btn("⏭️ Next", UDim2.new(0, 160, 0, 300), function()
        updateTargets()
        if #targets > 0 then
            currentIndex = currentIndex % #targets + 1
            aim(targets[currentIndex])
        end
    end)

    -- Minimize / Maximize for GoG
    local minimized = false
    local minBtn = Instance.new("TextButton", Frame)
    minBtn.Size = UDim2.new(0, 35, 0, 25)
    minBtn.Position = UDim2.new(1, -45, 0, 5)
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", minBtn)
    local tweenService = game:GetService("TweenService")
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            for _, c in pairs(Frame:GetChildren()) do
                if c ~= minBtn then
                    c.Visible = false
                end
            end
            Frame.Size = UDim2.new(0, 320, 0, 35)
            tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 90}):Play()
        else
            for _, c in pairs(Frame:GetChildren()) do
                c.Visible = true
            end
            Frame.Size = UDim2.new(0, 320, 0, 330)
            tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end)

    updateList()

    label("Made for Natan by Charlotte 💜", UDim2.new(0, 10, 0, 290))
    label("👨‍💻 Dev: E = mc² (Kilometres)", UDim2.new(0, 10, 0, 310))

    createSocialButton(Frame, "Telegram @E_equal_mc_square", UDim2.new(0, 10, 0, 320), "https://t.me/E_equal_mc_square")
    createSocialButton(Frame, "TikTok @e_equal_mc_square", UDim2.new(0, 10, 0, 350), "https://www.tiktok.com/@e_equal_mc_square?_t=8q2fpL5llSO&_r=1")
end

-- ===== Hide & Seek Panel =====
local function launchHS()
    UI:Destroy()
    local hsUI = Instance.new("ScreenGui", CoreGui)
    hsUI.Name = "HS_UI"

    local Frame = Instance.new("Frame", hsUI)
    Frame.Size = UDim2.new(0, 280, 0, 170)
    Frame.Position = UDim2.new(0, 30, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Frame.Draggable = true
    Frame.Active = true
    Instance.new("UICorner", Frame)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(160, 0, 255)

    local function label(text, pos)
        local L = Instance.new("TextLabel", Frame)
        L.Size = UDim2.new(1, -20, 0, 20)
        L.Position = pos
        L.Text = text
        L.TextColor3 = Color3.fromRGB(190, 160, 255)
        L.Font = Enum.Font.Gotham
        L.TextSize = 14
        L.BackgroundTransparency = 1
        L.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- ESP blue highlight for hiders (even if morphed)
    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and not p.Character:FindFirstChildOfClass("Highlight") then
                local h = Instance.new("Highlight", p.Character)
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0.3
                h.FillColor = Color3.fromRGB(0, 150, 255) -- blue highlight
            end
        end
    end)

    label("Hide & Seek: Blue highlights on all hiders", UDim2.new(0, 10, 0, 10))

    local minimized = false
    local minBtn = Instance.new("TextButton", Frame)
    minBtn.Size = UDim2.new(0, 35, 0, 25)
    minBtn.Position = UDim2.new(1, -45, 0, 5)
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", minBtn)

    local tweenService = game:GetService("TweenService")
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            for _, c in pairs(Frame:GetChildren()) do
                if c ~= minBtn then
                    c.Visible = false
                end
            end
            Frame.Size = UDim2.new(0, 280, 0, 35)
            tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 90}):Play()
        else
            for _, c in pairs(Frame:GetChildren()) do
                c.Visible = true
            end
            Frame.Size = UDim2.new(0, 280, 0, 170)
            tweenService:Create(minBtn, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end)

    label("Made for Natan by Charlotte 💜", UDim2.new(0, 10, 0, 120))
    label("👨‍💻 Dev: E = mc² (Kilometres)", UDim2.new(0, 10, 0, 140))

    createSocialButton(Frame, "Telegram @E_equal_mc_square", UDim2.new(0, 10, 0, 160), "https://t.me/E_equal_mc_square")
    createSocialButton(Frame, "TikTok @e_equal_mc_square", UDim2.new(0, 10, 0, 190), "https://www.tiktok.com/@e_equal_mc_square?_t=8q2fpL5llSO&_r=1")
end

-- Main Menu Buttons
createButton("🐺 Dog of War", 40, launchDoW)
createButton("🔫 Gun of Ground", 75, launchGoG)
createButton("👀 Hide & Seek", 110, launchHS)
