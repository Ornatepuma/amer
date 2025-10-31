repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.PlayerGui.ClientGui.MenuScreen.LoadingScreen:FindFirstChild("Bloodlines") and game.Players.LocalPlayer.PlayerGui.ClientGui.MenuScreen.LoadingScreen.Bloodlines.ImageTransparency == 1
local cont = game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.MenuScreen.Menu.Continue
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local request = syn and syn.request or http_request or (http and http.request)
local ReplicatedStorage = game.ReplicatedStorage
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local oldfog = Lighting.FogEnd
local oldfog2 = Lighting.FogStart
local player = game.Players.LocalPlayer
local illu = false
local Character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local event = game:GetService("ReplicatedStorage").Events.DataEvent
local df = game:GetService("ReplicatedStorage").Events.DataFunction
local loaded = false
local moderator = false
local servers = {"",""}
print("checking laoded")
local function checkloaded()
    for _, v in pairs(ReplicatedStorage.Loaded:GetChildren()) do
        if v.Name == player.Name then
            loaded = true
        end
    end
end
checkloaded()
print("getting serveres")
local function getservers()
    for _, server in pairs(game:GetService("ReplicatedStorage").Servers:GetChildren()) do
        if server:IsA("StringValue") then
            local value = server.Value
            local serverpopulation = tonumber(string.sub(value, -2))
            local serverid = string.sub(value, 1, 36)
            if serverpopulation > 5 then
                table.insert(servers, {serverpopulation, serverid})
            end    
        end
    end
end


local Window = Fluent:CreateWindow({
            Title = "BloodLines" .. Fluent.Version,
            SubTitle = "Puma",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = false,
            Theme = "Dark",
            MinimizeKey = Enum.KeyCode.LeftControl
    })
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Teleport = Window:AddTab({Title = "Teleport", Icon = ""}),
    Visuals = Window:AddTab({Title = "Visuals", Icon = ""}),
    Bots = Window:AddTab({Title = "Bots", Icon = ""}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
    local Options = Fluent.Options
-- illu noti / chakra sense noti tab and function
local illu_noti = Tabs.Main:AddToggle("in", {Title = "Illu Notifier", Default = true})
local detected = {} -- stores names of Illus already notified
local blacklist = "bersaintral"


-- Main

-- Get Moderators
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local groupId = 7450839

task.spawn(function()
    print("Checking for moderators in game...")

    -- helper function to check if any moderators exist
    local function checkForModerators()
        local foundModerator = false

        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= player then
                local ok, result = pcall(function()
                    return v:IsInGroup(groupId)
                end)

                if ok and result then
                    foundModerator = true
                    Fluent:Notify({
                        Title = "MODERATOR IN GAME",
                        Content = v.DisplayName .. " (" .. v.Name .. ") is a moderator"
                    })
                end
            end
        end

        -- update your global var based on actual result
        moderator = foundModerator
    end

    -- initial scan
    checkForModerators()

    -- live updates when new players join
    Players.PlayerAdded:Connect(function(v)
        if v == player then return end
        task.wait(1)
        local ok, result = pcall(function()
            return v:IsInGroup(groupId)
        end)
        if ok and result then
            moderator = true
            Fluent:Notify({
                Title = "MODERATOR IN GAME",
                Content = v.DisplayName .. " (" .. v.Name .. ") is a moderator"
            })
        end
    end)

    -- optionally detect when all moderators leave
    Players.PlayerRemoving:Connect(function(v)
        task.wait(0.5)
        checkForModerators()
    end)
end)





local loadoutmenu = Tabs.Main:AddToggle("autoclick",{Title = "Auto Click Continue", Default = false})

loadoutmenu:OnChanged(function(state)
    if state then
        task.wait(3)
        firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.MenuScreen.Menu.Continue.MouseButton1Click)
        firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.MenuScreen.Menu.Continue.Activated)
        firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.MenuScreen.Menu.Continue.MouseButton1Down)
    end
end)

