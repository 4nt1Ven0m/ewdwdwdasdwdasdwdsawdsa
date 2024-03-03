-- Assuming LaNoria UI library is imported and initialized as 'UI'

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
            esp.Visible = false
            return
        end

        if humanoid.Health <= 0 then
            esp.Visible = false
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

            if Config.BoxOutline then
                esp.BoxOutline.Visible = IsVisible
                esp.BoxOutline.Color = Config.BoxOutlineColor
                esp.BoxOutline.Size = Vector2.new(width, height)
                esp.BoxOutline.Position = Vector2.new(Target2dPosition.X - esp.Box.Size.X / 2, Target2dPosition.Y - esp.Box.Size.Y / 2)
            else
                esp.BoxOutline.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
        end

        if Config.NameText then
            esp.NameText.Text = displayName
            esp.NameText.Visible = IsVisible
        else
            esp.NameText.Visible = false
        end

        if Config.HealthBar then
            local healthBarHeight = 3
            local healthBarWidth = width * (humanoid.Health / humanoid.MaxHealth)
            local healthBarPosition = Vector2.new(Target2dPosition.X - width / 2, Target2dPosition.Y - height / 2 - healthBarHeight - 2)
            
            esp.HealthBarBackground.Size = Vector2.new(width, healthBarHeight)
            esp.HealthBarBackground.Position = healthBarPosition
            esp.HealthBarBackground.Color = Color3.new(0, 0, 0)
            esp.HealthBarBackground.Visible = IsVisible
            
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
        end

        -- Draw health text
        if Config.HealthText then
            esp.HealthText.Text = "" .. math.floor(humanoid.Health)
            esp.HealthText.Visible = IsVisible
        else
            esp.HealthText.Visible = false
        end

        -- Draw tool text
        if Config.ToolText then
            esp.ToolText.Text = "" .. tostring(findtool(character))
            esp.ToolText.Visible = IsVisible
        else
            esp.ToolText.Visible = false
        end

        -- Draw distance text
        if Config.DistanceText then
            esp.DistanceText.Text = "[" .. math.floor(distance) .. "s]"
            esp.DistanceText.Visible = IsVisible
        else
            esp.DistanceText.Visible = false
        end

        -- Draw tracers
        if Config.Tracers then
            esp.Tracers.Visible = IsVisible
            esp.Tracers.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            esp.Tracers.To = Vector2.new(Target2dPosition.X, Target2dPosition.Y)
            esp.Tracers.Color = Config.TracersColor
            esp.Tracers.Thickness = 1
            esp.Tracers.Transparency = 0.5
        end
    else
        esp.Visible = false
    end
end

function createEsp(player)
    local esp = {
        Box = UI.Create("Rectangle"),
        BoxOutline = UI.Create("Rectangle"),
        NameText = UI.Create("Text"),
        HealthBarBackground = UI.Create("Rectangle"),
        HealthBar = UI.Create("Rectangle"),
        HealthText = UI.Create("Text"),
        ToolText = UI.Create("Text"),
        DistanceText = UI.Create("Text"),
        Tracers = UI.Create("Line"),
    }

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
