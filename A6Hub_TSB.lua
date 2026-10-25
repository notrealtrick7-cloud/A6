-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
--
-- Stay safe:
--   • Never log in on unofficial Roblox sites or lookalike domains.
--   • Real Roblox links use roblox.com (check the .com ending).
--   • Treat fake Roblox login / "claim reward" pages as phishing.
-- [[ End Rscripts Risk Notice ]]
--// PREMIUM MINIMALIST GUI REWRITE (BLACK/WHITE/GRAY)
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

--// OLD SCRIPT TERMINATION SYSTEM
local scriptId = math.random(1, 1000000)
_G.A6HubTSBId = scriptId
local function isCurrent() return _G.A6HubTSBId == scriptId end

--// CONFIG
local Config = {
    Enabled = true,
    LethalEnabled = true,
    -- Primary + common TSB uppercut / lethal anim ids (numeric only for match)
    LethalAnim = "rbxassetid://10503381238",
    UppercutAnimIds = {
        ["10503381238"] = true, -- current lethal
        ["10491993682"] = true,
        ["10479335397"] = true,
        ["13380255751"] = true,
        -- leave room; scan also matches Animation.Name containing Uppercut
    },
    ScanUppercutName = true,
    DebugAnim = false,
    SolitudeHeart = false,
    SolitudeP = false,
    SolitudeR = false,
    PatternTwinnie = false,   -- straight + late 180 flick (not full circle)
    PatternBoomy = false,     -- front dash + 180 turn back
    PatternLordHeaven = false,-- 90° camera circle
    PatternVoid = false,      -- ryushin/void style tight orbit
    PatternDoopy = false,     -- tight centered loop (doopy style)
    InstantTwisted = false,   -- 4 M1 + stepback + Q dash + L/R/straight flick
    SolitudeDashCount = 4,
    SolitudeOrbitTime = 0.28,
    -- Per-tech settings (like other TSB scripts: delay / dashes / turn)
    TwinnieDashes = 3,
    TwinnieStep = 0.22,
    BoomyDashes = 2,
    BoomyStep = 0.18,
    LordHeavenDashes = 5,
    LordHeavenStep = 0.25,
    VoidDashes = 4,
    VoidStep = 0.20,
    DoopyDashes = 5,
    DoopyStep = 0.22,
    InstantTwistedStep = 0.12,
    InstantTwistedBack = 2.2,
    LethalDelay = 0.275,
    LethalJump = 54,
    LethalAccuracy = 15,
    LethalCancelDelay = 0.4,
    LethalMode = "V1",
    CancelEnabled = true,
    CooldownActive = true,
    NoClipEnabled = true,
    DashRange = 8,
    TouchMode = false,
    Platform = "PC",
    Keybind = "E",
    CooldownAnims = {
        ["10491993682"] = true,
        ["10479335397"] = true,
        ["13380255751"] = true,
    }
}

local dashAnims = {["rbxassetid://12296113986"] = true}
local isNoclipping = false
local isCooldown = false

-- // GLOBAL GUI VARIABLES
local ScreenGui, MainFrame, CooldownBar, CooldownFill

-- // NUMERIC ID EXTRACTION FUNCTION
local function getId(str)
    return tostring(str):match("%d+")
end

--// NEW DASH FUNCTION (USING REMOTEEVENT)
local function fireDash()
    local char = player.Character
    if not char then return end
    -- 1) TSB Communicate remote (several arg layouts)
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer({
                Dash = Enum.KeyCode.W,
                Key = Enum.KeyCode.Q,
                Goal = "KeyPress"
            })
        end)
        pcall(function()
            communicate:FireServer({
                Goal = "KeyPress",
                Key = Enum.KeyCode.Q
            })
        end)
        pcall(function()
            communicate:FireServer("Dash", "Front")
        end)
    end
    -- 2) VirtualInput fallback: press Q (dash) + hold W briefly
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.delay(0.12, function()
            VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end)
    -- 3) Humanoid Move in look direction as last resort
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum:Move(root.CFrame.LookVector, true)
            task.delay(0.15, function()
                if hum then hum:Move(Vector3.zero, true) end
            end)
        end
    end)
end

--// HELPER FUNCTIONS
local function clip()
    isNoclipping = false
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local function forceCancel()
    clip()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") or obj:IsA("Attachment") or obj:IsA("BodyAngularVelocity") then
                obj:Destroy()
            end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // COOLDOWN HANDLING FUNCTION
local function startCooldown(duration)
    if not isCurrent() or isCooldown then return end
    isCooldown = true
    
    if MainFrame and CooldownBar and CooldownFill then
        CooldownBar.Visible = true
        CooldownFill.Size = UDim2.new(1, 0, 1, 0)
        local tween = TweenService:Create(CooldownFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        tween:Play()
        
        task.delay(duration, function()
            isCooldown = false
            CooldownBar.Visible = false
        end)
    else
        task.wait(duration)
        isCooldown = false
    end
end

local function getTorsoTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    
    local parts = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, Config.DashRange, params)
    local target = nil
    local dist = Config.DashRange
    
    for _, part in pairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") and model ~= char then
            local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
            if torso then
                local d = (char.HumanoidRootPart.Position - torso.Position).Magnitude
                if d < dist then 
                    dist = d 
                    target = torso 
                end
            end
        end
    end
    return target
end

