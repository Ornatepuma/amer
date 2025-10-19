
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

local function checkloaded()
    for _, v in pairs(ReplicatedStorage.Loaded:GetChildren()) do
        if v.Name == player.Name then
            loaded = true
        end
    end
end
checkloaded()











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
    Fart = Window:AddTab({Title = "Spectate", Icon = ""}),
    Bots = Window:AddTab({Title = "Bots", Icon = ""}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
    local Options = Fluent.Options
-- illu noti / chakra sense noti tab and function
local illu_noti = Tabs.Main:AddToggle("Toggle", {Title = "Illu Notifier", Default = true})
local detected = {} -- stores names of Illus already notified

    
    

illu_noti:OnChanged(function(state)
    table.clear(detected)
    if state then
        task.spawn(function()
            while illu_noti.Value do
                task.wait(0.05)
                for _, cooldown in pairs(game.ReplicatedStorage.Cooldowns:GetChildren()) do
                    for _, cdName in pairs(cooldown:GetChildren()) do
                        if cdName.Name == "Chakra Sense" then
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
                for _, setting in pairs(game.ReplicatedStorage.Settings:GetChildren()) do
                    for _, currentskill in pairs(setting:GetChildren()) do
                        if currentskill.Value == "Chakra Sense" then
                            local illuname = setting.Name
                            illu = true
                            for _, live in pairs(workspace:GetChildren()) do
                                if live.Name == illuname then
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



-- local listillu = Tabs.Main:AddButton({Title = "List Current Illu", Description = "Press to List all the current illus in your server"})




    
    
--[[illu_noti:OnChanged(function(state)
    table.clear(detected)
    if state then
        task.spawn(function()
            while illu_noti.Value do
                task.wait(1)
                for _, v in pairs(game.ReplicatedStorage.Cooldowns:GetChildren()) do
                    
                    for _, move in pairs(v:GetChildren()) do
                        
                        if move.Name == "Chakra Sense" and not detected[v.Name] then
                            local user = v.Name
                            
                            print("setuser")
                            
                            local fart = workspace:FindFirstChild(v.Name)
                            if fart then
                                
                                print(fart)

                            end
                            local displayName
                            
                            
                            --if fart and fart:FindFirstChild("Humanoid") then
                            
                            displayName = fart.Humanoid:GetAttribute("DisplayName") 
                            if displayName then
                                
                                user = displayName
                                print(displayName)

                            end
                            --end

                            detected[v.Name] = true
                            Fluent:Notify({
                                Title = "ILLU DETECTED",
                                Content = user .. " HAS CHAKRA SENSE"
                            })
                        end
                    end
                end
            end
        end)
    end
end)]]



    local autocharge = Tabs.Main:AddToggle("Toggle", {Title = "Auto Charge Mana", Default = false})
    -- autocharge
    autocharge:OnChanged(function(state)
        if state then
            task.spawn(function()
                while autocharge.Value do
                    
                    event:FireServer("Charging")
                    wait(1)
                end
            end)
        end     
    end)
    -- autocharge keybind
        local Keybind = Tabs.Main:AddKeybind("Keybind", {
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

-- auto pickup
local params = OverlapParams.new()
params.FilterDescendantsInstances = fd
params.FilterType = Enum.RaycastFilterType.Exclude

local pick = Tabs.Main:AddToggle("Toggle", {Title = "Auto Pickup Fruits And Trinkets", Default = false})

pick:OnChanged(function(state)
    if state then
        task.spawn(function()
            while pick.Value do
                wait(.25)
                for i, v in pairs(workspace:GetPartBoundsInBox(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame, Vector3.new(15,15,15), params)) do
                    if v:FindFirstChild("Pickupable") then
                        event:FireServer("PickUp", v.ID.Value)
                    elseif v:FindFirstChild("SpawnTime") and v:FindFirstChild("ItemDetector") then
                        fireclickdetector(v.ItemDetector)
                    end
                end
            end
        end)
    end
end)


local nofall = Tabs.Main:AddToggle("Toggle", {Title = "No Fall", Default = false})

nofall:OnChanged(function(state)
    nofalltoggle = state
end)

-- Hold m1
--[[local holdm1 = Tabs.Main:AddToggle("Toggle", {Title = "Hold M1", Defualt = false})

holdm1:OnChanged(function(state)
    if state then

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                holdingClick = true
            end
        end)



        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                holdingClick = false
                print("Mouse button released")
            end
        end)


        task.spawn(function()
            while holdingm1.Value do
                task.wait(0.1)
                if holdingClick then
                    event:FireServer("CheckMeleeHit",nil ,"NormalAttack", false)
                end
            end
        end)
    end)
end]]
-- fullbright
local fullbright = Tabs.Visuals:AddToggle("Toggle", {Title = "FullBright", Default = false})
local oldbright = Lighting.Brightness

fullbright:OnChanged(function(state)
    if state then
        -- Enable fullbright
        task.spawn(function()
            while fullbright.Value do
                task.wait(0.1)
                Lighting.Brightness = 1
                Lighting.GlobalShadows = false
            end
        end)
    else
        -- Restore original lighting
        wait(.05)
        Lighting.Brightness = oldbright
        Lighting.GlobalShadows = true
    end
end)
-- no fog
local nofog = Tabs.Visuals:AddToggle("Toggle", {Title = "No Fog", Default = false})
local oldfog = Lighting.FogEnd
local oldfog2 = Lighting.FogStart
nofog:OnChanged(function(state)
    if state == true then
        Lighting.FogEnd = 100000000
        Lighting.FogStart = 100000000
        workspace.Debris:FindFirstChild("InvertedSphere").Transparency = 1
    elseif state == false then
        Lighting.FogEnd = oldfog
        Lighting.FogStart = oldfog2
        local invertesphere = workspace.Debris:FindFirstChild("InvertedSphere")
        if invertesphere then
            invertesphere.Transparency = 0
        elseif invertesphere == nil then return end
    end
end)

-- no rain remove rain
local norain = Tabs.Visuals:AddToggle("Toggle", {Title = "Remove Rain", Default = false})
local rainpart = workspace:FindFirstChild("RainParts")
local rainsound = game.Players.LocalPlayer.SoundPlaylist.RainSound
norain:OnChanged(function(state)  
    if state == true then        
        task.spawn(function()
            while norain.Value do
                wait()
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
    checkloaded()
    if state == false and loaded then
        wait(.1)
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
local chakrapoint = workspace.ChakraPoints

local yk = {}
for _, child in pairs(chakrapoint:GetChildren()) do
    for _, cn in pairs(child:GetChildren()) do
        if cn.Name == "PointName" then
            table.insert(yk, cn.Value)
        end
    end
end

local nokillbricks = Tabs.Main:AddToggle("Toggle",{Title = "Remove Kill Bricks", Default = false})

nokillbricks:OnChanged(function(state)
    if state then
        for i, v in pairs(workspace:GetChildren()) do
            if v.Name == "Void" and v:FindFirstChild("TouchInterest") then
                v.CanTouch = false
                v.CanQuery = false
            end
        end
        for i, v in pairs(workspace["Hyuga BossEntrances"]:GetChildren()) do
            for _, voids in pairs(v:GetChildren()) do
                if voids.Name == "Void" and voids:FindFirstChild("TouchInterest") then
                    voids.CanTouch = false
                    voids.CanQuery = false
                end
            end
        end
        for _, v in pairs(workspace:GetChildren(workspace:GetChildren())) do
            if v.Name == "HyugaVoids" or "Model" or "SandWormVoid" then
                for _, voids in pairs(v:GetChildren()) do
                    if voids.Name == "Void" then
                        voids.CanTouch = false
                        voids.CanQuery = false
                    end
                end
            end
        end
    end
end)

local ChakraPointlist = Tabs.Teleport:AddDropdown("Dropdown", {
    Title = "ChakraPoints",
    Values = yk,
    Multi = false,
    Default = 1
})

-- the actual tp part

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

local servers = {"",""}
local serverpopfinder = {}
local serverpop = {}
local startbot = Tabs.Bots:AddToggle("Toggle",{Title = "Run Wood Boss Bot", Default = false})















-- find all servers
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


local hoponillu = Tabs.Bots:AddToggle("Toggle",{Title = "Hop on chakra sense", {Default = false}})

hoponillu:OnChanged(function(state)
    if state then
        task.spawn(function()
            while wait(.1) do
                if illu and startbot.Value == true then
                    getservers()
                    while illu do
                        getservers()
                        event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
                        wait(.1)
                    end
                end
            end
        end)
    end 
end)

-- wood golem bot
local potato = Instance.new("Part")
potato.Anchored = true
potato.Parent = workspace
potato.Size = Vector3.new(15,1,15)


startbot:OnChanged(function(state) -- start of bot
    if state then
        task.spawn(function()
            while startbot.Value do
                local Golem = workspace:FindFirstChild("Wooden Golem") 
                getservers()
                if Golem == nil then
                    event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
                end
                local GolemRoot = Golem.HumanoidRootPart
                if GolemRoot == nil then
                    event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
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
                    wait(3)
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
                                wait(.75)
                                df:InvokeServer("Block")
                                task.wait()
                                task.spawn(function()
                                    wait(2)
                                    tim = false
                                end)
                            end
                        end
                        task.wait(2)
                        df:InvokeServer("EndBlock")
                        task.wait(0.1)
                        safe = false
                    end
                end)




                while task.wait() and Humanoid.Health > 0 do
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
                -- start autoloot                
                for i, v in pairs(workspace.WoodenGolemRewards:GetChildren()) do
                    for i, reward in pairs(v:GetChildren()) do
                        if string.find("Spawn") then
                            local waititme = 7
                            pick.Value = true
                            HumanoidRootPart.CFrame = reward.CFrame
                            wait(waititme)
                            waititme = waititme - 1.2
                        end
                    end
                end
                getservers()
                event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
            end
        end)
    end
end)

local hopifnear = Tabs.Bots:AddToggle("Toggle",{Title = "Hop If Player Near", {Default = false}})

hopifnear:OnChanged(function(state)
    if state then
        task.spawn(function()
            while hopifnear.Value do
                wait(.1)
                for _, v in pairs(workspace:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Name ~= player.Name then
                        local distance = (v.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        local golemdistance = (v.HumanoidRootPart.Position - workspace:WaitForChild("Wooden Golem").HumanoidRootPart.Position).Magnitude
                        if distance < 100 or golemdistance < 500 then
                            getservers()
                            event:FireServer("ServerTeleport", servers[math.random(1, #servers)][2])
                        end
                    end
                end
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
        if args[1] == "SetRainAbove" and norain.Value and args[2] == false then return end
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
