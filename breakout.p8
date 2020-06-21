pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init and run--

function _init()
	--initialise--
	cls()
	
	resetgame()
end

function _update60()
	--update every frame--
	
	if mode=="start" then
		update_start()
	elseif mode=="game" then
		update_game()
	elseif mode=="gameover" then
		update_gameover()
	end
end

function _draw()
	--draw every frame--
	if mode=="start" then
		draw_start()
	elseif mode=="game" then
		draw_game()
	elseif mode=="gameover" then
		draw_gameover()
	end
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
		pad.vel /= 1.8
	end
	
	pad.x += pad.vel

end


-->8
--collision--

function ballwallcollision()
	--ball wall collision--
	
		--ball position next frame--
	local nextx = ball.x + ball.dx
	local nexty = ball.y + ball.dy

	if nextx > 127 or nextx < 0 then
		--left and right walls--
		mid(0,nextx,127) --sets ball to 0 or 127
		ball.dx *= -1
		sfx(01)
	end
	if nexty > 127 or nexty < 0 then
		--top and bottom walls--
		mid(0,nexty,127) --sets ball to 0 or 127
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
																	
	if ball_hitbox(pad_box) then
		if calc_refl_dir(ball, pad_box) then
			ball.dx = -ball.dx
			sfx(02)
		else
			ball.dy = -ball.dy
			sfx(02)
		end
	end
end

function ballbrickcollision()
	--ball brick collision--
	for i=1,#bricks do																
		if ball_hitbox(bricks[i]) and bricks[i].vis then
			if calc_refl_dir(ball, bricks[i]) then
				ball.dx = -ball.dx
			else
				ball.dy = -ball.dy
			end
			sfx(05)
			points+=1
			bricks[i].vis = false
		end
	end
end

function ball_hitbox(box)
	--returns true if ball in specified box--
	
	--ball position next frame--
	local nextx = ball.x + ball.dx
	local nexty = ball.y + ball.dy
	
	if nexty-ball.r > box.y+box.h then
		--ball underneath box--
		return false
	elseif nexty+ball.r < box.y then
		--ball above box--
		return false
	end
	
	if nextx-ball.r > box.x+box.w then
		--ball to the right of box--
		return false
	elseif nextx+ball.r < box.x then
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
		if slope > 0 and ball.dx > 0 then
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

function draw_start()
	--start screen--
	cls()
	print("breakout", hcenter(8), 30, 11)
	print("press ❎ to start", hcenter(17), 40, 11)
end

function draw_gameover()
	--game over screen--
	cls()
end

function draw_game()
	--game screen--
	draw_background()
	draw_ball()
	draw_paddle()
	draw_bricks()
end

function draw_background()
	--render background--
	cls(1)
end

function draw_ball()
	--remder ball--
	circfill(ball.x, ball.y, ball.r, ball.col)
end

function draw_paddle()
	--render paddle--
	rectfill(pad.x, pad.y, pad.x+pad.w, pad.y+pad.h, pad.col)
end

function draw_bricks()
	for i=1,#bricks do
		if(bricks[i].vis) then
			rectfill(bricks[i].x,bricks[i].y,bricks[i].x+bricks[i].w, bricks[i].y+bricks[i].h, bricks[i].col)
		end
	end
end

-->8
--game states--

function resetgame()
	mode = "start"
end

function playgame()
	mode = "game"
	
	ball = {x = 64,
								dx = 1,
									y = 64,
								dy = 1,
									r = 2,
							col = 9}
	
	pad = {x = 52,
						vel = 0,
						acc = 3,
								y = 120,
								w = 24,
								h = 3,
						col = 7}
	
	bricks={}
	
	for i=1,6 do
		add(bricks,{x=10*i,y=64,w=5,h=4,col=14,vis=true })
	end

end

end

function gameover()
	mode = "gameover"
end

function update_start()
	--start game state--
	if btn(5) then
		playgame()
	end
end

function update_gameover()
	--game over state--
end

function update_game()
	--playing game state--
	padmove()
	padwallcollision()
	
	ballwallcollision()
	
	ballpadcollision()
	
	ballbrickcollision()
	
	ballmove()
end
-->8
--helper functions--

function hcenter(s)
  --given length of string
  --return horizontal center position--
  return 64-s*2
end

function randint(low, high)
	--given a min and max
	--returns a random int--
	return flr(rnd(high)) + low
end

function randpn()
	--returns 1 or -1 randomly
	
	if rnd() >= 0.5 then
		return 1
	else
		return -1
	end
end

function hright(s)
	--given length of string
 --return horizontal right position--
 return 128-s*4
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
01030000215502154021530215200f300103001030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000155501554015530155200f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