--// LETHAL EXECUTION FUNCTION
local isExecuting = false
local function executeLethal()
            task.delay(0.1, function() if Config.Enabled then runFullTechSequence() end end)
    if not isCurrent() or isExecuting or isCooldown then return end
    if not Config.Enabled or not Config.LethalEnabled then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local torso = getTorsoTarget()
    if not torso then clip() return end
    
    isExecuting = true
    
    if not Config.TouchMode then
        task.wait(Config.LethalDelay)
    end
    
    if not isCurrent() then isExecuting = false return end
    
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.LethalJump, root.AssemblyLinearVelocity.Z)
    isNoclipping = true
    fireDash()
    -- Solitude patterns chain after first lethal dash
    task.defer(solitudeAfterUppercut)
    
    local startT = tick()
    local flipped = false
    local forwardDir = (torso.Position - root.Position).Unit
    local sideVec = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
    local bav = nil
    
    if Config.LethalMode == "V1" then
        bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(0, 1000000, 0)
        bav.P = 15000
        bav.Parent = root
    end
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not isCurrent() or not torso or not torso.Parent or not root or not root.Parent then 
            if bav then bav:Destroy() end 
            clip()
            isExecuting = false
            if conn then conn:Disconnect() end
            return 
        end
        
        local elapsed = tick() - startT
        local torsoPos, rootPos = torso.Position, root.Position
        hum.AutoRotate = false
        
        if Config.LethalMode == "V1" then
            local angle = (elapsed / 0.45) * (math.pi / 1.5)
            local radius = Config.LethalAccuracy * (1 - math.clamp(elapsed / 0.45, 0, 1))
            local targetLookPos = torsoPos + (sideVec * math.cos(angle) + forwardDir * math.sin(angle)) * radius
            local lookAtCF = CFrame.lookAt(rootPos, Vector3.new(targetLookPos.X, rootPos.Y, targetLookPos.Z))
            local relativeCF = root.CFrame:Inverse() * lookAtCF
            local _, y, _ = relativeCF:ToEulerAnglesXYZ()
            if bav and bav.Parent then 
                bav.AngularVelocity = Vector3.new(0, y * 30, 0) 
            end
        else
            if elapsed >= Config.LethalAccuracy and not flipped then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
                flipped = true
            end
        end

        local distXZ = (Vector2.new(rootPos.X, rootPos.Z) - Vector2.new(torsoPos.X, torsoPos.Z)).Magnitude
        if Config.CancelEnabled and elapsed > Config.LethalCancelDelay then
            if distXZ < 2.2 then
                if bav then bav:Destroy() end
                forceCancel()
                isExecuting = false
                conn:Disconnect()
                return
            end
        end
        
        if not Config.Enabled or elapsed > 1.5 then
            if bav then bav:Destroy() end
            clip()
            isExecuting = false
            conn:Disconnect()
            return
        end
    end)
end



--// SOLITUDE TECH PATTERNS (Heart / P / R)
-- Community Solitude dash: after uppercut, loop front/side dashes under floater
local solitudeBusy = false
local function runSolitudePattern(kind)
    if solitudeBusy or not Config.Enabled then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "A6 Pattern",
            Text = "Running: " .. tostring(kind),
            Duration = 2,
        })
    end)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    if not root or not hum or not cam then return end
    solitudeBusy = true
    isNoclipping = true
    local n, step = 4, 0.28
    if kind == "Twinnie" then
        n = tonumber(Config.TwinnieDashes) or 3
        step = tonumber(Config.TwinnieStep) or 0.22
    elseif kind == "Boomy" then
        n = tonumber(Config.BoomyDashes) or 2
        step = tonumber(Config.BoomyStep) or 0.18
    elseif kind == "LordHeaven" then
        n = tonumber(Config.LordHeavenDashes) or 5
        step = tonumber(Config.LordHeavenStep) or 0.25
    elseif kind == "Void" then
        n = tonumber(Config.VoidDashes) or 4
        step = tonumber(Config.VoidStep) or 0.20
    elseif kind == "Doopy" then
        n = tonumber(Config.DoopyDashes) or 5
        step = tonumber(Config.DoopyStep) or 0.22
    elseif kind == "Heart" or kind == "P" or kind == "R" then
        n = tonumber(Config.SolitudeDashCount) or 4
        step = tonumber(Config.SolitudeOrbitTime) or 0.28
    end
    n = math.clamp(n, 1, 12)
    -- Community Solitude: after uppercut, stay under floater and
    -- flick camera/character in letter-shaped paths (P / R / Heart) while front-dashing.
    task.spawn(function()
        for i = 1, n do
            if not isCurrent() or not Config.Enabled then break end
            local torso = getTorsoTarget()
            if not torso or not torso.Parent then break end
            local rp = root.Position
            local tp = torso.Position
            local flat = Vector3.new(tp.X - rp.X, 0, tp.Z - rp.Z)
            if flat.Magnitude < 0.05 then
                flat = root.CFrame.LookVector
            end
            flat = flat.Unit
            local right = Vector3.new(-flat.Z, 0, flat.X)
            local t = (i - 1) / math.max(n - 1, 1) -- 0..1 along pattern
            local dir
            if kind == "P" then
                -- P: go up-stem then loop (right arc) — alternate forward / right-forward
                -- approximate: 0-0.4 forward, 0.4-1 right curve
                if t < 0.35 then
                    dir = flat
                else
                    local a = (t - 0.35) / 0.65 * math.pi -- half loop
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                end
            elseif kind == "R" then
                -- R: like P but leg kicks out (more right then back-right)
                if t < 0.3 then
                    dir = flat
                elseif t < 0.65 then
                    local a = (t - 0.3) / 0.35 * (math.pi * 0.7)
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                else
                    dir = (flat * 0.2 + right * 0.8).Unit
                end
            elseif kind == "Twinnie" then
                -- Twinnie (twinnie games): mostly straight under head, slight line then late 180 flick — not full circle
                if t < 0.7 then
                    dir = flat
                else
                    local a = (t - 0.7) / 0.3 * math.pi
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                end
            elseif kind == "Boomy" then
                -- Boomy instant lethal style: front then 180 snap back
                if t < 0.5 then
                    dir = flat
                else
                    dir = -flat
                end
            elseif kind == "LordHeaven" then
                -- LordHeaven: 90° camera circle (quarter turns around target)
                local a = t * (math.pi * 2)
                dir = (flat * math.cos(a) + right * math.sin(a)).Unit
            elseif kind == "Void" then
                -- Void / Ryushin: tighter smaller radius orbit
                local a = t * (math.pi * 2)
                dir = (flat * math.cos(a * 1.5) + right * math.sin(a * 1.5) * 0.7).Unit
            elseif kind == "Doopy" then
                -- Doopy-style: tight centered loop, stay close to torso
                local a = t * (math.pi * 2)
                dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                -- pull slightly toward target each step
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tp.X, root.Position.Y, tp.Z))
            
            else -- Heart
                -- Heart: left lobe then right lobe (two circles side by side)
                if t < 0.5 then
                    local a = t / 0.5 * math.pi
                    dir = (flat * math.cos(a) - right * math.sin(a)).Unit
                else
                    local a = (t - 0.5) / 0.5 * math.pi
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                end
            end
            -- face dash direction then fire front dash
            root.CFrame = CFrame.lookAt(rp, rp + dir)
            if cam then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir)
            end
            fireDash()
            pcall(function()
                local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local look = r.CFrame.LookVector
                    r.AssemblyLinearVelocity = Vector3.new(look.X * 48, math.max(r.AssemblyLinearVelocity.Y, 8), look.Z * 48)
                end
            end)
            task.wait(step)
        end
        clip()
        solitudeBusy = false
    end)
