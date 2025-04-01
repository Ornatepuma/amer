local plr = game.Players.LocalPlayer
_G.Running = false

local function Teleport(target)
    for _, v in pairs(game.Workspace.Live:GetChildren()) do
        if v.Name == plr.Name and v:FindFirstChild("HumanoidRootPart") then
            local LivePlr = v
            local targetHRP = target:FindFirstChild("HumanoidRootPart")
            
            if targetHRP then
                -- Move 3 studs behind the target
                local offsetCFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                LivePlr.HumanoidRootPart.CFrame = offsetCFrame
            end
        end
    end
end

local function BackAttach(targetName)
    
    while _G.Running do
        for _, v in pairs(game.Workspace.Live:GetChildren()) do
            if v.Name == targetName and v:FindFirstChild("HumanoidRootPart") then
                Teleport(v)
            elseif not v:FindFirstChild("HumanoidRootPart") then
                continue
            end
        end
        task.wait(0.1) -- Prevents script from freezing
    end
end

-- Example Usage: Follow a player named "EnemyPlayer"
BackAttach("EnemyPlayer") -- Replace with the actual target name
