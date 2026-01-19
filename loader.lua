-- =========================================
-- PAIDGRADE LOADER
-- =========================================

-- CONFIG
local SCRIPT_NAME = "PaidGrade"
local KEY_URL = "https://paidgrade-api.vercel.app/api/validate"
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- EXECUTOR HTTP
local request = (syn and syn.request) or http_request or request
if not request then
    warn("[PaidGrade] Executor does not support HTTP requests")
    return
end

-- USER KEY
local key = _G.script_key or getgenv().script_key
if not key then
    Players.LocalPlayer:Kick("[PaidGrade] No key provided")
    return
end

-- HWID
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- VERIFY KEY
local success, res = pcall(function()
    return request({
        Url = KEY_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            key = key,
            hwid = HWID,
            script = SCRIPT_NAME
        })
    })
end)

if not success or not res then
    Players.LocalPlayer:Kick("[PaidGrade] Key server unreachable")
    return
end

if res.StatusCode ~= 200 then
    Players.LocalPlayer:Kick("[PaidGrade] Server error: " .. tostring(res.StatusCode))
    return
end

-- PARSE RESPONSE
local data
local ok, err = pcall(function()
    data = HttpService:JSONDecode(res.Body)
end)

if not ok or not data then
    Players.LocalPlayer:Kick("[PaidGrade] Invalid server response")
    return
end

if not data.valid then
    local msg = data.error or "Key invalid or expired"
    Players.LocalPlayer:Kick("[PaidGrade] " .. msg)
    return
end

-- SHOW ACTIVATION DATE
if data.activatedAt then
    local ts = data.activatedAt / 1000
    local date = os.date("*t", ts)
    local formatted = string.format("%02d/%02d/%04d %02d:%02d:%02d",
        date.day, date.month, date.year, date.hour, date.min, date.sec)
    warn("[PaidGrade] Key activated on: " .. formatted)
end

-- LOAD MAIN SCRIPT
pcall(function()
    loadstring(game:HttpGet(SCRIPT_RAW_URL))()
end)
