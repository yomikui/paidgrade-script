--// CONFIG
local SCRIPT_NAME = "PaidGrade"
local KEY_URL = "https://paidgrade-api.vercel.app/api/validate"
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua" -- main script

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

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

-- Decode API response
local data
local decodeSuccess, decodeErr = pcall(function()
    data = HttpService:JSONDecode(res.Body)
end)

if not decodeSuccess or not data then
    warn("Decode error:", decodeErr)
    Players.LocalPlayer:Kick("[PaidGrade] Invalid server response")
end

if not data.valid then
    Players.LocalPlayer:Kick("[PaidGrade] Key invalid or expired")
end

-- Show activation date
if data.activatedAt then
    local ts = data.activatedAt / 1000 -- milliseconds → seconds
    local date = os.date("*t", ts)
    local formatted = string.format("%02d/%02d/%04d %02d:%02d:%02d", 
        date.day, date.month, date.year, date.hour, date.min, date.sec)
    warn("[PaidGrade] Key activated on: " .. formatted)
end

--// LOAD MAIN SCRIPT
pcall(function()
    loadstring(game:HttpGet(https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua))()
end)

