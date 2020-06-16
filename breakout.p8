pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init and run--

function _init()
	--initialise--
	cls()
	
	ball = {}
	ball.x = 64
	ball.dx = 1
	ball.y = 64
	ball.dy = 1
	ball.r = 2
	ball.col = 9 
	
	pad = {}
	pad.x = 52
	pad.vel = 0
	pad.acc = 5
	pad.y = 120
	pad.w = 24
	pad.h = 3
	pad.col = 7
	
	bkgrnd_col = 1
end

function _update()
	--update every frame--
	padmove()
	padwallcollision()
	
	ballmove()
	ballwallcollision()
	
	ballpadcollision()
end

function _draw()
	--draw every frame--
	drawbackground()
	drawball()
	drawpaddle()
end
-->8
--movement--

function ballmove()
	--move ball based on speed--
	ball.x += ball.dx
	ball.y += ball.dy
end

function padmove()
	--move paddle based on input--
	if btn(0) then
		--left--
		pad.vel -= pad.acc
	end
	
	if btn(1) then
		--right--
		pad.vel += pad.acc
	end
	
	if not btn(0) or not btn(1) then
		--slow down if no buttons--
		pad.vel /= 2
	end
	
	pad.x += pad.vel

end


-->8
--collision--

function ballwallcollision()
	--ball wall collision--
	if ball.x > 127 or ball.x < 0 then
		--left and right walls--
		ball.dx *= -1
		sfx(01)
	end
	if ball.y > 127 or ball.y < 0 then
		--top and bottom walls--
		ball.dy *= -1
		sfx(01)
	end
end

function padwallcollision()
	--paddle wall collision--
	if pad.x + pad.w > 127 then
		--right wall--
		pad.x = 127-pad.w
		pad.spd = 0
	elseif pad.x < 0 then
		--left wall--
		pad.x = 0
		pad.spd = 0
	end
	
end

function ballpadcollision()
	--ball paddle collision--
	local pad_box = {x = pad.x,
					y = pad.y,
					w = pad.w,
					h = pad.h}
																	
	pad.col = 7
	if ball_hitbox(pad_box) then
		pad.col = 9
	end
end

function ball_hitbox(box)
	--returns true if ball in specified box--
	
	if ball.y-ball.r > box.y+box.h then
		--ball underneath box--
		return false
	elseif ball.y+ball.r < box.y then
		--ball above box--
		return false
	end
	
	if ball.x-ball.r > box.x+box.w then
		--ball to the right of box--
		return false
	elseif ball.x+ball.r < box.x then
		--ball to the left of box--
		return false
	end
	
	return true
end

function calc_refl_dir(ball, box)
	--for a given ball and box--
	--returns true for horizontal collision--	
	
	if ball.dx == 0 then
		--moving vertically--
		return false
		
	elseif ball.dy == 0 then
		--moving horizontally--
		return true
		
	else
		--moving diagonally--
		
		local slope = ball.dy/ball.dx --gradient of ball trjectory
		local dis_x, dis_y --distance between ball and box corner
		
		--note: all gradients are upside down, using inverted coordinate system--
		if slope > 0 and bdx > 0 then
			--moving down right--

			--distance to top left corner--
			dis_x = box.x-ball.x
			dis_y = box.y-ball.y
			
			if dis_x <= 0 then
				--ball directly above or below box--
				return false

			elseif dis_y/dis_x > slope then
				--line ball -> corner more +ve than ball trajectory 
				--means ball will hit top of box--
				return false

			else
				--ball will hit side of box--
				return true
			end

		elseif slope < 0 and ball.dx > 0 then
			--moving up right--

			--distance to bottom left corner
			dis_x = box.x-ball.x
			dis_y = box.y+box.h - ball.y

			if dis_x <= 0 then
				--ball directly above or below box--
				return false

			elseif dis_y/dis_x < slope then
				--line ball -> corner more -ve than ball trajectory  
				--means ball will hit top of box--
				return false

			else
				--ball will hit side of box--
				return true
			end

		elseif slope > 0 and ball.dx < 0 then
			--moving up left--

			--distance to bottom right corner
			dis_x = box.x+box.w - ball.x
			dis_y = box.y+box.h - ball.y

			if dis_x >= 0 then
				--ball directly above or below box--
				return false

			elseif dis_y/dis_x > slope then
				--line ball -> corner more +ve than ball trajectory  
				--means ball will hit top of box--
				return false

			else
				--ball will hit side of box--
				return true
			end

		elseif slope > 0 and ball.dx < 0 then
			--moving down left--

			--distance to top right corner
			dis_x = box.x+box.w - ball.x
			dis_y = box.y - ball.y

			if dis_x >= 0 then
				--ball directly above or below box--
				return false

			elseif dis_y/dis_x < slope then
				--line ball -> corner more -ve than ball trajectory  
				--means ball will hit top of box--
				return false

			else
				--ball will hit side of box--
				return true
			end
		end
	end
end
-->8
--render--

function drawbackground()
	--render background--
	cls(bkgrnd_col)
end

function drawball()
	--remder ball--
	circfill(ball.x, ball.y, ball.r, ball.col)
end

function drawpaddle()
	--render paddle--
	rectfill(pad.x, pad.y, pad.x+pad.w, pad.y+pad.h, pad.col)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011900001f75000000177501a7501f7501a7500000017750177501a75000000237501f750000001f750000002375000000247501f700237502b750000002b7502770023750000000000000000000000000000000
00030000215502154021530215200f300103001030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
