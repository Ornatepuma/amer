-- DEATH DEATH DEATH DEATH DEATH DEATH
-- DEATH DEATH DEATH DEATH DEATH DEATH

function Rematch()
    game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()
end

for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
  v:Disable()
end

workspace.ChildAdded:Connect(function(c)
    if c.Name == "Map" then 
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then 
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(3)
        end
    end
end)
game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
    if v.Name == "BanChooser" then 
        v:WaitForChild("rem"):FireServer("pass")
    end
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if workspace:FindFirstChild("Map") then 
        task.wait(0.3)
        game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health = 0
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(3)
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RematchVote"):FireServer()
        end)
    end
end)
