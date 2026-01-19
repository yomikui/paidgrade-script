--// CONFIG
local SCRIPT_NAME = "PaidGrade"
local KEY_URL = "https://paidgrade-api.vercel.app/validate"
local KEY_URL = "https://paidgrade-api.vercel.app/api/validate"
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua" -- main script

local HttpService = game:GetService("HttpService")
@@ -68,3 +68,4 @@ end
pcall(function()
    loadstring(game:HttpGet(https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua))()
