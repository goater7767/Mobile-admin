

-- ULTIMATE MOBILE ADMIN V1
-- Roblox Studio LocalScript
-- Install in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local speedOn = false
local jumpOn = false
local flyOn = false
local invisibleOn = false
local flyingConnection

local normalSpeed = 16
local normalJump = 50
local flySpeed = 65

local gui = Instance.new("ScreenGui")
gui.Name = "UltimateMobileAdmin"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(205, 340)
frame.Position = UDim2.new(0, 15, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 120, 65)
title.Text = "ULTIMATE ADMIN"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function makeButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 42)
    button.Position = UDim2.fromOffset(8, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 65, 75)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Text = text
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.Activated:Connect(callback)
    return button
end

local speedButton
speedButton = makeButton("Speed: OFF", 52, function()
    speedOn = not speedOn
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speedOn and 40 or normalSpeed
    end
    speedButton.Text = "Speed: " .. (speedOn and "ON" or "OFF")
end)

local jumpButton
jumpButton = makeButton("Super Jump: OFF", 100, function()
    jumpOn = not jumpOn
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpOn and 100 or normalJump
    end
    jumpButton.Text = "Super Jump: " .. (jumpOn and "ON" or "OFF")
end)

local flyButton
flyButton = makeButton("Fly: OFF", 148, function()
    flyOn = not flyOn
    flyButton.Text = "Fly: " .. (flyOn and "ON" or "OFF")

    if flyingConnection then
        flyingConnection:Disconnect()
        flyingConnection = nil
    end

    local root = getRoot()
    local hum = getHumanoid()
    if not root or not hum then return end

    if flyOn then
        local attachment = Instance.new("Attachment")
        attachment.Parent = root

        local velocity = Instance.new("LinearVelocity")
        velocity.Attachment0 = attachment
        velocity.MaxForce = math.huge
        velocity.VectorVelocity = Vector3.zero
        velocity.Parent = root

        local gyro = Instance.new("AlignOrientation")
        gyro.Attachment0 = attachment
        gyro.MaxTorque = math.huge
        gyro.Responsiveness = 15
        gyro.Parent = root

        hum:ChangeState(Enum.HumanoidStateType.Physics)

        flyingConnection = RunService.RenderStepped:Connect(function()
            if not flyOn or not root.Parent then return end

            local camera = workspace.CurrentCamera
            local direction = Vector3.zero

            if UIS:IsKeyDown(Enum.KeyCode.W) then
                direction += camera.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                direction -= camera.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                direction -= camera.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                direction += camera.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.yAxis
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction -= Vector3.yAxis
            end

            velocity.VectorVelocity = direction * flySpeed
            gyro.CFrame = camera.CFrame
        end)

        -- Save objects for cleanup
        flyButton:SetAttribute("Flying", true)
        root:SetAttribute("AdminFlying", true)
        velocity:SetAttribute("AdminFly", true)
        attachment:SetAttribute("AdminFly", true)
        gyro:SetAttribute("AdminFly", true)
    else
        for _, obj in ipairs(root:GetChildren()) do
            if obj:GetAttribute("AdminFly") then
                obj:Destroy()
            end
        end
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

local invisibleButton
invisibleButton = makeButton("Local Invisibility: OFF", 196, function()
    invisibleOn = not invisibleOn

    local char = getCharacter()
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                if invisibleOn then
                    if obj:GetAttribute("OldTransparency") == nil then
                        obj:SetAttribute("OldTransparency", obj.Transparency)
                    end
                    obj.LocalTransparencyModifier = 1
                else
                    obj.LocalTransparencyModifier = 0
                end
            end
        end
    end

    invisibleButton.Text = "Local Invisibility: " ..
        (invisibleOn and "ON" or "OFF")
end)

makeButton("Teleport to Spawn", 244, function()
    local root = getRoot()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)

    if root and spawn then
        root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
    end
end)

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.fromOffset(90, 40)
hideButton.Position = UDim2.new(0, 15, 0.25, 350)
hideButton.Text = "HIDE MENU"
hideButton.TextScaled = true
hideButton.BackgroundColor3 = Color3.fromRGB(35, 120, 65)
hideButton.TextColor3 = Color3.new(1,1,1)
hideButton.Parent = gui

hideButton.Activated:Connect(function()
    frame.Visible = not frame.Visible
    hideButton.Text = frame.Visible and "HIDE MENU" or "OPEN MENU"
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    speedOn = false
    jumpOn = false
    flyOn = false
    invisibleOn = false
    

    if flyingConnection then
        flyingConnection:Disconnect()
        flyingConnection = nil
    end

    speedButton.Text = "Speed: OFF"
    jumpButton.Text = "Super Jump: OFF"
    flyButton.Text = "Fly: OFF"
    invisibleButton.Text = "Local Invisibility: OFF"
end)

print("ULTIMATE MOBILE ADMIN V1 LOADED")