end

local function solitudeAfterUppercut()
    if Config.SolitudeHeart then runSolitudePattern("Heart")
    elseif Config.SolitudeP then runSolitudePattern("P")
    elseif Config.SolitudeR then runSolitudePattern("R")
    elseif Config.PatternTwinnie then runSolitudePattern("Twinnie")
    elseif Config.PatternBoomy then runSolitudePattern("Boomy")
    elseif Config.PatternLordHeaven then runSolitudePattern("LordHeaven")
    elseif Config.PatternVoid then runSolitudePattern("Void")
    elseif Config.PatternDoopy then runSolitudePattern("Doopy")
    end
end


--// INSTANT TWISTED (4 M1 + stepback + forward dash + L→R→straight flick)
-- Community (VoidRBX / DrowningFish): best ~0-80ms; step back on 4th M1 then Q dash + camera flicks
local twistedState = { hits = 0, last = 0, stepped = false }
local function tryInstantTwisted()
    if not Config.InstantTwisted or not Config.Enabled then return end
    if isCooldown or isExecuting or solitudeBusy then return end
    local now = tick()
    if now - twistedState.last > 1.2 then
        twistedState.hits = 0
        twistedState.stepped = false
    end
end

local function runInstantTwisted()
    if solitudeBusy or isExecuting then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    solitudeBusy = true
    isNoclipping = true
    task.spawn(function()
        -- step back already assumed from player; face target then dash with L/R/straight
        local torso = getTorsoTarget()
        local cam = workspace.CurrentCamera
        local sequence = { "left", "right", "straight" }
        for _, phase in ipairs(sequence) do
            if not isCurrent() or not Config.InstantTwisted then break end
            torso = getTorsoTarget() or torso
            if not torso then break end
            local rp = root.Position
            local tp = torso.Position
            local flat = Vector3.new(tp.X - rp.X, 0, tp.Z - rp.Z)
            if flat.Magnitude < 0.05 then flat = root.CFrame.LookVector end
            flat = flat.Unit
            local right = Vector3.new(-flat.Z, 0, flat.X)
            local dir = flat
            if phase == "left" then dir = (flat * 0.4 - right * 0.9).Unit
            elseif phase == "right" then dir = (flat * 0.4 + right * 0.9).Unit
            else dir = flat end
            root.CFrame = CFrame.lookAt(rp, rp + dir)
            if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + dir) end
            fireDash()
            task.wait(tonumber(Config.InstantTwistedStep) or 0.12)
        end
        clip()
        solitudeBusy = false
        twistedState.hits = 0
        twistedState.stepped = false
    end)
end

-- Hook M1 count for Instant Twisted (4 hits then S/back or auto after 4)
UIS.InputBegan:Connect(function(input, gpe)
    if not isCurrent() or not Config.InstantTwisted then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if gpe then return end
        local now = tick()
        if now - twistedState.last > 1.2 then twistedState.hits = 0 end
        twistedState.hits += 1
        twistedState.last = now
        if twistedState.hits >= 4 then
            -- micro step back then twisted
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame * CFrame.new(0, 0, tonumber(Config.InstantTwistedBack) or 2.2)
            end
            task.delay(0.05, runInstantTwisted)
            twistedState.hits = 0
        end
    end
end)

--// COMBO UPPERCUT SCAN (M1 chain + jump = uppercut tech)
local comboState = {
    hits = 0,
    lastHit = 0,
    window = 1.15, -- time between M1s
    jumpPressed = false,
    lastJump = 0,
}

local function noteHit()
    local now = tick()
    if now - comboState.lastHit > comboState.window then
        comboState.hits = 0
    end
    comboState.hits += 1
    comboState.lastHit = now
end

