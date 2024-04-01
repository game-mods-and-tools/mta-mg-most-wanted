g_SERVER_TICK_RATE = 5 -- ticks per second, limited by other things

g_SHOW_PERK_SELECTION_AND_EXPLANATION = "show perks and explanations"
g_START_PERK_SELECTION_AND_EXPLANATION_TIMER = "will close the perk window in some time" -- time
g_CLOSE_PERK_SELECTION_AND_EXPLANATION = "close the ui"
g_FUGITIVE_PERK = { id = "fugitive perk id", name = "Fugitive", description = "After earning $500, you receive a single use nitro." }
g_MECHANIC_PERK = { id = "mechanic perk id", name = "Mechanic", description = "When not on a job, stand still to slowly regain health." }
g_HOTSHOT_PERK = { id = "hotshot perk id", name = "Hotshot", description = "Slightly higher top speed." }
g_PLAYER_SELECTED_PERK_EVENT = "select perk event" -- player, perk

g_PLAYER_ROLE_SELECTED_EVENT = "onPlayerRoleSelected" -- role

g_POLICE_ROLE = "Police Role"
g_CRIMINAL_ROLE = "Criminal Role"

g_SHOW_JOB_EVENT = "onShowJob" -- jobId, jobType, jobPos
g_HIDE_JOB_EVENT = "onHideJob" -- jobId
g_START_JOB_EVENT = "onStartJob" -- jobId, jobType
g_STOP_JOB_EVENT = "onStopJob" -- jobId, jobType
g_FINISH_JOB_EVENT = "onFinishJob" -- jobId (jobType) (reportedplayers) (client only)
g_JOB_STATUS_UPDATE_EVENT = "onJobStatusUpdate" -- jobId, jobType, data (depends on jobType)

g_MONEY_UPDATE_EVENT = "onMoneyUpdate"
g_GAME_STATE_UPDATE_EVENT = "onGameStateUpdate" -- state
g_COREGAME_STATE = "coregame"
g_ENDGAME_STATE = "endgame"
g_ENDENDGAME_STATE = "endendgame"

g_PICKUP_JOB = {
	elementType = "pickup_job",
	type = "pickup job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 52,
	color = { r = 0, g = 0, b = 255, a = 100 },
	jobWeight = 1,
	progressRate = 0.2
}
g_DELIVERY_JOB = {
	elementType = "delivery_job_start",
	type = "delivery job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 51,
	color = { r = 255, g = 0, b = 0, a = 100 },
	jobWeight = 1 -- and bonus
}
g_EXTORTION_JOB = {
	elementType = "extortion_job",
	type = "extortion job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 55,
	color = { r = 0, g = 255, b = 0, a = 100 },
	jobWeight = 1.2,
	progressRate = 0.01, -- per interval
	decayRate = 0.05, -- per interval
	interval = 100 -- in ms
}
g_GROUP_JOB = {
	elementType = "group_job",
	type = "group job",
	detectionRadius = 1000,
	zoneRadius = 22,
	blip = 6,
	color = { r = 255, g = 255, b = 255, a = 100 },
	jobWeight = 5,
	progressRate = 0.1,
	decayRate = 0.05,
	minPlayers = 2
}
g_JOBS_BY_TYPE = {
	[g_PICKUP_JOB.type] = g_PICKUP_JOB,
	[g_DELIVERY_JOB.type] = g_DELIVERY_JOB,
	[g_EXTORTION_JOB.type] = g_EXTORTION_JOB,
	[g_GROUP_JOB.type] = g_GROUP_JOB
}