print("illu noti")
illu_noti:OnChanged(function(state)
    table.clear(detected)
    if state then
        task.spawn(function()
            while illu_noti.Value do
                task.wait(1)
                for _, cooldown in pairs(game.ReplicatedStorage.Cooldowns:GetChildren()) do
                    for _, cdName in pairs(cooldown:GetChildren()) do
                        if cdName.Name == "Chakra Sense" and not cdName.Name == blacklist and cooldown.Name ~= player.Name then
                            illu = true
                            local illuname = cooldown.Name
                             for _, v in pairs(workspace:GetChildren()) do
                                if v.Name == illuname then
                                    local liveplr = v:FindFirstChild("Humanoid")
                                    if liveplr and not detected[illuname] then
                                        local display = liveplr.DisplayName
                                        local displayname = tostring(display or illuname)
                                        Fluent:Notify({
                                            Title = "Chakra Sense Detected",
                                            Content = displayname .. " (" .. illuname .. ") has Chakra Sense"
                                        })
                                        detected[illuname] = true
                                    end
                                end
                            end
                        end
                    end
                end
                for _, setting in pairs(game.ReplicatedStorage.Settings:GetDescendants()) do
                    if setting:IsA("StringValue") then
                        if setting.Value == "Chakra Sense" then
                            local illuname = setting.Name
                            for _, live in pairs(workspace:GetChildren()) do
                                if live.Name == illuname and live.Name ~= player.Name then
                                    illu = true
                                    local livehumanoid = live:FindFirstChild("Humanoid")
                                    if livehumanoid and not detected[illuname] then
                                        local displayname = tostring(livehumanoid.DisplayName)
                                        Fluent:Notify({
                                            Title = "Chakra Sense Detected",
                                            Content = displayname .. " (" .. illuname .. ") has Chakra Sense"
                                        })
                                        detected[illuname] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end 
        end) 
    end
end)

print("auto charge")
local autocharge = Tabs.Main:AddToggle("ac", {Title = "Auto Charge Mana", Default = false})
-- autocharge
autocharge:OnChanged(function(state)
    if state then
        task.spawn(function()
            while autocharge.Value do
                
                event:FireServer("Charging")
                task.wait(1)
            end
        end)
    end     
end)
-- autocharge keybind
    local Keybind = Tabs.Main:AddKeybind("ack", {
    Title = "Auto Charge Keybind",
    Mode = "Toggle",
    Default = "", 
    Callback = function(change)
        if change == true then
            autocharge:SetValue(change)
        else
            autocharge:SetValue(change)
            event:FireServer("StopCharging")
        end
    end,
    ChangedCallback = function(New)
        print("Keybind changed!", New)
    end
})

local fd = {}

for i, v in pairs(workspace:GetChildren()) do
    if not v:IsA("BasePart") and not v:FindFirstChild("Pickupable") then
        table.insert(fd, v)
    end
end

-- auto pickup autopickup
local params = OverlapParams.new()
params.FilterDescendantsInstances = fd
params.FilterType = Enum.RaycastFilterType.Exclude

local pick = Tabs.Main:AddToggle("ap", {Title = "Auto Pickup Fruits And Trinkets", Default = false})
print("auto pickup")
pick:OnChanged(function(state)
    if state then
        task.spawn(function()
            while pick.Value do
                task.wait(.25)
                for i, v in pairs(workspace:GetPartBoundsInBox(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame, Vector3.new(15,15,15), params)) do
                    if v:FindFirstChild("Pickupable") then
                        event:FireServer("PickUp", v.ID.Value)
                    elseif v:FindFirstChild("SpawnTime") and v:FindFirstChild("ItemDetector") then
                        fireclickdetector(v.ItemDetector)
                    elseif v:FindFirstChild("ItemOwner") then
                        if v.Name == player.Name then
                            firetouchinterest(v.TouchInterest)
                            print(v.Name)
                        end
                    end
                end
            end
        end)
    end
end)


local nofall = Tabs.Main:AddToggle("nf", {Title = "No Fall", Default = false})
print("nofall")
nofall:OnChanged(function(state)
    nofalltoggle = state
end)

-- NO KILL BRICKS

local nokillbricks = Tabs.Main:AddToggle("nkb",{Title = "Remove Kill Bricks", Default = false})
print("no kill bricks")
nokillbricks:OnChanged(function(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v and v:IsA("BasePart") then
                local kb = tostring(v.Name):lower()
                if kb:find("void") then
                    v.CanTouch = false
                end
            end
        end
    end
end)



-- TELEPORT
[[--print("servver hop")
local serverhop = Tabs.Teleport:AddButton({
    Title = "Hop Server",
    Description = "Change To A Different Server",
    Callback = function()
        Window:Dialog({
            Title = "Server Hop",
            Content = "Are You Sure You Want To Hop To A Different Server?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        getservers()
                        repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        task.wait()
                    end
                }
            }
        })
        
    end
    })]]




