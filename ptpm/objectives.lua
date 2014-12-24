﻿addEvent( "onObjectiveEnter", false )
addEventHandler( "onObjectiveEnter", root,
	function( thePlayer )
		if classes[getPlayerClassID( thePlayer )].type == "pm" then
			local objective = getElementParent( source )
			
			if objective == data.objectives.activeObjective then
				data.objectives.pmOnObjective = true
				
				data.objectives[objective].enterTime = getTickCount()
				
				for _, p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) then
						-- if theyre a good guy
						if getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] then
							drawStaticTextToScreen( "draw", p, "objText", "Defend checkpoint for " .. data.objectives[objective].time/1000 .. " seconds.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colourImportant, 1, "clear", "top", "center" )
							drawStaticTextToScreen( "draw", p, "objDesc", "Objective description:\n" .. data.objectives[objective].desc, "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colourImportant, 1, "clear", "top", "center")					
						end
					end
				end
			end
		end		
	end
)


addEvent( "onObjectiveLeave", false )
addEventHandler( "onObjectiveLeave", root,
	function( thePlayer )
		if classes[getPlayerClassID( thePlayer )].type == "pm" then
			local objective = getElementParent( source )
			
			if objective == data.objectives.activeObjective then
				data.objectives.pmOnObjective = nil
				
				data.objectives[objective].enterTime = nil
				
				for _,p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) then
						-- if theyre a good guy
						if getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] then
							clearObjectiveTextFor( p )
						end
					end
				end
			end
		end		
	end
)


function checkObjectives( players, tick )
	if not data.roundEnded and currentPM and data.objectives.pmOnObjective then
		if tick - data.objectives[data.objectives.activeObjective].enterTime < data.objectives[data.objectives.activeObjective].time then
			for _, p in ipairs( players ) do
				if p and isElement( p ) then
					if getPlayerClassID(p) and teams["goodGuys"][classes[getPlayerClassID(p)].type] == true then
						drawStaticTextToScreen( "update", p, "objText", "Defend checkpoint for " .. math.floor((data.objectives[data.objectives.activeObjective].time - (tick - data.objectives[data.objectives.activeObjective].enterTime))/1000) .. " seconds.", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colourImportant, 1, "clear", "top", "center" )				
					end
				end
			end
		else
			for _, p in ipairs( players ) do
				if p and isElement( p ) then
					if getPlayerClassID(p) and teams["goodGuys"][classes[getPlayerClassID(p)].type] == true then
						clearObjectiveTextFor( p )	
					end
				end
			end	
			
			data.objectives.finished = data.objectives.finished + 1
			
			if options.objectivesToFinish == data.objectives.finished then
				everyoneViewsBody( currentPM, currentPM, getElementInterior( currentPM ) )
			
				sendGameText( root, "The Prime Minister completed objectives!", 7000, classColours["pm"], nil, 1.4, nil, nil, 3 )
				
				if isRunning( "ptpm_accounts" ) then
					local pmvictory = exports.ptpm_accounts:getPlayerStat( currentPM, "pmvictory" ) or 0
					exports.ptpm_accounts:setPlayerStat( currentPM, "pmvictory", pmvictory + 1 )
					
					local players = getElementsByType( "player" )
					for _, p in ipairs( players ) do
						if p and isElement( p ) and isPlayerActive( p ) then
							local classID = getPlayerClassID( p )
							if classID then
								if classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
									local roundswon = exports.ptpm_accounts:getPlayerStat( p, "roundswon" ) or 0
									exports.ptpm_accounts:setPlayerStat( p, "roundswon", roundswon + 1 )
								end
							end
						end
					end
				end
				
				data.roundEnded = true
				options.endGamePrepareTimer = setTimer( endGame, 3000, 1 )
			else
				if tableSize( data.objectives ) == 1 then -- there is less objectives in map file than required to pass map
					everyoneViewsBody( currentPM, currentPM, getElementInterior( currentPM ) )
				
					sendGameText( root, "The Prime Minister completed objectives!", 7000, classColours["pm"], nil, 1.4, nil, nil, 3 )
					
					if isRunning( "ptpm_accounts" ) then
						local pmvictory = exports.ptpm_accounts:getPlayerStat( currentPM, "pmvictory" ) or 0
						exports.ptpm_accounts:setPlayerStat( currentPM, "pmvictory", pmvictory + 1 )
						
						local players = getElementsByType( "player" )
						for _, p in ipairs( players ) do
							if p and isElement( p ) and isPlayerActive( p ) then
								local classID = getPlayerClassID( p )
								if classID then
									if classes[classID].type == "pm" or classes[classID].type == "bodyguard" or classes[classID].type == "police" then
										local roundswon = exports.ptpm_accounts:getPlayerStat( p, "roundswon" ) or 0
										exports.ptpm_accounts:setPlayerStat( p, "roundswon", roundswon + 1 )
									end
								end
							end
						end
					end
					
					data.roundEnded = true
					options.endGamePrepareTimer = setTimer( endGame, 3000, 1 )
				else
					setupNewObjective()
				end
			end
			data.objectives.pmOnObjective = nil
		end
	end	
