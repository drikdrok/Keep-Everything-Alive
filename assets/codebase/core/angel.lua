angel = class("angel")
angels = {}

local sprite = love.graphics.newImage("assets/gfx/sprites/angel.png")

function angel:initialize(x, y)
	self.x = x
	self.y = y

	self.spawnX = x
	self.spawnY = y

	self.width = 16*3
	self.height = 24*3 

	self.id = #angels+1

	self.type = "angel"
	self.speed = 100

	self.health = 3

	self.age = 0

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
	table.insert(angels, self)
end

function angel:update(dt)
	self.age = self.age + dt


	if self.spawnY > planet.y - 100 and self.spawnY < planet.y + 48*3 then 
		self.y = self.y + self.speed * (math.cos(self.age))*dt
	else
		self.x = self.x + self.speed * (math.cos(self.age))*dt
	end

	collisionWorld:update(self, self.x, self.y)

	if self.health <= 0 then 
		self:destroy()
	end
end


function angel:draw()
	love.graphics.draw(sprite, self.x - self.width/2, self.y, 0, 3, 3)
end

function angel:destroy()
	collisionWorld:remove(self)
	angels[self.id] = nil
end

function updateAngels(dt)
	for i,v in pairs(angels) do
		v:update(dt)
	end
end

function drawAngels()
	for i,v in pairs(angels) do
		v:draw()
	end
end