-- Full auto sequence: 4 M1 + Jump detected → jump boost + Q dash + pattern flicks
local function runFullTechSequence()
    if not Config.Enabled or solitudeBusy or isExecuting then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local kind = nil
    if Config.SolitudeHeart then kind = "Heart"
    elseif Config.SolitudeP then kind = "P"
    elseif Config.SolitudeR then kind = "R"
    elseif Config.PatternTwinnie then kind = "Twinnie"
    elseif Config.PatternBoomy then kind = "Boomy"
    elseif Config.PatternLordHeaven then kind = "LordHeaven"
    elseif Config.PatternVoid then kind = "Void"
    elseif Config.PatternDoopy then kind = "Doopy"
    else kind = "Heart" -- default loop under floater
    end

    solitudeBusy = true
    isNoclipping = true
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "A6 Tech",
            Text = "Chase dash: " .. kind,
            Duration = 2,
        })
    end)

    task.spawn(function()
        -- Lift slightly so we are under floater path
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            math.max(root.AssemblyLinearVelocity.Y, Config.LethalJump or 54),
            root.AssemblyLinearVelocity.Z
        )
        task.wait(tonumber(Config.LethalDelay) or 0.22)

        -- Chase: 5-8 rapid face-torso + Q dashes in pattern (under floater)
        local dashes = 6
        local step = 0.16
        if kind == "Twinnie" then dashes, step = 3, 0.18
        elseif kind == "Boomy" then dashes, step = 2, 0.15
        elseif kind == "LordHeaven" then dashes, step = 5, 0.18
        elseif kind == "Void" or kind == "Doopy" then dashes, step = 6, 0.14
        end

        for i = 1, dashes do
            if not isCurrent() or not Config.Enabled then break end
            root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not root then break end
            local torso = getTorsoTarget()
            if not torso then break end

            local rp = root.Position
            local tp = torso.Position
            -- aim slightly under (Y lower) so we hit from below
            local aim = Vector3.new(tp.X, rp.Y, tp.Z)
            local flat = Vector3.new(aim.X - rp.X, 0, aim.Z - rp.Z)
            if flat.Magnitude < 0.05 then flat = root.CFrame.LookVector end
            flat = flat.Unit
            local right = Vector3.new(-flat.Z, 0, flat.X)
            local t = (i - 1) / math.max(dashes - 1, 1)
            local dir = flat
            if kind == "Heart" or kind == "LordHeaven" or kind == "Doopy" or kind == "Void" then
                local a = t * math.pi * 2
                local scale = (kind == "Void") and 0.7 or 1
                dir = (flat * math.cos(a) + right * math.sin(a) * scale).Unit
            elseif kind == "P" then
                if t < 0.35 then dir = flat
                else
                    local a = (t - 0.35) / 0.65 * math.pi * 1.5
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                end
            elseif kind == "R" then
                local a = t * math.pi * 1.2
                dir = (flat * math.cos(a) - right * math.sin(a)).Unit
            elseif kind == "Twinnie" then
                if t < 0.65 then dir = flat
                else
                    local a = (t - 0.65) / 0.35 * math.pi
                    dir = (flat * math.cos(a) + right * math.sin(a)).Unit
                end
            elseif kind == "Boomy" then
                dir = (t < 0.5) and flat or -flat
            end

            root.CFrame = CFrame.lookAt(rp, rp + dir)
            -- pull slightly toward target so we stay under
            local pull = (aim - rp)
            if pull.Magnitude > 1 then
                root.CFrame = root.CFrame + pull.Unit * math.min(2.5, pull.Magnitude * 0.25)
            end
            fireDash()
            root.AssemblyLinearVelocity = Vector3.new(dir.X * 55, math.max(root.AssemblyLinearVelocity.Y, 6), dir.Z * 55)
            task.wait(step)
        end
        clip()
        solitudeBusy = false
    end)
end

local function tryUppercutDash()
    if not Config.Enabled or not Config.LethalEnabled then return end
    -- 3+ M1 + jump → full chase sequence (mobile + PC)
    if comboState.hits >= 3 and (tick() - comboState.lastJump) < 1.1 then
        runFullTechSequence()
        comboState.hits = 0
        comboState.jumpPressed = false
    end
end

-- Mouse / touch M1
UIS.InputBegan:Connect(function(input, gpe)
    if not isCurrent() then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if not gpe then
            noteHit()
            tryUppercutDash()
        end
    end
    if input.KeyCode == Enum.KeyCode.Space then
        comboState.jumpPressed = true
        comboState.lastJump = tick()
        tryUppercutDash()
    end
end)

-- Also Humanoid.Jumping
task.spawn(function()
    local function bindJump(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.Jumping:Connect(function()
            if not isCurrent() then return end
            comboState.jumpPressed = true
            comboState.lastJump = tick()
            tryUppercutDash()
        end)
        hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Jumping then
                comboState.lastJump = tick()
                tryUppercutDash()
            end
        end)
    end
    if player.Character then bindJump(player.Character) end
    player.CharacterAdded:Connect(bindJump)
end)


--// GUI SYSTEM CLEANUP & SETUP (REMOVES OLD EXECUTED GUIS)
for _, gui in pairs(game.CoreGui:GetChildren()) do
    if gui.Name == "A6HubUI" or gui.Name == "A6HubTSBUI" then
        gui:Destroy()
    end
end

ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "A6HubUI"
ScreenGui.ResetOnSpawn = false

MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 320, 0, 300)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -130)
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.ClipsDescendants = true

local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 6)
end
applyCorner(MainFrame, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1

--// TOP BAR
local TopBar = Instance.new("Frame", MainFrame)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 36)
applyCorner(TopBar, 8)

