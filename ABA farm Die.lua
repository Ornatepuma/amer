-- DEATH DEATH DEATH DEATH DEATH DEATH
-- DEATH DEATH DEATH DEATH DEATH DEATH

local VirtualInputManager = game:GetService("VirtualInputManager")
local Live = game.Workspace.Live
local player = game.Players.LocalPlayer
local workspaceService = game:GetService("Workspace")
local resetLoopActive = false 
local deaths = game:GetService("Players").LocalPlayer.leaderstats.Deaths
local waitTime = 9 -- for einstein change this to higher number and the one on line 56 and 30
_G.Play = false
local NoAFK = false

print("executed DEATH", player.Name)

local function AntiAfk()
    if NoAFK == true then
        while NoAFK do
            game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()

        end
    end
end

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

            elseif deaths.Value >= 4 or deaths.Value <= 4 then
            
                if player.Character and player.Character:FindFirstChild("Humanoid") and resetLoopActive == true then
                    wait(waitTime)
                    game.Players.LocalPlayer.Character.Humanoid.Health = 0
                    waitTime = 4 -- <<<<<<<<<<< THIS ONE
                    print("Killed and set the wait time", resetLoopActive)
                    wait(1)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, nil) -- Press "2"
                    wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, nil) -- Release "2"
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
        print("Map Spawned antiafk and reset")
        Reset()
        NoAFK = true
        AntiAfk()
    end
end)

-- Detect when "Map" is removed
workspaceService.ChildRemoved:Connect(function(child)
    if child.Name == "Map" then
        stopResetLoop()  -- Stop the loop when map is removed
        waitTime = 9 -- <<<<<<<<<<   THIS ONE
        print("Stopping reset loop and changed respawn time", waitTime)
        NoAFK = false
    end
end)
