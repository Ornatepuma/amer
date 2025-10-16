local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local request = syn and syn.request or http_request or (http and http.request)
local event = game:GetService("ReplicatedStorage").Events.DataEvent

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
                                local fart = workspace:FindFirstChild(v.Name)
                                local poo
                                if fart then
                                    local name = fart.Humanoid:GetAttribute("DisplayName")
                                end
                                
                                
                                
                                detected[v.Name] = true
                                Fluent:Notify({
                                    Title = "ILLU DETECTED",
                                    Content = name .. " HAS CHAKRA SENSE"
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
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        Callback = function(change)
            if change == true then
                autocharge:SetValue(change)
            else
                autocharge:SetValue(change)
                event:FireServer("StopCharging")
            end
        end,

        -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
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

local oldnc;
oldnc = hookmetamethod(game,"__namecall",function(self, ...)
    if getnamecallmethod() == "FireServer" then
        local args = {...}
        if args[1] == "TakeDamage" and nofalltoggle then return end
        if args[1] == "StopCharging" and autocharge.Value then return end
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