local TopBarCover = Instance.new("Frame", TopBar)
TopBarCover.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBarCover.BorderSizePixel = 0
TopBarCover.Size = UDim2.new(1, 0, 0, 8)
TopBarCover.Position = UDim2.new(0, 0, 1, -8)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "  A6 Hub | TSB"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local Logo = Instance.new("ImageLabel", TopBar)
Logo.Name = "Logo"
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.new(0, 22, 0, 22)
Logo.Position = UDim2.new(0, 8, 0.5, -11)
Logo.Image = "rbxthumb://type=Asset&id=123931707434013&w=420&h=420"
Logo.ScaleType = Enum.ScaleType.Fit

-- shift title right for logo
Title.Position = UDim2.new(0, 34, 0, 0)
Title.Size = UDim2.new(0.55, 0, 1, 0)


--// DESTROY BUTTON
local DestroyBtn = Instance.new("TextButton", TopBar)
DestroyBtn.Text = "×"
DestroyBtn.Size = UDim2.new(0, 24, 0, 24)
DestroyBtn.Position = UDim2.new(1, -30, 0.5, -12)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DestroyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 14
applyCorner(DestroyBtn, 4)

local lastDestroyClick = 0
DestroyBtn.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastDestroyClick <= 5 then
        forceCancel()
        ScreenGui:Destroy()
    else
        lastDestroyClick = currentTime
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Confirm",
            Text = "Click '×' again to destroy script.",
            Duration = 5,
        })
    end
end)

--// MINIMIZE BUTTON
local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Text = "-"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -58, 0.5, -12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
applyCorner(MinimizeBtn, 4)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MinimizeBtn.Text = isMinimized and "+" or "-"
    
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 36) or UDim2.new(0, 320, 0, 300)
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

--// TAB BUTTONS CONTAINER
local TabHeader = Instance.new("Frame", MainFrame)
TabHeader.BackgroundTransparency = 1
TabHeader.Size = UDim2.new(1, -16, 0, 28)
TabHeader.Position = UDim2.new(0, 8, 0, 44)

local HomeTabBtn = Instance.new("TextButton", TabHeader)
HomeTabBtn.Size = UDim2.new(0.32, 0, 1, 0)
HomeTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HomeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HomeTabBtn.Text = "Tech"
HomeTabBtn.Font = Enum.Font.GothamSemibold
HomeTabBtn.TextSize = 11
applyCorner(HomeTabBtn, 5)

local SettingsTabBtn = Instance.new("TextButton", TabHeader)
SettingsTabBtn.Size = UDim2.new(0.32, 0, 1, 0)
SettingsTabBtn.Position = UDim2.new(0.34, 0, 0, 0)
SettingsTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SettingsTabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
SettingsTabBtn.Text = "Settings"
SettingsTabBtn.Font = Enum.Font.GothamSemibold
SettingsTabBtn.TextSize = 11
applyCorner(SettingsTabBtn, 5)

local MiscTabBtn = Instance.new("TextButton", TabHeader)
MiscTabBtn.Size = UDim2.new(0.32, 0, 1, 0)
MiscTabBtn.Position = UDim2.new(0.68, 0, 0, 0)
MiscTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MiscTabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
MiscTabBtn.Text = "Misc"
MiscTabBtn.Font = Enum.Font.GothamSemibold
MiscTabBtn.TextSize = 11
applyCorner(MiscTabBtn, 5)

--// TAB CONTAINERS
local ContainerHolder = Instance.new("Frame", MainFrame)
ContainerHolder.BackgroundTransparency = 1
ContainerHolder.Size = UDim2.new(1, -16, 1, -84)
ContainerHolder.Position = UDim2.new(0, 8, 0, 78)

local HomeContainer = Instance.new("ScrollingFrame", ContainerHolder)
HomeContainer.Size = UDim2.new(1, 0, 1, 0)
HomeContainer.BackgroundTransparency = 1
HomeContainer.CanvasSize = UDim2.new(0, 0, 0, 140)
HomeContainer.ScrollBarThickness = 2
HomeContainer.Visible = true

local HomeLayout = Instance.new("UIListLayout", HomeContainer)
HomeLayout.Padding = UDim.new(0, 8)
HomeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SettingsContainer = Instance.new("ScrollingFrame", ContainerHolder)
SettingsContainer.Size = UDim2.new(1, 0, 1, 0)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 310)
SettingsContainer.ScrollBarThickness = 2
SettingsContainer.Visible = false

local SettingsLayout = Instance.new("UIListLayout", SettingsContainer)
SettingsLayout.Padding = UDim.new(0, 6)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MiscContainer = Instance.new("ScrollingFrame", ContainerHolder)
MiscContainer.Size = UDim2.new(1, 0, 1, 0)
MiscContainer.BackgroundTransparency = 1
MiscContainer.CanvasSize = UDim2.new(0, 0, 0, 200)
MiscContainer.ScrollBarThickness = 2
MiscContainer.Visible = false

local MiscLayout = Instance.new("UIListLayout", MiscContainer)
MiscLayout.Padding = UDim.new(0, 8)
MiscLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Switch Tab Logic
local function setTab(active)
    HomeContainer.Visible = (active == "Tech")
    SettingsContainer.Visible = (active == "Settings")
    MiscContainer.Visible = (active == "Misc")
    local function style(btn, on)
        btn.BackgroundColor3 = on and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
        btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)
    end
    style(HomeTabBtn, active == "Tech")
    style(SettingsTabBtn, active == "Settings")
    style(MiscTabBtn, active == "Misc")
end

HomeTabBtn.MouseButton1Click:Connect(function() setTab("Tech") end)
SettingsTabBtn.MouseButton1Click:Connect(function() setTab("Settings") end)
MiscTabBtn.MouseButton1Click:Connect(function() setTab("Misc") end)

