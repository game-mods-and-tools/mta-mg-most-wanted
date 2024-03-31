local currentJobs = {}
local deliveryTarget = nil
local showProgressBar = false
local progressBarProgress = 0

addEvent(g_SHOW_JOB_EVENT, true)
addEventHandler(g_SHOW_JOB_EVENT, resourceRoot, function(id, type, pos)
	local job = g_JOBS_BY_TYPE[type]

	currentJobs[id] = {
		marker = createMarker(pos.x, pos.y, pos.z - 0.6, "cylinder", job.zoneRadius, job.color.r, job.color.g, job.color.b, 73),
		blip = createBlip(pos.x, pos.y, pos.z, job.blip, 2, 255, 0, 0, 255, 0, job.detectionRadius),
	}
end)

addEvent(g_HIDE_JOB_EVENT, true)
addEventHandler(g_HIDE_JOB_EVENT, resourceRoot, function(id)
	if not currentJobs[id] then return end

	destroyElement(currentJobs[id].marker)
	destroyElement(currentJobs[id].blip)

	currentJobs[id] = nil
end)

addEvent(g_START_JOB_EVENT, true)
addEventHandler(g_START_JOB_EVENT, resourceRoot, function(id)
	-- started a job
end)

addEvent(g_STOP_JOB_EVENT, true)
addEventHandler(g_STOP_JOB_EVENT, resourceRoot, function(id)
	-- ran from job before completing
end)

addEvent(g_SHOW_DELIVERY_TARGET_EVENT)
addEventHandler(g_SHOW_DELIVERY_TARGET_EVENT, resourceRoot, function(pos)
	deliveryTarget = {
		marker = createMarker(pos.x, pos.y, pos.z - 0.6, "cylinder", g_DELIVERY_TARGET_SIZE, 255, 0, 0, 100),
		blip = createBlip(pos.x, pos.y, pos.z, 29, 2, 255, 0, 0, 255)
	}
end)

addEvent(g_HIDE_DELIVERY_TARGET_EVENT)
addEventHandler(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot, function()
	destroyElement(deliveryTarget.marker)
	destroyElement(deliveryTarget.blip)

	deliveryTarget = nil
end)

addEvent(g_SHOW_PROGRESS_BAR_EVENT)
addEventHandler(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot, function()
	showProgressBar = true
end)

addEvent(g_HIDE_PROGRESS_BAR_EVENT)
addEventHandler(g_HIDE_PROGRESS_BAR_EVENT, resourceRoot, function()
	showProgressBar = false
end)

addEvent(g_UPDATE_PROGRESS_BAR_EVENT)
addEventHandler(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, function(data)
	progressBarProgress = data.progress
end)

addEvent(g_PLAYER_ROLE_SELECTED_EVENT, true)
addEventHandler(g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, function(role)
	if role == g_CRIMINAL_ROLE then
		outputChatBox(getPlayerName(localPlayer) .. " is a criminal")
	else
		outputChatBox(getPlayerName(localPlayer) .. " is a cop")
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()	
		if showProgressBar then
			local screenWidth, screenHeight = guiGetScreenSize()
			local color = tocolor(255, 255, 255)

			dxDrawRectangle(screenWidth / 2 - 126, screenHeight * 0.85, 252, 27, tocolor(0, 0, 0))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244, 19, tocolor(40, 40, 40))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244 * progressBarProgress, 19, color)
		end
	end)
end)