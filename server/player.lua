Player = {}

function Player:new(player)
	local o = {}
	setmetatable(o, self)

	self.__index = self
	o.role = g_CRIMINAL_ROLE
	o.player = player
	o.delivering = false

	return o
end

-- return if role successfully set
-- may not be set if there are no more cop cars to replace
function Player:setRole(role)
	if role == g_POLICE_ROLE then
		for _, copCar in pairs(getElementsByType("vehicle")) do
			-- at least 1 cop car to use
			self.role = role

			-- change player vehicle and tp to cop vehicle position
			local vehicle = getPedOccupiedVehicle(self.player)
			setElementModel(vehicle, 596) -- police LS
			setElementPosition(vehicle, getElementPosition(copCar))
			setElementRotation(vehicle, getElementRotation(copCar))
			setVehicleHandling(vehicle, "collisionDamageMultiplier", 0)
			setVehicleColor(vehicle, 0, 0, 0, 255, 255, 255, 0, 0, 0)

			-- lazy keep sirens on, let them be toggled off for at most 3 seconds
			-- for stealth gameplay
			setTimer(function()
				if not getVehicleSirensOn(vehicle) then
					setVehicleSirensOn(vehicle, true)
				end
			end, 3000, 0)

			destroyElement(copCar)
			triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)
			return true
		end

		return false
	else
		self.role = role
		triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)
	end

	return true
end