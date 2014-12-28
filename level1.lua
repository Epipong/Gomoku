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

	if x ~= 0 and GomokuField[y][x - 1] == oppositeColor then
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

	if y ~= 0 and GomokuField[y - 1][x] == oppositeColor then
		while y ~= 18 and (GomokuField[y + 1][x] ~= EMPTY and GomokuField[y + 1][x] ~= oppositeColor) do
			y = y + 1
		end
		if y ~= 18 and GomokuField[y + 1][x] == oppositeColor then
			GomokuField_[y][x] = EMPTY
			while GomokuField[y][x] == originalColor do
				GomokuField_[y][x] = EMPTY
				y = y - 1
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
		end
	end

	for y = 0, 18 do
		for x = 0, 18 do
			if GomokuField[y][x] ~= temporyGomokuField[y][x] then
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

	GomokuField = temporyGomokuField
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

local function GameOver()
	local background = display.newImageRect( "backgroundGomoku.png",screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0

end

local function playGomoku(event)

	x = event.target.x
	y = event.target.y

	CapturedPiece[PLAYER_ONE] = 0
	CapturedPiece[PLAYER_TWO] = 0
	local newImage

	if currentPlayer == PLAYER_ONE then
		newImage = display.newImageRect("white.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = WHITE

	elseif currentPlayer == PLAYER_TWO then
		newImage = display.newImageRect("black.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = BLACK

	end

	newImage.real_x = event.target.real_x
	newImage.real_y = event.target.real_y

	newImage.anchorX = 0
	newImage.anchorY = 0
	newImage.x = x
	newImage.y = y

	mergeGomoku()
	if haveWin() == true then
		GameOver()
		return true
	end

	currentPlayer = currentPlayer == PLAYER_ONE and PLAYER_TWO or PLAYER_ONE

	event.target:removeSelf()
	Playground[newImage.real_y][newImage.real_x] = newImage
	return true
end

function scene:create( event )

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