local Config = {
    Box = false,
    BoxOutline = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    NameText = false,
    NameTextColor = Color3.fromRGB(255, 255, 255),
    HealthBar = false,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthText = false,
    HealthTextColor = Color3.fromRGB(255, 255, 255),
    ToolText = false,
    ToolTextColor = Color3.fromRGB(255, 255, 255),
    DistanceText = false,
    DistanceTextColor = Color3.fromRGB(255, 255, 255),
    Tracers = false,
    TracersColor = Color3.fromRGB(255, 255, 255),
    HealthBarDynamicColor = false,  -- Enable dynamic color change for health bar
    LowHealthColor = Color3.fromRGB(255, 0, 0),  -- Color for low health
    HighHealthColor = Color3.fromRGB(0, 255, 0),  -- Color for high health
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local function createDrawingObjects()
    local drawingObjects = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        NameText = Drawing.new("Text"),
        HealthBarBackground = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        ToolText = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
        Tracers = Drawing.new("Line"),
    }
    return drawingObjects
end

local function updateEsp(player, esp)
    local character = player and player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local displayName = player.Name
        local toolName = humanoid and humanoid.Parent and humanoid.Parent:IsA("Tool") and humanoid.Parent.Name or ""
        local localHumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distance = localHumanoidRootPart and humanoidRootPart and (localHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude or nil

        if not humanoidRootPart or not head or not humanoid or not distance then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        if humanoid.Health <= 0 then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            return
        end

        local Target2dPosition, IsVisible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
        local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)

        if Config.Box then
            esp.Box.Visible = IsVisible
            esp.Box.Color = Config.BoxColor
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = Vector2.new(Target2dPosition.X - esp.Box.Size.X / 2, Target2dPosition.Y - esp.Box.Size.Y / 2)
            esp.Box.Thickness = 1
            esp.Box.ZIndex = 69

            if Config.BoxOutline then
                esp.BoxOutline.Visible = IsVisible
                esp.BoxOutline.Color = Config.BoxOutlineColor
                esp.BoxOutline.Size = Vector2.new(width, height)
                esp.BoxOutline.Position = Vector2.new(Target2dPosition.X - esp.Box.Size.X / 2, Target2dPosition.Y - esp.Box.Size.Y / 2)
                esp.BoxOutline.Thickness = 3
                esp.BoxOutline.ZIndex = 1
            else
                esp.BoxOutline.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
        end

        if Config.NameText then
            if IsVisible then
                esp.NameText.Text = displayName
                esp.NameText.Color = Config.NameTextColor
                esp.NameText.Position = Vector2.new(Target2dPosition.X, Target2dPosition.Y + height / 2 + 5)
                esp.NameText.Size = 18
                esp.NameText.Center = true
                esp.NameText.Outline = true
                esp.NameText.OutlineColor = Color3.new(0, 0, 0)
                esp.NameText.Visible = true
                esp.NameText.ZIndex = 69
            else
                esp.NameText.Visible = false
            end
        end

        if Config.HealthBar then
            local healthBarHeight = 3
            local healthBarWidth = width * (humanoid.Health / humanoid.MaxHealth)
            local healthBarPosition = Vector2.new(Target2dPosition.X - width / 2, Target2dPosition.Y - height / 2 - healthBarHeight - 2)
            
            esp.HealthBarBackground.Size = Vector2.new(width, healthBarHeight)
            esp.HealthBarBackground.Position = healthBarPosition
            esp.HealthBarBackground.Color = Color3.new(0, 0, 0)
            esp.HealthBarBackground.Visible = IsVisible
            esp.HealthBarBackground.Thickness = 1
            esp.HealthBarBackground.ZIndex = 68
            
            esp.HealthBar.Size = Vector2.new(healthBarWidth, healthBarHeight)
            esp.HealthBar.Position = healthBarPosition
            if Config.HealthBarDynamicColor then
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                local lowHealthThreshold = 0.3  -- Health percentage threshold for low health
                local healthBarColor
                if healthPercentage <= lowHealthThreshold then
                    healthBarColor = Config.LowHealthColor
                else
                    healthBarColor = Config.HighHealthColor
                end
                esp.HealthBar.Color = healthBarColor
            else
                esp.HealthBar.Color = Config.HealthBarColor
            end
            esp.HealthBar.Visible = IsVisible
            esp.HealthBar.Thickness = 1
            esp.HealthBar.ZIndex = 69
        end

        -- Draw health text
        if Config.HealthText then
            if IsVisible then
                esp.HealthText.Text = "" .. math.floor(humanoid.Health)
                esp.HealthText.Color = Config.HealthTextColor
                esp.HealthText.Position = Vector2.new(Target2dPosition.X + width / 2, Target2dPosition.Y - height / 2 - 20)
                esp.HealthText.Size = 18
                esp.HealthText.Center = false
                esp.HealthText.Outline = true
                esp.HealthText.OutlineColor = Color3.new(0, 0, 0)
                esp.HealthText.Visible = true
                esp.HealthText.ZIndex = 69
            else
                esp.HealthText.Visible = false
            end
        end

        -- Draw tool text
        if Config.ToolText then
            if IsVisible then
                esp.ToolText.Text = "" .. tostring(findtool(character))
                esp.ToolText.Color = Config.ToolTextColor
                esp.ToolText.Position = Vector2.new(Target2dPosition.X, Target2dPosition.Y + height / 2 + 20)
                esp.ToolText.Size = 18
                esp.ToolText.Center = true
                esp.ToolText.Outline = true
                esp.ToolText.OutlineColor = Color3.new(0, 0, 0)
                esp.ToolText.Visible = true
                esp.ToolText.ZIndex = 69
            else
                esp.ToolText.Visible = false
            end
        end

        -- Draw distance text
        if Config.DistanceText then
            if IsVisible then
                esp.DistanceText.Text = "[" .. math.floor(distance) .. "s]"
                esp.DistanceText.Color = Config.DistanceTextColor
                esp.DistanceText.Position = Vector2.new(Target2dPosition.X, Target2dPosition.Y + height / 2 + 40)
                esp.DistanceText.Size = 18
                esp.DistanceText.Center = true
                esp.DistanceText.Outline = true
                esp.DistanceText.OutlineColor = Color3.new(0, 0, 0)
                esp.DistanceText.Visible = true
                esp.DistanceText.ZIndex = 69
            else
                esp.DistanceText.Visible = false
            end
        end

        -- Draw tracers
        if Config.Tracers then
            esp.Tracers.Visible = IsVisible
            esp.Tracers.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            esp.Tracers.To = Vector2.new(Target2dPosition.X, Target2dPosition.Y)
            esp.Tracers.Color = Config.TracersColor
            esp.Tracers.Thickness = 1
            esp.Tracers.Transparency = 0.5
            esp.Tracers.ZIndex = 69
        end
    else
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
    end
end

function createEsp(player)
    local esp = createDrawingObjects()

    local Updater
    Updater = game:GetService("RunService").Heartbeat:Connect(function()
        updateEsp(player, esp)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createEsp(player)
        player.CharacterAdded:Connect(function()
            createEsp(player)
        end)
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createEsp(player)
        player.CharacterAdded:Connect(function()
            createEsp(player)
        end)
    end
end

return Config
