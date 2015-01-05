-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local Playground = {}
local GomokuField = {}
local EMPTY = 0
local WHITE = 1
local BLACK = 2
local PLAYER_ONE = 0
local PLAYER_TWO = 1
local NOT_VISITED = 0
local VISITED = 1
local CapturedPiece = {}
local callback
local musicMenu = audio.loadStream("game.mp3")
local menuChannel



currentPlayer = PLAYER_ONE

local function didHeWin(y, x, value)
	if (y - 4 >= 0 and GomokuField[y - 1][x] == value and GomokuField[y - 2][x] == value and GomokuField[y - 3][x] == value and GomokuField[y - 4][x] == value) then
		return true -- check up
	end

	if (x - 4 >= 0 and GomokuField[y][x - 1] == value and GomokuField[y][x - 2] == value and GomokuField[y][x - 3] == value and GomokuField[y][x - 4] == value) then
		return true -- check right
	end

	if (x - 4 >= 0 and y - 4 >= 0 and GomokuField[y - 1][x - 1] == value and GomokuField[y - 2][x - 2] == value and GomokuField[y - 3][x - 3] == value and GomokuField[y - 4][x - 4] == value) then
		return true -- check first diagonal
	end

	if (x - 4 >= 0 and y + 4 <= 18 and GomokuField[y + 1][x - 1] == value and GomokuField[y + 2][x - 2] == value and GomokuField[y + 3][x - 3] == value and GomokuField[y + 4][x - 4] == value) then
		return true
	end

	return false
end

local function mergeRight(x, y, GomokuField_)

	if (GomokuField[y][x] == EMPTY) then
		return true
	end

	oppositeColor = GomokuField[y][x] == WHITE and BLACK or WHITE
	originalColor = GomokuField[y][x]

	while x ~= 0 and GomokuField[y][x - 1] == originalColor do
		x = x - 1
	end

	if x ~= 0 and GomokuField[y][x - 1] == oppositeColor and GomokuField[y][x] == originalColor and GomokuField[y][x + 1] == originalColor then
		while x ~= 18 and (GomokuField[y][x + 1] ~= EMPTY and GomokuField[y][x + 1] ~= oppositeColor) do
			x = x + 1
		end
		if x ~= 18 and GomokuField[y][x + 1] == oppositeColor then

			GomokuField_[y][x] = EMPTY
			while GomokuField[y][x] == originalColor do
				GomokuField_[y][x] = EMPTY
				x = x - 1
			end
		end
	end
	return true

end

local function mergeUp(x, y, GomokuField_)

	if (GomokuField[y][x] == EMPTY) then
		return true
	end

	oppositeColor = GomokuField[y][x] == WHITE and BLACK or WHITE
	originalColor = GomokuField[y][x]

	while y ~= 0 and GomokuField[y - 1][x] == originalColor do
		y = y - 1
	end

	if y ~= 0 and GomokuField[y - 1][x] == oppositeColor and GomokuField[y][x] == originalColor and GomokuField[y + 1][x] == originalColor then
		while y ~= 18 and (GomokuField[y + 1][x] ~= EMPTY and GomokuField[y + 1][x] ~= oppositeColor) do
			y = y + 1
		end
		if y <= 17 and GomokuField[y + 1][x] == oppositeColor  then
			GomokuField_[y][x] = EMPTY
			while GomokuField[y][x] == originalColor do
				if GomokuField_[y][x] == EMPTY then
					CapturedPiece[originalColor - 1] = CapturedPiece[originalColor - 1] + 1
				end
				GomokuField_[y][x] = EMPTY
				y = y - 1
			end
		end
	end
	return true
end

