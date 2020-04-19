game = class("game")

local populationSprite = love.graphics.newImage("assets/gfx/sprites/population.png")
local moneySprite = love.graphics.newImage("assets/gfx/sprites/coin.png")
local interveneSprite = love.graphics.newImage("assets/gfx/sprites/intervene.png")
local introSprite = love.graphics.newImage("assets/gfx/sprites/intro.png")

local angelButton = love.graphics.newImage("assets/gfx/sprites/angelButton.png")
local shieldButton = love.graphics.newImage("assets/gfx/sprites/shieldButton.png")
local shieldSprite = love.graphics.newImage("assets/gfx/sprites/shield.png")

function game:initialize()
	self.width = 1920
	self.height = 1080

	self.year = -1446
	self.population = 14101
	self.growthFactor = 0.006
	self.peak = 0

	self.fonts = {}
	self.font = nil
	self:fontSize(20)

	self.scale = love.graphics.getWidth() / 1920

	self.eventTimer = 0

	self.interventionBox = {x = self.width / 2 - 120*2/2, y = 370, width = 120*2, height = 31*2, type="intervention"}
	self.canIntervene = false

	self.state = "menu"
	self.won = false

	self.canStart = false
	self.canMenu = false

end

function game:update(dt)
	if self.state == "playing" then 
		self.year = self.year + 16*dt
		self.population = self.population*(1+self.growthFactor*16*dt)
	end

	if self.growthFactor <= 0 and not player.intervening then 
		self.growthFactor = self.growthFactor - 0.002*dt
	end

	background:update(dt)
	planet:update(dt)
	updateAstroids(dt)
	updateExplosions(dt)
	updateTexts(dt)
	updateAngels(dt)
	updateUfos(dt)
	updateBullets(dt)
	
	if self.state == "playing" then 
		game:handleEvents(dt)
		player:update(dt)

		if self.population < 1 then 
			self.state = "dead"
		elseif self.population > 1000000000000000 then 
			self.won = true
			self.state = "dead" 
		end

	elseif self.state == "menu" then -- Gamejam spaghetti code :(
		local x, y = love.mouse.getPosition() -- Start button
		if x > self.width*self.scale / 2 - self.font:getWidth("Start")/2*self.scale and x < self.width*self.scale / 2 + self.font:getWidth("Start")/2*self.scale and y > 250*self.scale - self.font:getHeight("Start")/2*self.scale and y < 250*self.scale + self.font:getHeight("Start")*self.scale then 
			self.canStart = true
		else
			self.canStart = false
		end

	elseif self.state == "dead" then
		local x, y = love.mouse.getPosition() 
		if x > self.width*self.scale / 2 - self.font:getWidth("Restart")/2*self.scale and x < self.width*self.scale / 2 + self.font:getWidth("Restart")/2*self.scale and y > 250*self.scale - self.font:getHeight("Restart")/2*self.scale and y < 250*self.scale + self.font:getHeight("Restart")*self.scale then 
			self.canStart = true
		else
			self.canStart = false
		end
		if x > self.width / 2*self.scale - self.font:getWidth("Menu")/2*self.scale and x < self.width*self.scale / 2 + self.font:getWidth("Menu")/2*self.scale and y > 350*self.scale - self.font:getHeight("Menu")/2*self.scale and y < 350*self.scale + self.font:getHeight("Menu")*self.scale then 
			self.canMenu = true
		else
			self.canMenu = false
		end
	end	

	if self.population > self.peak then 
		self.peak = self.population
	end
end

function game:draw()
	background:draw()
	planet:draw()
	drawAstroids()
	drawExplosions()
	drawAngels()
	drawBullets()
	drawUfos()

	if self.state == "playing" then 
		player:draw()
		drawTexts()
		self:drawHUD()
	elseif self.state == "menu" then 
		self:drawMenu()
	elseif self.state == "dead" then 
		self:drawDeathMenu()
	elseif self.state == "intro" then 
		self:drawHUD()
		love.graphics.draw(introSprite, self.width / 2 - 400*2 / 2, self.height / 2 - 300*2 / 2, 0, 2,2 )
	end


end

function game:fontSize(size)
	if not self.fonts[size] then 
		self.fonts[size] = love.graphics.newFont("assets/gfx/fonts/pixelmix.ttf", size)
	end
	self.font = self.fonts[size]
	love.graphics.setFont(self.font)
end


function game:drawHUD()
	local suffix
	if self.year < 0 then 
		suffix = "B.C."
	else
		suffix = "A.D."
	end
	love.graphics.print(math.floor(math.abs(self.year))..suffix, self.width / 2 - self.font:getWidth(math.floor(math.abs(self.year)))/2, 10)

	love.graphics.draw(populationSprite, 2, 10, 0, 3, 3)
	local pop = formatNumber(self.population)
	love.graphics.print(pop, 35, 12)

	love.graphics.draw(moneySprite, 0, 40, 0, 2, 2)
	love.graphics.print(player.money, 35, 44)

	if self.canIntervene then 
		love.graphics.draw(interveneSprite, self.width / 2 - 120*2/2, 370, 0, 2, 2)
	end

	if player.intervening then 
		local percentage = 1
		local color = {1, 0, 0}
		if self.growthFactor > 0 then 
			percentage = self.growthFactor / 0.006 
			color = {0,1,0}
		end
		love.graphics.setColor(color)
		love.graphics.rectangle("fill", game.width / 2 - 50, 450, 100*percentage, 5)
		love.graphics.setColor(1,1,1)
	end	


	--Angel button
	love.graphics.print("1", 40, game.height - 145)
	love.graphics.draw(angelButton, 10, game.height - 118, 0, 2, 2)
	love.graphics.print("5x", 45, game.height - 40)
	love.graphics.draw(moneySprite, 10, game.height - 45, 0, 2, 2)
	if player.angelTimer > 0 then 
		love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
		love.graphics.rectangle("fill", 10, game.height - 118 + 68*player.angelTimer, 68, 68*(1-player.angelTimer))
		love.graphics.setColor(1,1,1)
	end

	--Shield button

	love.graphics.print("2", 127, game.height - 145)
	love.graphics.draw(shieldButton, 100, game.height - 118, 0, 2, 2)
	love.graphics.draw(shieldSprite, 101, game.height - 117, 0, 1.2, 1.2)
	love.graphics.print("10x", 135, game.height - 40)
	love.graphics.draw(moneySprite, 100, game.height - 45, 0, 2, 2)
	if player.shieldTimer > 0 then 
		love.graphics.setColor(0.3, 0.3, 0.3, 0.4)
		love.graphics.rectangle("fill", 100, game.height - 118 + 68*(player.shieldTimer/8), 68, 68*(1-(player.shieldTimer/8)))
		love.graphics.setColor(1,1,1)
	end

end

function game:handleEvents(dt)
	self.eventTimer = self.eventTimer + dt

	if self.eventTimer >= 3 then 
		local n = math.random(1, 10)
		if n == 2 and not player.intervening then 
			if self.year < 1950 then 
				text:new("Plague")
			else
				text:new("Global Warming")
			end
			self.growthFactor = self.growthFactor - 0.002
		elseif n == 3 and not player.intervening then
			local deaths = self.population / 100 * math.random(1, 10) + math.random(5, 10000)
			text:new("War: -"..formatNumber(deaths))
			self.population = self.population - deaths
			self.growthFactor = self.growthFactor - 0.002
		elseif n == 4 and not player.intervening then 
			if self.year < 1950 then 
				text:new("Famine")
			else
				text:new("Recession")
			end
			self.growthFactor = self.growthFactor - 0.002
		elseif n == 5 then 
			text:new("Medical Breakthrough")
			self.growthFactor = self.growthFactor + 0.002
		end

		self.growthFactor = self.growthFactor + 0.00005
		self.eventTimer = 0

	end

	if self.growthFactor < 0 then 
		if not self.canIntervene and not player.intervening then 
			self.canIntervene = true
			collisionWorld:add(self.interventionBox, self.interventionBox.x, self.interventionBox.y, self.interventionBox.width, self.interventionBox.height)
		end
	end
end

function game:keypressed(key)
	if self.state == "playing" then 
		player:keypressed(key)
	elseif self.state == "menu" then 
		if key == "space" then 
			self:reset()
		end
	elseif self.state == "intro" then 
		if key == "space" then 
			self.state = "playing"
		end
	end
end

function game:mousepressed()
	if self.state == "menu" or self.state == "dead" then
		if self.canStart then 
			self:reset()
		elseif self.canMenu then 
			self.state = "menu"
		end
	end
end

function game:reset()
	self.year = -1446
	self.population = 14101
	self.growthFactor = 0.006
	self:fontSize(20)

	self.won = false
	self.eventTimer = 0 

	if self.canIntervene then 
		self.canIntervene = false
		collisionWorld:remove(self.interventionBox)
	end

	player:reset()

	local entities = {angels, bullets, ufos, astroids, texts}

	for i,v in pairs(entities) do
		for j, k in pairs(v) do
			k:destroy()
		end
	end

	self.state = "intro"
end



function game:drawMenu()
	self:fontSize(40)
	love.graphics.print("Keep Everything Alive", self.width / 2 - self.font:getWidth("Keep Everything Alive")/2, 100)
	self:fontSize(32)
	if self.canStart then 
		love.graphics.setColor(0,0,1)
	end
	love.graphics.print("Start", self.width / 2 - self.font:getWidth("Start")/2, 250)
	love.graphics.setColor(1,1,1)
	self:fontSize(30)
	love.graphics.print("F11 for fullscreen", self.width - self.font:getWidth("F11 for fullscreen") - 10, self.height - 40)
	love.graphics.print("Christian Schwenger - Ludum Dare 46", 10, self.height - 40)
end	

function game:drawDeathMenu()
	self:fontSize(40)
	local message = "Humans went extinct!"
	if self.won then 
		message = "You Win!"
	end

	love.graphics.print(message, self.width / 2 - self.font:getWidth(message)/2, 100)
	self:fontSize(32)
	
	local suffix
	if self.year < 0 then 
		suffix = "B.C."
	else
		suffix = "A.D."
	end
	message = "Humanity lasted until "..math.abs(math.floor(self.year))..suffix.. " with a peak population of "..formatNumber(self.peak)
	if self.won then 
		message = "Humanity reached a population of over 1 quadrillion in the year "..math.abs(math.floor(self.year))..suffix
	end

	love.graphics.print(message, self.width / 2 - self.font:getWidth(message)/2, 180)
	if self.canStart then 
		love.graphics.setColor(0,0,1)
	end
	love.graphics.print("Restart", self.width / 2 - self.font:getWidth("Restart")/2, 250)
		love.graphics.setColor(1,1,1)
	if self.canMenu then 
		love.graphics.setColor(0,0,1)
	end
	love.graphics.print("Menu", self.width / 2 - self.font:getWidth("Menu")/2, 350)
	love.graphics.setColor(1,1,1)
end



function formatNumber(num) 
	local pop
	local suffix

	if num > 1000000000000 then -- Trillions
		pop = round(num / 1000000000000, 2)
		suffix = "T"
	elseif num > 1000000000 then -- Billions
		pop = round(num / 1000000000, 2)
		suffix = "B"
	elseif num > 1000000 then -- Millions
		pop = round(num / 1000000, 2)
		suffix = "M"
	elseif num > 1000 then -- Thousands
		pop = round(num / 1000, 2)
		suffix = "K"
	else
		return math.floor(num)
	end

	return pop..suffix
end