pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
points = 0

button = {}
button.x = 60
button.y = 80
button.sprite = 4

function _update()
	if btn(4) or btn(5) then
		points += 1
		button.sprite = 2
	else
		button.sprite = 4
	end
end



function _draw()
	cls()
	print(points, 64, 64)
	spr(button.sprite, button.x, button.y)
	spr(button.sprite+1, button.x+8, button.y)

end
__gfx__
00000000000000000000000000000000007777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077777777777700070000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700000000000070700000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007700000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007770000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007707777777777770700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700000000000070070000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077777777777700007777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000