--// CONFIG
local SCRIPT_NAME = "PaidGrade"
local KEY_URL = "https://paidgrade-api.vercel.app/validate"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// EXECUTOR HTTP
local request = http_request or request or syn.request
if not request then
    warn("[PaidGrade] Executor does not support HTTP requests")
    return
end

--// USER KEY
local key = _G.script_key or getgenv().script_key
if not key then
    Players.LocalPlayer:Kick("[PaidGrade] No key provided")
end

--// HWID
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

--// VERIFY KEY WITH API
local success, res = pcall(function()
    return request({
        Url = KEY_URL,
        Method = "POST",
        Headers = { ["Content-Type"]="application/json" },
        Body = HttpService:JSONEncode({ key=key, hwid=HWID, script=SCRIPT_NAME })
    })
end)

if not success or not res then
    Players.LocalPlayer:Kick("[PaidGrade] Key server unreachable")
end

if res.StatusCode ~= 200 then
    Players.LocalPlayer:Kick("[PaidGrade] Server returned error: " .. tostring(res.StatusCode))
end

local data
local decodeSuccess, decodeErr = pcall(function()
    data = HttpService:JSONDecode(res.Body)
end)

if not decodeSuccess or not data then
    Players.LocalPlayer:Kick("[PaidGrade] Invalid server response")
end

if not data.valid then
    Players.LocalPlayer:Kick("[PaidGrade] Key invalid or expired")
end

-- =====================================================
-- AUTO BAT & SPEED (SEPARATE)
@@ -258,3 +203,4 @@ RunService.Heartbeat:Connect(function()
    end