--// HOME TAB COMPONENTS (Toggles & Mode Switch)
local ToggleBtn = Instance.new("TextButton", HomeContainer)
ToggleBtn.Size = UDim2.new(1, 0, 0, 38)
ToggleBtn.Text = "  Loop Dash: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 12
ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
applyCorner(ToggleBtn, 6)

local ToggleIndicator = Instance.new("Frame", ToggleBtn)
ToggleIndicator.Size = UDim2.new(0, 10, 0, 10)
ToggleIndicator.Position = UDim2.new(1, -20, 0.5, -5)
ToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
applyCorner(ToggleIndicator, 5)

local Hint = Instance.new("TextLabel", HomeContainer)
Hint.Size = UDim2.new(1, 0, 0, 18)
Hint.BackgroundTransparency = 1
Hint.Text = "AUTO: M1 x4 + Jump = Q dash + pattern flick"
Hint.TextColor3 = Color3.fromRGB(140, 140, 150)
Hint.Font = Enum.Font.Gotham
Hint.TextSize = 10
Hint.TextXAlignment = Enum.TextXAlignment.Left

local ModeBtn = Instance.new("TextButton", HomeContainer)
ModeBtn.Size = UDim2.new(1, 0, 0, 38)
ModeBtn.Text = "  Mode Switch: V1"
ModeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
ModeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ModeBtn.Font = Enum.Font.GothamSemibold
ModeBtn.TextSize = 12
ModeBtn.TextXAlignment = Enum.TextXAlignment.Left
applyCorner(ModeBtn, 6)

local function makeTechToggle(text, key)
    local btn = Instance.new("TextButton", HomeContainer)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local function refresh()
        local on = Config[key]
        btn.Text = "  " .. text .. ": " .. (on and "ON" or "OFF")
        btn.TextColor3 = on and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(150, 150, 155)
    end
    refresh()
    applyCorner(btn, 6)
    btn.MouseButton1Click:Connect(function()
        -- exclusive solitude patterns
        local patternKeys = {
            SolitudeHeart=true, SolitudeP=true, SolitudeR=true,
            PatternTwinnie=true, PatternBoomy=true, PatternLordHeaven=true,
            PatternVoid=true, PatternDoopy=true,
        }
        Config[key] = not Config[key]
        if patternKeys[key] and Config[key] then
            for k in pairs(patternKeys) do
                if k ~= key then Config[k] = false end
            end
            Config.Enabled = true
            Config.LethalEnabled = true
            pcall(function()
                ToggleBtn.Text = "  Loop Dash: ON"
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
            end)
        end
        refresh()
    end)
    return btn
end

makeTechToggle("Solitude Heart Pattern", "SolitudeHeart")
makeTechToggle("Solitude P Pattern", "SolitudeP")
makeTechToggle("Solitude R Pattern", "SolitudeR")

makeTechToggle("Twinnie Tech", "PatternTwinnie")
makeTechToggle("Boomy Pattern", "PatternBoomy")
makeTechToggle("LordHeaven Pattern", "PatternLordHeaven")
makeTechToggle("Void Pattern", "PatternVoid")
makeTechToggle("Doopy Pattern", "PatternDoopy")
makeTechToggle("Instant Twisted", "InstantTwisted")
HomeContainer.CanvasSize = UDim2.new(0, 0, 0, 520)


-- expand canvas for new buttons
HomeContainer.CanvasSize = UDim2.new(0, 0, 0, 280)


--// SETTINGS TAB COMPONENTS
local function CreateInput(name, configKey)
    local frame = Instance.new("Frame", SettingsContainer)
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Text = name
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.45, 0, 1, 0)
    input.Position = UDim2.new(0.55, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    input.Text = tostring(Config[configKey])
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 11
    applyCorner(input, 4)
    
    local stroke = Instance.new("UIStroke", input)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    
    input.FocusLost:Connect(function() 
        local val = tonumber(input.Text) 
        if val then Config[configKey] = val 
        else Config[configKey] = input.Text end
    end)
    
    RunService.RenderStepped:Connect(function() 
        if not isCurrent() then return end 
        if not input:IsFocused() then 
            input.Text = tostring(Config[configKey]) 
        end 
    end)
    return frame
end

local DelayInput = CreateInput("Delay", "LethalDelay")
CreateInput("Jump Power", "LethalJump")
local AccInput = CreateInput("Accuracy / Flip", "LethalAccuracy")
CreateInput("Dash Range", "DashRange")
CreateInput("Cancel Delay", "LethalCancelDelay")
local KeyInput = CreateInput("Keybind", "Keybind")

local TouchBtn = Instance.new("TextButton", SettingsContainer)
TouchBtn.Size = UDim2.new(1, 0, 0, 32)
TouchBtn.Text = "Touch Mode: OFF"
TouchBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TouchBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TouchBtn.Font = Enum.Font.Gotham
TouchBtn.TextSize = 11
applyCorner(TouchBtn, 4)

local PlatformBtn = Instance.new("TextButton", SettingsContainer)
PlatformBtn.Size = UDim2.new(1, 0, 0, 32)
PlatformBtn.Text = "Platform: PC"
PlatformBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PlatformBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
PlatformBtn.Font = Enum.Font.Gotham
PlatformBtn.TextSize = 11
PlatformBtn.Visible = false
applyCorner(PlatformBtn, 4)
KeyInput.Visible = false

local CooldownBtn = Instance.new("TextButton", SettingsContainer)
CooldownBtn.Size = UDim2.new(1, 0, 0, 32)
CooldownBtn.Text = "Cooldown System: ON"
CooldownBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
CooldownBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CooldownBtn.Font = Enum.Font.Gotham
CooldownBtn.TextSize = 11
applyCorner(CooldownBtn, 4)

-- Per-tech settings labels in Settings tab
local function techSetting(name, key)
    CreateInput(name, key)
end
techSetting("Solitude Dashes", "SolitudeDashCount")
techSetting("Solitude Step", "SolitudeOrbitTime")
techSetting("Twinnie Dashes", "TwinnieDashes")
techSetting("Twinnie Step", "TwinnieStep")
techSetting("Boomy Dashes", "BoomyDashes")
techSetting("Boomy Step", "BoomyStep")
techSetting("LordHeaven Dashes", "LordHeavenDashes")
techSetting("LordHeaven Step", "LordHeavenStep")
techSetting("Void Dashes", "VoidDashes")
techSetting("Void Step", "VoidStep")
techSetting("Doopy Dashes", "DoopyDashes")
techSetting("Doopy Step", "DoopyStep")
techSetting("InstTwist Step", "InstantTwistedStep")
techSetting("InstTwist Back", "InstantTwistedBack")
SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 720)


