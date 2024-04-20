local copFindBlips = {}
local cops = {}

local function startPedRequestListener()
	addEvent(g_REQUEST_SPAWN_PED_EVENT, true)
	addEventHandler(g_REQUEST_SPAWN_PED_EVENT, getRootElement(), function()
		local extortionJobs = getElementsByType("extortion_job", resourceRoot)
		local randomExtortion = extortionJobs[math.random(#extortionJobs)]
		local ped = createPed(281, getElementPosition(client))
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
			local detection = getElementsWithinRange(x, y, z, 25)
			for _, thing in ipairs(detection) do
				if getElementType(thing) == "vehicle" then
					local player = getVehicleOccupant(thing)
					if player and getPlayerTeam(player) == g_CriminalTeam then
						copFindBlips[#copFindBlips + 1] = createBlipAttachedTo(thing, 0, 2)
					end
				end
			end
		end
	end, 1000, 0)
end

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", getRootElement(), function(state)
	if state == "Running" then
		startPedRequestListener()
	end
end)
