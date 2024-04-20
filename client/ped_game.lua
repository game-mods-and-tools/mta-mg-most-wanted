local spawned = false
local playerPed = nil
local function canSpawnAsPedCondition()
	return not spawned and getElementData(localPlayer, "state") == "spectating"
end

addEvent(g_SPAWN_PLAYER_PED_EVENT, true)
addEventHandler(g_SPAWN_PLAYER_PED_EVENT, getRootElement(), function(ped)
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

	function forceTarget()
		if getCameraTarget() ~= ped then
			setCameraTarget(ped)
			setTimer(forceTarget, 10, 1)
		end
	end
	forceTarget()

	setTimer(function()
		setPedCameraRotation(ped, getPedCameraRotation(localPlayer))
	end, 10, 0)

	addEventHandler("onClientPedDamage", ped, function()
		-- cancelling the event removes the knocked back animation
		setElementHealth(ped, 1000)
	end)

	playerPed = ped
end)

bindKey("space", "down", function()
	-- and getElementData(localPlayer, "state") == "spectating"
	if canSpawnAsPedCondition() then
		spawned = true
		triggerServerEvent(g_REQUEST_SPAWN_PED_EVENT, resourceRoot)
	elseif spawned and getCameraTarget(localPlayer) ~= playerPed then
		-- if you spectate away, press space to refocus on ped i guess?
		-- check what happens in spectator mode
		setCameraTarget(playerPed)
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()

		if canSpawnAsPedCondition() then
			dxDrawBorderedText(0.5,"#C8C8C8You've died... press space to spawn as a #33A5FFcop", screenWidth / 2, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 3, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5, "#C8C8C8and seek out #A000D2criminals #C8C8C8 on foot", screenWidth / 2, screenHeight * 0.3 + 50,  screenWidth, screenHeight, tocolor(160, 0, 210, 255), 2.8, "arial", center, top, false, false, false, true)
		end
	end)
end)

