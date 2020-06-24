pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init and run--

function _init()
	--initialise--
	cls()
	
	startgame()
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
	ball.x = nextx
	ball.y = nexty
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
	
	local wallx1=ball.r --left wall
	local wallx2=127-ball.r --right wall
	local wally1=ui_h+ball.r -- ceiling
	local wally2=127-ball.r --floor
	
	if nextx < wallx1 or nextx > wallx2 then
		--left and right walls--
		nextx=mid(wallx1,nextx,wallx2) --sets ball to 0 or 127
		ball.dx *= -1
		sfx(01)
	end
	
	if nexty < wally1 then
		--top wall--
		nexty=mid(wally1,nexty,wally2) --sets ball to 0 or 127
		ball.dy *= -1
		sfx(01)
		
	elseif nexty > wally2 then
		--bottom--
		die()
		sfx(03)
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
			--horizontal refection--
			ball.dx = -ball.dx
			if ball.x < pad.x+(pad.w/2) then
				--left pad edge collision--
				nextx=pad.x-ball.r
			else
				--right pad edge collision--
				nextx=pad.x+pad.w+ball.r
			end
		else
			--vertical refection--
			ball.dy = -ball.dy
			if ball.y > pad.y then
				--ball under pad--
				nexty = pad.y+pad.h+ball.r
			else
				nexty = pad.y-ball.r
			end
		end
		sfx(02)
		points+=1
	end
end

function ballbrickcollision()
	--ball brick collision--
	
	--check if ball hit brick this frame-- 
	local brickhit=false
	
	for i=1,#bricks do
		--check all brick collisions--																
		if ball_hitbox(bricks[i]) and bricks[i].vis then
			--only visible bricks can be hit--
			if not brickhit then
				--only have 1 brick collision per frame--
				if calc_refl_dir(ball, bricks[i]) then
					--horizontal reflection--
					ball.dx = -ball.dx
				else
					--vertical reflection--
					ball.dy = -ball.dy
				end
			end
			brickhit=true
			sfx(05)
			points+=1
			bricks[i].vis = false
		end
	end
end

function ball_hitbox(box)
	--returns true if ball in specified box--
	
	--ball position next frame--
	nextx = ball.x + ball.dx
	nexty = ball.y + ball.dy
	
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
	print("breakout", hcenter(8), 40, 11)
	print("press ❎ to start", hcenter(17), 60, 11)
end

function draw_gameover()
	--game over screen--
	cls()
	print("game over!", hcenter(10), 40, 8)
	print("press ❎ to restart", hcenter(19), 60, 8)
end

function draw_game()
	--game screen--
	draw_background()
	draw_ball()
	draw_paddle()
	draw_bricks()
	draw_ui()
end

function draw_background()
	--render background--
	cls(1)
end

function draw_ui()
	ui_h=7
	rectfill(0,0,128,ui_h,0)
	print("lives: "..lives,1,1,7)
	print("score: "..points,hright(7+#tostr(points)),1,7)
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

function startgame()
	mode = "start"
	lives = 3
	points = 0
	--sfx(06)
end

function playgame()
	mode = "game"
	
	ball = {x = 64,
								dx = randpn(),
									y = 70,
								dy = -1,
									r = 2,
							col = 9}
							
	
	if lives == 3 then
		buildbricks()
		
			pad = {x = 52,
						vel = 0,
						acc = 3,
								y = 120,
								w = 24,
								h = 3,
						col = 7}
	end
end

function buildbricks()
	bricks={}
		
	for i=1,9 do
		for j=1,8 do
			add(bricks,{x=12*i,
			y=8+(6*j),
			w=10,
			h=4,
			col=14,
			vis=true })
		end	
	end
end

function die()
	lives -= 1
	
	if lives <= 0 then
		gameover()
	else
		playgame()
	end
	
end

function gameover()
	mode = "gameover"
	sfx(04)
end

function update_start()
	--start game state--
	if btnp(5) then
		playgame()
	end
end

function update_gameover()
	--game over state--
	if btnp(5) then
		startgame()
	end
end

function update_game()
	--playing game state--
	padmove()
	padwallcollision()
	
	ballwallcollision()
	
	ballbrickcollision()
	
	ballpadcollision()
	
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
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011900001f75000000177501a7501f7501a7500000017750177501a75000000237501f750000001f750000002375000000247501f700237502b750000002b7502770023750000000000000000000000000000000
00030000215502154021530215200f300103001030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000155501554015530155200f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002805026050220501b05016050110500d0502805026050220501b05016050110500d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000027050240501e050160500e050000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002d5502d5402d5302d5200f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00001f75000000177501a7501f7501a7500000017750177501a75000000237501f75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
