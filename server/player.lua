Player = {}

local policeTeam = createTeam(g_POLICE_TEAM_NAME)
local criminalTeam = createTeam("Criminals")

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

			bindKey(self.player, "vehicle_secondary_fire", "down", function()
				giveWeapon(self.player, 31, 9999, true) -- uzi
				setPedDoingGangDriveby(self.player, not isPedDoingGangDriveby(self.player))
			end)

			destroyElement(copCar)
			triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)
			
			setPlayerTeam(self.player, policeTeam)
			return true
		end

		return false
	else
		self.role = role
		triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)
		
		setPlayerTeam(self.player, criminalTeam)
	end

	return true
end