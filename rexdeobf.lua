local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

ESP.Enabled = true
ESP.Boxes = true
ESP.Names = true
ESP.Color = Color3.fromRGB(255, 0, 0) -- Red color for ESP elements
ESP.TextSize = 14

-- Function to create a 2D box for each player
local function DrawESP(player)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local position, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            local headPos = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local legPos = Camera:WorldToViewportPoint((humanoidRootPart.CFrame * CFrame.new(0, -3, 0)).p)
            
            -- Calculate size for the box
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2

            -- Draw the box
            if ESP.Boxes then
                Solara.Drawing.new("Square", {
                    Position = Vector2.new(position.X - width / 2, position.Y - height / 2),
                    Size = Vector2.new(width, height),
                    Color = ESP.Color,
                    Filled = false,
                    Thickness = 2
                }):Draw()
            end

            -- Draw the name above the player
            if ESP.Names then
                Solara.Drawing.new("Text", {
                    Text = player.Name,
                    Position = Vector2.new(position.X, position.Y - height / 2 - ESP.TextSize),
                    Color = ESP.Color,
                    Size = ESP.TextSize,
                    Center = true,
                    Outline = true
                }):Draw()
            end
        end
    end
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            DrawESP(player)
        end
    end
end)

-- Toggle ESP function
function ESP:Toggle(state)
    ESP.Enabled = state
end

-- Toggle Box drawing
function ESP:ToggleBoxes(state)
    ESP.Boxes = state
end

-- Toggle Name drawing
function ESP:ToggleNames(state)
    ESP.Names = state
end

-- Change color
function ESP:SetColor(color)
    ESP.Color = color
end

-- Change text size
function ESP:SetTextSize(size)
    ESP.TextSize = size
end

return ESP
