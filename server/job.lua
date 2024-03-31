-- typical sit and wait job for 1 person
Job = {}

function Job:new(id, type, x, y, z)
	local o = {}
	setmetatable(o, self)

	self.__index = self
	o.id = id
	o.type = type
	o.pos = { x = x, y = y, z = z }
	o.progress = 1
	o.players = {}

	return o
end

function Job:money()
	return g_JOBS_BY_TYPE[self.type].jobWeight
end

function Job:isComplete()
	return self.progress == 1
end

function Job:isAvailable()
	return self.progress ~= 1 and #self:activePlayers() == 0
end

function Job:assign(player, players)
	self.players[player.player] = true

	self:disable(players)
	triggerClientEvent(player.player, g_START_JOB_EVENT, resourceRoot, self.id, self.type)
end

function Job:isAssignedTo(player)
	return self.players[player.player]
end

function Job:unassign(player, players)
	self.players[player.player] = false

	self.progress = 0
	triggerClientEvent(player.player, g_STOP_JOB_EVENT, resourceRoot, self.id, self.type)
	self:enable(players)
end

function Job:enable(players)
	self.progress = 0
	triggerClientEvent(players, g_SHOW_JOB_EVENT, resourceRoot, self.id, self.type, self.pos)
end

function Job:disable(players)
	triggerClientEvent(players, g_HIDE_JOB_EVENT, resourceRoot, self.id)
end

function Job:finish(criminals, police)
	self.progress = 1

	local players = self:activePlayers()
	triggerClientEvent(players, g_FINISH_JOB_EVENT, resourceRoot, self.id, self.type, players)
	triggerClientEvent(police, g_FINISH_JOB_EVENT, resourceRoot, self.id, self.type, players)

	self:disable(criminals)
	self.players = {}
end

function Job:activePlayers()
	local players = {}

	for player, doing in pairs(self.players) do
		if doing then
			players[#players + 1] = player
		end
	end

	return players
end

function Job:tick()
	local players = self:activePlayers()

	if self:isComplete() then return false end
	if #players == 0 then
		self.progress = 0 -- fully reset progress if no one is working on it
		return false
	end

	-- these take 10 intervals of sitting still
	self.progress = math.min(self.progress + g_JOBS_BY_TYPE[self.type].progressRate / g_SERVER_TICK_RATE, 1)
	triggerClientEvent(players, g_JOB_STATUS_UPDATE_EVENT, resourceRoot, self.id, self.type, { progress = self.progress })

	return self.progress == 1
end

-- a job with "2" stages that can only be accepted with 1 person
DeliveryJob = Job:new()

function DeliveryJob:money()
	return g_JOBS_BY_TYPE[self.type].jobWeight + self.bonus
end

function DeliveryJob:assign(player, players)
	if player.delivering then return end

	self.deliverer = player
	self.deliverer.delivering = true
	self.players[player.player] = true

	local endpoints = getElementsByType("delivery_job_end")
	local endpoint = endpoints[math.random(#endpoints)]

	local x, y, z = getElementPosition(endpoint)

	self.bonus = math.min(0.5, getDistanceBetweenPoints3D(self.pos.x, self.pos.y, self.pos.z, x, y, z) / 1200)

	triggerClientEvent(player.player, g_START_JOB_EVENT, resourceRoot, self.id, self.type)
	triggerClientEvent(player, g_JOB_STATUS_UPDATE_EVENT, resourceRoot, self.id, self.type, { pos = { x = x, y = y, z = z }, bonus = bonus })

	self:disable(players)
end

function DeliveryJob:unassign(player)
	-- you can't be unassigned from a destination job
end

function DeliveryJob:tick()
	-- does nothing since we just need the player to reach a destination
	return false
end

-- sit and wait... in a group job
GroupJob = Job:new()

function GroupJob:assign(player)
	self.players[player.player] = true

	triggerClientEvent(player.player, g_START_JOB_EVENT, resourceRoot, self.id, self.type)
end

function GroupJob:unassign(player)
	self.players[player.player] = false

	triggerClientEvent(player.player, g_STOP_JOB_EVENT, resourceRoot, self.id, self.type)
end

function GroupJob:tick()
	local players = self:activePlayers()

	if self:isComplete() then return false end
	if #players == 0 then
		self.progress = math.max(self.progress - g_JOBS_BY_TYPE[self.type].decayRate / g_SERVER_TICK_RATE, 0) -- decay
		return false
	end

	-- slower than normal job but scales with players, needs certain amount of players to progress
	self.progress = math.min(self.progress + g_JOBS_BY_TYPE[self.type].progressRate / g_SERVER_TICK_RATE * (#players + 1 - g_JOBS_BY_TYPE[self.type].minPlayers), 1)
	triggerClientEvent(players, g_JOB_STATUS_UPDATE_EVENT, resourceRoot, self.id, self.type, { progress = self.progress, playerCount = #players })

	return self.progress == 1
end

function GroupJob:isAvailable()
	return self.progress ~= 1
end

-- also 2 stages but 2nd stage is honking at same location
ExtortionJob = Job:new()

function ExtortionJob:assign(player, players)
	self.players[player.player] = true

	triggerClientEvent(player.player, g_START_JOB_EVENT, resourceRoot, self.id, self.type)
	triggerClientEvent(player, g_JOB_STATUS_UPDATE_EVENT, resourceRoot, self.id, self.type, { pos = { x = x, y = y, z = z } })
	self:disable(players)
end

function ExtortionJob:tick()
	return false
end