local spawned = false
local playerPed = nil
local focusPed = false
local savedPos = nil
local toggleKey = next(getBoundKeys("enter_exit")) or "enter_exit"
local function canSpawnAsPedCondition()
	local state = getElementData(localPlayer, "state")
	return not spawned and (
		state == "spectating" or
		state == "waiting" or
		state == "dead"
	)
end

addEvent(g_PED_GAME_READY_EVENT, true)
addEventHandler(g_PED_GAME_READY_EVENT, resourceRoot, function()
	addEvent(g_SPAWN_PLAYER_PED_EVENT, true)
	addEventHandler(g_SPAWN_PLAYER_PED_EVENT, resourceRoot, function(ped)
		-- the spectate workaround logic is messed up
		-- this makes sure that the client is considered spectating so it can
		-- be cancelled. if not spectating, then the server may lock the
		-- camera in a way that I haven't figured out
		triggerEvent("onClientCall_race", root, "Spectate.start", "auto")
		triggerEvent("onClientCall_race", root, "MovePlayerAway.start")

		-- bind keys to ped
		local controls = {
			"forwards",
			"backwards",
			"left",
			"right",
			"sprint",
			"jump"
		}
		for _, control in ipairs(controls) do
			for key in pairs(getBoundKeys(control)) do
				bindKey(key, "down", function()
					triggerServerEvent(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, playerPed, control, true)
					setControlState(playerPed, control, true)
				end)

				bindKey(key, "up", function()
					triggerServerEvent(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, playerPed, control, false)
					setControlState(playerPed, control, false)
				end)
			end
		end

		-- ped emotes
		local emotes = {
			["1"] = {"ped", "endchat_03" },
			["2"] = {"ped", "fucku" },
			["3"] = {"dancing", "dan_down_a" }
		}
		for key, anim in pairs(emotes) do
			bindKey(key, "down", function()
				triggerServerEvent(g_PED_ANIMATION_EVENT, resourceRoot, playerPed, anim[1], anim[2])
			end)
		end

		-- match camera rotation
		setTimer(function()
			setPedCameraRotation(ped, getPedCameraRotation(localPlayer))
			if focusPed and getCameraTarget() ~= playerPed then
				triggerEvent("onClientCall_race", root, "Spectate.stop", "auto")
				triggerEvent("onClientCall_race", root, "MovePlayerAway.stop")
				setCameraTarget(ped)
			end
		end, 10, 0)

		addEventHandler("onClientPedDamage", ped, function()
			-- cancelling the event removes the knocked back animation
			-- for now peds only have 1 life with default hp
		end)

		playerPed = ped
	end)

	addEvent(g_PED_CONTROL_UPDATE_EVENT, true)
	addEventHandler(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, function(ped, control, status)
		if ped ~= playerPed then
			setPedControlState(ped, control, status)
		end
	end)

	addEvent(g_PED_ANIMATION_EVENT, true)
	addEventHandler(g_PED_ANIMATION_EVENT, resourceRoot, function(ped, block, anim)
		setPedAnimation(ped, block, anim, -1, false, true, true, false)
	end)

	bindKey(toggleKey, "down", function()
		if canSpawnAsPedCondition() then
			spawned = true
			focusPed = true

			-- should trigger ped spawn event which sets target to ped
			triggerServerEvent(g_REQUEST_SPAWN_PED_EVENT, resourceRoot)
		elseif playerPed then
			focusPed = not focusPed
			if focusPed then
				setElementPosition(playerPed, unpack(savedPos))
				triggerEvent("onClientCall_race", root, "Spectate.stop", "auto")
			else
				savedPos = {getElementPosition(playerPed)}
				triggerEvent("onClientCall_race", root, "Spectate.start", "auto")
			end
		end
	end)

	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()
		dxDrawBorderedText(0.5,"A NEARBY PEDESTRIAN IS REVEALING YOUR LOCATION!", screenWidth / 2, screenHeight * 0.22, screenWidth, screenHeight, tocolor(222, 26, 26, 255), 2.5, "arial", center, top, false, false, false, true)


		if canSpawnAsPedCondition() then
			dxDrawBorderedText(0.5, "#C8C8C8Press " .. toggleKey .. " to spawn as a pedestrian.", screenWidth / 2, screenHeight * 0.9,  screenWidth, screenHeight, tocolor(160, 0, 210, 255), 2, "arial", center, top, false, false, false, true)
		elseif playerPed then
			if focusPed then
				dxDrawBorderedText(0.5, "Press " .. toggleKey .. " to return to spectator.", screenWidth / 2, screenHeight * 0.9,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "arial", center, top, false, false, false, true)
			else
				dxDrawBorderedText(0.5,"Press " .. toggleKey .. " to return to pedestrian.", screenWidth / 2, screenHeight * 0.9,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "arial", center, top, false, false, false, true)
			end

			if isPedDead(playerPed) then
				dxDrawBorderedText(0.5, "Oh dear, you are dead! Better luck next time.", screenWidth / 2, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "sans", center, top, false, false, false, true)
			else
				dxDrawBorderedText(0.5,"If you are killed, you can not respawn!", screenWidth / 2, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.5, "sans", center, top, false, false, false, true)
			end

			dxDrawBorderedText(0.5,"Any player close to you will be revealed on the radar to everyone.", screenWidth / 2, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.5, "sans", center, top, false, false, false, true)
		end
	end)
end)
