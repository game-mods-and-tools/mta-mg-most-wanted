-- global for debug purposes atm
players = {}
jobs = {}

local playersByClient = {}
local police = {}
local criminals = {}

lastJobId = 0
availableJobs = 0
totalMoneyProgress = 0
moneyEscapeQuota = 0
randomMoneyScaler = 1
gameState = g_COREGAME_STATE

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", getRootElement(), function(state)
	if state == "GridCountdown" then
		for _, player in pairs(getElementsByType("player")) do
			local p = Player:new(player)
			players[#players + 1] = p
			playersByClient[player] = p
		end

		setTimer(function()
			preGameSetup()
			startGameLoop()
		end, 1000, 1)
	end
end)

function startGameLoop()
	triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, gameState)

	setTimer(function()
		trySpawnJob()
		updateJobProgress()
		maybeUpdateGameState()
	end, 1000 / g_SERVER_TICK_RATE, 0)
end

function maybeUpdateGameState()
	-- if totalMoneyProgress >= moneyEscapeQuota and not endGame then
	if gameState == g_COREGAME_STATE and totalMoneyProgress > moneyEscapeQuota then
		gameState = g_ENDGAME_STATE
		triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, gameState)

		for _, criminal in ipairs(criminals) do
			createBlipAttachedTo(criminal, 0, 2, 223, 179, 0, 255, 6, 80085)
		end
	-- elseif gameState == g_ENDGAME_STATE and totalMoneyProgress >= moneyEscapeQuota * 2 then
	elseif gameState == g_ENDGAME_STATE and totalMoneyProgress >= moneyEscapeQuota + 5 then
		gameState = g_ENDENDGAME_STATE
		triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, gameState)

		for _, criminal in ipairs(criminals) do
			bindKey(criminal, "vehicle_secondary_fire", "down", function()
				giveWeapon(criminal, 30, 9999, true) -- uzi
				setPedDoingGangDriveby(criminal, not isPedDoingGangDriveby(criminal))
			end)
		end
	end
end

function trySpawnJob()
	-- if availableJobs > #criminals * 3 then return end
	if availableJobs > math.floor(#jobs / 1.5) then return end

	lastJobId = lastJobId + 1
	local nextJob = jobs[lastJobId]

	if nextJob:isComplete() then
		nextJob:enable(criminals)
		availableJobs = availableJobs + 1
	end

	if lastJobId == #jobs then
		lastJobId = 0
	end
end

function updateJobProgress()
	for _, job in ipairs(jobs) do
		local completed = job:tick()

		if completed then
			finishJob(job)
		end
	end
end

function preGameSetup()
	-- attempt to remove player blips, doesnt work probably
	for _, blip in pairs(getElementsByType("blip")) do
		destroyElement(blip)
	end

	-- randomly select cops and criminals
	shuffle(players)

	-- local policeCount = math.max(math.floor(#players / 4), 1)
	local policeCount = math.max(math.floor(#players / 8), 1)
	if #players == 1 then
		policeCount = 0
	end
	local totalPolice = 0

	for i = 1, policeCount do
		police[#police + 1] = players[i].player
		local success = players[i]:setRole(g_POLICE_ROLE)
		if not success then break end
		totalPolice = totalPolice + 1
	end
	for i = totalPolice + 1, #players do
		criminals[#criminals + 1] = players[i].player
		players[i]:setRole(g_CRIMINAL_ROLE)
	end

		local jobElements = {}

	for _, job in ipairs({
		g_PICKUP_JOB,
		g_GROUP_JOB,
		g_DELIVERY_JOB,
		g_EXTORTION_JOB
	}) do
		for _, element in ipairs(getElementsByType(job.elementType, resourceRoot)) do
			jobElements[#jobElements + 1] = { element = element, job = job }
		end
	end

	-- set up player based limits
	randomMoneyScaler = 1000 -- random numbers used to scale quota for big $$$
	moneyEscapeQuota = #criminals * 10
	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = 0,
		moneyQuota = moneyEscapeQuota * randomMoneyScaler
	})

	-- shuffle jobs into order they will spawn in
	shuffle(jobElements)

	for id, element in ipairs(jobElements) do
		local job = nil
		if element.job == g_DELIVERY_JOB then
			job = DeliveryJob:new(id, element.job.type, getElementPosition(element.element))
		elseif element.job == g_GROUP_JOB then
			job = GroupJob:new(id, element.job.type, getElementPosition(element.element))
		elseif element.job == g_EXTORTION_JOB then
			job = ExtortionJob:new(id, element.job.type, getElementPosition(element.element))
		else
			job = Job:new(id, element.job.type, getElementPosition(element.element))
		end

		jobs[#jobs + 1] = job

		local col = createColCircle(job.pos.x, job.pos.y, g_JOBS_BY_TYPE[job.type].zoneRadius)
		addEventHandler("onColShapeHit", col, function(element)
			local player, vehicle = toPlayer(element)
			if not player then return end
			if not vehicle then return end -- in case of spectator?

			player = playersByClient[player]

			if not player then return end
			if player.role ~= g_CRIMINAL_ROLE then return end

			local _, _, z = getElementPosition(vehicle)
			if math.abs(z - job.pos.z) > 5 then return end

			if not job:isAvailable() then return end

			job:assign(player, criminals)
			print("assigned job", id, "to", getPlayerName(player.player))
		end)
		addEventHandler("onColShapeLeave", col, function(element)
			local player = toPlayer(element)
			if not player then return end

			player = playersByClient[player]

			if not player then return end
			if not job:isAssignedTo(player) then return end
			-- can't check Z but don't care?

			job:unassign(player, criminals)
			print("unassigned job", id, "from", getPlayerName(player.player))
		end)
	end

	-- start listening for client side completion of jobs (honk job, delivery job)
	addEvent(g_FINISH_JOB_EVENT, true)
	addEventHandler(g_FINISH_JOB_EVENT, getRootElement(), function(id)
		finishJob(jobs[id])
	end)
end

function finishJob(job)
	job:finish(criminals, police)

	availableJobs = availableJobs - 1
	totalMoneyProgress = totalMoneyProgress + job:money()

	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = totalMoneyProgress * randomMoneyScaler,
		moneyQuota = moneyEscapeQuota * randomMoneyScaler
	})
	print("Job", job.id, "finished. progress", totalMoneyProgress)
end

function shuffle(a)
	for i = #a, 2, -1 do
		local j = math.random(i)
		a[i], a[j] = a[j], a[i]
	end
end

function toPlayer(element)
	if getElementType(element) ~= "vehicle" then return false end
	return getVehicleOccupant(element), element
end

-- debugging
addCommandHandler("ug", function(ply, arg, var, val)
	print(arg, var, val)
	_G[var] = tonumber(val)
end)

addCommandHandler("fj", function(ply, arg, job)
	print(arg, job)
	finishJob(jobs[tonumber(job)])
end)

addCommandHandler("p", function(ply, arg, var)
	print(arg, var)
	print(_G[var])
end)