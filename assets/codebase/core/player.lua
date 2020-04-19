player = class("player")

local angelEffect = love.audio.newSource("assets/sfx/Angel.wav", "static")
local shieldEffect = love.audio.newSource("assets/sfx/Powerup.wav", "static")

function player:initialize()
	self.x = 100
	self.y = 100

	self.image = love.graphics.newImage("assets/gfx/sprites/god.png")

	self.width = 16*3
	self.height = 24*3 

	self.type = "player"

	self.intervening = false

	self.money = 0

	self.angelTimer = 0
	self.shieldTimer = 0

	collisionWorld:add(self, self.x, self.y, self.width, self.height)
end

function player:update(dt)
	local x, y = love.mouse.getPosition()
	self.x = x/game.scale - self.width / 2
	self.y = y/game.scale - self.height / 2

	if self.intervening then 
		if game.growthFactor < 0.006 then 
			game.growthFactor = game.growthFactor + 0.001*dt
		else
			self.intervening = false
			collisionWorld:add(self, self.x, self.y, self.width, self.height)
		end
	else
		collisionWorld:update(self, self.x, self.y)
		self:collide()
	end

	self.angelTimer = self.angelTimer - dt
	self.shieldTimer = self.shieldTimer - dt

end

function player:draw()
	if not self.intervening then 
		love.graphics.draw(self.image, self.x, self.y, 0, 3, 3, 3)
	end
end

function player:collide()
	local x, y, cols, len = collisionWorld:check(self, self.x, self.y)

	if #cols > 0 then 
		for i,v in pairs(cols) do
			if v.other.type == "intervention" then 
				collisionWorld:remove(self)
				collisionWorld:remove(v.other)
				game.canIntervene = false
				self.intervening = true

			elseif v.other.type == "bullet" then 
				v.other:destroy()
				explosion:new(self.x, self.y)
			end
		end
	end
end

function player:keypressed(key)
	if key == "1" then 
		if self.money >= 5 and self.angelTimer <= 0 and not self.intervening then 
			self.money = self.money - 5
			angel:new(self.x, self.y)
			self.angelTimer = 1
			angelEffect:play()
		end

	elseif key == "2" then 
		if self.money >= 10 and self.shieldTimer <= 0 then 
			self.money = self.money - 10
			planet.hasShield = true
			self.shieldTimer = 8
			shieldEffect:play()
		end
	end
end

function player:reset()
	self.money = 0
	self.angelTimer = 0
	self.shieldTimer = 0

	if self.intervening then 
		self.intervening = false
		collisionWorld:add(self, self.x, self.y, self.width, self.height)
	end
end