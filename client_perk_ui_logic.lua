(function()

local perkAndExplanationUi = nil
local perkAndExplanationCloseAt = 0

addEvent(g_SHOW_PERK_SELECTION_AND_EXPLANATION, true)
addEventHandler(g_SHOW_PERK_SELECTION_AND_EXPLANATION, resourceRoot, function()
	c("g_SHOW_PERK_SELECTION_AND_EXPLANATION")

	showCursor(true)
	perkAndExplanationUi = guiCreateWindow(0.1, 0.1, 0.8, 0.8, "Instructions and Perks", true)
	for i, perk in ipairs({
		g_FUGITIVE_PERK,
		g_MECHANIC_PERK,
		g_HOTSHOT_PERK,
	}) do

		local button = createPerkButton(perkAndExplanationUi, perk, i)
		addEventHandler("onClientGUIClick", button, function()
			c("onClientGUIClick " .. perk.name)
			triggerServerEvent(g_PLAYER_SELECTED_PERK_EVENT, resourceRoot, perk.id)
		end, false)
	end

	-- default select fugitive perk
	triggerServerEvent(g_PLAYER_SELECTED_PERK_EVENT, resourceRoot, g_FUGITIVE_PERK.id)
end)

function createPerkButton(parentElement, perk, position)
	local width = 0.05
	local spacing = 0.1

	guiCreateLabel((spacing + width) * position, 0.55, width, 0.05, perk.description, true, parentElement)
	return guiCreateButton((spacing + width) * position, 0.5, width, 0.05, perk.name, true, parentElement)
end

addEvent(g_START_PERK_SELECTION_AND_EXPLANATION_TIMER, true)
addEventHandler(g_START_PERK_SELECTION_AND_EXPLANATION_TIMER, resourceRoot, function(timeToClose)
	c("g_START_PERK_SELECTION_AND_EXPLANATION_TIMER, time: " .. timeToClose)

	perkAndExplanationCloseAt = nowMs() + timeToClose
end)

addEvent(g_CLOSE_PERK_SELECTION_AND_EXPLANATION, true)
addEventHandler(g_CLOSE_PERK_SELECTION_AND_EXPLANATION, resourceRoot, function()
	c("g_CLOSE_PERK_SELECTION_AND_EXPLANATION")

	showCursor(false)
	guiSetVisible(perkAndExplanationUi, false)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, function()
		local now = nowMs()
		local screenWidth, screenHeight = guiGetScreenSize()

		if perkAndExplanationCloseAt > now then
			local timeLeft = perkAndExplanationCloseAt - now
			dxDrawText(timeLeft / 1000, screenWidth * 0.65 + 2, screenHeight * 0.25 - 2, screenWidth, screenHeight, tocolor(255, 255, 255, 255), 1, "bankgothic")
			-- incorporate in gui window somehow
		end
	end)
end)

function nowMs()
	return getRealTime().timestamp * 1000
end

end)()

function c(...)
	print("CLIENT", ...)
end