local function mergeDiagonalUp(x, y, GomokuField_)

	if (GomokuField[y][x] == EMPTY) then
		return true
	end

	oppositeColor = GomokuField[y][x] == WHITE and BLACK or WHITE
	originalColor = GomokuField[y][x]

	while y ~= 0 and x ~= 0 and GomokuField[y + 1][x - 1] == originalColor do
		y = y - 1
		x = x - 1
	end

	if y ~= 0 and x ~= 0 and GomokuField[y - 1][x - 1] == oppositeColor and GomokuField[y][x] == originalColor and GomokuField[y + 1][x + 1] == originalColor then
		while y ~= 18 and (GomokuField[y + 1][x + 1] ~= EMPTY and GomokuField[y + 1][x + 1] ~= oppositeColor) do
			y = y + 1
			x = x + 1
		end
		if y <= 17 and x <= 17 and GomokuField[y + 1][x + 1] == oppositeColor  then
			GomokuField_[y][x] = EMPTY
			while GomokuField[y][x] == originalColor do
				if GomokuField_[y][x] == EMPTY then
					CapturedPiece[originalColor - 1] = CapturedPiece[originalColor - 1] + 1
				end
				GomokuField_[y][x] = EMPTY
				y = y - 1
				x = x - 1
			end
		end
	end
	return true
end

local function mergeDiagonalDown(x, y, GomokuField_)

	if (GomokuField[y][x] == EMPTY) then
		return true
	end

	oppositeColor = GomokuField[y][x] == WHITE and BLACK or WHITE
	originalColor = GomokuField[y][x]

	while y ~= 18 and x ~= 0 and GomokuField[y + 1][x - 1] == originalColor do
		y = y + 1
		x = x - 1
	end

	if y ~= 18 and x ~= 0 and GomokuField[y + 1][x - 1] == oppositeColor and GomokuField[y][x] == originalColor and GomokuField[y - 1][x + 1] == originalColor then
		while y ~= 0 and x ~= 18 and (GomokuField[y - 1][x + 1] ~= EMPTY and GomokuField[y - 1][x + 1] ~= oppositeColor) do
			y = y - 1
			x = x + 1
		end
		if y ~= 0 and x <= 17 and GomokuField[y - 1][x + 1] == oppositeColor  then
			GomokuField_[y][x] = EMPTY
			while GomokuField[y][x] == originalColor do
				if GomokuField_[y][x] == EMPTY then
					CapturedPiece[originalColor - 1] = CapturedPiece[originalColor - 1] + 1
				end
				GomokuField_[y][x] = EMPTY
				y = y + 1
				x = x - 1
			end
		end
	end
	return true
end


local function mergeGomoku()

	oppositeColor = currentPlayer == PLAYER_ONE and BLACK or WHITE
	originalColor = currentPlayer == PLAYER_ONE and WHITE or BLACK
	temporyGomokuField = {}

	for y = 0, 18 do
		temporyGomokuField[y] = {}
		for x = 0, 18 do
			temporyGomokuField[y][x] = GomokuField[y][x]
		end
	end

	for y = 0, 18 do

		for x = 0, 18 do
			mergeUp(x, y, temporyGomokuField)
			mergeRight(x, y, temporyGomokuField)
			mergeDiagonalUp(x, y, temporyGomokuField)
			mergeDiagonalDown(x, y, temporyGomokuField)
		end
	end

	for y = 0, 18 do
		for x = 0, 18 do
			if GomokuField[y][x] ~= temporyGomokuField[y][x] then
				GomokuField[y][x] = temporyGomokuField[y][x]
				Playground[y][x]:removeSelf()
				Playground[y][x] = nil
				Playground[y][x] = display.newImageRect("empty.png", 13, 13)
				Playground[y][x].anchorY = 0
				Playground[y][x].anchorX = 0
				
				Playground[y][x].real_x = x
				Playground[y][x].real_y = y			

				Playground[y][x].x = 116 + (x * 13)
				Playground[y][x].y = 37 +  (y * 13)	

				Playground[y][x]:addEventListener("tap", callback)
				
			end
		end
	end
end

local function haveWin()
	
	for var_y = 0, 18 do

		for var_x = 0, 18 do
			if GomokuField[var_y][var_x] ~= EMPTY then
				if didHeWin(var_y, var_x, GomokuField[var_y][var_x]) == true then
					return true
				end
			end
		end
	end

	return false	
end

