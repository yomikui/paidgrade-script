--// CONFIG
local SCRIPT_NAME = "PaidGrade"
local KEY_URL = "https://paidgrade-api.vercel.app/validate"
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua"

--// SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// EXECUTOR HTTP
local request = http_request or request or syn.request
if not request then
    warn("[PaidGrade] Executor does not support HTTP requests")
    return
end

--// KEY FROM USER
local key = _G.script_key or getgenv().script_key
if not key then
    Players.LocalPlayer:Kick("[PaidGrade]\nNo key provided.")
    return
end

--// HWID
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

--// VERIFY KEY WITH API
local success, res = pcall(function()
    return request({
        Url = KEY_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            key = key,
            hwid = HWID,
            script = SCRIPT_NAME
        })
    })
end)

if not success or not res then
    Players.LocalPlayer:Kick("[PaidGrade]\nKey server unreachable.")
    return
end

if res.StatusCode ~= 200 then
    Players.LocalPlayer:Kick("[PaidGrade]\nServer error: " .. tostring(res.StatusCode))
    return
end

local data
local decodeSuccess, decodeErr = pcall(function()
    data = HttpService:JSONDecode(res.Body)
end)

if not decodeSuccess or not data then
    Players.LocalPlayer:Kick("[PaidGrade]\nInvalid server response.")
    return
end

if not data.valid then
    Players.LocalPlayer:Kick("[PaidGrade]\nKey invalid or expired.")
    return
end

--// LOAD MAIN SCRIPT
pcall(function()
    loadstring(game:HttpGet(https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua))()
end)

