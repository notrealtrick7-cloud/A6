-- A6 Hub | TSB Fix Lag (Potato)
-- No UI — execute once. Client-side only.
-- Style: common TSB anti-lag / potato graphic scripts

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "A6 Fix Lag",
        Text = "Potato mode ON",
        Duration = 3,
    })
end)

-- Graphics floor
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    if settings().Rendering.EagerBulkExecution ~= nil then
        settings().Rendering.EagerBulkExecution = false
    end
end)

-- Lighting
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 200
    Lighting.FogStart = 0
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ClockTime = 14
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect")
            or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect")
            or fx:IsA("DepthOfFieldEffect") or fx:IsA("Atmosphere") then
            fx.Enabled = false
        end
    end
end)

-- Terrain water cheap
pcall(function()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 1
    end
end)

local function stripEffects(inst)
    if not inst then return end
    pcall(function()
        if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
            inst.Enabled = false
            inst:Destroy()
        elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
            inst.Enabled = false
            inst:Destroy()
        elseif inst:IsA("Explosion") then
            inst.Visible = false
            inst.BlastPressure = 0
            inst.BlastRadius = 0
        elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
            inst.Enabled = false
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            -- keep essential, lower
            if inst.Transparency then
                inst.Transparency = math.max(inst.Transparency, 0.35)
            end
        end
    end)
end

-- Initial sweep
for _, v in ipairs(workspace:GetDescendants()) do
    stripEffects(v)
end
for _, v in ipairs(Lighting:GetDescendants()) do
    stripEffects(v)
end

-- Live: new VFX / debris / effects
workspace.DescendantAdded:Connect(function(obj)
    task.defer(stripEffects, obj)
end)

-- Soft destroy noisy debris names common in TSB
local killNames = {
    "Effect", "VFX", "Particle", "Smoke", "Dust", "Crack", "Crater",
    "Debris", "Rock", "Slash", "Hit", "Aura", "Trail", "Shockwave",
    "Explosion", "Flash", "Glow", "AfterImage", "Afterimage",
}
local function nameLooksVfx(n)
    n = string.lower(n or "")
    for _, k in ipairs(killNames) do
        if string.find(n, string.lower(k), 1, true) then
            return true
        end
    end
    return false
end

workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if nameLooksVfx(obj.Name) then
            if obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CanCollide = false
                obj.Anchored = true
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Model") or obj:IsA("Folder") then
                pcall(function() obj:Destroy() end)
            else
                stripEffects(obj)
            end
        end
    end)
end)

-- Character clothes / accessories reduce (optional light)
local function simplifyChar(char)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        stripEffects(v)
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
            pcall(function() v:Destroy() end)
        end
    end
end

if player.Character then simplifyChar(player.Character) end
player.CharacterAdded:Connect(simplifyChar)

-- Other players auras (client only)
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        simplifyChar(c)
    end)
end)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then simplifyChar(plr.Character) end
end

-- Periodic light clean (TSB spams effects mid-fight)
task.spawn(function()
    while true do
        task.wait(4)
        pcall(function()
            for _, v in ipairs(workspace:GetChildren()) do
                if nameLooksVfx(v.Name) then
                    pcall(function() v:Destroy() end)
                end
            end
        end)
    end
end)

print("[A6 Fix Lag] Potato active")
