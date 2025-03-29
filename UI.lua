    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Live = game.Workspace.Live
    local player = game.Players.LocalPlayer
    local workspaceService = game:GetService("Workspace")
    local resetLoopActive = false 
    local deaths = game:GetService("Players").LocalPlayer.leaderstats.Deaths
    local waitTime = 9 -- for einstein change this to higher number and the one on line 56 and 30
    local HttpService = game:GetService("HttpService")
    local request = syn and syn.request or http_request or (http and http.request)
    _G.Play = false


    -- Create UI Window
    local Window = Fluent:CreateWindow({
        Title = "ABA Demon script 101 " .. Fluent.Version,
        SubTitle = "Puma",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Define Tabs
    local Tabs = {
        Main = Window:AddTab({ Title = "Nanami", Icon = "knife" }),
        Death = Window:AddTab({ Title = "Death", Icon = "skull" }),
        Live = Window:AddTab({ Title = "Live", Icon = "heart" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local wbhk = Tabs.Live:AddInput("MyInput", {
        Title = "Enter ur webhook",
        Default = "",
        Placeholder = "Type here...",
        Numeric = false, -- Only allow numbers
        Finished = true, -- Only triggers when pressing enter
    })

    wbhk:OnChanged(function(value)
        _G.webhook = value  -- Set _G.webhook to the input value
        print("Webhook set to:", _G.webhook)  -- Optional: to check the input in the output console
    end)

    local Options = Fluent.Options
    local running = false
    local deathRunning = false
    local liveRunning = false

    --====================--
    --    Core Scripts    --
    --====================--





    -- Anti Afk With rematch
    local function AntiAfk()
        if NoAFK == true then
            while NoAFK do
                wait(.5)
                game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, nil) -- Press "2"
                wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, nil) -- Release "2"
            end
        end
    end



    -- Cutter Detection Script
    local function StartCutterLoop()
        spawn(function()
            local Live = game.Workspace.Live
            while running do
                task.wait(0.05)
                for _, v in pairs(Live:GetDescendants()) do
                    if v.Name == "Cutter" then
                        if math.abs(v.Position.X.Scale - 0.7) < 0.01 then
                            mouse1click()
                        end
                    end
                end
            end
        end)
    end

    -- Death Script
    local function StartDeathLoop()
        spawn(function()

            while deathRunning do
                wait(.1)
                local function Reset()
                    if _G.Play == false and resetLoopActive == false then
                        resetLoopActive = true
                        _G.Play = true
                        while resetLoopActive do
                            wait(.3)
                
                            -- Check for death count
                            if deaths.Value == 4 then
                                wait(1)
                                game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()
                                print("Voted rematch")
                                AFK()
                
                            elseif deaths.Value >= 4 or deaths.Value <= 4 then
                            
                                if player.Character and player.Character:FindFirstChild("Humanoid") and resetLoopActive == true then
                                    wait(waitTime)
                                    game.Players.LocalPlayer.Character.Humanoid.Health = 0
                                    waitTime = 4 -- <<<<<<<<<<< THIS ONE
                                    print("Killed and set the wait time", resetLoopActive)
                                    wait(1)
                                end
                            end
                        end
                    end
                end
                
                -- Function to stop the reset loop
                local function stopResetLoop()
                    resetLoopActive = false
                    _G.Play = false
                end
                
                -- Detect when "Map" is added
                workspaceService.ChildAdded:Connect(function(child)
                    if child.Name == "Map" then
                        Reset()
                        print("Map Spawned antiafk and reset")
                        AntiAfk()
                    end
                end)
                
                -- Detect when "Map" is removed
                workspaceService.ChildRemoved:Connect(function(child)
                    if child.Name == "Map" then
                        stopResetLoop()  -- Stop the loop when map is removed
                        waitTime = 9 -- <<<<<<<<<<   THIS ONE
                        print("Stopping reset loop and changed respawn time", waitTime)
                    end
                end)
            end
        end)
    end

    -- Live Script
    local function StartLiveLoop()
        spawn(function()
            while liveRunning do
                wait(.1)
                if not player then
                    warn("Player is nil! Cannot proceed.")
                    return
                end
                
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
                        wait(.1)
                        sendWeb(65280, "User", player)
                        NoAFK = true
                        AntiAfk()
                    end
                end)
                
                workspaceService.ChildRemoved:Connect(function(MapRemoved)
                    if MapRemoved.Name == "Map" then
                        NoAFK = false
                    end
                end)
            end
        end)
    end

    --====================--
    --    UI Setup        --
    --====================--

    -- Cutter Toggle
    local CutterToggle = Tabs.Main:AddToggle("CutterToggle", { Title = "Enable Cutter", Default = false })
    CutterToggle:OnChanged(function()
        running = Options.CutterToggle.Value
        if running then
            StartCutterLoop()
        end
    end)

    -- Death Toggle
    local DeathToggle = Tabs.Death:AddToggle("DeathToggle", { Title = "Enable Death Script", Default = false })
    DeathToggle:OnChanged(function()
        deathRunning = Options.DeathToggle.Value
        if deathRunning then
            StartDeathLoop()
        end
    end)

    -- Live Toggle
    local LiveToggle = Tabs.Live:AddToggle("LiveToggle", { Title = "Enable Live Script", Default = false })
    LiveToggle:OnChanged(function()
        liveRunning = Options.LiveToggle.Value
        if liveRunning then
            StartLiveLoop()
        end
    end)

    --====================--
    --    Settings & UI   --
    --====================--

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)
    Fluent:Notify({ Title = "Fluent", Content = "The script has been loaded.", Duration = 8 })
    SaveManager:LoadAutoloadConfig()
