local copFindBlips = {}
local cops = {}
local loaded = false

local function startPedRequestListener()
	addEvent(g_REQUEST_SPAWN_PED_EVENT, true)
	addEventHandler(g_REQUEST_SPAWN_PED_EVENT, getRootElement(), function()
		local extortionJobs = getElementsByType("extortion_job", resourceRoot)
		local randomExtortion = extortionJobs[math.random(#extortionJobs)]
		local ped = createPed(281, 1272.4, -1337, 13) -- police station
		cops[#cops + 1] = ped

		triggerClientEvent(client, g_SPAWN_PLAYER_PED_EVENT, resourceRoot, ped)
	end)

	setTimer(function()
		for _, blip in ipairs(copFindBlips) do
			destroyElement(blip)
		end
		copFindBlips = {}
		for _, cop in ipairs(cops) do
			local x, y, z = getElementPosition(cop)
			local detection = getElementsWithinRange(x, y, z, 50, "vehicle")
			for _, vehicle in ipairs(detection) do
				local player = getVehicleOccupant(vehicle)
				if player and getPlayerTeam(player) == g_CriminalTeam then
					copFindBlips[#copFindBlips + 1] = createBlipAttachedTo(vehicle, 0, 2, 150, 0, 200, 255, 6, 80085)
				end
			end
		end
	end, 1000, 0)

	triggerClientEvent(getRootElement(), g_PED_GAME_READY_EVENT, resourceRoot)
end

addEvent(g_GAME_STATE_UPDATE_EVENT)
addEventHandler(g_GAME_STATE_UPDATE_EVENT, resourceRoot, function(state)
	if state == g_COREGAME_STATE and loaded == false then
		loaded = true
		startPedRequestListener()
	end
end)