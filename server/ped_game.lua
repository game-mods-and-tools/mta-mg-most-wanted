local pedFindBlips = {}
local peds = {}
local loaded = false

local function startPedRequestListener()
	addEvent(g_REQUEST_SPAWN_PED_EVENT, true)
	addEventHandler(g_REQUEST_SPAWN_PED_EVENT, getRootElement(), function()
		local extortionJobs = getElementsByType("extortion_job", resourceRoot)
		local randomExtortion = extortionJobs[math.random(#extortionJobs)]
		local ped = createPed(281, 1272.4, -1337, 13) -- police station
		setElementHealth(ped, 100)
		setElementSyncer(ped, client, true)
		peds[#peds + 1] = ped

		triggerClientEvent(client, g_SPAWN_PLAYER_PED_EVENT, resourceRoot, ped)
	end)

	-- forward control state information to everyone
	addEvent(g_PED_CONTROL_UPDATE_EVENT, true)
	addEventHandler(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, function(ped, control, status)
		triggerClientEvent(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, ped, control, status)
	end)

	addEvent(g_PED_ANIMATION_EVENT, true)
	addEventHandler(g_PED_ANIMATION_EVENT, resourceRoot, function(ped, block, anim)
		triggerClientEvent(g_PED_ANIMATION_EVENT, resourceRoot, ped, block, anim)
	end)

	setTimer(function()
		for _, blip in ipairs(pedFindBlips) do
			destroyElement(blip)
		end
		pedFindBlips = {}
		for _, cop in ipairs(peds) do
			if isPedDead(cop) then
				local x, y, z = getElementPosition(cop)
				local detection = getElementsWithinRange(x, y, z, 50, "vehicle")
				for _, vehicle in ipairs(detection) do
					local player = getVehicleOccupant(vehicle)
					if player then
						if getPlayerTeam(player) == g_CriminalTeam then
							pedFindBlips[#pedFindBlips + 1] = createBlipAttachedTo(vehicle, 0, 2, 150, 0, 200, 255, 6, 80085)
						else
							pedFindBlips[#pedFindBlips + 1] = createBlipAttachedTo(vehicle, 0, 2, 30, 190, 240, 255, 6, 80085)
						end
					end
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
