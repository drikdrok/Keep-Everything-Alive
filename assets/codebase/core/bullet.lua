bullet = class("bullet")

bullets = {}

local sprite = love.graphics.newImage("assets/gfx/sprites/bullet.png")
local soundEffect = love.audio.newSource("assets/sfx/Bullet.wav", "static")

function bullet:initialize(x, y, direction)

	self.x = x
	self.y = y
	self.direction = direction

	self.width = 9*3
	self.height = 9

	self.speed = 200

	self.type = "bullet"

	collisionWorld:add(self, self.x, self.y, self.width, self.height)

	self.id = #bullets + 1
	table.insert(bullets, self)

	soundEffect:play()
end

function bullet:update(dt)
	self.x = self.x + self.speed * self.direction * dt

	collisionWorld:update(self, self.x, self.y)
	local x, y, cols, len = collisionWorld:check(self, self.x, self.y)
	if #cols > 0  then 
		for i,v in pairs(cols) do
			if v.other.type == "planet" then 
				if not planet.hasShield then 
					local deaths = game.population / 100 * math.random(5, 15)
					text:new("-"..formatNumber(deaths))
					game.population = game.population - deaths
					game.growthFactor = game.growthFactor - 0.001
				end

				explosion:new(self.x, self.y)
				self:destroy()
			elseif v.other.type == "angel" then
				explosion:new(self.x, self.y)
				self:destroy()
				v.other.health = v.other.health - 1
			end
		end
	end
end

function bullet:draw()
	love.graphics.draw(sprite, self.x, self.y, 0, 3, 3)
end

function bullet:destroy()
	bullets[self.id] = nil
	collisionWorld:remove(self)
end

function updateBullets(dt)
	for i,v in pairs(bullets) do
		v:update(dt)
	end
end

function drawBullets()
	for i,v in pairs(bullets) do
		v:draw()
	end
end