local chakrapoint = workspace.ChakraPoints
print("get chakra points")
local yk = {}
for _, child in pairs(chakrapoint:GetChildren()) do
    for _, cn in pairs(child:GetChildren()) do
        if cn.Name == "PointName" then
            table.insert(yk, cn.Value)
        end
    end
end

local ChakraPointlist = Tabs.Teleport:AddDropdown("cpl", {
    Title = "ChakraPoints",
    Values = yk,
    Multi = false,
    Default = 1
})

-- the actual tp part
print("chakra point tp")
local ChakraPointTp = Tabs.Teleport:AddButton({
    Title = "Teleport To Selected Point",
    Description = "Press After You Have Selected Chakra Point",
    Callback = function()
        Window:Dialog({
            Title = "Teleport",
            Content = "Are You Sure You Want To Teleport",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local selected = ChakraPointlist.Value
                        print("Selected chakra:", selected)

                        local point
                        for _, v in pairs(workspace.ChakraPoints:GetChildren()) do
                            local pointName = v:FindFirstChild("PointName")
                            if pointName and pointName.Value == selected then
                                point = v
                                break
                            end
                        end

                        if not point then
                            print("No chakra point found for:", selected)
                            return
                        end

                        local pool = point:FindFirstChild("InnerPool")
                        if not pool then
                            print("No InnerPool found inside:", point.Name)
                            return
                        end

                        -- ✅ Handle both Model and Part cases
                        if pool:IsA("Model") then
                            local part = pool.PrimaryPart or pool:FindFirstChildWhichIsA("BasePart")
                            if part then
                                player.Character.HumanoidRootPart.CFrame = part.CFrame
                                print("Teleported to model part:", part.Name)
                            else
                                print("No BasePart found inside InnerPool model.")
                            end
                        elseif pool:IsA("BasePart") then
                            player.Character.HumanoidRootPart.CFrame = pool.CFrame
                            print("Teleported to part:", pool.Name)
                        else
                            print("InnerPool is not a model or part:", pool.ClassName)
                        end
                                            
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        Fluent:Notify({
                            Title = "Teleport",
                            Content = "Cancelled tp",
                            Duration = "2"
                        })
                    end
                }
            }
        })
    end
})











-- VISUALS

-- fullbright
print("full bright")
local fullbright = Tabs.Visuals:AddToggle("fb", {Title = "FullBright", Default = false})
local oldbright = Lighting.Brightness
local oda = Lighting.OutdoorAmbient
fullbright:OnChanged(function(state)
    if state then
        -- Enable fullbright
        task.spawn(function()
            while fullbright.Value do
                task.wait(0.1)
                Lighting.Brightness = 1.55
                Lighting.GlobalShadows = false
            end
        end)
    else
        -- Restore original lighting
        task.wait(.1)
        Lighting.Brightness = oldbright
        Lighting.GlobalShadows = true
    end
end)
-- no fog
print("no fog")
local nofog = Tabs.Visuals:AddToggle("nf", {Title = "No Fog", Default = false})
local oldfog = Lighting.FogEnd
local oldfog2 = Lighting.FogStart
nofog:OnChanged(function(state)
    if state then
        checkloaded()
        task.wait(1)
        if loaded then
            task.spawn(function()
                while task.wait() do
                    if state == true then
                        Lighting.FogEnd = 100000000
                        Lighting.FogStart = 100000000
                        workspace.Debris:FindFirstChild("InvertedSphere").Parent = nil
                    end
                end
            end)
        end
    else
        task.wait(.1)
        Lighting.FogEnd = oldfog
        Lighting.FogStart = oldfog2
    end
end)

    


