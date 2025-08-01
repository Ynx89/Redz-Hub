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
	if last_exec and (tick() - last_exec) <= 5 then return nil end
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
	if _ENV.rz_error_message then _ENV.rz_error_message:Destroy() end
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
		task.spawn(function()
			task.wait(10) -- delay biar module Redz kebuka dulu
			local success, cf = pcall(function()
				return require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
			end)
			if not success then return end

			local rc = debug.getupvalues(cf)[2]
			local ac = rc and rc.activeController
			if not ac then return end

			ac.timeToNextAttack = 0.1
			ac.attacking = false

			game:GetService("RunService").RenderStepped:Connect(function()
				pcall(function()
					if ac and ac.equipped then
						local blade = ac.blades[1]
						if not blade then return end
						local enemies = {}
						for _, mob in pairs(workspace.Enemies:GetChildren()) do
							if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
								table.insert(enemies, mob)
							end
						end
						ac.hitboxMagnitude = 60
						ac.timeToNextAttack = 0.1
						ac.increment = 3
						ac:attack(enemies)
					end
				end)
			end)
		end)
		
		return fetcher.load("{Repository}Games/" .. Script.UrlPath)(fetcher, ...)
	end
    end
