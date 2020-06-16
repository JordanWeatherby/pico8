pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
sprite = 1
anicount = 0
fox_x = 0
fox_y = 64
speed = flr(rnd(3))+1


function _update()
	anicount += 1
	fox_x += speed
	if anicount == 3 then
		sprite += 1
		anicount = 0
		if sprite > 3 then
			sprite = 1
		end
	end
	
	if fox_x >= 128 then
		fox_x = 0
		speed = flr(rnd(3))+1
		fox_y = flr(rnd(120))+8
	end
end

function _draw() 
	cls()
	spr(sprite, fox_x, fox_y)
	
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700090000000900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000900000909000009090000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000900000999000009990000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700099999000999990009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090009000900090099000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090000909000090000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000d000000000000003335033350333503335033350343501b5501c5503435030650343503065018350343502d650343502a5502615034350343502e150343503435034350343503335032350313503135030350