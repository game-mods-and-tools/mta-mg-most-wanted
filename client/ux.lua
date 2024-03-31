local currentJobs = {}
local deliveryTarget = nil
local showProgressBar = false
local progressBarProgress = 0
local money = {
	total = 0,
	quota = 0
}
local role = g_CRIMINAL_ROLE

local showText = {}
local groupJobAppeared = "groupJobAppeared"
local pickupJobInfo = "pickupJobInfo"
local deliveryJobInfo = "deliveryJobInfo"
local extortionJobInfo = "extortionJobInfo"
local groupJobInfo = "groupJobInfo"
local groupJobNeedsPeople = "groupJobNeedsPeople" -- value is the current people
local copRoleInfo = "copeRoleInfo"
local criminalRoleInfo = "criminalRoleInfo"
local abandonedJob = "abandonedJob"
local endGameInfo = "endGameInfo"

addEvent(g_SHOW_JOB_EVENT, true)
addEventHandler(g_SHOW_JOB_EVENT, resourceRoot, function(id, type, pos)
	local job = g_JOBS_BY_TYPE[type]

	currentJobs[id] = {
		marker = createMarker(pos.x, pos.y, pos.z - 1, "cylinder", job.zoneRadius, job.color.r, job.color.g, job.color.b, 73),
		blip = createBlip(pos.x, pos.y, pos.z, job.blip, 3, 255, 0, 0, 255, 0, job.detectionRadius),
	}

	if type == g_GROUP_JOB.type then
		showText[groupJobAppeared] = true
		setTimer(function() showText[groupJobAppeared] = false end, 3000, 1)
	end
end)

addEvent(g_HIDE_JOB_EVENT, true)
addEventHandler(g_HIDE_JOB_EVENT, resourceRoot, function(id)
	if not currentJobs[id] then return end

	destroyElement(currentJobs[id].marker)
	destroyElement(currentJobs[id].blip)

	currentJobs[id] = nil
end)

addEvent(g_START_JOB_EVENT, true)
addEventHandler(g_START_JOB_EVENT, resourceRoot, function(id, type)
	if type == g_PICKUP_JOB.type then
		showText[pickupJobInfo] = true
	elseif type == g_DELIVERY_JOB.type then
		showText[deliveryJobInfo] = true
	elseif type == g_EXTORTION_JOB.type then
		showText[extortionJobInfo] = true
	elseif type == g_GROUP_JOB.type then
		showText[groupJobInfo] = true
	end
end)

addEvent(g_STOP_JOB_EVENT, true)
addEventHandler(g_STOP_JOB_EVENT, resourceRoot, function(id, type)
	showText[abandonedJob] = true
	setTimer(function() showText[abandonedJob] = false end, 1000, 1)

	if type == g_PICKUP_JOB.type then
		showText[pickupJobInfo] = false
	elseif type == g_DELIVERY_JOB.type then
		showText[deliveryJobInfo] = false
	elseif type == g_EXTORTION_JOB.type then
		showText[extortionJobInfo] = false
	elseif type == g_GROUP_JOB.type then
		showText[groupJobInfo] = false
		showText[groupJobNeedsPeople] = false
	end
end)

addEvent(g_PAUSE_JOB_EVENT)
addEventHandler(g_PAUSE_JOB_EVENT, resourceRoot, function(count)
	showText[groupJobNeedsPeople] = count
end)

addEvent(g_RESUME_JOB_EVENT)
addEventHandler(g_RESUME_JOB_EVENT, resourceRoot, function(count)
	showText[groupJobNeedsPeople] = false
end)

addEvent(g_FINISH_JOB_EVENT, true)
addEventHandler(g_FINISH_JOB_EVENT, resourceRoot, function(id, type)
	playSound("client/lodsofemone.wav")

	if type == g_PICKUP_JOB.type then
		showText[pickupJobInfo] = false
	elseif type == g_DELIVERY_JOB.type then
		showText[deliveryJobInfo] = false
	elseif type == g_EXTORTION_JOB.type then
		showText[extortionJobInfo] = false
	elseif type == g_GROUP_JOB.type then
		showText[groupJobInfo] = false
		showText[groupJobNeedsPeople] = false
	end
end)

addEvent(g_SHOW_DELIVERY_TARGET_EVENT)
addEventHandler(g_SHOW_DELIVERY_TARGET_EVENT, resourceRoot, function(pos)
	deliveryTarget = {
		marker = createMarker(pos.x, pos.y, pos.z - 0.6, "checkpoint", g_DELIVERY_TARGET_SIZE, 255, 0, 0, 50),
		blip = createBlip(pos.x, pos.y, pos.z, 0, 3, 255, 0, 0, 255, 5)
	}
end)

addEvent(g_HIDE_DELIVERY_TARGET_EVENT)
addEventHandler(g_HIDE_DELIVERY_TARGET_EVENT, resourceRoot, function()
	destroyElement(deliveryTarget.marker)
	destroyElement(deliveryTarget.blip)

	deliveryTarget = nil
end)