local function checkTwoThreeUp(y, x, color)
	local _y = y - 4

	while _y ~= y + 1 do
		local nbPiece = 0
		local _yLimit = _y + 5
		local _yBegin = _y

		while _yBegin ~= _yLimit do

			if _yBegin < 0 then
				break
			end
			if _yBegin > 18 then
				break
			end
			if GomokuField[_yBegin][x] == color then
				nbPiece = nbPiece + 1
			end

			if GomokuField[_yBegin][x] ~= EMPTY and GomokuField[_yBegin][x] ~= color then
				nbPiece = 0
				break
			end

			_yBegin = _yBegin + 1
		end

		if nbPiece >= 3 then
			return true
		end

		_y = _y + 1
	end
	return false
end

local function checkTwoThreeLeft(y, x, color)
	local _x = x - 4

	while _x ~= x + 1 do
		local nbPiece = 0
		local _xLimit = _x + 5
		local _xBegin = _x

		while _xBegin ~= _xLimit do

			if _xBegin < 0 then
				break
			end
			if _xBegin > 18 then
				break
			end
			if GomokuField[y][_xBegin] == color then
				nbPiece = nbPiece + 1
			end

			if GomokuField[y][_xBegin] ~= EMPTY and GomokuField[y][_xBegin] ~= color then
				nbPiece = 0
				break
			end

			_xBegin = _xBegin + 1
		end

		if nbPiece >= 3 then
			return true
		end

		_x = _x + 1
	end
	return false
end


local function  itNotPossible(y, x, color)

	local _y = y
	local _x = x
	local nbPaire = 0

	if checkTwoThreeUp(_y, _x, color) == true then
		nbPaire = nbPaire + 1
	end

	if checkTwoThreeLeft(_y, _x, color) == true then
		nbPaire = nbPaire + 1
	end

	if nbPaire >= 2 then
		return true
	end

	return false
end

local function GameOver()
	local sceneGroup = scene.view

	local background = display.newImageRect( "backgroundGomoku.png",screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0

	sceneGroup:insert(background)
end

local function playGomoku(event)

	x = event.target.x
	y = event.target.y

	local newImage
	local colorActuel

	if currentPlayer == PLAYER_ONE then
		newImage = display.newImageRect("white.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = WHITE
		colorActuel = WHITE
	elseif currentPlayer == PLAYER_TWO then
		newImage = display.newImageRect("black.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = BLACK
		colorActuel = BLACK
	end

	if itNotPossible(event.target.real_y, event.target.real_x, colorActuel) == true then
		newImage:removeSelf()
		GomokuField[event.target.real_y][event.target.real_x] = EMPTY

		return false
	end

	newImage.real_x = event.target.real_x
	newImage.real_y = event.target.real_y

	newImage.anchorX = 0
	newImage.anchorY = 0
	newImage.x = x
	newImage.y = y

	event.target:removeSelf()
	Playground[newImage.real_y][newImage.real_x] = newImage

	mergeGomoku()
	if CapturedPiece[PLAYER_ONE] >= 10 then
		GameOver()
		return true
	end
	if CapturedPiece[PLAYER_TWO] >= 10 then
		GameOver()
		return true
	end


	if haveWin() == true then
		GameOver()
		return true
	end

	currentPlayer = currentPlayer == PLAYER_ONE and PLAYER_TWO or PLAYER_ONE

	return true
end

function scene:create( event )

	--menuChannel = audio.play(musicMenu, { channel=2, loops=-1, fadein=200})

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	callback = playGomoku
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "backgroundGomoku.png",screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0

	sceneGroup:insert( background )
	CapturedPiece[PLAYER_ONE] = 0
	CapturedPiece[PLAYER_TWO] = 0


	for var_y = 0, 18 do
		Playground[var_y] = {}
		GomokuField[var_y] = {}

		for var_x = 0, 18 do
			Playground[var_y][var_x] = display.newImageRect("empty.png", 13, 13)
			Playground[var_y][var_x].anchorY = 0
			Playground[var_y][var_x].anchorX = 0
			
			Playground[var_y][var_x].real_x = var_x
			Playground[var_y][var_x].real_y = var_y			

			Playground[var_y][var_x].x = 116 + (var_x * 13)
			Playground[var_y][var_x].y = 37 +  (var_y * 13)	

			Playground[var_y][var_x]:addEventListener("tap", callback)

			GomokuField[var_y][var_x] = EMPTY

			sceneGroup:insert(Playground[var_y][var_x])
		end
	end

	-- all display objects must be inserted into group
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene