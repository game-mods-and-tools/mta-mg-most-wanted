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
local roleInfo = "roleInfo"
local abandonedJob = "abandonedJob"
local endGameInfo = "endGameInfo"
local crimeReported = "crimeReported"
local endGameInfo = "endGameInfo"
local endEndGameInfo = "endEndGameInfo"
local endEndGameScrollTimer = nil

addEvent(g_SHOW_JOB_EVENT, true)
addEventHandler(g_SHOW_JOB_EVENT, resourceRoot, function(id, type, pos)
	local job = g_JOBS_BY_TYPE[type]

	currentJobs[id] = {
		marker = createMarker(pos.x, pos.y, pos.z - 1, "cylinder", job.zoneRadius, job.color.r, job.color.g, job.color.b, 73),
		blip = createBlip(pos.x, pos.y, pos.z, job.blip, 1, 255, 0, 0, 255, 0, job.detectionRadius),
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
addEventHandler(g_FINISH_JOB_EVENT, resourceRoot, function(id, type, reportedCriminals)
	if role == g_CRIMINAL_ROLE then
		playSound("client/lodsofemone.wav")

		for _, player in pairs(reportedCriminals) do
			if player == localPlayer then
				showText[crimeReported] = true
				setTimer(function() showText[crimeReported] = false end, 3000, 1)
				break
			end
		end

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
	elseif role == g_POLICE_ROLE then
		-- lets police track criminals when they finish a job
		for _, criminal in pairs(reportedCriminals) do
			local blip = createBlipAttachedTo(criminal, 0, 2, 200, 125, 0, 255, 6, 80085)
			setTimer(function() destroyElement(blip) end, 5000, 1)
		end

		if #reportedCriminals > 0 then
			showText[crimeReported] = true
			setTimer(function() showText[crimeReported] = false end, 3000, 1)
		end
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

	showText[roleInfo] = true
	setTimer(function() showText[roleInfo] = false end, 5000, 1)
end)

addEvent(g_MONEY_UPDATE_EVENT, true)
addEventHandler(g_MONEY_UPDATE_EVENT, resourceRoot, function(data)
	money.total = math.floor(data.money)
	money.quota = math.floor(data.moneyQuota)
end)

addEvent(g_GAME_STATE_UPDATE_EVENT, true)
addEventHandler(g_GAME_STATE_UPDATE_EVENT, resourceRoot, function(state)
	if state == g_ENDGAME_STATE then
		showText[endGameInfo] = true
		setTimer(function() showText[endGameInfo] = false end, 3000, 1)
	elseif state == g_ENDENDGAME_STATE then
		showText[endEndGameInfo] = true
		playSound("client/pag.mp3")
		endEndGameScrollTimer = setTimer(function() showText[endEndGameInfo] = false end, 10000, 1)
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()
		local screenWidth, screenHeight = guiGetScreenSize()

		-- fullscreen ui
		if showText[roleInfo] then
			if role == g_CRIMINAL_ROLE then
				dxDrawBorderedText(0.5,"CRIMINAL", screenWidth / 2 - 400, screenHeight * 0.18,  screenWidth, screenHeight, tocolor(180, 110, 0, 255), 5, "bankgothic")
				dxDrawBorderedText(0.5,"Complete the various jobs available in the city for money.", screenWidth / 2 - 410, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Once the money quota is reached, it's time to escape.", screenWidth / 2 - 385, screenHeight * 0.35 + 50,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				--		dxDrawBorderedText(0.5,"The#1EBEF0 Police#D2D2D2 is out to get you. Evade them at all costs!", screenWidth / 2 - 380, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"The Police is out to get you. Evade them at all costs!", screenWidth / 2 - 380, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)

				-- perk ui, doesnt do anything
				-- dxDrawBorderedText(0.5,"PRESS THE NUMBER TO SELECT A PERK", screenWidth / 2 - screenWidth / 6, screenHeight * 0.55,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.3, "sans", center, top, false, false, false, true)

				-- guiCreateStaticImage(screenWidth / 2 - 40 - screenWidth / 6, screenHeight * 0.6, 64, 64, "client/fugitive.png", false)
				-- dxDrawBorderedText(0.5,"1", screenWidth / 2 - screenWidth / 6 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)

				-- guiCreateStaticImage(screenWidth / 2 - 40, screenHeight * 0.6, 64, 64, "client/mechanic.png", false)
				-- dxDrawBorderedText(0.5,"2", screenWidth / 2 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)

				-- guiCreateStaticImage(screenWidth / 2 - 40 + screenWidth / 6, screenHeight * 0.6, 64, 64, "client/hotshot.png", false)
				-- dxDrawBorderedText(0.5,"3",				screenWidth / 2 + screenWidth / 6 - 15, screenHeight * 0.6 + 80,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "sans", center, top, false, false, false, true)
			elseif role == g_POLICE_ROLE then
				dxDrawBorderedText(0.5,"POLICE", screenWidth / 2 - 330, screenHeight * 0.18,  screenWidth, screenHeight, tocolor(30, 190, 240, 255), 5, "bankgothic")
				--		dxDrawBorderedText(0.5,"#DFB300Criminals#D2D2D2 are planning to go on a crime spree.", screenWidth / 2 - 40, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Criminals are planning to go on a crime spree.", screenWidth / 2 - 350, screenHeight * 0.35,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Once they've stolen enough, they will attempt to skip town.", screenWidth / 2 - 440, screenHeight * 0.35 + 50,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Deploy your firearm by pressing the secondary fire key.", screenWidth / 2 - 400, screenHeight * 0.35 + 120,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Use any force necessary to eliminate them!", screenWidth / 2 - 330, screenHeight * 0.35 + 170,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.5, "sans", center, top, false, false, false, true)
			end
			return -- dont want to show anything else
		elseif showText[endGameInfo] then
			if role == g_CRIMINAL_ROLE then
				dxDrawBorderedText(0.5,"QUOTA REACHED!!!", screenWidth / 2 - 250, screenHeight * 0.25,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 4, "arial", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Evade the#33A5FF police#C8C8C8 until an #FFDC00escape route#C8C8C8 is ready!", screenWidth / 2 - 380, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"There's also still more crimes to commit.", screenWidth / 2 - 340, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			elseif role == g_POLICE_ROLE then
				dxDrawBorderedText(0.5,"The#C87D00 criminals#C8C8C8 are trying to escape the city!", screenWidth / 2 - 380, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
				dxDrawBorderedText(0.5,"Stop them before they circumvent our roadblocks!", screenWidth / 2 - 440, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			end
		end

		-- hud
		if role == g_CRIMINAL_ROLE then
			-- HUD (crim)
			dxDrawBorderedText(2,"ESCAPE QUOTA", screenWidth * 0.72, screenHeight * 0.22, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.quota, screenWidth * 0.72, screenHeight * 0.22 + 20, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"TOTAL MONEY", screenWidth * 0.72, screenHeight * 0.22 + 55, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.total, screenWidth * 0.72, screenHeight * 0.22 + 75, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			-- dxDrawBorderedText(2,"YOUR MONEY", screenWidth * 0.72, screenHeight * 0.22 + 110, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			-- dxDrawBorderedText(2,"$" .. money.personal, screenWidth * 0.72, screenHeight * 0.22 + 130, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
		elseif role == g_POLICE_ROLE then
			-- HUD (cop)
			dxDrawBorderedText(2,"ESTIMATED QUOTA", screenWidth * 0.72, screenHeight * 0.22, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.quota, screenWidth * 0.72, screenHeight * 0.22 + 20, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"MONEY STOLEN", screenWidth * 0.72, screenHeight * 0.22 + 55, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
			dxDrawBorderedText(2,"$" .. money.total, screenWidth * 0.72, screenHeight * 0.22 + 75, screenWidth, screenHeight, tocolor(190, 222, 222, 255), 0.9, "bankgothic", center, top, false, false, false, true)
		end

		-- top middle ui
		if showText[crimeReported] then
			if role == g_CRIMINAL_ROLE then
				dxDrawBorderedText(0.5,"YOUR CRIME WAS REPORTED!", screenWidth / 2 - 320, screenHeight * 0.18, 800, screenHeight, tocolor(222, 26, 26, 255), 3, "arial", center, top, false, false, false, true)
			elseif role == g_POLICE_ROLE then
				dxDrawBorderedText(0.5,"A #C87D00criminal#D2D2D2 was spotted fleeing a crime!", screenWidth / 2 - 320, screenHeight * 0.75 + 40, 800, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			end
		elseif showText[abandonedJob] then
			dxDrawBorderedText(0.5,"JOB ABANDONED", screenWidth / 2 - 180, screenHeight * 0.35, 800, screenHeight, tocolor(222, 26, 26, 255), 3, "arial", center, top, false, false, false, true)
		end

		-- slightly under top middle ui
		if showText[groupJobAppeared] then
			dxDrawBorderedText(0.5,"A heist is being organised somewhere!", screenWidth / 2 - 320, screenHeight * 0.3,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "arial", center, top, false, false, false, true)
		end

		if showText[endEndGameInfo] then
			local timeLeft, _, totalTime = getTimerDetails(endEndGameScrollTimer)
			if timeLeft then
				if role == g_CRIMINAL_ROLE then
					local offset = (screenWidth + 1500) * (totalTime - timeLeft) / totalTime
					dxDrawText("WOULD YOU LOOK AT THAT......YOU HAVE FARMED LOS SANTOS THOROUGHLY WELL......GO SLAUGHTER SOME PIGS!!!  -BIG PIG", screenWidth - offset, screenHeight * 0.95,  screenWidth, screenHeight, tocolor(40, 255, 10, 250), 2, "default", center, top, false, false, false, true)
					dxDrawText("WOULD YOU LOOK AT THAT......YOU HAVE FARMED LOS SANTOS THOROUGHLY WELL......GO SLAUGHTER SOME PIGS!!!  -BIG PIG", screenWidth + 2 - offset, screenHeight * 0.95 + 2,  screenWidth, screenHeight, tocolor(200, 255, 200, 100), 2, "default", center, top, false, false, false, true)
					dxDrawText("WOULD YOU LOOK AT THAT......YOU HAVE FARMED LOS SANTOS THOROUGHLY WELL......GO SLAUGHTER SOME PIGS!!!  -BIG PIG", screenWidth - 2 - offset, screenHeight * 0.95 + 2,  screenWidth, screenHeight, tocolor(200, 255, 200, 100), 2, "default", center, top, false, false, false, true)
				elseif role == g_POLICE_ROLE then
					local offset = (screenWidth + 1200) * (totalTime - timeLeft) / totalTime
					dxDrawText("HAHAHAHA.......STUPID PIGS......YOU ARE ABOUT TO BE TURNED INTO BACON BITS!!!  -BIG PIG", screenWidth - offset, screenHeight * 0.95,  screenWidth, screenHeight, tocolor(40, 255, 10, 250), 2, "default", center, top, false, false, false, true)
					dxDrawText("HAHAHAHA.......STUPID PIGS......YOU ARE ABOUT TO BE TURNED INTO BACON BITS!!!  -BIG PIG", screenWidth + 2 - offset, screenHeight * 0.95 + 2,  screenWidth, screenHeight, tocolor(200, 255, 200, 100), 2, "default", center, top, false, false, false, true)
					dxDrawText("HAHAHAHA.......STUPID PIGS......YOU ARE ABOUT TO BE TURNED INTO BACON BITS!!!  -BIG PIG", screenWidth - 2 - offset, screenHeight * 0.95 + 2,  screenWidth, screenHeight, tocolor(200, 255, 200, 100), 2, "default", center, top, false, false, false, true)
				end
			end
		elseif showText[pickupJobInfo] then
			dxDrawBorderedText(0.5,"Wait in place. The money is coming.", screenWidth / 2 - 320, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[extortionJobInfo] then
			dxDrawBorderedText(0.5,"Intimidate by honking until you get the money.", screenWidth / 2 - 380, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[groupJobNeedsPeople] then
			dxDrawBorderedText(0.5,"You will need " .. (g_GROUP_JOB.minPlayers - showText[groupJobNeedsPeople]) .. " more associate(s) to start this heist.", screenWidth / 2 - 380, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[groupJobInfo] then
			dxDrawBorderedText(0.5,"The heist has started!", screenWidth / 2 - 200, screenHeight * 0.75,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			dxDrawBorderedText(0.5,"Stay in the area to receive money when the job is completed!", screenWidth / 2 - 440, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		elseif showText[deliveryJobInfo] then
			dxDrawBorderedText(0.5,"Deliver the goods to this#DE1A1A location#D2D2D2 to get the money.", screenWidth / 2 - 390, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			-- destruction
			-- dxDrawBorderedText(0.5,"Destroy the#DE1A1A evidence#D2D2D2 to get the money.", screenWidth / 2 - screenWidth / 6, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
			-- delivery to player
			-- dxDrawBorderedText(0.5,"Get this message to#DE1A1A <PLAYERNAMEHERE>#D2D2D2 to get the money.", screenWidth / 2 - screenWidth / 4, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		end

		-- if g_DELIVERY_JOB then --delivery: contact job target died - cancelled
		--	dxDrawBorderedText(0.5,"DELIVERY CANCELLED", screenWidth / 2 - screenWidth / 9, screenHeight * 0.24, 800, screenHeight, tocolor(222, 26, 26, 255), 3, "arial", center, top, false, false, false, true)
		--	dxDrawBorderedText(0.5,"#DE1A1APLAYERNAMEHERE#D2D2D2 is no longer with us.", screenWidth / 2 - screenWidth / 5, screenHeight * 0.70, 800, screenHeight, tocolor(210, 210, 210, 255), 3, "default-bold", center, top, false, false, false, true)
		-- end

		--escape route ready
		--dxDrawBorderedText(0.5,"Received several possible#FFDC00 escape routes#C8C8C8!", screenWidth / 2 - screenWidth / 5.5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		--
		----escape route: more
		--dxDrawBorderedText(0.5,"Additional#FFDC00 escape routes#C8C8C8 are accessible!", screenWidth / 2 - screenWidth / 5.5, screenHeight * 0.75 + 40,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2.8, "default-bold", center, top, false, false, false, true)
		--
		----escape route: escapee (idk if this is rly needed)
		--dxDrawBorderedText(0.5,"#DFB300PLAYERNAMEHERE#C8C8C8 successfully fled!", screenWidth / 2 - screenWidth / 8, screenHeight * 0.1,  screenWidth, screenHeight, tocolor(210, 210, 210, 255), 2, "default-bold", center, top, false, false, false, true)
		--

		-- slightly under bottom middle ui
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

