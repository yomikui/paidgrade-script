--// CONFIG
local SCRIPT_RAW_URL = "https://raw.githubusercontent.com/yomikui/paidgrade-script/main/script.lua"

--// LOAD SCRIPT
pcall(function()
    loadstring(game:HttpGet(SCRIPT_RAW_URL))()
end)
