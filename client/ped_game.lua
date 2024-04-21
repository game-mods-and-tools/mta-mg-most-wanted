local spawned = false
local playerPed = nil
local toggleKey = next(getBoundKeys("enter_exit")) or "enter_exit"
local function canSpawnAsPedCondition()
	local state = getElementData(localPlayer, "state")
	return not spawned and (
		state == "spectating" or
		state == "waiting" or
		state == "dead"
	)
end
local function stopSpectating()
	-- auto means the player position ingame wont be saved
	triggerEvent("onClientCall_race", root, "Spectate.stop", "auto")
end
local function startSpectating()
	-- auto means the player position ingame wont be saved
	triggerEvent("onClientCall_race", root, "Spectate.start", "auto")
end
-- force camera target until ped
function forceTarget()
	if playerPed and getCameraTarget() ~= playerPed then
		setCameraTarget(playerPed)
		setTimer(forceTarget, 10, 1)
	end
end

addEvent(g_PED_GAME_READY_EVENT, true)
addEventHandler(g_PED_GAME_READY_EVENT, resourceRoot, function()
	addEvent(g_SPAWN_PLAYER_PED_EVENT, true)
	addEventHandler(g_SPAWN_PLAYER_PED_EVENT, resourceRoot, function(ped)
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
					setPedControlState(ped, control, true)
				end)

				bindKey(key, "up", function()
					setPedControlState(ped, control, false)
				end)
			end
		end


		forceTarget()

		-- match camera rotation
		setTimer(function()
			setPedCameraRotation(ped, getPedCameraRotation(localPlayer))
		end, 10, 0)

		addEventHandler("onClientPedDamage", ped, function()
			-- cancelling the event removes the knocked back animation
			-- for now peds only have 1 life with default hp
		end)

		playerPed = ped
	end)

	bindKey(toggleKey, "down", function()
		if canSpawnAsPedCondition() then
			spawned = true

			stopSpectating()

			-- should trigger ped spawn event which sets target to ped
			triggerServerEvent(g_REQUEST_SPAWN_PED_EVENT, resourceRoot)
		elseif playerPed then
			if getCameraTarget(localPlayer) ~= playerPed then
				stopSpectating()
				forceTarget()
			elseif getCameraTarget(localPlayer) == playerPed then
				startSpectating()
			end
		end
	end)

	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()

		if canSpawnAsPedCondition() then
			dxDrawBorderedText(0.5,"#C8C8C8You've died... press " .. toggleKey .. " to spawn as a #33A5FFcop", screenWidth / 2, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5, "#C8C8C8and seek out #A000D2criminals #C8C8C8 on foot", screenWidth / 2, screenHeight * 0.3 + 50,  screenWidth, screenHeight, tocolor(160, 0, 210, 255), 2.8, "arial", center, top, false, false, false, true)
			dxDrawBorderedText(0.5, "#C8C8C8you only have 1 life...", screenWidth / 2, screenHeight * 0.3 + 100,  screenWidth, screenHeight, tocolor(160, 0, 210, 255), 2.8, "arial", center, top, false, false, false, true)
		elseif playerPed then
			if getCameraTarget(localPlayer) == playerPed and isPedDead(playerPed) then
				dxDrawBorderedText(0.5,"ur dead", screenWidth / 2, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "sans", center, top, false, false, false, true)
			else
				dxDrawBorderedText(0.5,"#C8C8C8" .. toggleKey .. " to toggle between cop and spectator", screenWidth / 2, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "sans", center, top, false, false, false, true)
			end
		end
	end)
end)
