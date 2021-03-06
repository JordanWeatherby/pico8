pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init and run--

function _init()
  --initialise game--
  cls()
  start_menu()
  set_countries()

  --make black non transparent--
  palt(0, false)
  --make pink transparent--
  palt(14, true)
end

function _update()
  --update game state each frame--
  if mode=="startmenu" then
    update_start_menu()
  elseif mode=="practicemenu" then
    update_practice_menu()
  elseif mode=="practicelist" then
    update_practice_list()
  elseif mode=="practiceflashcard" then
    update_practice_flashcard()
  elseif mode=="test" then
    update_test()
  elseif mode=="testover" then
    update_testover()
  end
end

function _draw()
 --update game screen each frame--
  if mode=="startmenu" then
    draw_menu(startmenu)
  elseif mode=="practicemenu" then
    draw_menu(practicemenu)
  elseif mode=="practicelist" then
    draw_practice_list()
  elseif mode=="practiceflashcard" then
    draw_practice_flashcard()
  elseif mode=="test" then
    draw_test()
  elseif mode=="testover" then
    draw_testover()
  end
end


-->8
--game states--

function start_menu()
  --initial game menu--
  mode="startmenu"
  
  startmenu={
    x=8,
    y=40,
    options={"practice","test"},
    sel=1,
    col1=7,
    col2=1,
    bkgcol=6
  }

  --set menu cursor location--
  cx=startmenu.x

end

function practice_menu()
  --menu for practice modes--
  mode="practicemenu"
  
  practicemenu={
    x=8,
    y=40,
    options={"list","flashcard"},
    sel=1,
    col1=7,
    col2=1,
    bkgcol=6
  }

  --set menu cursor location--
  cx=practicemenu.x

end

function practice_list()
  --list of all flags in game--
  mode="practicelist"

  --used for scrolling list--
  ypos=0
end

