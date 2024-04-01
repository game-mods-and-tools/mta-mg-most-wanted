Exit = {}

function Exit:new(vans, barricades, walls, exits)
	local o = {}
	setmetatable(o, self)

	self.__index = self

	o.vans = {}
	for _, v in ipairs(vans) do
		local van = createVehicle(427, getElementPosition(v))
		-- do not set rotation in ctor because...
		setElementRotation(van, getElementData(v, "rotX"), getElementData(v, "rotY"), getElementData(v, "rotZ"))
		o.vans[#o.vans + 1] = van
	end

	o.barricades = {}
	for _, b in ipairs(barricades) do
		local barricade = createObject(981, getElementPosition(b))
		setElementRotation(barricade, getElementData(b, "rotX"), getElementData(b, "rotY"), getElementData(b, "rotZ"))
		o.barricades[#o.barricades + 1] = barricade
	end

	o.walls = {}
	for _, w in ipairs(walls) do
		local wall = createObject(8172, getElementPosition(w))
		setElementRotation(wall, getElementData(w, "rotX"), getElementData(w, "rotY"), getElementData(w, "rotZ"))
		o.walls[#o.walls + 1] = wall
	end

	o.blips = {}
	o.markers = {}
	o.exits = exits

	for _, e in ipairs(exits) do
		local x, y, z = getElementPosition(e)
		local col = createColCircle(x, y, 10)
		addEventHandler("onColShapeHit", col, function(element)
			local player, vehicle = toPlayer(element)
			if not player then return end
			if not vehicle then return end -- in case of spectator?

			if not o.active then return end
			-- criminals only

			triggerEvent("onPlayerReachCheckpointInternal", player, 1)
		end)
	end

	o:disable()

	return o
end

function Exit:disable()
	for _, wall in ipairs(self.walls) do
		setElementCollisionsEnabled(wall, true)
		setElementAlpha(wall, 200)
	end
	for _, barricade in ipairs(self.barricades) do
		setElementCollisionsEnabled(barricade, true)
		setElementAlpha(barricade, 255)
	end
	for _, van in ipairs(self.vans) do
		setElementCollisionsEnabled(van, true)
		setElementAlpha(van, 255)
	end
	for _, blip in ipairs(self.blips) do
		destroyElement(blip)
	end
	for _, marker in ipairs(self.markers) do
		destroyElement(marker)
	end
	self.blips = {}
	self.markers = {}

	self.active = false
end

function Exit:enable()
	for _, wall in ipairs(self.walls) do
		setElementCollisionsEnabled(wall, false)
		setElementAlpha(wall, 100)
	end
	for _, barricade in ipairs(self.barricades) do
		setElementCollisionsEnabled(barricade, false)
		setElementAlpha(barricade, 0)
	end
	for _, van in ipairs(self.vans) do
		setElementCollisionsEnabled(van, false)
		setElementAlpha(van, 0)
	end
	for _, e in ipairs(self.exits) do
		local x, y, z = getElementPosition(e)
		self.blips[#self.blips + 1] = createBlip(x, y, z)
		self.markers[#self.markers + 1] = createMarker(x, y, z)
	end

	self.active = true

	triggerClientEvent(getRootElement(), g_ESCAPE_ROUTE_APPEARED, resourceRoot)
end