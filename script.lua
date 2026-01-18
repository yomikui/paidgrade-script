
-- =====================================================
-- SPEED + AUTO BAT ON Q (CARRY SPEED 29 + BURST)
-- =====================================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Speed values
local NORMAL_SPEED = 58
local CARRY_SPEED = 29

-- Burst settings
local BURST_SPEED = 29.25
local BURST_DELAY = 3.5
local BURST_DURATION = 0.15

-- State
local speedToggled = false
local hittingCooldown = false
local burstActive = false
local burstTaskId = 0

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 190)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function makeBtn(txt, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = frame
    return b
end

local speedBtn = makeBtn("Speed", 0)
local closeBtn = makeBtn("X", 80)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 120)
statusLabel.Text = "Q: Carry Speed + Auto Bat"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = frame

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

-- ===== Q toggle =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        speedToggled = not speedToggled
        burstActive = false
        burstTaskId += 1
        local myTaskId = burstTaskId

        if speedToggled then
            local bat = getBat()
            if bat then
                bat.Parent = LocalPlayer.Character
                tryHitBat()
            end

            -- Burst after delay
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
    speedBtn.BackgroundColor3 = speedToggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

    if speedLbl then
        local displaySpeed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
        speedLbl.Text = "Speed: " .. string.format("%.1f", displaySpeed)
    end
end)

-- ===== Auto bat =====
RunService.Heartbeat:Connect(function()
    if speedToggled then
        tryHitBat()
    end
end)

-- =====================================================
-- SECOND SCRIPT LOAD (UNCHANGED)
-- =====================================================
pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"
    ))()
end)
