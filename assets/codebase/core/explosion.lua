explosion = class("explosion")
explosions = {}

local sheet = love.graphics.newImage("assets/gfx/sprites/explosion.png")

local grid = anim8.newGrid(32, 32, sheet:getWidth(), sheet:getHeight())


function explosion:initialize(x, y)
	self.x = x
	self.y = y

	self.animation = anim8.newAnimation(grid("1-4", 1), 0.1)

	self.age = 0

	self.id = #explosions + 1
	table.insert(explosions, self)
	
	local soundEffect = love.audio.newSource("assets/sfx/Explosion.wav", "static")
	soundEffect:play()
end

function explosion:update(dt)
	self.animation:update(dt)

	self.age = self.age + dt
	if self.age >= 0.4 then 
		explosions[self.id] = nil
	end
end

function explosion:draw()
	self.animation:draw(sheet, self.x, self.y, 0, 2, 2)
end

function updateExplosions(dt)
	for i, v in pairs(explosions) do
		v:update(dt)
	end
end

function drawExplosions()
	for i, v in pairs(explosions) do
		v:draw()
	end
end
