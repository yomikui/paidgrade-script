
-- =====================================================
-- AUTO BAT & SPEED (SEPARATE)
-- =====================================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Speed values
local NORMAL_SPEED = 57.25
local CARRY_SPEED = 29

-- Burst settings
local BURST_SPEED = 29.10
local BURST_DELAY = 3.5
local BURST_DURATION = 0.06

-- State
local speedToggled = false
local autoBatToggled = false
local hittingCooldown = false
local burstActive = false
local burstTaskId = 0

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function makeBtn(txt, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 260, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = frame
    return b
end

local speedBtn = makeBtn("Speed", 10, Color3.fromRGB(255,0,0))
local autoBatBtn = makeBtn("Auto-Bat", 60, Color3.fromRGB(255,0,0))
local closeBtn = makeBtn("X", 110, Color3.fromRGB(150,0,0))

-- Label for Q instruction
local helpLabel = Instance.new("TextLabel")
helpLabel.Size = UDim2.new(0, 260, 0, 30)
helpLabel.Position = UDim2.new(0, 10, 0, 160)
helpLabel.Text = "Q - Brainrot Pickup Help"
helpLabel.Font = Enum.Font.GothamBold
helpLabel.TextScaled = true
helpLabel.TextColor3 = Color3.fromRGB(255,255,255)
helpLabel.BackgroundTransparency = 1
helpLabel.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ===== Character setup =====
local h, hrp, speedLbl
local function setupChar(char)
    h = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    local head = char:FindFirstChild("Head")
    if head then
        local bb = Instance.new("BillboardGui", head)
        bb.Size = UDim2.new(0,120,0,25)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true

        speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Size = UDim2.new(1,0,1,0)
        speedLbl.BackgroundTransparency = 1
        speedLbl.TextColor3 = Color3.fromRGB(0,255,255)
        speedLbl.Font = Enum.Font.GothamBold
        speedLbl.TextScaled = true
        speedLbl.TextStrokeTransparency = 0
    end
end

LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then
    setupChar(LocalPlayer.Character)
end

-- ===== Get Bat =====
local function getBat()
    local char = LocalPlayer.Character
    if not char then return nil end

    local tool = char:FindFirstChild("Bat")
    if tool then return tool end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        tool = backpack:FindFirstChild("Bat")
        if tool then
            tool.Parent = char
            return tool
        end
    end
    return nil
end

-- ===== Bat hit =====
local SAFE_DELAY = 0.08
local function tryHitBat()
    if hittingCooldown then return end
    hittingCooldown = true

    local bat = getBat()
    if bat then
        pcall(function()
            bat:Activate()
            local evt = bat:FindFirstChildWhichIsA("RemoteEvent")
            if evt then
                evt:FireServer()
            end
        end)
    end

    task.delay(SAFE_DELAY, function()
        hittingCooldown = false
    end)
end

-- ===== Speed Toggle (Q) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        speedToggled = not speedToggled

        if speedToggled then
            burstActive = false
            burstTaskId += 1
            local myTaskId = burstTaskId

            task.delay(BURST_DELAY, function()
                if speedToggled and burstTaskId == myTaskId then
                    burstActive = true
                    task.delay(BURST_DURATION, function()
                        if burstTaskId == myTaskId then
                            burstActive = false
                        end
                    end)
                end
            end)
        end
    end
end)

-- ===== GUI Button Logic =====
speedBtn.MouseButton1Click:Connect(function()
    speedToggled = not speedToggled
end)

autoBatBtn.MouseButton1Click:Connect(function()
    autoBatToggled = not autoBatToggled
    autoBatBtn.BackgroundColor3 = autoBatToggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

-- ===== Movement =====
RunService.RenderStepped:Connect(function()
    if not (h and hrp) then return end

    local md = h.MoveDirection
    local speed =
        speedToggled
        and (burstActive and BURST_SPEED or CARRY_SPEED)
        or NORMAL_SPEED

    if md.Magnitude > 0 then
        hrp.Velocity = Vector3.new(md.X * speed, hrp.Velocity.Y, md.Z * speed)
    end

    speedBtn.Text = string.format("Speed: %.2f", speed)

    if speedLbl then
        local displaySpeed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
        speedLbl.Text = "Speed: " .. string.format("%.1f", displaySpeed)
    end
end)

-- ===== Auto Bat Loop =====
RunService.Heartbeat:Connect(function()
    if autoBatToggled then
        tryHitBat()
    end
end)


