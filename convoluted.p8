pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init and run--

blocks={}
colours={8,9,11,12,14}
bw=10
bh=10

cy=0
ci=0
function _init()
    generate_blocks(bw*bh)
    bx = 64-(4*bw)
    by = 64-(4*bh)

    cy = by
end

function _update()
  --cursor up--
  if btnp(2) and cy>by then 
    cy-=8
    ci-=1
  end
  --cursor down--
  if btnp(3) and cy<(by+(bh*8)) then 
    cy+=8
    ci+=1
  end

  --cursor left--
  if btnp(0) then
    local blockind = (ci*bw)+1
    local tmp = blocks[blockind]
    deli(blocks, blockind)
    add(blocks, tmp, blockind+bw-1)
  end
  
  --cursor right--
  if btnp(1) then
    local blockind = (ci*bw)
    local tmp = blocks[blockind+bw]
    deli(blocks, blockind+bw)
    add(blocks, tmp, blockind+1)
  end
end

function _draw()
    cls()
    draw_blocks(blocks, 6)
    spr(0, bx-8, cy)
    spr(1, bx+(bw*8), cy)
    print(cy,10,10,7)
end


function draw_blocks(blocks)
    for i=0, #blocks-1 do
        local blockx = bx+((i%bw)*8)
        local blocky = by+(flr(i/bw)*8)
        rectfill(blockx, blocky,blockx+7,blocky+7,blocks[i+1])
    end
end

function generate_blocks(num)
    for i=1, num do
        add(blocks, colours[randint(1,5)])
    end
end

-->8
--helper functions--
function randint(low, high)
    --given a min and max
    --returns a random int--
    return flr(rnd(high)) + low
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
