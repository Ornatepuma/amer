local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local request = syn and syn.request or http_request or (http and http.request)
local event = game:GetService("ReplicatedStorage").Events.DataEvent
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local oldfog = Lighting.FogEnd
local oldfog2 = Lighting.FogStart
local player = game.Players.LocalPlayer

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
                task.wait(1)
                for _, v in pairs(game.ReplicatedStorage.Cooldowns:GetChildren()) do
                    for _, move in pairs(v:GetChildren()) do
                        if move.Name == "Chakra Sense" and not detected[v.Name] then
                            local user = v.Name
                            local fart = workspace:FindFirstChild(v.Name)
                            
                            if fart and fart:FindFirstChild("Humanoid") then
                                local displayName = fart.Humanoid:GetAttribute("DisplayName")
                                if displayName then
                                    user = displayName
                                end
                            end

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
end)



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
-- no fog
local nofog = Tabs.Main:AddToggle("Toggle", {Title = "No Fog", Default = false})

nofog:OnChanged(function(state)
    if state == true then
        Lighting.FogEnd = 100000000
        Lighting.FogStart = 100000000
    elseif state == false then
        Lighting.FogEnd = oldfog
        Lighting.FogStart = oldfog2
    end
end)

workspace.Debris.ChildAdded:Connect(function(chud)
    if chud.Name == "InvertedSphere" and nofog.Value then
        chud:Destroy()
    end
end)



-- no rain remove rain
local norain = Tabs.Main:AddToggle("Toggle", {Title = "Remove Rain", Default = false})
local rainpart = workspace:FindFirstChild("RainParts")
local rainsound = game.Players.LocalPlayer.SoundPlaylist.RainSound
norain:OnChanged(function(state)  
    if state == true then
        rainsound.Playing = false
        task.spawn(function()
            while norain.Value do
                wait()
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
    if state == false then
        wait(.1)
        for _, children in pairs(rainpart:GetChildren()) do
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


local ChakraPointlist = Tabs.Teleport:AddDropdown("Dropdown", {
    Title = "ChakraPoints",
    Values = yk,
    Multi = false,
    Defualt = 1
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
                        for _, v in pairs(chakrapoint:GetChildren()) do
                            for _, points in pairs(v:GetChildren()) do
                                if points.Name == ChakraPointlist.Value.Name then
                                    player.Character.HumanoidRootPart.CFrame = points.ShardArea.Lights.CFrame
                                end
                            end
                        end                        
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        Fluent:Notify({
                            Title = "Teleport",
                            Content = "Cancelled tp"
                            Duration = "2"
                        })
                    end
                }
            }
        })
    end
})








-- block hooks!!
local oldnc;
oldnc = hookmetamethod(game,"__namecall",function(self, ...)
    if getnamecallmethod() == "FireServer" then
        local args = {...}
        if args[1] == "TakeDamage" and nofalltoggle then return end
        if args[1] == "StopCharging" and autocharge.Value then return end
        if args[1] == "SetRainAbove" and norain.Value then return end
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

