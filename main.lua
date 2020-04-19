love.graphics.setDefaultFilter("nearest", "nearest")
require("assets/codebase/core/require")
math.randomseed(os.time())


--Todo: check if game crashes when 2 astroids collide

local debug = false
local fullscreen = false

function love.load()
	collisionWorld = bump.newWorld()

	game = game:new()
	background = background:new()
	planet = planet:new()
	player = player:new()

	canvas = love.graphics.newCanvas(1920, 1080)
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		game:draw()

		if debug then 
			love.graphics.print(round(game.growthFactor, 6), 0, 100)
			love.graphics.print(love.timer.getFPS(), 0, 130)
			--love.graphics.print(#angels, 0, 140)

			local items = collisionWorld:getItems()
			for i,v in pairs(items) do
				love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
			end
		end
	love.graphics.setCanvas()

	local scale = love.graphics.getWidth() / 1920
	love.graphics.draw(canvas, 0, 0, 0, scale)

end

function love.keypressed(key)
	if key == "escape" then 
		love.event.quit()
	elseif key == "f1" then 
		debug = not debug
	elseif key == "u" then 
	--	ufo:new()
	elseif key == "f11" then 
		fullscreen = not fullscreen
		love.window.setMode(1920, 1080, {fullscreen=fullscreen, vsync=0})
		game.scale = love.graphics.getWidth() / 1920
	end

	game:keypressed(key)
end

function love.mousepressed()
	game:mousepressed()
end


function round(num, n)
    local mult = 10^(n or 0)
    return math.floor(num * mult + 0.5) / mult
end