end


function clearObjectiveTextFor( thePlayer )
	drawStaticTextToScreen( "delete", thePlayer, "objText" )
	drawStaticTextToScreen( "delete", thePlayer, "objDesc" )	
end


function setupObjectiveTextFor( thePlayer )
	drawStaticTextToScreen( "draw", thePlayer, "objText", "", "screenX*0.775", "screenY*0.28", "screenX*0.179", 40, colourImportant, 1, "clear", "top", "center" )
	drawStaticTextToScreen( "draw", thePlayer, "objDesc", "", "screenX*0.775", "screenY*0.28+40", "screenX*0.179", 120, colourImportant, 1, "clear", "top", "center")					
end


function setupActiveObjectiveFor( thePlayer )
	if data and data.objectives.activeObjective and data.objectives[data.objectives.activeObjective] then
		if not getPlayerClassID( thePlayer ) or classes[getPlayerClassID( thePlayer )].type == "psycho" then return end
		
		local desc = data.objectives[data.objectives.activeObjective].desc or "-NO DESCRIPTION-"
		
		sendGameText( thePlayer, "PM Objective: " .. desc .. "\nObjectives left: " .. (options.objectivesToFinish - data.objectives.finished), 10000, sampTextdrawColours.w, nil, 1.2, nil, nil, 2 )
		
		setElementVisibleTo( data.objectives[data.objectives.activeObjective].blip, thePlayer, true )
		setElementVisibleTo( data.objectives[data.objectives.activeObjective].marker, thePlayer, true )
	end
end


function setupNewObjective()
	if data.objectives.activeObjective then
		local removeID
		
		for i=1, #data.objectiveRandomizer, 1 do
			if data.objectiveRandomizer[i] == data.objectives.activeObjective then
				removeID = i
				break
			end
		end
		
		table.remove(data.objectiveRandomizer,removeID)
		
		destroyElement( data.objectives.activeObjective )
		
		data.objectives[data.objectives.activeObjective] = nil
	end
	
	local randomObjective = math.random( 1, #data.objectiveRandomizer )
	data.objectives.activeObjective = data.objectiveRandomizer[randomObjective]
	
	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) and isPlayerActive( value ) then
			setupActiveObjectiveFor( value ) 
		end 
	end
end


function clearObjective()
	if data.objectives and data.objectives.pmOnObjective then
		data.objectives[data.objectives.activeObjective].enterTime = nil
		data.objectives.pmOnObjective = nil
		
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) and getPlayerClassID( p ) and teams["goodGuys"][classes[getPlayerClassID( p )].type] == true then
				clearObjectiveTextFor( p )	
			end
		end	
	end
end