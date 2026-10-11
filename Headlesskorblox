local function onCharacterAdded(character)
    wait(1) -- Wait for the character to fully load
    
    local head = character:FindFirstChild("Head")
    if head then
        head.MeshId = "http://www.roblox.com/asset/?id=6686307858"
        head.TextureID = "http://www.roblox.com/asset/?id=6686307858"
        head.Transparency = 1
    end

    local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
    if rightLowerLeg then
        rightLowerLeg.MeshId = "http://www.roblox.com/asset/?id=902942093"
        rightLowerLeg.Transparency = 1
    end

    local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
    if rightUpperLeg then
        rightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
        rightUpperLeg.TextureID = "http://www.roblox.com/asset/?id=902843398"
    end

    local rightFoot = character:FindFirstChild("RightFoot")
    if rightFoot then
        rightFoot.MeshId = "http://www.roblox.com/asset/?id=902942089"
        rightFoot.Transparency = 1
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- In case the character is already spawned when the script runs
if game.Players.LocalPlayer.Character then
    onCharacterAdded(game.Players.LocalPlayer.Character)
end
