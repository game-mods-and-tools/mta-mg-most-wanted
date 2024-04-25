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

		-- destroy all things that might exist from previous role
		-- sure if endgame is reached there will be more blips again, but unimportant
		for _, e in ipairs(getElementsByType("marker", resourceRoot)) do
			destroyElement(e)
		end

		for _, e in ipairs(getElementsByType("blip", resourceRoot)) do
			destroyElement(e)
		end

		for _, e in ipairs(getElementsByType("colshape", resourceRoot)) do
			-- does this also clean up the listeners? who knows but idc
			destroyElement(e)
		end

		-- bind keys to ped
		local controls = {
			"forwards",
			"backwards",
			"left",
			"right",
			"sprint",
			"jump",
			"fire"
		}
		for _, control in ipairs(controls) do
			for key in pairs(getBoundKeys(control)) do
				bindKey(key, "down", function()
					if not isPedDead(playerPed) then
						if control == "fire" and getPedWeapon(playerPed) == 0 then return end
						triggerServerEvent(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, playerPed, control, true)
						setControlState(playerPed, control, true)
					end
				end)

				bindKey(key, "up", function()
					if not isPedDead(playerPed) then
						if control == "fire" and getPedWeapon(playerPed) == 0 then return end
						triggerServerEvent(g_PED_CONTROL_UPDATE_EVENT, resourceRoot, playerPed, control, false)
						setControlState(playerPed, control, false)
					end
				end)
			end
		end

		-- ped emotes
		local emotes = {
			["1"] = { "ped", "fucku" },
			["2"] = { "ped", "endchat_03" },
			["3"] = { "dancing", "dan_down_a" }
		}
		for key, anim in pairs(emotes) do
			bindKey(key, "down", function()
				if not isPedDead(playerPed) then
					triggerServerEvent(g_PED_ANIMATION_EVENT, resourceRoot, playerPed, anim[1], anim[2])
					setPedAnimation(playerPed, anim[1], anim[2], -1, false, true, true, false)
				end
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
		if ped ~= playerPed then
			setPedAnimation(ped, block, anim, -1, false, true, true, false)
		end
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
--		dxDrawBorderedText(0.5,"A NEARBY PEDESTRIAN IS REVEALING YOUR LOCATION!", screenWidth / 2, screenHeight * 0.22, screenWidth, screenHeight, tocolor(222, 26, 26, 255), 2.5, "arial", center, top, false, false, false, true)


		if canSpawnAsPedCondition() then
			dxDrawBorderedText(0.5, "#C8C8C8Press " .. toggleKey .. " to spawn as a pedestrian.", screenWidth / 2, screenHeight - 105,  screenWidth, screenHeight, tocolor(160, 0, 210, 255), 1.9, "arial", center, top, false, false, false, true)
		elseif playerPed then
			if focusPed then
				dxDrawBorderedText(0.5, "Press " .. toggleKey .. " to return to spectator.", screenWidth / 2, screenHeight - 105,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.9, "arial", center, top, false, false, false, true)
				if not isPedDead(playerPed) then
					dxDrawBorderedText(0.5, "Your pedestrian will remain vulnerable!", screenWidth / 2, screenHeight - 85,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.2, "arial", center, top, false, false, false, true)
					dxDrawBorderedText(0.5, "Any player close to you will have their location revealed on the radar to everyone.", screenWidth / 2, screenHeight - 55,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.2, "arial", center, top, false, false, false, true)
					dxDrawBorderedText(0.5, "Be careful! If you are killed, you will not be able to respawn!", screenWidth / 2, screenHeight - 35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.2, "arial", center, top, false, false, false, true)
					dxDrawBorderedText(0.5, "(press 1 to flip the bird, press 2 to wave, press 3 to show your moves)", screenWidth / 2, screenHeight - 15,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.2, "arial", center, top, false, false, false, true)
				else
					dxDrawBorderedText(0.5, "Oh dear, you are dead!", screenWidth / 2, screenHeight * 0.5,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "sans", center, top, false, false, false, true)
					dxDrawBorderedText(0.5, "Better luck next time.", screenWidth / 2, screenHeight * 0.5 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "sans", center, top, false, false, false, true)
				end
			else
				dxDrawBorderedText(0.5, "Press " .. toggleKey .. " to return to pedestrian.", screenWidth / 2, screenHeight - 105,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 1.9, "arial", center, top, false, false, false, true)
			end
		end
	end)
end)
