local honkProgress = 0
local timer = nil

function honk()
	honkProgress = math.min(honkProgress +  g_EXTORTION_JOB.progressRate, 1)
end

addEvent(g_STOP_JOB_EVENT, true)
addEventHandler(g_STOP_JOB_EVENT, resourceRoot, function(id)
	cleanupJobs()
end)

addEvent(g_FINISH_JOB_EVENT, true)
addEventHandler(g_FINISH_JOB_EVENT, resourceRoot, function(id)
	cleanupJobs()
end)

addEvent(g_JOB_STATUS_UPDATE_EVENT, true)
addEventHandler(g_JOB_STATUS_UPDATE_EVENT, resourceRoot, function(id, type, data)
	if type == g_DELIVERY_JOB.type then
		triggerEvent(g_SHOW_DELIVERY_TARGET_EVENT, resourceRoot, data.pos)
		local col = createColCircle(data.pos.x, data.pos.y, g_DELIVERY_TARGET_SIZE)

		function finishDelivery(element)
			if getPedOccupiedVehicle(localPlayer) ~= element then return end
			removeEventHandler("onClientColShapeHit", col, finishDelivery)

			triggerEvent(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot)
			triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
		end
		addEventHandler("onClientColShapeHit", col, finishDelivery)
	elseif type == g_EXTORTION_JOB.type then
		honkProgress = 0
		bindKey("horn", "down", honk)
		timer = setTimer(function()
			if honkProgress >= 1 then
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end

			honkProgress = math.max(honkProgress - g_EXTORTION_JOB.decayRate, 0)

			triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
			triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, { progress = honkProgress })
		end, g_EXTORTION_JOB.interval, 0)
	elseif type == g_GROUP_JOB.type then
		if data.playerCount < g_GROUP_JOB.minPlayers then
			triggerEvent(g_PAUSE_JOB_EVENT, resourceRoot, data.playerCount)
		else
			triggerEvent(g_RESUME_JOB_EVENT, resourceRoot, data.playerCount)
		end
		triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
		triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, data)
	elseif data.progress then
		triggerEvent(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot)
		triggerEvent(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, data)
	end
end)

function cleanupJobs()
	triggerEvent(g_HIDE_PROGRESS_BAR_EVENT	, resourceRoot)
	honkProgress = 0
	if isTimer(timer) then
		killTimer(timer)
	end
	timer = nil
	unbindKey("horn", "down", honk)
end