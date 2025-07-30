repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().Key = ""

-- Load Redz Hub
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Scripts/main/main.luau"))()
end)

-- Fast Attack dijalankan setelah semua benar-benar siap
task.spawn(function()
    -- Tunggu CombatFramework siap
    local CombatFramework, rigController, activeController
    while not CombatFramework or not rigController or not activeController do
        pcall(function()
            CombatFramework = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
            rigController = getupvalues(CombatFramework)[2]
            activeController = rigController.activeController
        end)
        task.wait(1)
    end

    -- Setup super fast attack
    activeController.timeToNextAttack = 0.1
    activeController.attacking = false

    local function Attack()
        if activeController and activeController.equipped then
            local blade = activeController.blades[1]
            if not blade then return end
            local hitEnemies = {}
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    table.insert(hitEnemies, mob)
                end
            end
            CombatFramework.activeController.hitboxMagnitude = 60
            CombatFramework.activeController.timeToNextAttack = 0.1
            CombatFramework.activeController.increment = 3
            CombatFramework.activeController:attack(hitEnemies)
        end
    end

    -- Jalankan terus
    game:GetService("RunService").Stepped:Connect(function()
        pcall(Attack)
    end)
end)
