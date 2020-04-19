text = class("text") 

texts = {}

function text:initialize(text)
	self.text = text

	self.x = game.width / 2 - game.font:getWidth(text) / 2
	self.y = planet.y

	self.alpha = 0

	self.speed = 30
	
	self.id = #texts+1
	table.insert(texts, self) 
end

function text:update(dt)
	self.y = self.y - self.speed * dt

	if self.alpha < 1 and self.y > planet.y - 80 then 
		self.alpha = self.alpha + 0.7*dt
	elseif self.y < planet.y + 80 then 
		self.alpha = self.alpha - 0.7*dt
	end

	if self.y < 0 then 
		self:destroy()
	end
end

function text:draw()
	love.graphics.setColor(1, 1, 1, self.alpha)

	love.graphics.print(self.text, self.x, self.y)

	love.graphics.setColor(1, 1, 1, 1)
end

function text:destroy()
	texts[self.id] = nil
end

function updateTexts(dt)
	for i,v in pairs(texts) do
		v:update(dt)
	end
end

function drawTexts()
	for i,v in pairs(texts) do
		v:draw()
	end
end