-- global for debug purposes atm
jobs = {}
exits = {}
playersByClient = {}

lastJobId = 0
availableJobs = 0
lastSpawnedJobAt = 0
totalMoneyProgress = 0
moneyEscapeQuota = 0
lastExitId = 0
lastSpawnedExitAt = 0
gameState = g_PREGAME_STATE
harvestJobCount = 0

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", getRootElement(), function(state)
	if state == "GridCountdown" then
		setTimer(function()
			local forceFreeze = setTimer(function()
				for _, player in ipairs(getElementsByType("player")) do
					toggleControl(player, "accelerate", false)
					toggleControl(player, "brake_reverse", false)
				end
			end, 10, 0)

			preGameSetup()

			setTimer(function()
				killTimer(forceFreeze)
				for _, player in ipairs(getElementsByType("player")) do
					toggleControl(player, "accelerate", true)
					toggleControl(player, "brake_reverse", true)
				end
				startGameLoop()
			end, g_PERK_SELECTION_DURATION, 1)
		end, 1000, 1) -- no reason for timer but helps with errors in testing
	end
end)

function startGameLoop()
	updateGameState(g_COREGAME_STATE)

	setTimer(function()
		local start = os.clock()
		maybeUpdateGameState()
		maybeSpawnExitPoint()
		maybeSpawnJob()
		updateJobProgress()
		checkPerks()
		local stop = os.clock()
		local over = math.floor((stop - start) * 1000 - g_SERVER_TICK_DELAY)
		if over > 0 then
			-- things aren't updating as fast as expected
			outputDebugString("game tick delayed by " .. over .. "ms", 2)
		end
	end, g_SERVER_TICK_DELAY, 0)
end

function checkPerks()
	for _, player in pairs(playersByClient) do
		player:checkPerk()
	end
end

function maybeUpdateGameState()
	if gameState == g_COREGAME_STATE and totalMoneyProgress >= moneyEscapeQuota then
		updateGameState(g_ENDGAME_STATE)
	elseif gameState == g_ENDGAME_STATE and totalMoneyProgress >= moneyEscapeQuota * g_SECRET_ENDING_REQUIREMENT_MULTIPLIER then
		updateGameState(g_ENDENDGAME_STATE)
	elseif gameState ~= g_NO_CRIMS_STATE then
		local criminals = getPlayersInTeam(g_CriminalTeam)
		for _, criminal in ipairs(criminals) do
			if getElementData(criminal, "state") == "alive" then
				return
			end
		end

		updateGameState(g_NO_CRIMS_STATE)
	end
end

function updateGameState(state)
	if state == g_COREGAME_STATE then
		g_CopWeaponId = 29 -- mp5
		-- remove blips?
		-- unbind criminal keys?
	elseif state == g_ENDGAME_STATE then
		-- g_CopWeaponId = 31 -- m4
		lastSpawnedExitAt = getRealTime().timestamp + 15 -- hack to add extra 30 seconds to first spawn

		for _, criminal in ipairs(getPlayersInTeam(g_CriminalTeam)) do
			if getElementData(criminal, "state") == "alive" then
				createBlipAttachedTo(criminal, 0, 2, 150, 0, 200, 255, 6, 80085)
			end
		end
	elseif state == g_ENDENDGAME_STATE then
		for _, criminal in ipairs(getPlayersInTeam(g_CriminalTeam)) do
			bindKey(criminal, "vehicle_secondary_fire", "down", function()
				takeAllWeapons(criminal)
				giveWeapon(criminal, 30, 9999, true) -- ak47
				setPedDoingGangDriveby(criminal, not isPedDoingGangDriveby(criminal))
			end)
		end
	elseif state == g_NO_CRIMS_STATE then
		-- no criminals, so guess its ogre?
	end

	gameState = state
	triggerClientEvent(getRootElement(), g_GAME_STATE_UPDATE_EVENT, resourceRoot, state)
end

function maybeSpawnExitPoint()
	if gameState == g_ENDGAME_STATE or gameState == g_ENDENDGAME_STATE then
		if lastSpawnedExitAt < getRealTime().timestamp - (g_DELAY_BETWEEN_EXIT_SPAWN / 1000) then
			lastExitId = lastExitId + 1
			spawnExitPoint(lastExitId)
			if lastExitId == #exits then
				lastExitId = 0
			end
			lastExitId = lastExitId + 1
			spawnExitPoint(lastExitId)
			if lastExitId == #exits then
				lastExitId = 0
			end
		end
	end
end

function spawnExitPoint(id)
	local exitPoint = exits[id]
	if not exitPoint.active then
		exitPoint:enable()
		lastSpawnedExitAt = getRealTime().timestamp
	end
end

function maybeSpawnJob()
	if availableJobs < countPlayersInTeam(g_CriminalTeam) * g_AVAILABLE_JOBS_MULTIPLIER + 10 then
		if lastSpawnedJobAt < getRealTime().timestamp - (g_DELAY_BETWEEN_JOB_SPAWN / 1000) then
			lastJobId = lastJobId + 1
			spawnJob(lastJobId)
			if lastJobId == #jobs then
				lastJobId = 0
			end
		end
	end
