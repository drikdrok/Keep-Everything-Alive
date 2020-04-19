ufo = class("ufo")
ufos = {}

local sprite = love.graphics.newImage("assets/gfx/sprites/ufo.png")

local directions = {1, -1}
local positions = {-100, 2020}

local spawnTimer = 0

function ufo:initialize()
	local d = math.random(1, 2)
	self.direction = directions[d]
	self.x = positions[d]
	self.y = math.random(0, game.height)

	self.state = 0

	self.angle = math.atan2(planet.y + planet.width / 2 - self.y, planet.x + planet.width / 2 - self.x)

	self.speed = 200

	self.timer = 0
	self.shootTimer = 0


	self.id = #ufos + 1 
	table.insert(ufos, self)

end

function ufo:update(dt)
	if self.state == 0 then -- Initial state
		self.x = self.x + self.speed * self.direction * dt
		self.y = self.y + self.speed * math.sin(self.angle) * dt

		if (self.direction == 1 and self.x >= game.width / 2 - 350) or (self.direction == -1 and self.x <= game.width / 2 + 350) then 
			self.state = 1
		end
	elseif self.state == 1 then -- Second state
		self.timer = self.timer + dt
		self.shootTimer = self.shootTimer + dt

		self.y = self.y + self.speed * math.cos(self.timer) * dt

		if self.shootTimer >= 0.8 then 
			bullet:new(self.x, self.y, self.direction)
			self.shootTimer = 0
		end

		if self.timer >= 10 then 
			self.state = 2 
		end

	elseif self.state == 2 then -- Final state 
		self.timer = self.timer + dt

		self.x = self.x - self.speed * self.direction * dt

		if self.timer >= 40 then 
			self:destroy()
		end 
	end	
end

function ufo:draw()
	love.graphics.draw(sprite, self.x, self.y, 0, 3, 3)
end

function ufo:destroy()
	ufos[self.id] = nil
end

function updateUfos(dt)
	for i, v in pairs(ufos) do
		v:update(dt)
	end	

	spawnTimer = spawnTimer + dt

	if spawnTimer >= 3 then 
		if math.random(1, 10) == 3 and game.state == "playing" then 
			ufo:new()
		end

		spawnTimer = 0
	end
end

function drawUfos()
	for i, v in pairs(ufos) do
		v:draw()
	end	
end