addEvent(g_SHOW_PROGRESS_BAR_EVENT)
addEventHandler(g_SHOW_PROGRESS_BAR_EVENT, resourceRoot, function()
	showProgressBar = true
end)

addEvent(g_HIDE_PROGRESS_BAR_EVENT)
addEventHandler(g_HIDE_PROGRESS_BAR_EVENT, resourceRoot, function()
	showProgressBar = false
end)

addEvent(g_UPDATE_PROGRESS_BAR_EVENT)
addEventHandler(g_UPDATE_PROGRESS_BAR_EVENT, resourceRoot, function(data)
	progressBarProgress = data.progress
end)

addEvent(g_PLAYER_ROLE_SELECTED_EVENT, true)
addEventHandler(g_PLAYER_ROLE_SELECTED_EVENT, resourceRoot, function(rolee)
	role = rolee

	if role == g_CRIMINAL_ROLE then
		showText[criminalRoleInfo] = true
		setTimer(function() showText[criminalRoleInfo] = false end, 5000, 1)
	else
		showText[copRoleInfo] = true
		setTimer(function() showText[copRoleInfo] = false end, 5000, 1)
	end
end)

addEvent(g_GAME_STATE_UPDATE_EVENT, true)
addEventHandler(g_GAME_STATE_UPDATE_EVENT, resourceRoot, function(data)
	money.total = math.floor(data.money)
	money.quota = math.floor(data.moneyQuota)
end)