end

function spawnJob(id)
	local job = jobs[id]
	if job:isComplete() then
		job:enable()
		availableJobs = availableJobs + 1
		lastSpawnedJobAt = getRealTime().timestamp
	end
end

function finishJob(job)
	job:finish()

	if job.type ~= g_HARVEST_JOB.type then
		availableJobs = availableJobs - 1
	end
	totalMoneyProgress = totalMoneyProgress + job:money()

	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = totalMoneyProgress,
		moneyQuota = moneyEscapeQuota
	})
end

function assignJob(job, player)
	job:assign(player)
end

function unassignJob(job, player)
	job:unassign(player)
end

function spawnHarvestJob(player)
	if not playersByClient[player] then return end
	if playersByClient[player].died then return end

	playersByClient[player].died = true

	local x, y, z = getElementPosition(player)
	harvestJobCount = harvestJobCount + 1
	local job = HarvestJob:new(-harvestJobCount, "harvest job", x, y, z)
	job:setup(player)
	job:enable()
	jobs[-harvestJobCount] = job -- using negatives so it doesnt interfere with other jobs
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
	-- attempt to remove player blips
	for _, blip in pairs(getElementsByType("blip")) do
		destroyElement(blip)
	end

	-- set up exit points and shuffle
	for _, group in ipairs(getElementsByType("exit_group", resourceRoot)) do
		-- not sure what the duplicates are
		if #getElementChildren(group) > 0 then
			exits[#exits + 1] = Exit:new(group)
		end
	end

	shuffle(exits)

	-- randomly select cops and criminals
	local players = {}
	for _, player in pairs(getElementsByType("player")) do
		playersByClient[player] = Player:new(player)
		players[#players + 1] = playersByClient[player]

		-- should toggle internal boolean to hide race nametags
		triggerClientEvent(player, "onClientScreenFadedOut", resourceRoot)
	end

	shuffle(players)

	local policeCount = math.ceil(#players / g_CRIMINALS_PER_COP)
	if #players == 1 then
		policeCount = 0
	end

	for i = 1, policeCount do
		local success = players[i]:setRole(g_POLICE_ROLE) -- may not succeed if not enough spawn points
		if not success then break end
	end
	for i = countPlayersInTeam(g_PoliceTeam) + 1, #players do
		players[i]:setRole(g_CRIMINAL_ROLE)
	end

	-- set up player based limits
	moneyEscapeQuota = countPlayersInTeam(g_CriminalTeam) * 10
	triggerClientEvent(getRootElement(), g_MONEY_UPDATE_EVENT, resourceRoot, {
		money = 0,
		moneyQuota = moneyEscapeQuota
	})

	-- shuffle jobs into order they will spawn in
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
		job:setup()
	end

	-- start listening for client side completion of jobs (honk job, delivery job)
	addEvent(g_FINISH_JOB_EVENT, true)
	addEventHandler(g_FINISH_JOB_EVENT, getRootElement(), function(id)
		finishJob(jobs[id])
	end)

	-- harvest jobs spawn whenever anyone disappears no matter what team
	addEventHandler("onPlayerQuit", getRootElement(), function()
		spawnHarvestJob(source)
	end)
	addEventHandler("onPlayerWasted", getRootElement(), function()
		spawnHarvestJob(source)
	end)
end

function shuffle(a)
	for i = #a, 2, -1 do
		local j = math.random(i)
		a[i], a[j] = a[j], a[i]
	end
end

function toPlayer(element)
	if getElementType(element) ~= "vehicle" then return false end
	return playersByClient[getVehicleOccupant(element)], element
end

if g_DEBUG_MODE then
	addCommandHandler("ugs", function(ply, arg, s)
		print(arg, s)
		updateGameState(s)
	end)

	addCommandHandler("sep", function(ply, arg, id)
		print(arg, id)
		spawnExitPoint(tonumber(id))
	end)

	addCommandHandler("sj", function(ply, arg, id)
		print(arg, id)
		spawnJob(tonumber(id))
	end)

	addCommandHandler("shj", function(ply, arg, id)
		spawnHarvestJob(ply)
	end)

	addCommandHandler("fj", function(ply, arg, id)
		print(arg, id)
		finishJob(jobs[tonumber(id)])
	end)

	addCommandHandler("aj", function(ply, arg, id)
		print(arg, id)
		assignJob(jobs[tonumber(id)], playersByClient[ply])
	end)

	addCommandHandler("uj", function(ply, arg, id)
		print(arg, id)
		unassignJob(jobs[tonumber(id)], playersByClient[ply])
	end)

	addCommandHandler("sr", function(ply, arg, r)
		print(arg, r)
		playersByClient[ply]:setRole(r)
	end)

	addCommandHandler("eee", function(ply, arg, ...)
		print(...)
		loadstring(...)()
	end)
end