-- no rain remove rain
print("no rain")
local norain = Tabs.Visuals:AddToggle("nr", {Title = "Remove Rain", Default = false})
local rainpart = workspace:FindFirstChild("RainParts")
local rainsound = game.Players.LocalPlayer.SoundPlaylist.RainSound
norain:OnChanged(function(state)  
    checkloaded()
    if state == true and loaded then        
        task.spawn(function()
            while norain.Value do
                task.wait()
                rainsound.Playing = false
                local rainpart = workspace:FindFirstChild("RainParts")
                for _, children in pairs(rainpart:GetChildren()) do
                    for _, particles in pairs(children:GetChildren()) do
                        if particles:IsA("ParticleEmitter") then
                            particles.Rate = 0
                        end
                    end
                end
            end
        end)
    end   
    if state == false and loaded then
        task.wait(.1)
        for _, children in pairs(rainpart:GetChildren()) do
            if children == nil then return end
            for _, particles in pairs(children:GetChildren()) do
                if particles:IsA("ParticleEmitter") then
                    particles.Rate = 120
                end
            end
        end
        rainsound.Playing = true
    end
end)
-- Chakra point tp selection

-- find all servers

-- BOTS

-- wood golem bot
local startbot = Tabs.Bots:AddToggle("sb",{Title = "Run Wood Boss Bot", Default = false})
local hoponillu = Tabs.Bots:AddToggle("hoi",{Title = "Hop on chakra sense", {Default = false}})
print("hop on illu")
hoponillu:OnChanged(function(state)
    checkloaded()
    if loaded then
        if state then
            task.spawn(function()
                while task.wait(.1) do
                    if illu or moderator and startbot then
                        -- getservers()
                        while illu or moderator and startbot do
                            --getservers()
                            --event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
                            print("hopping on illu")
                            task.wait(.1)
                        end
                    end
                end
            end)
        end 
    end
end)
local potato = Instance.new("Part")
potato.Anchored = true
potato.Parent = workspace
potato.Size = Vector3.new(15,1,15)
print("golem bot")
startbot:OnChanged(function(state)
    checkloaded()
    if loaded then   -- start of bot
        if state then
            task.spawn(function()
                task.wait(5)
                while startbot.Value do
                    local Golem = workspace:FindFirstChild("Wooden Golem") 
                    --getservers()
                    if Golem == nil then
                        -- repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                        print("no golem found hopping")
                    end
                    local GolemRoot = Golem:FindFirstChild("HumanoidRootPart")
                    if GolemRoot == nil then
                        -- repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                        print("no golem root found hopping")
                    end
                    local badandevil = {"rbxassetid://120758909308511","rbxassetid://116907126244057"}
                    local tploop;
                    
                    tploop = game:GetService("RunService").PreRender:Connect(function()
                        HumanoidRootPart.Velocity = Vector3.new()
                        HumanoidRootPart.AssemblyAngularVelocity = Vector3.new()
                        local mag = false
                        if workspace.Debris:FindFirstChild("WoodenDragonHead") then
                            mag = (workspace.Debris:FindFirstChild("WoodenDragonHead"):GetPivot().p - GolemRoot.Position + Vector3.new(0,GolemRoot.Size.Y/1.5,0)).Magnitude < 50
                        end
                        local goooo = CFrame.new(GolemRoot.Position - GolemRoot.CFrame.LookVector * 5 + Vector3.new(0,GolemRoot.Size.Y/1.5,0),GolemRoot.Position)
                        
                        HumanoidRootPart.CFrame = (safe or mag) and CFrame.new(GolemRoot.Position + Vector3.new(0,200,0)) or goooo
                        potato.CFrame = GolemRoot.CFrame + Vector3.new(0,196,0)
                    end)

                    HumanoidRootPart:GetPropertyChangedSignal("Parent"):Once(function()
                        tploop:Disconnect()
                    end)
                    GolemRoot:GetPropertyChangedSignal("Parent"):Once(function()
                        tploop:Disconnect()
                    end)

                    local Humanoid = Golem:WaitForChild("Humanoid");
                    local tim
                    local df = game:GetService("ReplicatedStorage").Events.DataFunction
                    Humanoid.Animator.AnimationPlayed:Connect(function(track)
                        if table.find(badandevil, track.Animation.AnimationId) then
                            safe = true
                            while track and track.IsPlaying do
                                tim = true
                                while tim do
                                    task.wait(1)
                                    df:InvokeServer("Block")
                                    task.wait()
                                    task.spawn(function()
                                        task.wait(2)
                                        tim = false
                                    end)
                                end
                            end
                            task.wait(.5)
                            df:InvokeServer("EndBlock")
                            task.wait(0.1)
                            safe = false
                        end
                    end)
                    local playerhumanoid = Character.Humanoid
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://5604340726"
                    local track = playerhumanoid:LoadAnimation(anim)
                    track:Play()



                    while task.wait() and Humanoid.Health > 0 and Golem.Parent do
                        if not safe then
                            event:FireServer("CheckMeleeHit",nil ,"NormalAttack", false)
                        else
                            game:GetService("StarterGui"):SetCore("SendNotification",{
                                Title = "EVIL DROID KILLER BOT EVIL EVIL 1.0 🤖🤖🤖",
                                Text = "GOLEM HEALTH: "..tostring(Humanoid.Health),
                            })
                            repeat task.wait() until not safe
                        end
                    end
                    pick:SetValue(true)
                    local timer = 6
                    track:Stop()
                    for _, v in pairs(workspace.WoodenGolemRewards:GetDescendants()) do
                        if v.Name:find("Trinket") then
                            HumanoidRootPart.CFrame = CFrame.new(v.CFrame * Vector3(0,15,0))
                            task.wait(timer)
                            if timer > 1 then
                                timer = timer * .7
                            end
                            
                        end
                    end
                    while true do
                        -- getservers()
                        task.wait(1)
                        -- event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
                    end
                end
            end)
        end
    end
end)