function practice_flashcard()
  --large flag image with name--
  mode="practiceflashcard"
  rand=randint(1,#countries)
end

function test()
  --test users flag skills--
  mode="test"
  score=0

  --pick a random flag--
  ans=randint(1,#countries)

  answermenu={
    x=8,
    y=64,
    options={""},
    sel=1,
    col1=7,
    col2=1,
    bkgcol=6
  }
  cx=answermenu.x

  --set answers, answers are really a menu--
  answermenu.options = testoptions()
end

function testover()
  --test complete--
  mode="testover"
end

-->8
--render--
function draw_menu(menu)
  --generic menu draw function--

  --set background--
  cls(menu.bkgcol)

  --draw all menu options with first option in a box with secondary colour--
  for i=1, #menu.options do
    oset=i*8
    if  i==menu.sel then
      rectfill(cx,menu.y+oset-1,cx+(#menu.options[i]*4),menu.y+oset+5,menu.col1)
      print(menu.options[i],cx+1,menu.y+oset,menu.col2)
    else
      print(menu.options[i],menu.x,menu.y+oset,menu.col1)
    end
  end
end

function draw_practice_list()
  --draw list of all flags in game--

  --grey background--
  cls(6)

  for i=1,#countries do
    local xoff = 0
    local yoff = 0
    local lastsprite = 0
    local sprite_n = 16*ceil(i/8)+(2*i)-18
    local sprite_y = (i-1)*11+ypos+3
    
    --flags represent missing pixels clockwise 1-4 from top--
    --  0 
    --3   1
    --  2
    local sprite_top = not fget(sprite_n, 0)
    local lastsprite_bottom = not fget(lastsprite, 2)

    spr(sprite_n, 10, sprite_y, 2,2)
    print(countries[i], 30, sprite_y+1,7)
    -- if sprite_top and lastsprite_bottom then
    --   --add space between them--
    --   spr(sprite_n, 10, sprite_y+1, 2,2)
    --   print(countries[i], 30, sprite_y+1,7)
    --   print(1, 100, sprite_y+1,7)
    -- elseif not sprite_top and not lastsprite_bottom then
    --   --remove space between them--
    --   spr(sprite_n, 10, sprite_y-1, 2,2)
    --   print(countries[i], 30, sprite_y-1,7)
    --   print(2, 100, sprite_y-1,7)
    -- else
    --   --dont change spacing--
    --   spr(sprite_n, 10, sprite_y, 2,2)
    --   print(countries[i], 30, sprite_y,7)
    --   print(3, 100, sprite_y,7)
    -- end

    lastsprite = i
  end
end


function draw_practice_flashcard()
  --draw large flag image with name--

  --grey background--
  cls(6)

  --zspr scales sprite, here have scaled x4--
  zspr(16*ceil(rand/8)+(2*rand)-18, 32, 24, 2, 2, 4)

  --show country name--
  print(countries[rand], hcenter(#countries[rand]), 80)
end

function draw_test()
  --draw large flag and display answers and score--
  draw_menu(answermenu)

  --zspr scales sprite, here have scaled x4--
  zspr(16*ceil(ans/8)+(2*ans)-18, 32, 24, 2, 2, 4)

  --display score--
  print("score: "..score,10,10,7)
end

function draw_testover()
  --draw test over screen--

  cls(6)
  scorestr = "you scored: "..score
  print(scorestr, hcenter(#scorestr),32,7)
  print("press 🅾️ to retry", hcenter(17), 64, 7)
  print("press ❎ to return to main menu", hcenter(31), 70, 7)
end
-->8
--update--

function update_cursor(menu)
  --move menu cursor based on button input--

  --cursor up--
  if (btnp(2)) menu.sel-=1 cx=menu.x sfx(0)
  --cursor down--
  if (btnp(3)) menu.sel+=1 cx=menu.x sfx(0)
  --select option--
  if (btnp(4)) cx=menu.x  sfx(1)
  --loop options--
  if (menu.sel>#menu.options) menu.sel=1
  if (menu.sel<=0) menu.sel=#menu.options
  
  --adds bounciness to cursor--
  cx=lerp(cx,menu.x+5,0.5)
end

function update_start_menu()
  --handle start menu selection--
  update_cursor(startmenu)
  
  if btnp(4) then
    if startmenu.options[startmenu.sel]=="practice" then
      practice_menu()
    elseif startmenu.options[startmenu.sel]=="test" then
      test()
    end
  end
end

function update_practice_menu()
  --handle practice menu selection--
  update_cursor(practicemenu)
  
  if btnp(4) then
    if practicemenu.options[practicemenu.sel]=="list" then
      practice_list()
    elseif practicemenu.options[practicemenu.sel]=="flashcard" then
      practice_flashcard()
    end
  elseif btnp(5) then
    start_menu()
  end
end

function update_practice_list()
  --handle button input on flag list--

  if btn(3) and ypos>-436 then
    --scroll down--
    ypos -= 1
  elseif btn(2) and ypos<0 then
    --scroll up--
    ypos +=1
  elseif btnp(1) and ypos>-436 then
    --jump one screen down--
    ypos = mid(ypos,ypos-128,-436)
  elseif btnp(0) and ypos<0 then
    --jump one screen up--
    ypos = mid(ypos,ypos+128,0)
  elseif btnp(5) then
    --go back to practice menu--
    practice_menu()
  end
end

function update_practice_flashcard()
  --handle button input on flashcard screen--
  if btnp(4) then
    --select new random flag--
    rand=randint(1,#countries)
  elseif btnp(5) then
    --go back to practice menu--
    practice_menu()
  end
end

function update_test()
  --handle test answer selection--
  update_cursor(answermenu)
  
  if btnp(4) then
    if answermenu.options[answermenu.sel] == countries[ans] then
      --correct answer--
      score += 1
      next_question()
    else
      --incorrect answer--
      testover()
    end
  end
end

function testoptions()
  --generate test answer options--
  local answers = {}

  --add correct answer--
  add(answers, countries[ans])
  while #answers<4 do
    --get random country--
    randans = randint(1,#countries)
    print(randans,100,10,7)
    if not (tablecontains(answers,countries[randans])) then
      --add random country to answers if not already added--.
      add(answers, countries[randans])
    end
  end

  --shuffle answers array--
  for i = #answers, 1, -1 do
    local j = randint(1,i)
    answers[i], answers[j] = answers[j], answers[i]
  end 

  return answers
end

function next_question()
  --pick a new country and generate new answers--
  
  --reset cursor--
  cx=answermenu.x
  answermenu.sel=1

  ans=randint(1,#countries)
  answermenu.options = testoptions()
end

function update_testover()
  --hand button input on test over screen--
  if btnp(4) then
    --restart--
    test()
  elseif btnp(5) then
    --go to start menu--
    start_menu()
  end
end
-->8
--helper functions--

function lerp(startv,endv,per)
  --linear interpolation--
  return(startv+per*(endv-startv))
end

function randint(low, high)
    --given a min and max
    --returns a random int--
    return flr(rnd(high)) + low
end

function zspr(n,dx,dy,w,h,dz)
    --scales sprite n (plus w and h sprite range)
    --at location dx dy by dz amount
  sx = 8 * (n % 16)
  sy = 8 * flr(n / 16)
  sw = 8 * w
  sh = 8 * h
  dw = sw * dz
  dh = sh * dz

  sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end

function hcenter(s)
  --given length of string
  --return horizontal center position--
  return 64-s*2
end

function tablecontains(table, element)
  --checks if given element is in given table--
  for i=1,#table do
    if table[i] == element then
      return true
    end
  end
  return false
end

function set_countries()
  countries={
    "albania",
    "andorra",
    "armenia",
    "austria",
    "azerbaijan",
    "belarus",
    "belgium",
    "bosnia and herzegovina",
    "bulgaria",
    "croatia",
    "cyprus",
    "czechia",
    "denmark",
    "estonia",
    "finland",
    "france",
    "georgia",
    "germany",
    "greece",
    "hungary",
    "iceland",
    "ireland",
    "italy",
    "kazakhstan",
    "kosovo",
    "latvia",
    "liechtenstein",
    "lithuania",
    "luxembourg",
    "malta",
    "moldova",
    "monaco",
    "montenegro",
    "netherlands",
    "north macedonia",
    "norway",
    "poland",
    "portugal",
    "romania",
    "russia",
    "san marino",
    "serbia",
    "slovakia",
    "slovenia",
    "spain",
    "sweden",
    "switzerland",
    "turkey",
    "ukraine",
    "united kingdom",
    "vatican city"
  }
end





__gfx__
888888888888888811111aaaaa88888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000aaaaa88888eeeeeeeeeeeeeeeee
880888088088808811111aaaaa88888e88888888888888888888888888888888cccccccccccccccc878888888888888800000aaaaa88888e1117199999999111
8880088008800888111114a4a488888e88888888888888888888888888888888cccccccccccccccc788888888888888800000aaaaa88888e1111719999999111
888880000008888811111a888a88888e88888888888888888888888888888888cccccccccccccccc888888888888888800000aaaaa88888e1111171999999111
8880000000000888111114888488888e111111111111111177777777777777778888888788888888788888888888888800000aaaaa88888e1111117199999111
888880000008888811111488a488888e111111111111111177777777777777778888887887888888878888888888888800000aaaaa88888e1111111719999111
888008800880088811111a444a88888e111111111111111177777777777777778888888788888888788888888888888800000aaaaa88888e1111111171999111
888888088088888811111aaaaa88888eaaaaaaaaaaaaaaaa88888888888888883333333333333333883333333333333300000aaaaa88888e1111111117199111
888800800800888811111aaaaa88888eaaaaaaaaaaaaaaaa88888888888888883333333333333333783333333333333300000aaaaa88888e1111111111719111
888888888888888811111aaaaa88888eaaaaaaaaaaaaaaaa88888888888888883333333333333333873333333333333300000aaaaa88888eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
7777777777777777888888888888888e777777777777777717777777777777778888877888888888eeeeeeeeeeeeeeee7777117777777777111117777788888e
7777777777777777888888888888888e77777777777779771177777777777777888887788888888811111111111111117777117777777777111117777788888e
777777777777777788888c1c0c88888e77777777777797771117777777777777888887788888888811111111111111117777117777777777111117777788888e
3333333333333333777777878777777e77799999999977771111777777777777888887788888888811111111111111117777117777777777111117777788888e
3333333333333333777777787777777e77779999999777771111177777777777777777777777777700000000000000001111111111111111111117777788888e
3333333333333333777777878777777e77777999997977771111188888888888777777777777777700000000000000001111111111111111111117777788888e
8888888888888888111111181111111e77777777777777771111888888888888888887788888888800000000000000007777117777777777111117777788888e
8888888888888888111111111111111e77777733377777771118888888888888888887788888888877777777777777777777117777777777111117777788888e
8888888888888888111111111111111e77777777777777771188888888888888888887788888888877777777777777777777117777777777111117777788888e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777777777771888888888888888888887788888888877777777777777777777117777777777111117777788888e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
7777777887777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1117887111111111bbbbb7777799999e333337777788888ecccccccccccccccc
77778778877778770000000000000000cc7ccccccccccccc88888888888888881117887111111111bbbbb7777799999e333337777788888ecacccccccccccccc
77787778877787770000000000000000cc7cc7777777777788888888888888881117887111111111bbbbb7777799999e333337777788888ecccccccccacccccc
7777777887777777000000000000000077777ccccccccccc88888888888888887777887777777777bbbbb7777799999e333337777788888ecaccccccaaaccccc
88888888888888888888888888888888cc7cc7777777777777777777777777778888888888888888bbbbb7777799999e333337777788888ecccccccccacccccc
88888888888888888888888888888888cc7ccccccccccccc77777777777777778888888888888888bbbbb7777799999e333337777788888ecacccccacccacccc
77777778877777778888888888888888777777777777777777777777777777777777887777777777bbbbb7777799999e333337777788888eccccccccaaaccccc
7777877887777877aaaaaaaaaaaaaaaacccccccccccccccc33333333333333331117887111111111bbbbb7777799999e333337777788888ecacccccccccccccc
7778777887778777aaaaaaaaaaaaaaaa777777777777777733333333333333331117887111111111bbbbb7777799999e333337777788888ecccccccccccccccc
7777777887777777aaaaaaaaaaaaaaaacccccccccccccccc33333333333333331117887111111111bbbbb7777799999e333337777788888eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
111111111111111122222222222222221111111111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee767777778888888811111aaaaa88888e8888888888888888
11117171717111112222222222222222111a11111111111199999999999999998888888888888888656777778888888811111aaaaa88888e8888888888888888
1111111111111111222222222222222211a0a1111111111199999999999999998888888888888888767777778888888811111aaaaa88888e8888888888888888
1117119911171111222222222222222211aaa1111111111199999999999999998888888888888888777777778888888811111aa4aa88888e8888888888888888
11111999991111117777777777777777111111111111111133333333333333337777777777777777777777778888888811111a484a88888e8888888888888888
11119999999111117777777777777777888888888888888833333333333333337777777777777777777777778888888811111a4c4a88888e7777777777777777
11111999991111112222222222222222888888888888888833333333333333337777777777777777777777778888888811111aa4aa88888e7777777777777777
1111199991111111222222222222222288888888888888888888888888888888cccccccccccccccc777777778888888811111aaaaa88888e7777777777777777
1111119111111111222222222222222288888888888888888888888888888888cccccccccccccccc777777778888888811111aaaaa88888e7777777777777777
1111111111111111222222222222222288888888888888888888888888888888cccccccccccccccc777777778888888811111aaaaa88888e7777777777777777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
999999999999999eeeeeeeeeeeeeeeee888a888a888a888e88871178888888887777777777777777333333888888888811111aaaaa88888eeeeeeeeeeeeeeeee
988888888888889e88888888888888888888a88a88a8888e88871178888888887777777777777777333333888888888811111aaaaa88888e7777777777777777
988888888888889e888888888888888888888a888a88888e888711788888888877777777777777773333aaaa8888888811111aaaaa88888e7777777777777777
988888898888889e88888888888888888888888a8888888e77771177777777777777777777777777333a8888a888888811111aaaaa88888e7777777777777777
988898989898889e7777777777777777aaaaa8a8a8aaaaae11111111111111117777777777777777333a8778a888888811111aaaaa88888e1111111111111111
988889919988889e77777777777777778888888a8888888e11111111111111118888888888888888333a8778a888888811111aaaaa88888e1111111111111111
988888939888889e777777777777777788888a888a88888e77771177777777778888888888888888333a8888a888888811111aaaaa88888e1111111111111111
988889898988889e11111111111111118888a88a88a8888e888711788888888888888888888888883333aaaa8888888811111aaaaa88888e8888888888888888
988888888888889e1111111111111111888a888a888a888e88871178888888888888888888888888333333888888888811111aaaaa88888e8888888888888888
999999999999999e1111111111111111888888888888888e88871178888888888888888888888888333333888888888811111aaaaa88888e8888888888888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
7777777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888888888888888cccccaaccccccccc8888888888eeeeee8888888888888888
77777777777777778888888888888888777777777777777777777777777777778888888888888888cccccaaccccccccc8888888888eeeeee8888888888888888
77777779977777778888888888888888777777777777777777777777777777778888888888888888cccccaaccccccccc8888778888eeeeee8887778888888888
777777999977777788889988888888887788877777777777777cc777777777779999999999999999cccccaaccccccccc8888778888eeeeee8878888888888888
777777399377777711187781111111111187811111111111ccc77ccccccccccc9998799999999999aaaaaaaaaaaaaaaa8877777788eeeeee8878887888888888
ccccc3c99c3ccccc11187781111111111187811111111111cccccccccccccccc999a899999999999aaaaaaaaaaaaaaaa8877777788eeeeee8878888888888888
cccccc3993cccccc11187781111111111111111111111111cccccccccccccccc9999999999999999cccccaaccccccccc8888778888eeeeee8887778888888888
cccccc7777cccccc7777887777777777888188888888888888888888888888888888888888888888cccccaaccccccccc8888778888eeeeee8888888888888888
cccccccccccccccc7777777777777777888888888888888888888888888888888888888888888888cccccaaccccccccc8888888888eeeeee8888888888888888
cccccccccccccccc7777777777777777888888888888888888888888888888888888888888888888cccccaaccccccccc8888888888eeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccc8811117887111188aaaaaaaa77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccc1188117887118811aaaaaaaa77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccc1111887887881111aaaaaaaa777aa777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccc7777777887777777aaaaaaaa77677a77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cccccccccccccccc8888888888888888aaaaaaaa7776a777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999999999999998888888888888888aaaaaaaa777a6777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999999999999997777777887777777aaaaaaaa77a77677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999999999999991111887887881111aaaaaaaa77788777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999999999999991188117887118811aaaaaaaa77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999999999999998811117887111188aaaaaaaa77777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
0000020201010101010101010202050500000202010101010101010102020505000002020000000000000101000002020000020200000000000001010000020200000101010101010000020202020404000001010101010100000202020204040000000000000101010100000202000000000000000001010101000002020000
0202010100000000000000000202010102020101000000000000000002020101000001010101010100000000020200000000010101010101000000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
