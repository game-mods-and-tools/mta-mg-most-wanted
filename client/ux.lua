local currentJobs = {}
local currentJobProgress = 0
local honkProgress = 0
local deliveryPoint = nil
local timer = nil

function honk()
	honkProgress = math.min(honkProgress + 0.1, 1)
end

addEvent(g_SHOW_JOB, true)
addEventHandler(g_SHOW_JOB, resourceRoot, function(id, type, pos)
	local job = g_JOBS_BY_TYPE[type]

	currentJobs[id] = {
		marker = createMarker(pos.x, pos.y, pos.z - 0.6, "cylinder", job.zoneRadius, job.color.r, job.color.g, job.color.b, 73),
		blip = createBlip(pos.x, pos.y, pos.z, job.blip, 2, 255, 0, 0, 255, 0, job.detectionRadius),
	}
end)

addEvent(g_HIDE_JOB, true)
addEventHandler(g_HIDE_JOB, resourceRoot, function(id)
	-- could modify alpha instead if we separate things differently
	if not currentJobs[id] then return end

	destroyElement(currentJobs[id].marker)
	destroyElement(currentJobs[id].blip)

	currentJobs[id] = nil
end)

addEvent(g_START_JOB, true)
addEventHandler(g_START_JOB, resourceRoot, function(id)
end)

addEvent(g_STOP_JOB, true)
addEventHandler(g_STOP_JOB, resourceRoot, function(id)
	currentJobProgress = 0
	honkProgress = 0
	if isTimer(timer) then
		killTimer(timer)
	end
	timer = nil
	unbindKey("horn", "down", honk)
end)

addEvent(g_JOB_STATUS_UPDATE, true)
addEventHandler(g_JOB_STATUS_UPDATE, resourceRoot, function(id, type, data)
	if type == g_DELIVERY_JOB.type then
		-- delivery job target
		local pickupSize = 10
		local col = createColCircle(data.pos.x, data.pos.y, pickupSize)

		local marker = createMarker(data.pos.x, data.pos.y, data.pos.z - 0.6, "cylinder", pickupSize, 255, 0, 0, 100)
		local blip = createBlip(data.pos.x, data.pos.y, data.pos.z, 29, 2, 255, 0, 0, 255)

		function finishDelivery(element)
			if getPedOccupiedVehicle(localPlayer) ~= element then return end
			destroyElement(marker)
			destroyElement(blip)
			removeEventHandler("onClientColShapeHit", col, finishDelivery)
			triggerServerEvent(g_FINISH_JOB, resourceRoot, id)
		end
		addEventHandler("onClientColShapeHit", col, finishDelivery)
	elseif type == g_EXTORTION_JOB.type then
		outputChatBox("START HONKING!!!")
		bindKey("horn", "down", honk)
		timer = setTimer(function()
			if honkProgress >= 1 then
				triggerServerEvent(g_FINISH_JOB, resourceRoot, id)
			end

			-- 5 honks a second at least?
			honkProgress = math.max(honkProgress - 0.01, 0)
		end, 200, 0)
	elseif data.progress then
		-- group or solo camp jobs
		currentJobProgress = data.progress
	end
end)

addEvent(g_FINISH_JOB, true)
addEventHandler(g_FINISH_JOB, resourceRoot, function(id)
	currentJobProgress = 0
	honkProgress = 0
	if isTimer(timer) then
		killTimer(timer)
	end
	timer = nil
	unbindKey("horn", "down", honk)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()
		if currentJobProgress > 0 then
			local screenWidth, screenHeight = guiGetScreenSize()
			local color = tocolor(255, 255, 255)

			dxDrawRectangle(screenWidth / 2 - 126, screenHeight * 0.85, 252, 27, tocolor(0, 0, 0))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244, 19, tocolor(40, 40, 40))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244 * currentJobProgress, 19, color)
		end

		if honkProgress > 0 then
			local screenWidth, screenHeight = guiGetScreenSize()
			local color = tocolor(255, 255, 255)

			dxDrawRectangle(screenWidth / 2 - 126, screenHeight * 0.85, 252, 27, tocolor(0, 0, 0))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244, 19, tocolor(40, 40, 40))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244 * honkProgress, 19, color)
		end
	end)
end)

addEvent(g_SELECT_PLAYER_ROLE, true)
addEventHandler(g_SELECT_PLAYER_ROLE, resourceRoot, function(role)
	if role == g_CRIMINAL_ROLE then
		outputChatBox(getPlayerName(localPlayer) .. " is a criminal")
	else
		outputChatBox(getPlayerName(localPlayer) .. " is a cop")
	end
end)