local hopifnear = Tabs.Bots:AddToggle("hif",{Title = "Hop If Player Near", {Default = false}})
print("hop if near")
hopifnear:OnChanged(function(state)
    checkloaded()
    if loaded then
        if state then
            task.spawn(function()
                while hopifnear.Value and startbot.Value do
                    task.wait(.1)
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Name ~= player.Name then
                            local distance = (v.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            local golemdistance = (v.HumanoidRootPart.Position - workspace:WaitForChild("Wooden Golem").HumanoidRootPart.Position).Magnitude
                            if distance < 1 or golemdistance < 250 then
                                -- getservers()
                                -- repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                            end
                        end
                    end
                end
            end)
        end
    end 
end)



-- Auto summon fruits autosummon

local fruitsummon = Tabs.Bots:AddToggle("fs",{Title = "Auto Summon Fruits"})
local thing = true
print("fruit summon")
fruitsummon:OnChanged(function(state)
    if state then
        checkloaded()
        task.wait(.4)
        repeat task.wait() until loaded == true
        if loaded and not illu or not moderator then
            local ff = Character:FindFirstChild("ForceField")
            if ff then
                repeat
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    task.wait(1)
                until not Character:FindFirstChild("ForceField")
            end
            pick:SetValue(true)
            task.spawn(function()
                while fruitsummon.Value do
                    if illu then
                        repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.Mainframe.Danger.Visible == false
                        -- getservers()
                        -- repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                    else    
                        event:FireServer("startSkill", "Fruit Summoning", vector.create(2369.8818359375, 281.14227294921875, -874.48828125) , true, "MouseButton2")
                        event:FireServer("ReleaseSkill")
                        
                    end
                    if thing == true and hopifnear == true then
                        thing = false
                        task.spawn(function()
                            while task.wait(.1) do
                                for i, v in pairs(game.Workspace:GetChildren()) do
                                    if v:FindFirstChild("Humanoid") and v.Name ~= player.Name then
                                        for _, plr in pairs(game.Players:GetChildren()) do
                                            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                                local distance = (v.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                                if distance < 100 then
                                                    print("hopped to player" .. distance, v.Name)
                                                    task.wait(1)
                                                    -- getservers()
                                                    -- repeat task.wait(.1) event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2]) until HumanoidRootPart == nil
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(13.1)
                end
            end)
        end
    end
end)
-- auto Sell fruits autosell


local GameManager = require(game:GetService("ReplicatedStorage").GameManager)


local v80, v81, v82 = game:GetService("ReplicatedStorage").Events.DataFunction:InvokeServer("getVillageData");
VillageData = v80;
villageMonth = v81;
villageWeek = v82;

getVillageData = function(v83, v84, v85) --[[ Line: 177 ]] --[[ Name: getVillageData ]]
    v84 = v84 or villageMonth;
    local v86 = v85 or villageWeek;
    return VillageData["Month" .. v84]["Week" .. v86][v83];
end;

getEconomy = function(v87) --[[ Line: 184 ]] --[[ Name: getEconomy ]]
    if v87 == "Rogue" then
        return "Struggling";
    elseif v87 == "Neutral" then
        return "Average";
    elseif not v87 then
        return "Average";
    else
        return getVillageData(v87).Politics.Economy;
    end;
end;

getVillageRelationship = function(v88, v89) --[[ Line: 202 ]] --[[ Name: getVillageRelationship ]]
    if not v88 or not v89 then
        return nil;
    elseif v88 == "Rogue" or v89 == "Rogue" then
        return "War";
    elseif v88 == "Neutral" or v89 == "Neutral" then
        return "Neutral";
    else
        local v90 = getVillageData(v88);
        local v91 = getVillageData(v89);
        if v88 == v89 then
            return "Own";
        elseif table.find(v90.Politics.Alliances, v89) or table.find(v91.Politics.Alliances, v88) then
            return "Allied";
        elseif table.find(v90.Politics.Wars, v89) or table.find(v91.Politics.Wars, v88) then
            return "War";
        else
            return "Neutral";
        end;
    end;
end;

local function GetPrice(item, merchant)
    local VillageData,_ ,_  = game:GetService("ReplicatedStorage").Events.DataFunction:InvokeServer("GetData");
    local Price = GameManager:getPrice(item);
    Price = GameManager:getModifiedPrice(Price, getVillageRelationship(VillageData.Village, merchant.HumanoidRootPart:GetAttribute("Village")), getEconomy(merchant.HumanoidRootPart:GetAttribute("Village")), "Sell");
    return Price
end

function GetHighestPaying(name)
    local highest = 0
    local best;
    for i, v in pairs(workspace:GetChildren()) do
        if v.Name == name then
            local price = GetPrice("Mango", v)
            if price > highest then
                highest = price
                best = v
            end
        end
    end
    return best, highest
end


local Prices = {
    ["Orange"] = 1,
    ["Banana"] = 1,
    ["Mango"] = 2,
    ["Apple"] = 1,
    ["Pear"] = 1,
    ["Bolive Crops"] = 1,
    ["Chakra Crops"] = 1,
    ["Alluring Apple"] = 5
}


local function getFruits()
    local Fruits = {}
    for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ClientGui.Mainframe.Loadout:GetDescendants()) do
        if v.Name == "SlotText" and v:IsA("TextLabel") and Prices[v.Text] then
            local fruitname = v.Text
            print("fruitname:" .. fruitname)
            local Amount = string.gsub(v.Parent.ItemNumber.Number.Text, "x", "", 1)
            print("amount: " .. Amount)
            Fruits[fruitname] = tonumber(Amount)
            -- print("fruit name:" .. Fruits[fruitname])
        end
    end 
    return Fruits
