-- LIVE LIVE LIVE LIVE LIVE
-- LIVE LIVE LIVE LIVE LIVE


local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local request = syn and syn.request or http_request or (http and http.request)
local player = game.Players.LocalPlayer
local Rematch = game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()
local workspaceService = game:GetService("Workspace")
local NoAFK = false

for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
  v:Disable()
end

if not player then
    warn("Player is nil! Cannot proceed.")
    return
end
print("executed LIVE", player.Name)

local function sendWeb(color, role, player)
    if not request then
        warn("Request function is not available! Your executor may not support HTTP requests.")
        return
    end


    local Level = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Lvl.Text

    local OSTime = os.time()
    local Time = os.date('!*t', OSTime)

    -- Ensure all values exist, otherwise provide defaults
    local playerName = player and player.Name or "Unknown Player"
    local displayName = player and player.DisplayName or "Unknown DisplayName"
    local userId = player and player.UserId or 0
    local roleName = role or "Unknown Role"
    local colorValue = math.random(0, 16777215) -- Random color if none is provided
    local iconUrl = icon and "https://files.catbox.moe/" .. icon or ""

    -- Construct the embed
    local testEmbed = {
        content = "",
        embeds = {{
            title = "ABA Ranked Farm Webhook",
            color = colorValue,
            fields = {
                { name = roleName .. " Name:", value = playerName .. " [" .. displayName .. "]", inline = true },
                { name = "Level:", value = Level, inline = false } -- No bold, using code block for size change
            },
            thumbnail = { url = iconUrl },
            timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
        }}
    }

    -- Debug JSON payload before sending
    local success, jsonData = pcall(function()
        return HttpService:JSONEncode(testEmbed)
    end)

    -- Send the request
    request({
        Url = _G.webhook,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = jsonData
    })
end
-- Example call (change values as needed)

workspaceService.ChildAdded:Connect(function(MapAdded)
    if MapAdded.Name == "Map" then
        print("Map detected! Starting Rematch", player.Name)
        sendWeb(65280, "User", player)
        NoAFK = true
        AntiAfk()
    end
end)
game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
    if v.Name == "BanChooser" then 
        v:WaitForChild("rem"):FireServer("pass")
    end
end)
workspaceService.ChildRemoved:Connect(function(MapRemoved)
    if MapRemoved.Name == "Map" then
        NoAFK = false
    end
end)
