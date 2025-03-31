local plr = game.Players.LocalPlayer

local function Teleport(position)
    for i, v in pairs(game.workspace.Live:GetChildren()) do
        if v.Name == plr.Name then
            local LivePlr = v
            LivePlr.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end
end

for i, v in pairs(game.workspace.Live:GetChildren() do
    Teleport(v.HumanoidRootPart.Position)
end
