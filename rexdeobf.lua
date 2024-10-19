-- ESP Library (Solara-compatible, loadable via loadstring)
local ESP = {}
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")

-- Settings table with customization options
ESP.Settings = {
    Enabled = true,
    Boxes = true,
    OutlineBoxes = true, -- New: Draws outline/glow around boxes
    Skeletons = true,
    Tracers = true,
    Names = true,
    HealthBar = true,
    HealthPercentage = true, -- New: Display health percentage
    Distance = true,
    HeadDot = true, -- New: Draws a dot on the player's head
    HitMarkers = true, -- New: Shows hit markers when players are damaged
    ArrowsForOffScreen = true, -- New: Draw arrows for off-screen enemies
    TeamCheck = false,
    FOVCheck = false,
    FOVRadius = 500, -- Field of View radius for ESP

    -- Custom Colors
    BoxColor = Color3.fromRGB(255, 0, 0),
    OutlineBoxColor = Color3.fromRGB(255, 255, 0), -- New: Outline box color
    SkeletonColor = Color3.fromRGB(0, 255, 0),
    TracerColor = Color3.fromRGB(0, 0, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthPercentageColor = Color3.fromRGB(255, 255, 255), -- New: Health percentage color
    DistanceColor = Color3.fromRGB(255, 255, 0),
    HeadDotColor = Color3.fromRGB(255, 0, 255), -- New: Head dot color
    HitMarkerColor = Color3.fromRGB(255, 255, 255), -- New: Hit marker color
    ArrowColor = Color3.fromRGB(255, 255, 0), -- New: Arrow color

    -- Misc
    LineThickness = 2,
    Transparency = 0.5
}

-- Helper function to check if a player is within FOV
local function withinFOV(position)
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    if onScreen then
        local centerX, centerY = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
        local dist = ((screenPos.X - centerX) ^ 2 + (screenPos.Y - centerY) ^ 2) ^ 0.5
        return dist <= ESP.Settings.FOVRadius
    end
    return false
end

-- Function to create drawing objects
local function createDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

-- Function to get the player's position on screen
local function getScreenPosition(position)
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Function to get the player's health ratio
local function getHealthRatio(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        return character.Humanoid.Health / character.Humanoid.MaxHealth
    end
    return 0
end

-- Function to create hit markers
local function createHitMarker(position)
    local hitMarkerSize = 10
    createDrawing("Line", {
        From = position - Vector2.new(hitMarkerSize, hitMarkerSize),
        To = position + Vector2.new(hitMarkerSize, hitMarkerSize),
        Color = ESP.Settings.HitMarkerColor,
        Thickness = ESP.Settings.LineThickness
    })
    createDrawing("Line", {
        From = position + Vector2.new(hitMarkerSize, -hitMarkerSize),
        To = position - Vector2.new(hitMarkerSize, hitMarkerSize),
        Color = ESP.Settings.HitMarkerColor,
        Thickness = ESP.Settings.LineThickness
    })
end

-- Function to create off-screen arrows pointing towards enemies
local function drawArrowToEnemy(position)
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen then
        local centerX, centerY = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
        local arrowDirection = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(centerX, centerY)).Unit
        local arrowPos = Vector2.new(centerX, centerY) + (arrowDirection * 100) -- Arrow 100 pixels from center

        createDrawing("Triangle", {
            Color = ESP.Settings.ArrowColor,
            Filled = true,
            Thickness = ESP.Settings.LineThickness,
            PointA = arrowPos,
            PointB = arrowPos + Vector2.new(10, 20), -- Adjust for arrow shape
            PointC = arrowPos + Vector2.new(-10, 20)
        })
    end
end

-- Main ESP rendering loop
local function drawESP()
    runService.RenderStepped:Connect(function()
        if not ESP.Settings.Enabled then return end

        for _, player in ipairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                local rootPart = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                local healthRatio = getHealthRatio(player)

                if ESP.Settings.TeamCheck and player.Team == localPlayer.Team then
                    continue
                end

                -- FOV Check (Optional)
                if ESP.Settings.FOVCheck and not withinFOV(rootPart.Position) then
                    continue
                end

                -- Get player's screen position
                local rootScreenPos, onScreen = getScreenPosition(rootPart.Position)
                local headScreenPos = getScreenPosition(head.Position)

                if onScreen then
                    -- Draw box
                    if ESP.Settings.Boxes then
                        local boxWidth, boxHeight = 100, 150  -- Customize size as needed
                        local box = createDrawing("Square", {
                            Color = ESP.Settings.BoxColor,
                            Thickness = ESP.Settings.LineThickness,
                            Transparency = ESP.Settings.Transparency,
                            Position = rootScreenPos - Vector2.new(boxWidth / 2, boxHeight / 2),
                            Size = Vector2.new(boxWidth, boxHeight),
                            Filled = false
                        })
                        
                        -- Draw outline box
                        if ESP.Settings.OutlineBoxes then
                            createDrawing("Square", {
                                Color = ESP.Settings.OutlineBoxColor,
                                Thickness = ESP.Settings.LineThickness,
                                Transparency = ESP.Settings.Transparency,
                                Position = rootScreenPos - Vector2.new(boxWidth / 2, boxHeight / 2),
                                Size = Vector2.new(boxWidth, boxHeight),
                                Filled = false
                            })
                        end
                    end

                    -- Draw skeleton
                    if ESP.Settings.Skeletons and character:FindFirstChild("LeftFoot") and character:FindFirstChild("RightFoot") then
                        createDrawing("Line", {
                            From = headScreenPos,
                            To = getScreenPosition(character.LeftFoot.Position),
                            Color = ESP.Settings.SkeletonColor,
                            Thickness = ESP.Settings.LineThickness
                        })
                        createDrawing("Line", {
                            From = headScreenPos,
                            To = getScreenPosition(character.RightFoot.Position),
                            Color = ESP.Settings.SkeletonColor,
                            Thickness = ESP.Settings.LineThickness
                        })
                    end

                    -- Draw tracer
                    if ESP.Settings.Tracers then
                        createDrawing("Line", {
                            From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y),
                            To = rootScreenPos,
                            Color = ESP.Settings.TracerColor,
                            Thickness = ESP.Settings.LineThickness
                        })
                    end

                    -- Draw name
                    if ESP.Settings.Names then
                        createDrawing("Text", {
                            Text = player.Name,
                            Position = headScreenPos,
                            Color = ESP.Settings.NameColor,
                            Size = 16,
                            Center = true,
                            Outline = true
                        })
                    end

                    -- Draw health bar
                    if ESP.Settings.HealthBar then
                        local healthBarHeight = 150 * healthRatio  -- Health bar adjusts based on player's health
                        createDrawing("Line", {
                            From = rootScreenPos - Vector2.new(55, 0),
                            To = rootScreenPos - Vector2.new(55, healthBarHeight),
                            Color = ESP.Settings.HealthBarColor,
                            Thickness = ESP.Settings.LineThickness
                        })
                    end

                    -- Draw health percentage
                    if ESP.Settings.HealthPercentage then
                        createDrawing("Text", {
                            Text = string.format("%d%%", healthRatio * 100), -- Display health as a percentage
                            Position = rootScreenPos - Vector2.new(70, 0),
                            Color = ESP.Settings.HealthPercentageColor,
                            Size = 16,
                            Center = true,
                            Outline = true
                        })
                    end

                    -- Draw distance
                    if ESP.Settings.Distance then
                        local distance = (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        createDrawing("Text", {
                            Text = string.format("%.1f studs", distance),
                            Position = rootScreenPos - Vector2.new(50, 30),
                            Color = ESP.Settings.DistanceColor,
                            Size = 16,
                            Center = true,
                            Outline = true
                        })
                    end

                    -- Draw head dot
                    if ESP.Settings.HeadDot then
                        createDrawing("Circle", {
                            Position = headScreenPos,
                            Radius = 5,
                            Color = ESP.Settings.HeadDotColor,
                            Filled = true
                        })
                    end
                else
                    -- Draw off-screen arrow for enemies
                    if ESP.Settings.ArrowsForOffScreen then
                        drawArrowToEnemy(rootPart.Position)
                    end
                end

                -- Optionally, handle hit markers (you would need to integrate damage events)
                if ESP.Settings.HitMarkers and player.Character:FindFirstChildOfClass("Humanoid").Health < player.Character.Humanoid.MaxHealth then
                    createHitMarker(rootScreenPos)
                end
            end
        end
    end)
end

-- Enable the ESP
function ESP:Toggle(state)
    ESP.Settings.Enabled = state
end

-- Run the ESP
drawESP()

return ESP