addEvent(g_ENDGAME_START_EVENT, true)
addEventHandler(g_ENDGAME_START_EVENT, resourceRoot, function()
	showText[endGameInfo] = true
	setTimer(function() showText[endGameInfo] = false end, 3000, 1)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()

		if showText[criminalRoleInfo] then
			dxDrawBorderedText(0.5,"CRIMINAL", screenWidth / 3 - 100, screenHeight * 0.18,  screenWidth, screenHeight, tocolor(230, 150, 0, 255), 5, "bankgothic")
			dxDrawBorderedText(0.5,"Complete the various jobs available in the city for money.", screenWidth / 3 - 110, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Once the money quota is reached, it's time to escape.", screenWidth / 3 - 85, screenHeight * 0.35 + 50,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			--		dxDrawBorderedText(0.5,"The#1EBEF0 Police#D2D2D2 is out to get you. Evade them at all costs!", screenWidth / 3 - 80, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"The Police is out to get you. Evade them at all costs!", screenWidth / 3 - 80, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
		elseif showText[copRoleInfo] then
			dxDrawBorderedText(0.5,"POLICE", screenWidth / 3, screenHeight * 0.18,  screenWidth, screenHeight, tocolor(30, 190, 240, 255), 5, "bankgothic")
			--		dxDrawBorderedText(0.5,"#DFB300Criminals#D2D2D2 are planning to go on a crime spree.", screenWidth / 3 - 40, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Criminals are planning to go on a crime spree.", screenWidth / 3 - 40, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Once they've stolen enough, they will attempt to skip town.", screenWidth / 3 - 130, screenHeight * 0.35 + 50,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Use any force necessary to eliminate them!", screenWidth / 3 - 20, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
		else
			-- HUD
			dxDrawBorderedText(2,"ESCAPE QUOTA", screenWidth * 0.72, screenHeight * 0.22, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.quota, screenWidth * 0.72, screenHeight * 0.22 + 20, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"TOTAL MONEY", screenWidth * 0.72, screenHeight * 0.22 + 55, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.total, screenWidth * 0.72, screenHeight * 0.22 + 75, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			-- dxDrawBorderedText(2,"MONEY", screenWidth * 0.72, screenHeight * 0.22 + 110, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			-- dxDrawBorderedText(2,"$" .. money.personal, screenWidth * 0.72, screenHeight * 0.22 + 130, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
		end

		if showText[groupJobAppeared] then
			dxDrawBorderedText(0.5,"A heist is being organised somewhere!", screenWidth / 2 - screenWidth / 6, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "arial", center, top, false, false, false, true)
		end

		if showText[pickupJobInfo] then
			dxDrawBorderedText(0.5,"Wait in place. The money is coming.", screenWidth / 2 - screenWidth / 6, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[extortionJobInfo] then
			dxDrawBorderedText(0.5,"Intimidate by honking until you get the money.", screenWidth / 2 - screenWidth / 5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[groupJobNeedsPeople] then
			dxDrawBorderedText(0.5,"You will need " .. (g_GROUP_JOB.minPlayers - showText[groupJobNeedsPeople]) .. " more associate(s) to start this heist.", screenWidth / 2 - screenWidth / 5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[groupJobInfo] then
			dxDrawBorderedText(0.5,"The heist has started!", screenWidth / 2 - screenWidth / 10, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Stay in the area to receive money until everything is gone!", screenWidth / 2 - screenWidth / 4, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[deliveryJobInfo] then
			dxDrawBorderedText(0.5,"Deliver the goods to#3344DB this location#D2D2D2 to get the money.", screenWidth / 2 - screenWidth / 5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			-- destruction
			-- dxDrawBorderedText(0.5,"Destroy the#3344DB evidence#D2D2D2 to get the money.", screenWidth / 2 - screenWidth / 6, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			-- delivery to player
			-- dxDrawBorderedText(0.5,"Get this message to#3344DB <PLAYERNAMEHERE>#D2D2D2 to get the money.", screenWidth / 2 - screenWidth / 4, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		end

		if showText[abandonedJob] then
			dxDrawBorderedText(0.5,"JOB ABANDONED", screenWidth / 2 - screenWidth / 11, screenHeight * 0.2, 800, screenHeight, tocolor(222, 26, 26, 255), 3, "arial", center, top, false, false, false, true)
		end

		-- if g_DELIVERY_JOB then --delivery: contact job target died - cancelled
		--	dxDrawBorderedText(0.5,"DELIVERY CANCELLED", screenWidth / 2 - screenWidth / 9, screenHeight * 0.24, 800, screenHeight, tocolor(222, 26, 26, 255), 3, "arial", center, top, false, false, false, true)
		--	dxDrawBorderedText(0.5,"#DE1A1APLAYERNAMEHERE#D2D2D2 is no longer with us.", screenWidth / 2 - screenWidth / 5, screenHeight * 0.70, 800, screenHeight, tocolor(210, 210, 210, 255), 3, "default-bold", center, top, false, false, false, true)
		-- end


		----idk
		--dxDrawBorderedText(0.5,"PRESS THE NUMBER TO SELECT A PERK", screenWidth / 2 - screenWidth / 6, screenHeight * 0.55,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.3, "sans", center, top, false, false, false, true)
		--
		--guiCreateStaticImage(screenWidth / 2 - 40 - screenWidth / 6, screenHeight * 0.6, 64, 64, "client/fugitive.png", false)
		--dxDrawBorderedText(0.5,"1", screenWidth / 2 - screenWidth / 6 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)
		--
		--guiCreateStaticImage(screenWidth / 2 - 40, screenHeight * 0.6, 64, 64, "client/mechanic.png", false)
		--dxDrawBorderedText(0.5,"2", screenWidth / 2 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)
		--
		--guiCreateStaticImage(screenWidth / 2 - 40 + screenWidth / 6, screenHeight * 0.6, 64, 64, "client/hotshot.png", false)
		--dxDrawBorderedText(0.5,"3", screenWidth / 2 + screenWidth / 6 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)

		if showText[endGameInfo] then
			if role == g_CRIMINAL_ROLE then
				dxDrawBorderedText(0.5,"The money quota has been reached!", screenWidth / 2 - screenWidth / 6, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Evade the#33A5FF police#C8C8C8 until an #2AE500Escape Route#C8C8C8 is ready!", screenWidth / 2 - screenWidth / 4.5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			else
				dxDrawBorderedText(0.5,"The#838383 criminals#C8C8C8 are trying to escape the city!", screenWidth / 2 - screenWidth / 5, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Stop them before they circumvent our roadblocks!", screenWidth / 2 - screenWidth / 4.3, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			end
		end

		--escape route ready
		--dxDrawBorderedText(0.5,"Received several possible#2AE500 Escape Routes#C8C8C8!", screenWidth / 2 - screenWidth / 5.5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		--
		----escape route: more
		--dxDrawBorderedText(0.5,"Additional#2AE500 Escape Routes#C8C8C8 are accessible!", screenWidth / 2 - screenWidth / 5.5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		--
		----escape route: escapee (idk if this is rly needed)
		--dxDrawBorderedText(0.5,"#DFB300PLAYERNAMEHERE#C8C8C8 successfully fled!", screenWidth / 2 - screenWidth / 8, screenHeight * 0.1,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "default-bold", center, top, false, false, false, true)
		--


		if showProgressBar then
			local color = tocolor(255, 255, 255)

			dxDrawRectangle(screenWidth / 2 - 126, screenHeight * 0.85, 252, 27, tocolor(0, 0, 0))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244, 19, tocolor(40, 40, 40))
			dxDrawRectangle(screenWidth / 2 - 122, screenHeight * 0.85 + 4, 244 * progressBarProgress, 19, color)
		end
	end)
end)

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    local outline = (scale or 1) * (1.333333333333334 * (outline or 1))
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top - outline, right - outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top - outline, right + outline, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top + outline, right - outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top + outline, right + outline, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left - outline, top, right - outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left + outline, top, right + outline, bottom, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top - outline, right, bottom - outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text:gsub("#%x%x%x%x%x%x", ""), left, top + outline, right, bottom + outline, tocolor (0, 0, 0, 225), scale, font, alignX, alignY, clip, wordBreak, postGUI, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end

