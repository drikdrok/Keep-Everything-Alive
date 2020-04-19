background = class("background")

function background:initialize()
	self.alphas = {}
	self.activated = {}
	for y=0, game.height/24 do
		local row1 = {}
		local row2 = {}
		for x=0, game.width/24 do
			table.insert(row1, 1)
			table.insert(row2, {false, 0})
		end
		table.insert(self.alphas, row1)
		table.insert(self.activated, row2)
	end

end

function background:update(dt)
	for y=1, game.height/24 do
		for x=1, game.width/24 do
			if self.activated[y][x][1] then 
				self.activated[y][x][2] = self.activated[y][x][2] + dt
				self.alphas[y][x] = self.alphas[y][x] - math.cos(self.activated[y][x][2])*dt
			end
		end
	end


	self.activated[math.random(1, game.height/24)][math.random(1, game.width/24 )][1] = true

end

function background:draw()
	for y=1, game.height/24 do
		for x=1, game.width/24 do
			local n = love.math.noise(x*5, y*5)

			love.graphics.setColor(1, 1, 1, self.alphas[y][x])

			if n > 0.9 then 
				love.graphics.circle("fill", (x-1)*24, (y-1)*24, 3)
			end

		end
	end
	love.graphics.setColor(1,1,1,1)
end