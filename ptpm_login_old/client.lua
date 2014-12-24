local colourWhite = tocolor(255,255,255)

local loginGui = nil

addEvent("showLogin",true)


addEventHandler("onClientResourceStart",resourceRoot,
	function()
		-- for relative positioning
		screenX,screenY = guiGetScreenSize()

		if screenY > 600 then
			imageHeight = 269
			imageWidth = 320
		else
			imageHeight = 135
			imageWidth = 160
		end
		
		triggerServerEvent("attemptAutoLogin",localPlayer)
		
		local played = xmlLoadFile("played.xml")
		if not played then
			played = xmlCreateFile("played.xml","root")
			xmlSaveFile(played)
			setupLogin()
		end
		
		xmlUnloadFile(played)
	end
)


function setupLogin()
	loginGui = {}

	-- disable controls and show the cursor
	showCursor( true )

	-- gui set for guests
	loginGui.textWelcome = guiCreateLabel((screenX / 2) - (320 / 2),(screenY / 2) - 50,320,50,"Welcome to Protect the Prime Minister, "..getPlayerName(localPlayer)..".\nClick the following button to play as a guest, or sign in below.",false)
	guiLabelSetColor(loginGui.textWelcome,200,200,200)
	guiLabelSetVerticalAlign(loginGui.textWelcome,"center")
	guiLabelSetHorizontalAlign(loginGui.textWelcome,"center",true)
	guiSetFont(loginGui.textWelcome,"clear")
	
	loginGui.buttonPlayAsGuest = guiCreateButton((screenX / 2) - (450 / 2),(screenY / 2) + 20,450,35,"Just play!",false)

	-- gui set for registered players
	loginGui.inputUsername = guiCreateEdit(screenX / 2,(screenY / 2) + 75,220,30,getPlayerName(localPlayer),false)
	loginGui.inputPassword = guiCreateEdit(screenX / 2,(screenY / 2) + 115,220,30,"",false)
	
--	local CheckBoxSave = guiCreateCheckBox ( (screenX / 2) - (90 / 2),yOffset + 255,90,35, "Save login", false , false)

	guiEditSetMasked(loginGui.inputPassword,true)
	loginGui.buttonPlayAsMember = guiCreateButton((screenX / 2) - (450 / 2),(screenY / 2) + 170,450,35,"Sign in",false)
	loginGui.buttonRegister = guiCreateButton((screenX / 2) - (450 / 2),(screenY / 2) + 220,450,35,"Register",false)	
	
	setAlpha(0)
	
	-- maybe add Guest status to /pinfo
	addEventHandler ( "onClientGUIClick", loginGui.buttonPlayAsGuest, removeLogin, false)
	addEventHandler ( "onClientGUIClick", loginGui.buttonPlayAsMember, attemptLogin, false)
	addEventHandler ( "onClientGUIClick", loginGui.buttonRegister, attemptRegister, false)	
	
	fadeCamera(false,1.0)
	
	if loginGui.timer then
		killTimer(loginGui.timer)
		loginGui.timer = nil
	end
	
	loginGui.timer = setTimer(	
		function()	
			addEventHandler("onClientRender",root,drawLogin)
			
			loginGui.timer = nil
			
			setAlpha(1)
			
			guiSetInputEnabled(true)
		end,
	900,1)
	
	--exports.ptpm:toggleClassSelectionInterface(false)
end
addEventHandler("showLogin",root,setupLogin)



function drawLogin()
	dxDrawImage((screenX / 2) - (imageWidth / 2),(screenY / 2) - 50 - imageHeight - 10,imageWidth,imageHeight,"images/ptpm-default.png")
	
	dxDrawText("username",screenX / 2 - 220,(screenY / 2) + 60,(screenX / 2) - 10,(screenY / 2) + 60 + 50,colourWhite,2,"clear","right","center",false,false,false)
	dxDrawText("password",screenX / 2 - 220,(screenY / 2) + 100,(screenX / 2) - 10,(screenY / 2) + 100 + 50,colourWhite,2,"clear","right","center",false,false,false)
end

addCommandHandler("ptpmlogin",setupLogin)
bindKey("l","down",
	function()
		if loginGui then
			removeLogin()
		else
			setupLogin()
		end
	end
)


function removeLogin()
	if not loginGui then return end

	if loginGui.timer then 
		killTimer(loginGui.timer)
		loginGui.timer = nil
	else
		removeEventHandler("onClientRender",root,drawLogin)		
	end
	
	fadeCamera(true,1.0)
	
	destroyLogin()
	
	guiSetInputEnabled(false)
	
	showCursor(false,false)
	
	--exports.ptpm:toggleClassSelectionInterface(true)
end
addEventHandler("onClientPtpmPlayerLogin",root,removeLogin)
addEventHandler("onClientPtpmPlayerRegister",root,removeLogin)


function destroyLogin()
	guiSetVisible(loginGui.textWelcome,false)
	guiSetVisible(loginGui.buttonPlayAsGuest,false)
	guiSetVisible(loginGui.inputUsername,false)
	guiSetVisible(loginGui.inputPassword,false)
	guiSetVisible(loginGui.buttonPlayAsMember,false)
	guiSetVisible(loginGui.buttonRegister,false)
	
	loginGui = nil
end


function setAlpha(alpha)
	guiSetAlpha(loginGui.textWelcome,alpha)
	guiSetAlpha(loginGui.buttonPlayAsGuest,alpha)
	guiSetAlpha(loginGui.inputUsername,alpha)
	guiSetAlpha(loginGui.inputPassword,alpha)
	guiSetAlpha(loginGui.buttonPlayAsMember,alpha)
	guiSetAlpha(loginGui.buttonRegister,alpha)
end


function attemptLogin()
	local username = guiGetText( loginGui.inputUsername )
	local password = guiGetText( loginGui.inputPassword )
	
	if checkInputs(username,password) then
		triggerServerEvent ( "attemptLogin", localPlayer , username, md5(password) )
	end
end


function attemptRegister()
	local username = guiGetText( loginGui.inputUsername )
	local password = guiGetText( loginGui.inputPassword )
	
	if checkInputs(username,password) then
		triggerServerEvent ( "attemptRegister", localPlayer , username, md5(password) )
	end
end


function checkInputs(username,password)
	if username and password and #username > 2 and #password > 4 then
		return true
	elseif username and #username < 3 then
		outputChatBox("Username must be at least 3 characters long.")
	elseif password and #password < 5 then
		outputChatBox("Password must be at least 5 characters long.")
	else
		outputChatBox("Please enter a username and password.")
	end
	
	return false
end


addEventHandler("onClientResourceStart",root,
	function(res)
		if getResourceName(res) == "ptpm_accounts" then
			addEventHandler("onClientPtpmPlayerLogin",root,removeLogin)
			addEventHandler("onClientPtpmPlayerRegister",root,removeLogin)
		end
	end
)

addEventHandler("onClientResourceStop",root,
	function(res)
		if getResourceName(res) == "ptpm_accounts" then
			removeEventHandler("onClientPtpmPlayerLogin",root,removeLogin)
			removeEventHandler("onClientPtpmPlayerRegister",root,removeLogin)
		end
	end
)