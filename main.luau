local Scripts = {
	{
		PlacesIds = {2753915549, 4442272183, 7449423635},
		UrlPath = "BloxFruits.luau"
	},
	{
		PlacesIds = {10260193230},
		UrlPath = "MemeSea.luau"
	},
}

local fetcher, urls = {}, {}

local _ENV = (getgenv or getrenv or getfenv)()

urls.Owner = "https://raw.githubusercontent.com/tlredz/"
urls.Repository = urls.Owner .. "Scripts/refs/heads/main/"
urls.Translator = urls.Repository .. "Translator/"
urls.Utils = urls.Repository .. "Utils/"

do
	local last_exec = _ENV.rz_execute_debounce
	if last_exec and (tick() - last_exec) <= 5 then
		return nil
	end
	_ENV.rz_execute_debounce = tick()
end

do
	local executor = syn or fluxus
	local queueteleport = queue_on_teleport or (executor and executor.queue_on_teleport)

	if not _ENV.rz_added_teleport_queue and type(queueteleport) == "function" then
		local ScriptSettings = {...}
		local SettingsCode = ""

		_ENV.rz_added_teleport_queue = true

		local Success, EncodedSettings = pcall(function()
			return game:GetService("HttpService"):JSONEncode(ScriptSettings)
		end)

		if Success and EncodedSettings then
			SettingsCode = "unpack(game:GetService('HttpService'):JSONDecode('" .. EncodedSettings .. "'))"
		end

		pcall(queueteleport, ("loadstring(game:HttpGet('%smain.luau'))(%s)"):format(urls.Repository, SettingsCode))
	end
end

do
	if _ENV.rz_error_message then
		_ENV.rz_error_message:Destroy()
	end

	local identifyexecutor = identifyexecutor or (function() return "Unknown" end)

	local function CreateMessageError(Text)
		_ENV.loadedFarm = nil
		_ENV.OnFarm = false

		local Message = Instance.new("Message", workspace)
		Message.Text = string.gsub(Text, urls.Owner, "")
		_ENV.rz_error_message = Message

		error(Text, 2)
	end

	local function formatUrl(Url)
		for key, path in urls do
			if Url:find("{" .. key .. "}") then
				return Url:gsub("{" .. key .. "}", path)
			end
		end

		return Url
	end

	function fetcher.get(Url)
		local success, response = pcall(function()
			return game:HttpGet(formatUrl(Url))
		end)

		if success then
			return response
		else
			CreateMessageError(`[1] [{ identifyexecutor() }] failed to get http/url/raw: { Url }\n>>{ response }<<`)
		end
	end

	function fetcher.load(Url: string, concat: string?)
		local raw = fetcher.get(Url) .. (if concat then concat else "")
		local runFunction, errorText = loadstring(raw)

		if type(runFunction) ~= "function" then
			CreateMessageError(`[2] [{ identifyexecutor() }] sintax error: { Url }\n>>{ errorText }<<`)
		else
			return runFunction
		end
	end
end

local function IsPlace(Script)
	if Script.PlacesIds and table.find(Script.PlacesIds, game.PlaceId) then
		return true
	elseif Script.GameId and Script.GameId == game.GameId then
		return true
	end
end

for _, Script in Scripts do
	if IsPlace(Script) then
		-- ✅ Jalankan Script Redz
		fetcher.load("{Repository}Games/" .. Script.UrlPath)(fetcher, ...)

		-- 🗡️ Super Fast Attack Setup
		getgenv().SuperFastAttack = false -- Default OFF
		local AttackDelay = 0.05
		local UserInputService = game:GetService("UserInputService")

		-- 🔁 Loop Attack
		spawn(function()
			while true do
				pcall(function()
					if getgenv().SuperFastAttack then
						local CombatFramework = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework")))[2]
						local CF = CombatFramework
						local Anim = CF.activeController

						if Anim and Anim.equipped then
							Anim.timeToNextAttack = 0
							local target = nil
							local shortest = math.huge
							for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
								if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
									local distance = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
									if distance < shortest then
										shortest = distance
										target = v
									end
								end
							end
							if target then
								CF.activeController:attack()
							end
						end
					end
				end)
				wait(AttackDelay)
			end
		end)

		-- 🛑 Toggle ON/OFF dengan tombol K
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
				getgenv().SuperFastAttack = not getgenv().SuperFastAttack
				warn("Super Fast Attack:", getgenv().SuperFastAttack and "✅ ON" or "❌ OFF")
			end
		end)

		break
	end
end
