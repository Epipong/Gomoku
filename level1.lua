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

	local newImage

	if currentPlayer == PLAYER_ONE then
		newImage = display.newImageRect("white.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = WHITE

	elseif currentPlayer == PLAYER_TWO then
		newImage = display.newImageRect("black.png", 13, 13)
		GomokuField[event.target.real_y][event.target.real_x] = BLACK

	end

	newImage.anchorX = 0
	newImage.anchorY = 0
	newImage.x = x
	newImage.y = y

	if haveWin() == true then
		GameOver()
		return true
	end
	currentPlayer = currentPlayer == PLAYER_ONE and PLAYER_TWO or PLAYER_ONE

	event.target:removeSelf()

	return true
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

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

			Playground[var_y][var_x]:addEventListener("tap", playGomoku)

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