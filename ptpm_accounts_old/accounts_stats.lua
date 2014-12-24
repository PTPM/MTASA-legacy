-- will need to export functions for getting/setting account data
-- data should be cached here on login, and applied to the database on quit
-- suggest: 
--	getPlayerAccountData(player) - returns all data associated with the account being used by player in a table
--	getPlayerAccountData(player,dataName) - returns specific data from the account being used by player (eg: getPlayerAccountData(player,"kills"))
--	setPlayerAccountData(player,data) - data is a table in the format '["dataName"] = value'


function loadStats(thePlayer, result)
	playerStats[thePlayer] = {}
	
	local row = mysql_fetch_assoc(result)
	
	if row then
		for _,r in mysql_fields(result) do	
			if row[r["name"]] ~= mysql_null() then
			--	outputDebugString("loadstats: "..tostring(r["name"]) .. " = " .. row[r["name"]])
			
				if needsLoading(r["name"]) then			
					playerStats[thePlayer][r["name"]] = row[r["name"]]
				end
			else
				if needsLoading(r["name"]) then		
					playerStats[thePlayer][r["name"]] = defaultValue(r["name"])
				end				
			end
		end
	end
end


function saveStats(thePlayer)
	if not thePlayer or not isElement(thePlayer) then return end
	
	if not playerStats[thePlayer] then return end
	
	local set = ""
	
	for dataName,value in pairs(playerStats[thePlayer]) do
		if dataName ~= "oldUsername" then
			set = set .. (#set > 0 and "," or "") .. "`" ..dataName.. "` = '" ..value.. "'"
		end	
	--	outputDebugString("Saving "..dataName.. " = ".. tostring(value),thePlayer)
	end
	
	if #set > 0 then
		local result = mysql_query(db,"UPDATE `users` SET "..set.." WHERE `username` = '"..(playerStats[thePlayer]["oldUsername"] or playerStats[thePlayer]["username"]).."'")
		
		playerStats[thePlayer]["oldUsername"] = nil
		
		if result then
			mysql_free_result(result)
		else
			outputDebugString("Error saving stats ("..getPlayerName(thePlayer).."): (" .. mysql_errno(db) .. ") " .. mysql_error(db))
		end
	end
end
addCommandHandler("ptpmsave",saveStats)


function needsLoading(stat)
	if --[[stat == "username" or]] stat == "password" or stat == "serial" or stat == "ip" then
		return false
	end
	
	return true
end


function defaultValue(name)
	if name == "kills" then return 0
	elseif name == "admin" then return 0
	elseif name == "deaths" then return 0
	elseif name == "pmCount" then return 0
	elseif name == "pmKills" then return 0
	elseif name == "pmVictory" then return 0
	elseif name == "muted" then return 0
	end
end


function getPlayerAccountData(thePlayer, data)
	if not thePlayer or not isElement(thePlayer) then return nil end
	
	if not playerStats[thePlayer] then return false end

	if data then
		if playerStats[thePlayer][data] then 
			return playerStats[thePlayer][data]
		else
			return false
		end
	end
	
	return playerStats[thePlayer]
end


function setPlayerAccountData(thePlayer, data)
	if not thePlayer or not isElement(thePlayer) then return nil end
	
	if not playerStats[thePlayer] then return false end
	
	if type(data) ~= "table" then return false end
	
	for dataName,value in pairs(data) do
		if type(value) == "string" and value == ">+1" then
			playerStats[thePlayer][dataName] = (playerStats[thePlayer][dataName] or defaultValue[dataName]) + 1
		else
			if dataName == "username" then
				playerStats[thePlayer]["oldUsername"] = playerStats[thePlayer][dataName]
			end
			playerStats[thePlayer][dataName] = value
		end
	end
	
	return true
end


addEventHandler("onPlayerQuit",root,
	function()
		if playerStats[source] then
			logoutPlayer(source)
		end
	end
)