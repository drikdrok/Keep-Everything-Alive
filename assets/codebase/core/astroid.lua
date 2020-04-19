astroid = class("astroid")

astroids = {}

local spawnTimer = 0
local sprites = {love.graphics.newImage("assets/gfx/sprites/astroid1.png"), love.graphics.newImage("assets/gfx/sprites/astroid2.png"), love.graphics.newImage("assets/gfx/sprites/astroid3.png")}

function astroid:initialize(x, y, angle, grace)
	
	self.x = x or 0 
	self.y = y or 0

	if self.x == 0 then -- No custom location
		local xPos = {-100, game.width + 100}
		local yPos = {-100, game.height + 100}

		if math.random(1, 2) == 1 then -- Decide position
			self.x = math.random(0, game.width)
			self.y = yPos[math.random(1, 2)]
		else
			self.x = xPos[math.random(1, 2)]
			self.y = math.random(0, game.height)
		end
	end

	self.grace = grace or false

	self.angle = angle or math.atan2(planet.y + planet.height / 2 - self.y ,  planet.x + planet.width / 2 - self.x)
	
	self.rotation = 0
	self.rotationFactor = math.random(0.5, 3)
	self.speed = math.random(100, 600)

	self.size = 1
	if math.random(1, 3) == 2 and not grace then -- Big astroid cannot spawn another big one 
		self.size = 2
		self.speed = math.random(100, 250)
	end

	self.dead = false

	self.image = sprites[math.random(1, #sprites)]

	self.width = self.image:getWidth() * 3
	self.height = self.image:getHeight() * 3

	self.age = 0
	self.type = "astroid"

	collisionWorld:add(self, self.x, self.y, self.width, self.height)

	self.id = #astroids + 1
	table.insert(astroids, self)
end

function astroid:update(dt)
	self.x = self.x + self.speed * math.cos(self.angle) * dt
	self.y = self.y + self.speed * math.sin(self.angle) * dt

	self.rotation = self.rotation + self.rotationFactor * dt

	self.age = self.age + dt

	collisionWorld:update(self, self.x, self.y)
	self:collide()
	
	if self.age > 30 then  
		self:destroy()
	elseif self.age > 0.5 then 
		self.grace = false
	end	
end

function astroid:draw()
	love.graphics.draw(self.image, self.x + self.width / 2, self.y + self.height / 2, self.rotation, 3 * self.size, 3 * self.size, self.image:getWidth()/2, self.image:getHeight()/2)
end

function astroid:destroy()
	if self.size == 2 and game.state == "playing" then 
		local n = math.random(2, 5)
		for i=0, n do 
			astroid:new(self.x, self.y, self.angle + math.random(-100, 100)/100, true)
		end
	end

	collisionWorld:remove(self)
	astroids[self.id] = nil

	self.dead = true
end

function astroid:collide()
	local x, y, cols, len = collisionWorld:check(self, self.x, self.y)
	
	if #cols > 0 then 
		for i,v in pairs(cols) do
			if v.other.type == "planet" and not planet.hasShield then 
				local kills = game.population * (math.random(20, 85)/100) + math.random(1000, 10000)
				game.population = game.population - kills
				text:new("-"..formatNumber(kills))
				if not player.intervening then 
					game.growthFactor = game.growthFactor - 0.004
				end
				self.grace = false
			elseif v.other.type == "player" and not self.grace then 
				player.money = player.money + 1
			elseif v.other.type == "angel" then
				v.other:destroy()
			end

			if not self.grace and not self.dead then 
				explosion:new(self.x, self.y)
				self:destroy()
			end
		end
	end
end


function updateAstroids(dt)
	for i, v in pairs(astroids) do
		v:update(dt)
	end	

	spawnTimer = spawnTimer + dt
	if spawnTimer > 1 then 
		spawnTimer = 0

		if math.random(0, 5) == 4 and game.state == "playing" then 
			astroid:new()
		end
	end
end

function drawAstroids()
	for i,v in pairs(astroids) do
		v:draw()
	end
end

