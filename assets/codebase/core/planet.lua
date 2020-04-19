planet = class("planet")

function planet:initialize()
	self.image = love.graphics.newImage("assets/gfx/sprites/planet.png")
	self.shieldImage = love.graphics.newImage("assets/gfx/sprites/shield.png")

	self.width = 48 * 2.5
	self.height = 48 * 2.5

	self.x = game.width / 2 - 48*3 / 2 + 10
	self.y = game.height / 2 - 48*3 / 2 + 10

	self.rotation = 0

	self.type = "planet"

	self.hasShield = false


	collisionWorld:add(self, self.x, self.y, self.width, self.height)
end

function planet:update(dt)
	if player.shieldTimer <= 0 then 
		self.hasShield = false
	end
end


function planet:draw()
	love.graphics.draw(self.image, self.x - 10, self.y - 10, self.rotation, 3, 3)
	if self.hasShield then 
		love.graphics.draw(self.shieldImage, self.x - 18.5, self.y - 18.5, 0, 3, 3)
	end
end