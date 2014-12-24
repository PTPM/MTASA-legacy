playerStats = {}

-- using MTA-MySQL (http://wiki.mtasa.com/wiki/Modules/MTA-MySQL)

--	Use the following parameters in the connect table:
--  host,user,password,database
local connect = {"", "", "", ""}

db = mysql_connect ( connect[1], connect[2], connect[3], connect[4] )

setTimer(
	function()
		local result = mysql_query(db, "SELECT 1+1") -- ping of some sort
		if not result then -- reconnect, the server may drop the connection after so many hours
			db = mysql_connect ( connect[1], connect[2], connect[3], connect[4] )
			if not db then
				outputDebugString( "Couldn't reconnect!" )
			end
		end		
	end
,30000,0)


addEvent("onPtpmPlayerLogin",false)
addEvent("onPtpmPlayerRegister",false)


addEventHandler("onResourceStart",resourceRoot,
	function()
		if ( not db ) then
			outputDebugString("Unable to connect to the MySQL server.")
		else
			local result = mysql_query(db, "CREATE TABLE IF NOT EXISTS users ( username varchar(22), password varchar(128), serial varchar(100), ip varchar(15), admin TINYINT UNSIGNED, kills INT UNSIGNED, deaths INT UNSIGNED, pmCount INT UNSIGNED, pmKills INT UNSIGNED, pmVictory INT UNSIGNED, muted TINYINT UNSIGNED )")
			
			if result then mysql_free_result(result) end
			
			outputDebugString("Connected to the MySQL server.")
		end
	end
)


addEventHandler("onResourceStop",resourceRoot,
	function()
		if db then
			mysql_close(db)
		end
	end
)


	-- expected columns:
	-- [1]			[2]						[3]					[4]			[5]					[6]
	-- username, 	encrypted password, 	password length, 	serial, 	save login data?, 	ip
-- passlength can just be faked with an 8 character star string, exact length isnt needed
-- save should probably be automatic 



function registerPlayer(thePlayer,username,password)
	if not db then return end

	if not thePlayer or not isElement(thePlayer) then
		return
	end
	
	if not username or #username < 3 then
		outputChatBox("Username must be at least 3 characters long.",thePlayer)
		return
	end
	
	if not password or #password < 5 then
		outputChatBox("Password must be at least 5 characters long.",thePlayer)
		return
	end
	
	username = mysql_escape_string(db, username)
	
	-- check the account doesnt exist
	local result = mysql_query(db, "SELECT username FROM users WHERE username = '"..username.."'")
	
	if result then
		if mysql_num_rows(result) > 0 then
			outputChatBox("An account already exists with that username.",thePlayer)
			mysql_free_result(result)
			return
		end
		mysql_free_result(result)
	else
		outputDebugString("Error executing user check query: (" .. mysql_errno(db) .. ") " .. mysql_error(db))
	end
	
	if createPlayerAccount(thePlayer, username, password) then
		-- success
		return loginPlayerAccount(thePlayer, username, password)
	end
	return false
end
addCommandHandler("register",registerPlayer)


function createPlayerAccount(thePlayer, username, password)
	local result = mysql_query(db, "INSERT INTO `users` (username, password, serial, ip) VALUES ('"..username.."', '"..password.."', '"..getPlayerSerial(thePlayer).."', '"..getPlayerIP(thePlayer).."')")

	if result then
		-- registered
	--	outputChatBox("Registered",thePlayer)
		
		mysql_free_result(result)
		
		triggerEvent("onPtpmPlayerRegister",thePlayer,username)
		triggerClientEvent(thePlayer,"onClientPtpmPlayerRegister",thePlayer)		
		
		return true
	else
	--	outputChatBox("register failed",thePlayer)
		-- failed
		
		outputDebugString("Error executing register query: (" .. mysql_errno(db) .. ") " .. mysql_error(db))
		
		return
	end
end


function loginPlayer(thePlayer, username, password)
	if not db then return end

	if not thePlayer or not isElement(thePlayer) then
		return
	end
	
	if not username then return end
	
	if not password then return end
	
	username = mysql_escape_string(db, username)	
	
	return loginPlayerAccount(thePlayer, username, password)
end


function autoLoginPlayer( thePlayer )
	if not db then return end

	local result = mysql_query(db, "SELECT username,password FROM users WHERE serial = '" .. getPlayerSerial( thePlayer ) .."' AND ip = '" .. getPlayerIP( thePlayer ) .."'")
	
	if result then
		if mysql_num_rows(result) > 0 then
			if loginPlayerAccount( thePlayer, mysql_result ( result, 1, 1 ), mysql_result ( result, 1, 2 ) ) then
				return true
			end
		end
		
		mysql_free_result(result)
	else
		outputDebugString("Error executing autologin query: (" .. mysql_errno(db) .. ") " .. mysql_error(db))
	end	
	
	return
end


function loginPlayerAccount(thePlayer, username, password)
	local result = mysql_query(db, "SELECT * FROM users WHERE username = '" .. username .."' AND password = '" .. password .."'")
	
	if result then
		if mysql_num_rows(result) > 0 then
			--logged in
		--	outputChatBox("login",thePlayer)

			loadStats(thePlayer,result)
			
			triggerEvent("onPtpmPlayerLogin",thePlayer,username)
			triggerClientEvent(thePlayer,"onClientPtpmPlayerLogin",thePlayer)
						
			mysql_free_result(result)
			return true
		else
			-- failed
		--	outputChatBox("login failed",thePlayer)
			
			mysql_free_result(result)
			return
		end
	else
		-- failed
	--	outputChatBox("login failed",thePlayer)
			
		outputDebugString("Error executing login query: (" .. mysql_errno(db) .. ") " .. mysql_error(db))
			
		return
	end
end


function logoutPlayer(thePlayer)
	if not thePlayer or not isElement(thePlayer) then return end

	if playerStats[thePlayer] then
		saveStats(thePlayer)
		playerStats[thePlayer] = nil
	end
end	


addEventHandler("onResourceStop",resourceRoot,
	function()
		for _,p in ipairs(getElementsByType("player")) do
			logoutPlayer(p)
		end
	end
)