end


function SellFruits()
    local Merchant = GetHighestPaying("Food Merchant")
    local df = game:GetService("ReplicatedStorage").Events.DataFunction
    local Fruits = getFruits()
    local Price = 0
    for i, v in pairs(Fruits) do
        Price = Price + (GetPrice(i, Merchant) * v)
    end
    print(Price)
    df:InvokeServer("SellingBulk",Price,"Fruit","Fish")
end

local timer = 300

local autosellinterval = Tabs.Bots:AddSlider("asi", {
    Title = "Sell Interval (Minutes)",
    Description = "",
    Default = 5,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        timer = value * 60 
    end
})
local start = tick()
local autosell = Tabs.Bots:AddToggle("autosell", {Title = "Auto Sell", Default = false})
autosell:OnChanged(function(state)
    if state then
        task.spawn(function()
            while autosell.Value do
                task.wait()
                if tick() - start < timer then continue end
                local pickval = pick.Value
                pick:SetValue(false)
                SellFruits()
                pick:SetValue(pickval)
                start = tick()
                print("fired function bulk sold")
            end
        end)
    end
end)



-- block hooks!!
local oldnc;
oldnc = hookmetamethod(game,"__namecall",function(self, ...)
    if getnamecallmethod() == "FireServer" then
        local args = {...}
        if args[1] == "TakeDamage" and nofalltoggle then return end
        if args[1] == "StopCharging" and autocharge.Value then return end
        if args[1] == "UpdateMousePosition" then return task.wait(9e9) end
    end
    return oldnc(self, ...)
end)




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
