repeat wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()

-- Tunggu CombatFramework
local CombatFramework
repeat
    pcall(function()
        CombatFramework = require(plr.PlayerScripts:FindFirstChild("CombatFramework"))
    end)
    task.wait(1)
until CombatFramework

-- Cari activeController
local rig = debug.getupvalues(CombatFramework)[2]
local controller = rig.activeController
repeat task.wait() until controller and controller.equipped

-- Equip tool otomatis
local function autoEquipTool()
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = chr
            break
        end
    end
end
autoEquipTool()

-- Fast Attack logic
local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
    pcall(function()
        if controller and controller.equipped then
            local blade = controller.blades[1]
            if not blade then return end
            local enemies = {}
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    table.insert(enemies, mob)
                end
            end
            controller.hitboxMagnitude = 60
            controller.timeToNextAttack = 0.1
            controller.increment = 3
            controller:attack(enemies)
        end
    end)
end)