--// COOLDOWN UI BAR
CooldownBar = Instance.new("Frame", MainFrame)
CooldownBar.Name = "CooldownBar"
CooldownBar.Size = UDim2.new(1, 0, 0, 2)
CooldownBar.Position = UDim2.new(0, 0, 1, -2)
CooldownBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CooldownBar.BackgroundTransparency = 0.5
CooldownBar.BorderSizePixel = 0
CooldownBar.Visible = false
CooldownBar.ZIndex = 10

CooldownFill = Instance.new("Frame", CooldownBar)
CooldownFill.Name = "Fill"
CooldownFill.Size = UDim2.new(1, 0, 1, 0)
CooldownFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CooldownFill.BorderSizePixel = 0
CooldownFill.ZIndex = 11

--// MOBILE BUTTON TRIGGER
local MobileTrigger = Instance.new("TextButton", ScreenGui)
MobileTrigger.Size = UDim2.new(0, 56, 0, 56)
MobileTrigger.Position = UDim2.new(0.7, 0, 0.5, 0)
MobileTrigger.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileTrigger.Text = "A6"
MobileTrigger.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileTrigger.Font = Enum.Font.GothamBold
MobileTrigger.TextSize = 11
MobileTrigger.Visible = false
MobileTrigger.Draggable = true
MobileTrigger.Active = true
applyCorner(MobileTrigger, 28)

local TriggerStroke = Instance.new("UIStroke", MobileTrigger)
TriggerStroke.Color = Color3.fromRGB(60, 60, 60)


--// MISC TAB: Fix Lag / Potato Mode
Config.PotatoMode = Config.PotatoMode or false

local PingNote = Instance.new("TextLabel", MiscContainer)
PingNote.Size = UDim2.new(1, 0, 0, 36)
PingNote.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PingNote.TextColor3 = Color3.fromRGB(180, 180, 190)
PingNote.Font = Enum.Font.Gotham
PingNote.TextSize = 11
PingNote.TextWrapped = true
PingNote.Text = "  Ping tip: ~40ms easiest for Solitude / floater"
applyCorner(PingNote, 6)

local PotatoBtn = Instance.new("TextButton", MiscContainer)
PotatoBtn.Size = UDim2.new(1, 0, 0, 38)
PotatoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PotatoBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
PotatoBtn.Font = Enum.Font.GothamSemibold
PotatoBtn.TextSize = 12
PotatoBtn.TextXAlignment = Enum.TextXAlignment.Left
applyCorner(PotatoBtn, 6)

local function refreshPotato()
    PotatoBtn.Text = Config.PotatoMode and "  Fix Lag: Potato Mode ON" or "  Fix Lag: Potato Mode OFF"
    PotatoBtn.TextColor3 = Config.PotatoMode and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(200, 200, 200)
end
refreshPotato()

local function applyPotato(on)
    local lighting = game:GetService("Lighting")
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    pcall(function()
        if on then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            lighting.GlobalShadows = false
            lighting.FogEnd = 200
            lighting.Brightness = 1
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                elseif v:IsA("Explosion") then
                    v.Visible = false
                end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            lighting.GlobalShadows = true
            lighting.FogEnd = 100000
        end
    end)
end

PotatoBtn.MouseButton1Click:Connect(function()
    Config.PotatoMode = not Config.PotatoMode
    applyPotato(Config.PotatoMode)
    refreshPotato()
end)

--// INTERACTIONS LOGIC
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "  Loop Dash: ON" or "  Loop Dash: OFF"
    ToggleIndicator.BackgroundColor3 = Config.Enabled and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
end)

ModeBtn.MouseButton1Click:Connect(function()
    Config.LethalMode = (Config.LethalMode == "V1") and "V2" or "V1"
    ModeBtn.Text = "  Mode Switch: " .. Config.LethalMode
    if Config.LethalMode == "V2" then
        AccInput:FindFirstChildOfClass("TextLabel").Text = "Flip Delay"
        Config.LethalAccuracy = 0.25
    else
        AccInput:FindFirstChildOfClass("TextLabel").Text = "Accuracy / Flip"
        Config.LethalAccuracy = 15
    end
end)

TouchBtn.MouseButton1Click:Connect(function()
    Config.TouchMode = not Config.TouchMode
    TouchBtn.Text = "Touch Mode: " .. (Config.TouchMode and "ON" or  "OFF")
    TouchBtn.TextColor3 = Config.TouchMode and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    PlatformBtn.Visible = Config.TouchMode
    DelayInput.Visible = not Config.TouchMode
    KeyInput.Visible = (Config.TouchMode and Config.Platform == "PC")
    MobileTrigger.Visible = (Config.TouchMode and Config.Platform == "Mobile")
end)

