repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().Key = ""

-- Load Redz Hub
loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Scripts/main/main.luau"))()

-- Delay agar Redz selesai load
task.delay(10, function()
    local success, CombatFramework = pcall(function()
        return require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
    end)

    if not success then return warn("CombatFramework tidak ditemukan") end

    local RigController = debug.getupvalues(CombatFramework)[2]
    local Controller = RigController.activeController

    Controller.timeToNextAttack = 0.1
    Controller.attacking = false

    game:GetService("RunService").RenderStepped:Connect(function()
        pcall(function()
            if Controller and Controller.equipped then
                local blade = Controller.blades[1]
                if not blade then return end

                local enemies = {}
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        table.insert(enemies, mob)
                    end
                end

                Controller.hitboxMagnitude = 60
                Controller.timeToNextAttack = 0.1
                Controller.increment = 3
                Controller:attack(enemies)
            end
        end)
    end)
end)
