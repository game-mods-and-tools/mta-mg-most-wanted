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
		cancelEvent()
	end)
end)

local spawned = false
bindKey("space", "down", function()
	-- and getElementData(localPlayer, "state") == "spectating"
	if not spawned then
		spawned = true
		triggerServerEvent(g_REQUEST_SPAWN_PED_EVENT, resourceRoot)
	end
end)

