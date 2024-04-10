g_FUGITIVE_PERK = {
	id = "fugitivePerkId",
	name = "Fugitive",
	duration = 30000, -- ms
	description = "After reaching the quota, become temporarily invisible."
}
g_MECHANIC_PERK = {
	id = "mechanicPerkId",
	name = "Mechanic",
	healRate = 5, -- per second
	description = "Stand still to slowly regain health."
}
g_HOTSHOT_PERK = {
	id = "hotshotPerkId",
	name = "Hotshot",
	velocityRate = 0.2, -- maxVelocity per missing hp
	accelRate = 0.01, -- engineAcceleration per missing hp
	description = "The lower your health, the higher your top speed."
}
g_PERK_SELECTION_DURATION = 15000

g_PLAYER_ROLE_SELECTED_EVENT = "onPlayerRoleSelected" -- role

g_POLICE_ROLE = "PoliceRole"
g_CRIMINAL_ROLE = "CriminalRole"
g_POLICE_TEAM_NAME = "The Police"

g_SHOW_JOB_EVENT = "onShowJob" -- jobId, jobType, jobPos
g_HIDE_JOB_EVENT = "onHideJob" -- jobId
g_START_JOB_EVENT = "onStartJob" -- jobId, jobType
g_STOP_JOB_EVENT = "onStopJob" -- jobId, jobType
g_FINISH_JOB_EVENT = "onFinishJob" -- jobId (jobType) (reportedplayers) (client only)
g_JOB_STATUS_UPDATE_EVENT = "onJobStatusUpdate" -- jobId, jobType, data (depends on jobType)

g_MONEY_UPDATE_EVENT = "onMoneyUpdate"
g_GAME_STATE_UPDATE_EVENT = "onGameStateUpdate" -- state
g_ESCAPE_ROUTE_APPEARED = "onEscapeRouteAppeared"
g_PREGAME_STATE = "pregame"
g_COREGAME_STATE = "coregame"
g_ENDGAME_STATE = "endgame"
g_ENDENDGAME_STATE = "endendgame"
g_NO_CRIMS_STATE = "nocrimsgame"

g_PICKUP_JOB = {
	elementType = "pickup_job",
	type = "pickup job",
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 52,
	color = { r = 20, g = 150, b = 0, a = 100 },
	jobWeight = 0.879,
	progressRate = 0.15 -- per second
}
g_DELIVERY_JOB = {
	elementType = "delivery_job_start",
	type = "delivery job",
	subtypes = {
		ELIMINATION = "elimination",
		DELIVERY = "delivery",
	},
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 51,
	color = { r = 255, g = 0, b = 0, a = 100 },
	jobWeight = 1.213 -- and bonus
}
g_EXTORTION_JOB = {
	elementType = "extortion_job",
	type = "extortion job",
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 55,
	color = { r = 0, g = 0, b = 160, a = 100 },
	jobWeight = 1.061,
	progressRate = 0.025, -- per interval
	decayRate = 0.05, -- per interval
	interval = 100 -- in ms, client side, unrelated to server ticks
}
g_GROUP_JOB = {
	elementType = "group_job",
	type = "group job",
	detectionRadius = 1000,
	zoneRadius = 22,
	blip = 6,
	color = { r = 255, g = 255, b = 255, a = 100 },
	jobWeight = 6.865,
	progressRate = 0.05, -- per second
	decayRate = 0.1, -- per second
	minPlayers = 3
}
g_JOBS_BY_TYPE = {
	[g_PICKUP_JOB.type] = g_PICKUP_JOB,
	[g_DELIVERY_JOB.type] = g_DELIVERY_JOB,
	[g_EXTORTION_JOB.type] = g_EXTORTION_JOB,
	[g_GROUP_JOB.type] = g_GROUP_JOB
}