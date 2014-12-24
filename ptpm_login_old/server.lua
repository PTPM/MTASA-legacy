-- PtPM serverside login script


addEvent("attemptAutoLogin",true)
addEventHandler("attemptAutoLogin",root,
	function()
		if not exports.ptpm_accounts:autoLoginPlayer(client) then
		--	triggerClientEvent(client,"showLogin",client)
			outputChatBox("Couldn't find user account, playing as guest!",client)
		else
			outputChatBox("Welcome back, ".. tostring(exports.ptpm_accounts:getPlayerAccountData(client,"username")) .. "! (automatically logged in)",client)
		end
	end
)


addEvent("attemptLogin",true)
addEventHandler("attemptLogin",root,
	function(username, password)
		if exports.ptpm_accounts:getPlayerAccountData(client,"username") then
			return outputChatBox("You are already logged in.",client)
		end
		
		if not exports.ptpm_accounts:loginPlayer(client, username, password) then
			outputChatBox("Could not log in.",client)
		else
			outputChatBox("Welcome, ".. tostring(exports.ptpm_accounts:getPlayerAccountData(client,"username")) .."!",client)
		end
	end
)



addEvent("attemptRegister",true)
addEventHandler("attemptRegister",root,
	function(username, password)
		local res = exports.ptpm_accounts:registerPlayer(client, username, password)
		
		if res == false then
			outputChatBox("Could not register.",client)
		elseif res == nil then
			outputChatBox("Could not log in.",client)
		end
	end
)


function checkMySerial( thePlayer, command )
    local theSerial = getPlayerSerial( thePlayer )
    if theSerial then
        outputChatBox( "Your serial is: " .. theSerial, thePlayer )
    else
        outputChatBox( "Sorry, you have no serial. =(", thePlayer )
    end
end
addCommandHandler( "serial", checkMySerial )
