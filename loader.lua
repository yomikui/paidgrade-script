-- PaidGrade Loader (GUI + Auto Key Entry)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Executor HTTP check
local request = (syn and syn.request) or http_request or request
if not request then
    player:Kick("[PaidGrade] Your executor does not support HTTP requests!")
end

-- URLs
local KEY_URL = "https://paidgrade-api.vercel.app/api/validate"
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0,280,0,40)
keyBox.Position = UDim2.new(0,10,0,20)
keyBox.PlaceholderText = "Enter your PaidGrade key"
keyBox.ClearTextOnFocus = false
keyBox.TextScaled = true
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
keyBox.Parent = frame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0,280,0,40)
submitBtn.Position = UDim2.new(0,10,0,70)
submitBtn.Text = "Submit & Load"
submitBtn.TextScaled = true
submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
submitBtn.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0,280,0,30)
statusLabel.Position = UDim2.new(0,10,0,120)
statusLabel.Text = ""
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = frame

-- Submit
submitBtn.MouseButton1Click:Connect(function()
    local key = keyBox.Text
    if key == "" then
        statusLabel.Text = "Please enter a key!"
        return
    end
    _G.script_key = key
    statusLabel.Text = "Verifying key..."

    local ok,res = pcall(function()
        return request({
            Url = KEY_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = HWID, script = "PaidGrade" })
        })
    end)

    if not ok or not res then
        statusLabel.Text = "Server unreachable!"
        return
    end

    if res.StatusCode ~= 200 then
        statusLabel.Text = "Server error: "..res.StatusCode
        return
    end

    local data
    local decodeOk, err = pcall(function() data = HttpService:JSONDecode(res.Body) end)
    if not decodeOk or not data then
        statusLabel.Text = "Invalid server response!"
        return
    end

    if not data.valid then
        statusLabel.Text = "Key invalid, expired, or HWID mismatch!"
        return
    end

    statusLabel.Text = "Key valid! Loading script..."
    local loadOk, loadErr = pcall(function()
        loadstring(game:HttpGet(SCRIPT_RAW_URL))()
    end)

    if not loadOk then
        statusLabel.Text = "Failed to load script!"
        warn("Loader error:", loadErr)
    else
        statusLabel.Text = "Script loaded successfully!"
        gui:Destroy()
    end
end)
