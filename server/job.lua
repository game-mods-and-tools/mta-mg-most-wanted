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
	o.reward = 100

	return o
end

function Job:money()
	return self.reward
end

function Job:justCompleted()
	return self:isComplete() and #self:activePlayers() > 0
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
end

function Job:isAssignedTo(player)
	return self.players[player.player]
end

function Job:unassign(player, players)
	self.players[player.player] = false

	self.progress = 0
	self:enable(players)
end

function Job:enable(players)
	self.progress = 0
	triggerClientEvent(players, g_SHOW_JOB, resourceRoot, self.id, self.type, self.pos)
end

function Job:disable(players)
	triggerClientEvent(players, g_HIDE_JOB, resourceRoot, self.id)
end

function Job:finish(players)
	self.progress = 1
	self:disable(players)
	triggerClientEvent(self:activePlayers(), g_FINISH_JOB, resourceRoot, self.id)
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

	if self:isComplete() then return end
	if #players == 0 then
		self.progress = 0 -- fully reset progress if no one is working on it
	end

	-- these take 10 intervals of sitting still
	self.progress = math.min(self.progress + 0.1, 1)
	triggerClientEvent(players, g_JOB_STATUS_UPDATE, resourceRoot, self.id, self.type, { progress = self.progress })
end

-- a job with "2" stages that can only be accepted with 1 person
DeliveryJob = Job:new()

function DeliveryJob:money()
	return self.reward + self.bonus
end

function DeliveryJob:assign(player, players)
	if player.delivering then return end

	self.deliverer = player
	self.deliverer.delivering = true
	self.players[player.player] = true

	local endpoints = getElementsByType("delivery_job_end")
	local endpoint = endpoints[math.random(#endpoints)]

	local x, y, z = getElementPosition(endpoint)

	self.bonus = math.floor(getDistanceBetweenPoints3D(self.pos.x, self.pos.y, self.pos.z, x, y, z) / 24)

	triggerClientEvent(player, g_JOB_STATUS_UPDATE, resourceRoot, self.id, self.type, { pos = { x = x, y = y, z = z } })
	self:disable(players)
end

function DeliveryJob:unassign(player)
	-- you can't be unassigned from a destination job
end

function DeliveryJob:tick()
	-- does nothing since we just need the player to reach a destination
end

function DeliveryJob:finish(players)
	self.progress = 1
	self.deliverer.delivering = false
	self:disable(players)
	triggerClientEvent(self:activePlayers(), g_FINISH_JOB, resourceRoot, self.id)
	self.players = {}
end

-- sit and wait... in a group job
GroupJob = Job:new()

function GroupJob:assign(player)
	self.players[player.player] = true
end

function GroupJob:unassign(player)
	self.players[player.player] = false
end

function GroupJob:tick()
	local players = self:activePlayers()

	if self:isComplete() then return end
	if #players == 0 then
		self.progress = math.max(self.progress - 0.05, 0) -- decay
	end

	-- slower than normal job but scales with players
	self.progress = math.min(self.progress + 0.02 * #players, 1)
	triggerClientEvent(players, g_JOB_STATUS_UPDATE, resourceRoot, self.id, self.type, { progress = self.progress })
end

function GroupJob:isAvailable()
	return self.progress ~= 1
end

-- also 2 stages but 2nd stage is honking at same location
ExtortionJob = DeliveryJob:new()

function ExtortionJob:assign(player, players)
	self.players[player.player] = true
	self.bonus = 0

	triggerClientEvent(player, g_JOB_STATUS_UPDATE, resourceRoot, self.id, self.type, { pos = { x = x, y = y, z = z } })
	self:disable(players)
end

function ExtortionJob:unassign(player, players)
	self.players[player.player] = false

	self:enable(players)
end

function ExtortionJob:finish(players)
	self.progress = 1

	self:disable(players)
	triggerClientEvent(self:activePlayers(), g_FINISH_JOB, resourceRoot, self.id)
	self.players = {}
end