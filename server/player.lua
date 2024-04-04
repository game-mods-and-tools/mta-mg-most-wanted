Player = {}

local criminalNames = {
	"Forelli Family",
	"Leone Family",
	"Ancelotti Family",
	"Pegorino Crime Family",
	"Pecorinos",
	"Gambetti Family",
	"Messina Family",
	"McRearys",
	"Mendez Cartel",
	"Albanian Mob",
	"Bulgarin Crime Syndicate",
	"Red Gecko Tong",
	"Mountain Cloud Boys",
	"Da Nang Boys",
	"Yakuza",
	"Yardies",
	"Varrios Los Aztecas",
	"Grove Street Families",
	"Vagos",
	"Colombian Cartel",
	"The Lost MC",
	"Angels of Death",
	"Uptown Riders",
	"Ballas",
	"Bloodhound Gang",
	"Anti-Fleischberg Group",
	"Tunnel Snakes",
	"Los Pollos Hermanos",
	"Trailer Park Mafia",
	"Hillside Posse",
	"Jingweon Mafia",
	"Midtown Gangsters",
	"Wonsu Nodong",
	"Dharma Initiative",
	"E-Corp",
	"Serious Individuals",
	"Jax Trust",
	"Kiketsu Family",
	"Scavengers",
	"Tyger Claws",
	"Voodoo Boys",
	"Rifa",
	"Loco Syndicate",
	"Stetchkov Syndicate",
	"Blood Feather Triad",
	"Snake Farmers",
	"Team Rocket",
	"Cerberus",
	"Discord Mods United",
	"Package Hunters Initiative",
	"Team SKC",
	"GTA Community Rebellion"
}

g_PoliceTeam = createTeam(g_POLICE_TEAM_NAME)
g_CriminalTeam = createTeam(criminalNames[math.random(#criminalNames)])

function Player:new(player)
	local o = {}
	setmetatable(o, self)

	self.__index = self
	o.role = nil
	o.player = player
	o.delivering = false

	return o
end

-- return if role successfully set
-- may not be set if there are no cop cars
function Player:setRole(role)
	if role == g_POLICE_ROLE then
		for _, copCar in pairs(getElementsByType("vehicle", resourceRoot)) do
			if getElementModel(copCar) == 596 then
				-- at least 1 cop car to use
				self.role = role

				-- change player vehicle and tp to cop vehicle position
				local vehicle = getPedOccupiedVehicle(self.player)
				setElementModel(vehicle, 596) -- police LS
				setElementPosition(vehicle, getElementPosition(copCar))
				setElementRotation(vehicle, getElementRotation(copCar))
				setVehicleHandling(vehicle, "collisionDamageMultiplier", 0)
				setVehicleHandling(vehicle, "acceleration", 27)
				setVehicleColor(vehicle, 0, 0, 0, 255, 255, 255, 0, 0, 0)

				bindKey(self.player, "vehicle_secondary_fire", "down", function()
					giveWeapon(self.player, 31, 9999, true) -- uzi
					setPedDoingGangDriveby(self.player, not isPedDoingGangDriveby(self.player))
				end)

				destroyElement(copCar) -- so players won't spawn on top of each other

				triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)

				setPlayerTeam(self.player, g_PoliceTeam)
				return true
			end
		end

		return false
	else
		self.role = role
		triggerClientEvent(self.player, g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, role)

		setPlayerTeam(self.player, g_CriminalTeam)

		local clowncar = getPedOccupiedVehicle(self.player)
		setVehicleHandling(clowncar, "collisionDamageMultiplier", 0.2)
	end

	return true
end