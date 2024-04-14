local honkProgress = 0
local honking = false
local honkTimer = nil

bindKey("horn", "down", function()
	honking = true
end)
bindKey("horn", "up", function()
	honking = false
end)

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
		if data.subtype == g_DELIVERY_JOB.subtypes.DELIVERY then
			local col = createColCircle(data.pos.x, data.pos.y, g_DELIVERY_TARGET_SIZE)

			function finishDelivery(element)
				if getPedOccupiedVehicle(localPlayer) ~= element then return end
				removeEventHandler("onClientColShapeHit", col, finishDelivery)

				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end
			addEventHandler("onClientColShapeHit", col, finishDelivery)
		elseif data.subtype == g_DELIVERY_JOB.subtypes.ELIMINATION then
			local ped = createPed(127, data.pos.x, data.pos.y, data.pos.z)
			local blip = nil
			setElementHealth(ped, 30)
			setElementRotation(ped, data.rot.x, data.rot.y, data.rot.z)
			setPedAnimation(ped, "dealer", "dealer_deal")

			local pedPositioner = setTimer(function()
				setElementPosition(ped, data.pos.x, data.pos.y, data.pos.z)
			end, 1000, 0)

			local turnPed = setTimer(function()
				setPedCameraRotation(ped, math.random(360))
			end, 100, 0)

			function pedTouched(ele)
				if ele == ped then
					killTimer(pedPositioner)
					removeEventHandler("onClientVehicleCollision", getPedOccupiedVehicle(localPlayer), pedTouched)
				end
			end

			local firstHit = false
			function pedHit()
				setPedControlState(ped, "forwards", true)
				if not firstHit then
					firstHit = true
					blip = createBlipAttachedTo(ped, 60)
					triggerEvent(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot)
				end
			end

			function pedDie()
				killTimer(turnPed)
				destroyElement(blip)
				removeEventHandler("onClientPedWasted", ped, pedDie)
				removeEventHandler("onClientPedDamage", ped, pedHit)
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end
			addEventHandler("onClientPedWasted", ped, pedDie)
			addEventHandler("onClientPedDamage", ped, pedHit)
			addEventHandler("onClientVehicleCollision", getPedOccupiedVehicle(localPlayer), pedTouched)
		end
	elseif type == g_HARVEST_JOB.type then
		triggerEvent(g_SHOW_DELIVERY_TARGET_EVENT, resourceRoot, data.pos)
		local col = createColCircle(data.pos.x, data.pos.y, g_DELIVERY_TARGET_SIZE)

		function finishDelivery(element)
			if getPedOccupiedVehicle(localPlayer) ~= element then return end
			removeEventHandler("onClientColShapeHit", col, finishDelivery)
			
			triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)

			local organs = 0
			local screenWidth, screenHeight = guiGetScreenSize()
			for _, organ in ipairs({
				"client/org_brain.png",
				"client/org_eyeball.png",
				"client/org_heart.png",
				"client/org_kidleft.png",
				"client/org_kidright.png",
				"client/org_liver.png",
				"client/org_lung.png",
				"client/org_test.png",
			}) do
				local window = guiCreateWindow(math.random() * (screenWidth - 150), math.random() * (screenHeight - 150), 150, 150, "Click to collect", false)
				guiCreateStaticImage(25, 25, 100, 100, organ, false, window)

				function grabOrgan()
					if isElement(window) then
						removeEventHandler("onClientGUIClick", window, grabOrgan)
						destroyElement(window)
					end
					organs = organs + 1
					if organs > 7 then
						showCursor(false, false)
					end
				end
				addEventHandler("onClientGUIClick", window, grabOrgan)
				setTimer(function()
					grabOrgan()
				end, 7500, 1)
			end
			showCursor(true, false)
		end
		addEventHandler("onClientColShapeHit", col, finishDelivery)
	elseif type == g_EXTORTION_JOB.type then
		honkProgress = 0
		honkTimer = setTimer(function()
			if honkProgress >= 1 then
				triggerServerEvent(g_FINISH_JOB_EVENT, resourceRoot, id)
			end

			if honking then
				honkProgress = math.min(honkProgress + g_EXTORTION_JOB.progressRate, 1)
			else
				honkProgress = math.max(honkProgress - g_EXTORTION_JOB.decayRate, 0)
			end

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

addEvent(g_GAME_STATE_UPDATE_EVENT, true)
addEventHandler(g_GAME_STATE_UPDATE_EVENT, resourceRoot, function(state)
	if state == g_COREGAME_STATE then
		local policeTeam = getTeamFromName(g_POLICE_TEAM_NAME)
		if getPlayerTeam(localPlayer) == policeTeam then return end

		function createCopSirens()
			setTimer(function()
				local cops = getPlayersInTeam(policeTeam)
				if #cops == 0 then return createCopSirens() end

				for _, cop in ipairs(cops) do
					local x, y, z = getElementPosition(cop)
					local sound = playSound3D("client/siren.mp3", x, y, z, true)
					setSoundMinDistance(sound, 10)
					setSoundMaxDistance(sound, 150)
					setTimer(function()
						if not isElement(cop) then
							destroyElement(sound)
							return
						end
						local x, y, z = getElementPosition(cop)
						setElementPosition(sound, x, y, z)
					end, 100, 0)
				end
			end, 1000, 1)
		end
		createCopSirens()
	elseif state == g_NO_CRIMS_STATE then
		triggerEvent("onClientCall_race", root, "checkpointReached", getPedOccupiedVehicle(localPlayer))
	end
end)

addEventHandler("onClientVehicleDamage", root, function(a, w, l, dx, dy, dz, tire)
	if tire then cancelEvent() end
end)
addEventHandler("onClientExplosion", root, function(x, y, z, t)
	if t == 4 then cancelEvent() end
end)

-- suppress race mode error
addEvent("onClientCall_race", true)

function cleanupJobs()
	triggerEvent(g_HIDE_PROGRESS_BAR_EVENT, resourceRoot)
	honkProgress = 0
	if isTimer(honkTimer) then
		killTimer(honkTimer)
	end
	honkTimer = nil
end