local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local de = RS:WaitForChild("Events"):WaitForChild("DataEvent")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local pickupRange = 10
local fruits = {
	"Banana", "Orange", "Fruit Of Forgetfulness", "Pear",
	"Apple", "Alluring Apple", "Mango", "Fruit Of Life"
}
local trinket = {
	"Gold Necklace", "Gold Bracelet", "Gold Ring",
	"Silver Ring", "Silver Necklace", "Silver Bracelet",
	"Ring Of Infusion", "Chakra Heart",
	"Summoning Scroll", "Staff Schematics", "Gold Enclosed Ring", "Ring Of Nourishment", "Silver Enclosed Ring"
}



local function isFruit(name)
	for _, fruitName in ipairs(fruits) do
		if name == fruitName then
			return true
		end
	end
	return false
end

local function isTrinket(name)
	for _, item in ipairs(trinket) do
		if name == item then
			return true
		end
	end
	return false
end

while task.wait(0.2) do
	if not root then continue end

	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("MeshPart") or v:IsA("Part") then
			local id = v:FindFirstChild("ID")
			if id and (v.Position - root.Position).Magnitude <= pickupRange then
				if isFruit(v.Name) or isTrinket(v.Name) then
					de:FireServer("PickUp", id.Value)
				end
			end
		end
	end
end








-- ESP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local Active_Gui = {}

for _, v in pairs(workspace:GetChildren()) do
    if isFruit(v.Name) or isTrinket(v.Name) then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 100, 0, 20)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(255, 255, 255)
		label.Text = v.Name
		label.Visible = true
		label.Parent = screenGui
    end
end
