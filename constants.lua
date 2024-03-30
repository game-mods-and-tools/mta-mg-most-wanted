g_SHOW_PERK_SELECTION_AND_EXPLANATION = "show perks and explanations"
g_START_PERK_SELECTION_AND_EXPLANATION_TIMER = "will close the perk window in some time" -- time
g_CLOSE_PERK_SELECTION_AND_EXPLANATION = "close the ui"

g_FUGITIVE_PERK = { id = "fugitive perk id", name = "Fugitive", description = "fug desc" }
g_MECHANIC_PERK = { id = "mechanic perk id", name = "Mechanic", description = "mech desc" }
g_HOTSHOT_PERK = { id = "hotshot perk id", name = "Hotshot", description = "hot desc" }

g_PLAYER_SELECTED_PERK = "select perk event" -- player, perk

g_SELECT_PLAYER_ROLE = "select player role" -- role

g_POLICE_ROLE = "copper role"
g_CRIMINAL_ROLE = "criminal role"

g_SHOW_JOB = "show job" -- jobId, jobType, jobPos
g_HIDE_JOB = "hide job" -- jobId
g_JOB_STATUS_UPDATE = "job status update" -- jobId, jobType, data (depends on jobType)

g_PICKUP_JOB = {
	elementType = "pickup_job",
	type = "pickup job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 63,
	color = { r = 0, g = 0, b = 255 }
}
g_DELIVERY_JOB = {
	elementType = "delivery_job_start",
	type = "delivery job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 51,
	color = { r = 255, g = 255, b = 0 }
}
g_EXTORTION_JOB = {
	elementType = "extortion_job",
	type = "extortion job",
	detectionRadius = 200,
	zoneRadius = 5,
	blip = 52,
	color = { r = 0, g = 255, b = 0 }
}
g_GROUP_JOB = {
	elementType = "group_job",
	type = "group job",
	detectionRadius = 800,
	zoneRadius = 10,
	blip = 58,
	color = { r = 255, g = 255, b = 255 }
}
g_JOBS_BY_TYPE = {
	[g_PICKUP_JOB.type] = g_PICKUP_JOB,
	[g_DELIVERY_JOB.type] = g_DELIVERY_JOB,
	[g_EXTORTION_JOB.type] = g_EXTORTION_JOB,
	[g_GROUP_JOB.type] = g_GROUP_JOB
}

g_START_JOB = "start doing job" -- player, jobId
g_STOP_JOB = "stop doing job" -- player, jobId
g_FINISH_JOB = "finish job" -- player, jobId