PlatformBtn.MouseButton1Click:Connect(function()
    Config.Platform = (Config.Platform == "PC") and "Mobile" or "PC"
    PlatformBtn.Text = "Platform: " .. Config.Platform
    KeyInput.Visible = (Config.Platform == "PC")
    MobileTrigger.Visible = (Config.Platform == "Mobile")
end)

CooldownBtn.MouseButton1Click:Connect(function()
    Config.CooldownActive = not Config.CooldownActive
    CooldownBtn.Text = "Cooldown System: " .. (Config.CooldownActive and "ON" or "OFF")
    CooldownBtn.TextColor3 = Config.CooldownActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
end)

MobileTrigger.MouseButton1Click:Connect(executeLethal)

-- Big mobile TECH button
local TechMobile = Instance.new("TextButton")
TechMobile.Name = "A6TechBtn"
TechMobile.Size = UDim2.new(0, 70, 0, 70)
TechMobile.Position = UDim2.new(1, -90, 0.55, 0)
TechMobile.AnchorPoint = Vector2.new(0, 0)
TechMobile.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TechMobile.TextColor3 = Color3.fromRGB(255, 255, 255)
TechMobile.Font = Enum.Font.GothamBold
TechMobile.TextSize = 14
TechMobile.Text = "TECH"
TechMobile.Parent = ScreenGui
applyCorner(TechMobile, 12)
local ts = Instance.new("UIStroke", TechMobile)
ts.Color = Color3.fromRGB(120, 120, 130)
ts.Thickness = 1.5
TechMobile.MouseButton1Click:Connect(function()
    if not Config.Enabled then
        Config.Enabled = true
        Config.LethalEnabled = true
    end
    runFullTechSequence()
end)


UIS.InputBegan:Connect(function(input, gpe)
    if not isCurrent() or gpe then return end
    if Config.TouchMode and Config.Platform == "PC" then
        if input.KeyCode == Enum.KeyCode[Config.Keybind:upper()] then
            executeLethal()
        end
    end
end)



-- MOBILE-SAFE: count tool/punch animations + jump state
local function hookChar(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    hum.AnimationPlayed:Connect(function(track)
        if not isCurrent() or not Config.Enabled then return end
        local name = (track.Animation and track.Animation.Name or ""):lower()
        local id = tostring(track.Animation and track.Animation.AnimationId or "")
        -- count any melee / punch / m1 style anim as hit
        if name:find("punch") or name:find("m1") or name:find("attack")
            or name:find("swing") or name:find("hit") or name:find("combo")
            or name:find("normal") or name:find("light") then
            noteHit()
        end
        if name:find("upper") or id:find("10503381238") or name:find("upcut") then
            comboState.lastJump = tick()
            task.defer(tryUppercutDash)
            task.delay(0.12, runFullTechSequence)
        end
        if Config.CooldownActive and Config.CooldownAnims[getId(id)] then
            startCooldown(5)
        end
    end)
    hum.StateChanged:Connect(function(_, new)
        if not isCurrent() then return end
        if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.Freefall then
            comboState.jumpPressed = true
            comboState.lastJump = tick()
            tryUppercutDash()
        end
    end)
    hum.Jumping:Connect(function()
        if not isCurrent() then return end
        comboState.jumpPressed = true
        comboState.lastJump = tick()
        tryUppercutDash()
    end)
end
hookChar(player.Character)
player.CharacterAdded:Connect(hookChar)

-- Force active pattern with keybind (default Q) — works without waiting uppercut anim
local PatternKey = Enum.KeyCode.Q
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not isCurrent() then return end
    if input.KeyCode == PatternKey then
        if not Config.Enabled then return end
        if Config.InstantTwisted then
            runInstantTwisted()
            return
        end
        -- any pattern on → run it
        solitudeAfterUppercut()
        -- if no pattern, still try lethal
        if not (Config.SolitudeHeart or Config.SolitudeP or Config.SolitudeR
            or Config.PatternTwinnie or Config.PatternBoomy or Config.PatternLordHeaven
            or Config.PatternVoid or Config.PatternDoopy) then
            executeLethal()
        end
    end
end)

--// CORE SETUP & NOCLIP
local function setup(char)
    if not isCurrent() then return end
    local hum = char:WaitForChild("Humanoid")
    hum.AnimationPlayed:Connect(function(track)
        if not isCurrent() then return end
        if not track or not track.Animation then return end

        local animId = getId(track.Animation.AnimationId)
        local animName = tostring(track.Animation.Name or "")

        if Config.DebugAnim then
            print("[A6 TSB Anim]", animId, animName)
        end

        if Config.CooldownActive and animId and Config.CooldownAnims[animId] then
            startCooldown(5)
        end

        if not Config.Enabled or not Config.LethalEnabled then
            return
        end

        local isUpper =
            (animId and Config.UppercutAnimIds[animId] == true)
            or (track.Animation.AnimationId == Config.LethalAnim)
            or (Config.ScanUppercutName and animName:lower():find("uppercut", 1, true) ~= nil)

        if isUpper then
            executeLethal()
        end
    end)
end

RunService.Stepped:Connect(function()
    if not isCurrent() or not Config.NoClipEnabled then return end
    
    if isNoclipping and player.Character then
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model ~= player.Character and (model:FindFirstChild("Humanoid") or model:FindFirstChildOfClass("Humanoid")) then
                for _, part in pairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

if player.Character then setup(player.Character) end
player.CharacterAdded:Connect(setup)
