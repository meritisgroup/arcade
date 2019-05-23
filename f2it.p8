pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--girls in space
--girls in space
--shooter game by f2it


time_per_level = 35
level=0
fadered={14,8,2,1 }
fadegreen={11,3,3,5 }
fadeyellow={5,4,9,10}
fadeship={14,8,2,1}
fadegrey ={6,6,13,5 }
fadeblue ={12,13,1,5 }
fades={fadered, fadegreen, fadeyellow, fadeblue}

ada_pal={{12,3},{10,5},{4,2}, {6,13}, {8,13}, {5,13}, {2,13}}
katie_pal={{10,4},{4,8}, {6,15}, {5,0}}
hamilton_pal={{6,15},{2,5}, {8,6}}
letter_gray_pal={{10,5},{9,5}, {4,5}, {8,5}, {14,5}}
letter_dark_pal={{10,1},{9,1}, {4,1}}

nextdraw={}
nextupdate={}
logo =32
function _init()
  level=0
  skip_main=false
  letters= {
    g=218,
    i=216,
    r=220,
    l=221,
    z=222,
    n=223,
    t=217,
    s=230,
    p=219,
    a=231,
    c=232,
    e=233,
    m=234,
    h=215,
    o=198,
    u=235,
    k=236,
    b=237,
    d=238,
    v=239,
    f=246,
    plus=197}
  letters["1"] = 199  
  letters["2"] = 200  
  letters["3"] = 201  
  letters["!"] = 247  
  skip_level=false
  skip_frame = false
  skip_draw = false
  scoreup = 0
  bonus = 0
  srand(2019)
  life_saved=false
  hyperspace = 0
  explodeonscreen = 0
  t=0
  tlevel = 0
  ctime = {m=0,s=0,ms=0}
  music(11)

  transition = 0
  --make ship
  ship = {
    tho = 0,
    thx = 0,
    dir=0,
    hvel=0,
    vvel=0,
    sp=192,
    x=60,
    y=100,
    h=4,
    p=0,
    t=0,
    imm=false,
    box = {x1=0,y1=0,x2=7,y2=7}}
  bullets = {}
  smoke = {}
  smoke2 = {}
  smoke3 = {}
  ebullets = {}
  explosions = {}
  stars = {}
  hits={}
  msgs={}
  enemies = {}

  -- make stars
  for i=1,128 do
    add(stars,{
      x=rnd(128),
      y=rnd(128),
      s=rnd(8)+1,
      b=rnd(200)+1
    })
  end

  --init screen shake
  scr = {
    x = 0,
    y = 0,
    shake = 0,
    intensity = 10
  }

  start()
end

function start()
  _update = update_menu
  _draw = draw_menu
  _question = "  le programme apollo ne repose\n      que sur des hommes ?\n"
end

function time_manager()
  t=t+1
  tlevel = tlevel + 1
  scoreup = max(0, scoreup - 1)
  if scoreup == 0 then
    bonus = 0
    hits={}
  end
  ctime.ms = ctime.ms + 1/30
  if (ctime.ms >= 1) then
    ctime.ms = 0
    ctime.s = ctime.s + 1
    if (ctime.s >= 60) then
      ctime.s = 0
      ctime.m = ctime.m  + 1
    end
  end
end


function update_menu()
  movestars()
  enemies={}
  bullets={}
  ebullets={}
  smoke={}
  ship.y=56
  t = t+1
  move_ship()
  if t>30 and (btn(4) or transition > 0) then
    transition = transition + 1
    
    local shipmove = outback(max(0, transition), 0, 54, 50)
    --ship.y = min(110, 80 + transition)
    ship.y = 56 + shipmove
    if transition >= 50 then
      transition = 0
      _update = update_game
      _draw = draw_game
    end
  end
end


function outback(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inback(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

local function linear(t, b, c, d)
  return c * t / d + b
end

function drawtitleletters(goup, line1, line2)
   print2(line1, 40, 10-goup)
   print2(line2, 48, 20-goup)
end

function drawtitle(line1, line2)
 local goup = inback(max(0, transition - 30), 0, 30, 20)
 
  pal()

  camera(-2,-2)
  draw_with_palette(letter_dark_pal, function() drawtitleletters(goup, line1, line2)  end)
  
  camera(-1,-1)
  draw_with_palette(letter_gray_pal, function() drawtitleletters(goup, line1, line2)  end)
  
  camera()
  drawtitleletters(goup, line1, line2)

  camera(-1,0)

  pal(4,7)
  drawtitleletters(goup, line1, line2)
  pal()
  
  camera()
  
  if transition < 35 then
    pal(3, 4)
    pal(11, 9)
    pal(10, 10)
    spr(121 + rnd(2), 77, 6- goup)
    pal(3, 5)
    pal(11, 6)
    pal(10, 7)
    spr(121 + rnd(2), 109, 16 - goup)
    pal()
  end
end

function drawqrcode()
  color(7)
  rectfill(101, 101+transition, 128, 128)
  pal(1, 0)
  spr(9, 102, 102+transition, 4,4)
  pal()
end

function drawlogo()
  pal(9, 13)
  pal(10, 6)
  if t%2==0 then
    pal(11, 6)
    pal(8, 13)
    pal(3, 12)
  else
    pal(11, 0)
    pal(8, 5)
    pal(3, 0)
  end
  spr(logo, 2, 110+max(0, transition-10), 2, 2)
  pal()
end

function drawuranus()
  local allc = {7,1,2,15,14,13,12,6,8}
  local flrt = flr(t/3)%11
  for i = 1, #allc do
    if i == flrt then 
      pal(allc[i], 9)
    else   
      pal(allc[i], 10)
    end
  end

  spr(64, 5, 5- 4 * transition, 3, 3)
  pal()
end

function drawbadguys()
  spr(160+2*(flr(t/8)%4),20,50- 3 * transition,2,2)
  spr(168+2*(flr(t/7)%4),80,35- 3 * transition,2,2)
  spr(138 + (t/5)%6,80,56- 4 * transition)
  spr(138 + (t/5)%6,96,56- 4 * transition)
  spr(138 + (t/5)%6,112,56- 4 * transition)
end

function draw_menu()
  cls()
  drawstars()
  drawship()
  drawuranus()
  if not skip_main then
    drawbadguys()
    drawtitle("girlz", "in space")
    drawlogo()
    drawqrcode()
  else
    drawtitle(" level "..(level+1), "")
  end
  if transition > 35 then
    local dh = linear(max(0, transition - 35), -8, 8, 15)
    drawhearts(dh);
    drawscore(dh);
  end

  if transition < 10 then
    print(_question.."\n\n\n      tapez x pour vrai \n      tapez c pour faux",2,81,5)
    print(_question,1,80,7)
    print("\n\n\n\n\n      tapez x pour vrai",1,80,6 +  ((t)/16)%2)
    print("\n\n\n\n\n\n      tapez c pour faux",1,80, 6 +  ((t+16)/16)%2)
    print("\n\n\n\n\n            x",1,80,1 +  11*flr(((t+15)/4)%2))
    print("\n\n\n\n\n\n            c",1,80,2 +  6*flr(((t+15)/4)%2))
  end
end


function draw_quizz2()
  _update = update_menu
  _draw = draw_menu
  skip_main=true
  _question = " la toute premiere photo d'un \ntrou noir a ete devoilee \npar des hommes ?"
end

function draw_quizz3()
  _update = update_menu
  _draw = draw_menu
  skip_main=true
  _question = " le tout premier programme \ninformatique a ete realise \n par un homme ?"
end

function restore_life()
  ship.h=4
  ship.imm = false
  enemies={}
  bullets={}
  ebullets={}
  smoke={}
end

function update_heroine()
  restore_life()
  movestars()
  t = t+1
  if btn(5) then
    _update = nextupdate
    _draw = nextdraw
    level=level+1
  end
end

function draw_with_palette(palette, drawfunction)
   for conv in all(palette) do
    pal(conv[1], conv[2])
  end
  drawfunction()
  pal()

end

function hello_heroine()
  if flr((t/10)%2) == 1 then
    pal(3, 15)
    pal(11, 0)
  else
    pal(3, 0)
    pal(11, 15)
  end
end

function draw_heroine_screen(name1, name2, lines, palette)
  cls()
  drawstars()
  local goup = 0

  draw_with_palette(letter_gray_pal,
   function() 
      print2(name1, 1, 11)
      print2(name2, 11, 21) 
    end)
  
  
  print2(name1, 0, 10)
  print2(name2, 10, 20)

  
  drawcup(96, 10)

  
  hello_heroine()
  draw_with_palette(palette,function() spr(23, 32, 32, 2, 2) end)

  print(lines,1,70, 7)
  print("   tapez x pour continuer", 1+1, 118+1, 5)
  print("   tapez x pour continuer", 1, 118, 7)
  print("         x",1,118,1 +  11*flr(((t+15)/4)%2))
end

function draw_ada()
 draw_heroine_screen(
    "ada", "lovelace", "voici ada lovelace :) \npionniere de la science \ninformatique elle a realise le \ntout premier programme \ninformatique ... \n..sur l'ancetre de l'ordinateur: \nla machine analytique.  \n\n", ada_pal)
end

function draw_katie()
  draw_heroine_screen("katie", "bouman", "katie bouman ! \ncette informaticienne et \nchercheuse a devoile la toute \npremiere image d'un trou \nnoir avec son algorithme chirp.\n\n\n\n", katie_pal)
end

function draw_hamilton()
  draw_heroine_screen("margaret", "hamilton", "voici margaret hamilton\n\ncette informaticienne a concu \nle systeme embarque du programme\nspatial apollo.\n\n\n\n", hamilton_pal)
end

function drawcup(x, y)
  spr(76, x, y, 4, 4)
  pal(3, 4)
  pal(11, 9)
  pal(10, 10)
  spr(121 + rnd(2), x+16, y)
  pal()
end

function print2(text, x, y)
  local x_= x
  for i = 1, #text do
    spr(letters[sub(text, i, i)], x_, y)
    x_ = x_ + 8  
  end
end

function none()
end

function drawchain(b)
  local colors = {1, 5, 4, 10, 9, 8}
  circfill(b.x, b.y, 16, colors[b.ttl])
end

function chainexplode(b)
if b.big then
  add(bullets, {
      draw=drawchain,
      ttl = 6,
      damage=1,
      x=b.x,
      y=b.y,
      dx=0,
      dy=0,
      box = {x1=-16,y1=-16,x2=16,y2=16}
    })
    end
end

function drawdebris(d)
  local dcolor = d.pal[d.col]
  circfill(d.x, d.y, rnd(1.5), dcolor)
  d.x = d.x + d.dx
  d.y = d.y + d.dy
  if rnd(100) < 20 then
    d.col = d.col -1
  end
  if d.col == 0 then
    del(smoke, d)
  end
end

function pmachine(b)
  for i=0,30 do
    add(smoke, rmachine(b.x+4, b.y+4, fadeyellow, 0.7))
  end
end

function rmachine(x, y, pal, derive)
  local angle = rnd(1)
  local vel = rnd(1) + 0.1
  return { x=x, y = y , dx = cos(angle) * vel, dy = sin(angle) * vel + derive, col=4, draw = drawdebris, pal=pal}
end

function pfadesmachine(b, fade)
  for i=0,100 do
    for j=1,4 do
      add(smoke, rmachine(b.x+rnd(16), b.y+rnd(16), fade[j], 0.7))
    end  
  end
end

function predgreenmachine(b)
  pfadesmachine(b, {fadegreen, fadered, fadegreen, fadered})
end

function pgreygreenmachine(b)
  pfadesmachine(b, {fadegreen, fadegrey, fadegrey, fadegrey})
end

function explodelittle(e, b)
  explode(b.x-2,b.y-4, false)
  explode(e.x - 8 + rnd(24) ,e.y- 8 + rnd(24), false)
  ship.p = ship.p +9 + (bonus + 1)
  if scoreup > 0 then
    if bonus == 0 then
      add(msgs, {x=e.x, y=e.y, bonus=1, dt=t, hit=true, timer=25})
    else
      add(hits, {x=e.x, y=e.y, bonus=bonus+1, dt=t})
    end
    bonus = bonus + 1
  end
  scoreup=45
  explodeonscreen = max(1 + level, explodeonscreen)
  del(enemies,e)
  chainexplode(b)
  pmachine(e)
end

function explodebig(e, b)
  skip_frame = true
  e.h = e.h - b.damage
  e.hit = 10
  explode(b.x,b.y, true)
  explodeonscreen = max(2+e.h, explodeonscreen)

  explode(e.x - 32 + rnd(64) ,e.y- 32 + rnd(64), false)
  if e.h <= 0 then
    e.particules(e)
    ship.p = ship.p + e.pts + 2*(bonus + 1)
    if scoreup > 0 then
      add(hits, {x=e.x, y=e.y, bonus=bonus+1, dt=t})
      bonus = bonus + 2
    end
    scoreup=45
    del(enemies,e)
    for i = 0,(b.damage+1)*2 do
      explode(e.x - 32 + rnd(64) ,e.y- 32 + rnd(64), false, true)
    end
    explodeonscreen = max(10 + level, explodeonscreen)
    screenshake(10)
  else
    add(msgs, {x=e.x, y=e.y, bonus=0, dt=t, hit=true, timer=25})
  end
  chainexplode(b)
end

function explode_stone(e, b)
  e.hit=10
  explode(b.x,b.y, true)
  --e.dy=e.dy-0.05*b.damage
  for i = 0, 30 do
    add(smoke, rmachine(b.x+rnd(16), b.y+rnd(16), fadegrey, 0.7))
  end  
  if rnd(100) > 50 then
    --del(enemies,e)
    for j = 1, 3 do
      add(enemies, spawn_small_stone(e))
    end  
  end
  --chainexplode(b)
end

function explode_mini_stone(e, b)
  e.hit=10
  explode(b.x,b.y, true)
  for i = 0, 30 do
    add(smoke, rmachine(b.x+rnd(16), b.y+rnd(16), fadegrey, 0.7))
  end  
end


function respawn_line(level)
  local reverse = 1
  local d = -1
  if rnd(100)<50 then reverse=-1 end
  if rnd(100)<50 then d=1 end
  for i=0,9 do
    if rnd(1)<0.5 then d=1 end
    local drawennemy = draw_little_level1
    if level >= 2 then
      drawennemy = draw_little_level3
    end
    add(enemies, {
      type=0,
      sp=19,
      t=0,
      th=0,
      m_x=i*16,
      m_y=-20 -i*4*(1+reverse)+i*4*(1-reverse),
      --d=d,
      d=d,
      x=-32,
      y=-32,
      r=12,
      explode=explodelittle,
      move = move_ennemy_line,
      draw= drawennemy,
      shoot=no_shoot,
      box = {x1=0,y1=0,x2=8,y2=5}
    })
  end
end

function spawnbig()
  add(enemies, {
    type=1,
    pts=5,
    sp=160,
    x=8 + rnd(112),
    y=-20,
    dy=1,
    dx=0,
    r=80,
    f=0,
    h=3,
    th= 30,
    hit =0,
    fs=flr(rnd(2))*2-1,
    explode=explodebig,
    particules=pgreygreenmachine,
    move=move_ennemy_big,
    draw=draw_big,
    shoot=ennemy_shoot,
    box = {x1=0,y1=0,x2=17,y2=17}
  })
end

function spawnbig2()
  add(enemies, {
    type=2,
    pts=20,
    sp=168,
    x=8 + rnd(112),
    y=-20,
    dy=1,
    r=80,
    f=0,
    h=7,
    th= 30,
    hit =0,
    rtime=0,
    fs=flr(rnd(2))*2-1,
    explode=explodebig,
    particules=predgreenmachine,
    move=move_ennemy_big2,
    draw=draw_big,
    shoot=ennemy_shoot2,
    box = {x1=0,y1=0,x2=17,y2=17}
  })
end


function spawnbig_stone()
  local hflip = false
  if rnd(100)>50 then
    hflip = true
  end
  add(enemies, {
    sp = 134 + flr(rnd(2))*2,
    type=-1,
    hit=0,
    x=-4+ship.x,--8 + rnd(112),
    y=-30,
    size=2,
    dy=0.2+ rnd(2),
    dx=0,
    r=80,
    hf=hflip,
    f=0,
    ay=max(10, rnd(100)-40)/5000,
    fs=0,
    h=3,
    explode=explode_stone,
    move=move_ennemy_big,
    draw=draw_big_stone,
    shoot=no_shoot,
    box = {x1=0,y1=0,x2=17,y2=17}
  })
end

function spawn_small_stone(e)
  local hflip = false
  if rnd(100)>50 then
    hflip = true
  end
  add(enemies, {
    sp = 154 + flr(rnd(2)),
    type=-1,
    hit=0,
    x=4+e.x+rnd(8),--8 + rnd(112),
    y=4+e.y,
    dy=0.2+ rnd(2) + e.dy,
    dx=rnd(2) - 1,
    r=80,
    hf=hflip,
    f=0,
    size=1,
    ay=max(10, rnd(100)-40)/5000,
    fs=0,
    h=3,
    explode=explode_mini_stone,
    move=move_ennemy_big,
    draw=draw_big_stone,
    shoot=no_shoot,
    box = {x1=0,y1=0,x2=7,y2=7}
  })
end

function no_shoot(e)
-- nothing
end

function ennemy_mini_shoot(e)
  e.th = e.th - 1
  if e.th <= 0 and rnd(1000) < 5 then
    e.th = 40
    add(ebullets, {
      sp=120,
      damage=1,
      x=e.x,
      y=e.y,
      dx=0,
      dy=4+rnd(2),
      box = {x1=2,y1=0,x2=5,y2=4}
    })
  end
end

function ennemy_shoot(e)
  e.th = e.th - 1
  if e.th <= 0 then
    e.th = 90
    add(ebullets, {
      sp=120,
      damage=1,
      x=e.x,
      y=e.y,
      dx=(ship.x-e.x)/60,
      dy=(ship.y-e.y)/60,
      box = {x1=2,y1=0,x2=5,y2=4}
    })
  end
end

function ennemy_shoot2(e)
  e.th = e.th - 1
  if e.th <= 0 then
    e.th = 80
    add(ebullets, {
      red=true,
      sp=120,
      damage=1,
      x=e.x,
      y=e.y,
      dx=(ship.x-e.x)/40,
      dy=(ship.y-e.y)/40,
      box = {x1=2,y1=0,x2=5,y2=4}
    })
    add(ebullets, {
      red=true,
      sp=120,
      damage=1,
      x=e.x+8,
      y=e.y+8,
      dx=(ship.x-e.x)/40,
      dy=(ship.y-e.y)/40,
      box = {x1=2,y1=0,x2=5,y2=4}
    })
    add(ebullets, {
      red=true,
      sp=120,
      damage=1,
      x=e.x-8,
      y=e.y-8,
      dx=(ship.x-e.x)/40,
      dy=(ship.y-e.y)/40,
      box = {x1=2,y1=0,x2=5,y2=4}
    })
  end
end



function hit_ennemy(e, b)

end


function screenshake(nb)
  scr.shake = nb
end


function game_over()
  _update = update_over
  _draw = draw_over
end

function update_over()
t=t+1
movestars()

  if #smoke < 200 then
    local d = 9999
    local ex = 0
    local ey = 0
    while d > 2304 do
      ex = rnd(128)
      ey = rnd(128)
      d = (ex-64)*(ex-64) + (ey-40)*(ey-40)
    end
    local fade = fades[1+flr(rnd(4))]
    for i=0,120 do
      --add(smoke, rmachine(rnd(128), rnd(128), fades[1+flr(rnd(2))], 0.7))
      add(smoke, rmachine(ex, ey, fade, 0.7))
      --add(smoke, rmachine(70, 35, fadeyellow, 0.7))
    end
  end
  
  if btnp(4) then _init() end
end

function draw_over()
  cls()
--  drawstars()
  drawcup(45, 2)
  for s in all(smoke) do
    s.draw(s)
  end
 
 
  draw_with_palette(letter_gray_pal, function()   print2("felicitations!", 6, 51) end)
  print2("felicitations!", 5, 50)
  
  
  
  print("score :",45, 60, 7)
  camera(-30,0)
  
  if flr(t/7)%3  > 0 then
    drawscore(70, true)
  end
  camera()

  print(" retrouve les",35,108,12)
  print("\nexperts meritis",33,108,12)
  print("\n\nsur notre blog",35,108,12)
  drawqrcode()
  
  --camera(-36, 0)
  drawlogo()
  camera()
  
end
--function draw_over()
--  cls()
--  drawstars()
--  drawcup(96, 24)
--  for s in all(smoke) do
--    s.draw(s)
--  end
-- 
-- 
--  draw_with_palette(letter_gray_pal, function()   print2("felicitations !", 6, 3) end)
--  print2("felicitations !", 5, 2)
--  
--  camera(0, -16)
--  hello_heroine()
--  draw_with_palette(hamilton_pal,function() spr(23, 2, 40, 2, 2) end)
--  print("margaret hamilton",20,40, 6)
--  
--  hello_heroine()  
--  draw_with_palette(katie_pal,function() spr(23, 18, 48, 2, 2) end)
--  print("katie bouman",36,48, 6)
--  
--  hello_heroine()  
--  draw_with_palette(ada_pal,function() spr(23, 34, 56, 2, 2) end)
--  print("ada lovelace",52,56, 6)  
--  camera()
--  
--  
--  print("tu as fini le jeu dans cette \ngalaxie :)",1, 16, 7)
--  print("    score :",1,33, 7)
--  camera(-30,0)
--  
--  if flr(t/7)%3  > 0 then
--    drawscore(40, true)
--  end
--  camera()
--
--  print("retrouve les experts \nmeritis sur meritis.fr \npour plus d'aventures !",1,92,12)
--  drawqrcode()
--  
--  camera(-36, 0)
--  drawlogo()
--  camera()
--  
--end

--box collision
function abs_box(s)
  local box = {}
  box.x1 = s.box.x1 + s.x
  box.y1 = s.box.y1 + s.y
  box.x2 = s.box.x2 + s.x
  box.y2 = s.box.y2 + s.y
  return box
end

function coll(a,b)
  -- todo
  local box_a = abs_box(a)
  local box_b = abs_box(b)

  if box_a.x1 > box_b.x2 or
    box_a.y1 > box_b.y2 or
    box_b.x1 > box_a.x2 or
    box_b.y1 > box_a.y2 then
    return false
  end

  return true
end

function explode(x,y, smoke, green)
  add(explosions,{x=x,y=y,t=0,f=0, size=rnd(4)+16, smoke=smoke, green = green})
  sfx(2)
end

function drawmissile(b)
  pal(14, 9*(t%2))
  spr(102, b.x,b.y)
  pal()
  add(smoke, { x=b.x + 4 - 4 + rnd(8), y= b.y+4 , size = 3+rnd(4), col = 5 + rnd(1.2) + 0.2, draw = drawsmoke})
end

function drawsmoke(b)
  if rnd(100) < 33 then
    return
  end
  circfill(b.x, b.y, 8-b.size, b.col)
  b.size = b.size - rnd(2)
  if b.size < 0 then
    del(smoke, b)
  end
  b.col = b.col - rnd(1)/2.5
  if b.col < 5 then
    del(smoke, b)
  end  
end

function drawbeamtrace(b)
  if rnd(100) < 10 then
    return
  end
  if b.size > 2 then
    circfill(b.x, b.y, 1,   flr(rnd(2))*5+7)
  else
    circfill(b.x, b.y, 1,   flr(rnd(1)) + 5)
  end  
  b.size = b.size - rnd(2) -0.1
  if b.size < 0 then
    del(smoke, b)
  end
end


function drawbeam(b)
  if rnd(100) > 80 then
    pal(6, 12)
    pal(7, 12)
    pal(5, 0)
  end
  if rnd(100) > 50 then
    pal(8, 12)
  else  
    pal(8, 0)
  end
  spr(103, b.x,b.y)
  pal()
  for i = 1, 4 do
    add(smoke, { x=b.x+4, y= b.y+5-i , size = rnd(4), draw = drawbeamtrace})
  end
end

function drawshoot(b)
    circfill(b.x+4, b.y, 4, 7)
    del(bullets, b)
end

function showshoot(b)
  add(bullets, {
    draw=drawshoot,
    ttl = 3,
    damage=1,
    x=b.x,
    y=b.y,
    dx=0,
    dy=0,
    box = {x1=0,y1=0,x2=0,y2=0}
  })
end

function fire()
  ship.hvel = min(ship.hvel, 1)
  ship.vvel = min(ship.vvel, 1)
  if ship.tho < 1 then
    ship.tho = ship.tho + 15
    local b = {
      big=true,
      draw=drawmissile,
      damage=3,
      x=ship.x,
      y=ship.y,
      dx=0,
      dy=-4.5,
      box = {x1=2,y1=0,x2=5,y2=4}
    }
    add(bullets,b)
    showshoot(b)
  end

end

function firebeam(sx, sy, dx) 
  local bc = {
    draw=drawbeam,
    damage=1,
    x=sx,
    y=sy,
    dx=dx,
    dy=-5.2,
    box = {x1=2,y1=0,x2=5,y2=4}
  }
  showshoot(bc)
  add(bullets, bc)
end

function firex()
  ship.hvel = min(ship.hvel, 1)
  ship.vvel = min(ship.vvel, 1)
  if ship.thx < 1 then
    ship.thx = ship.thx + 5
    firebeam(ship.x  , ship.y,  0)
    firebeam(ship.x-8, ship.y, -0.7)
    firebeam(ship.x+8, ship.y,  0.7)
  end
end


function move_ennemy_line(e)
  e.m_y = e.m_y + (13 + level * level) / 10
  e.x = e.r*cos(e.d*e.t/50) + e.m_x
  e.y = e.r*sin(e.t/50) + e.m_y
  e.t = e.t+1
end

function move_ennemy_big(e)
  e.y = e.y+e.dy
  e.x= e.x + e.dx
  if e.ay then
    e.dy = e.dy +e.ay
  end
  if t%8 == 0 then
    e.f = e.f + e.fs
    if e.f == 4 then
      e.f = 0
    end
    if e.f == -1 then
      e.f = 3
    end
  end
  if e.y > 128 or e.y < -50 then
    del(enemies,e)
  end

end

function move_ennemy_big2(e)
  e.y = cos((tlevel-e.rtime)/150)*25 + 25
  e.x = sin((tlevel-e.rtime)/150)*56 + 56
  if t%8 == 0 then
    e.f = e.f + e.fs
    if e.f == 4 then
      e.f = 0
    end
    if e.f == -1 then
      e.f = 3
    end
  end
  --  if e.y > 128 then
  --    del(enemies,e)
  --  end

end

function draw_little_level1(e)
  spr(138 + (t/5)%6,e.x,e.y)
end


function draw_little_level3(e)
  pal(10,11)
  pal(9,3)
  spr(138 + (t/5)%6,e.x,e.y)
  pal()
end

function draw_big(e)
  if e.hit>0 then
    e.hit=e.hit-1
    local lp = {3,4,5,8,6,11,14}
    for l in all(lp) do pal(l, 7) end
  end  
  spr(e.sp+2*e.f,e.x,e.y,2,2)
  pal()
end


function draw_big_stone(e)
  if e.hit > 0 then
    e.hit = e.hit -1
    local lp = {10,13,19,16,14,15,1}
    for l in all(lp) do pal(l, 7) end
  end
  spr(e.sp , e.x, e.y, e.size, e.size, e.hflip, false)
  pal()
  --spr(160+2*e.f,e.x,e.y,2,2)
end

function movestars(hyper)
  for st in all(stars) do
    if level == 0 or hyper then
      st.y = st.y + st.s/4
    elseif level == 1 then
      st.y = st.y + st.s/2
    elseif level >= 2 then
      st.y = st.y + st.s*0.75
    end
    st.b = st.b + 1
    if st.b > 210 then
      st.b = rnd(200)+1
    end
    --st.y = st.y + st.s
    if st.y >= 128 then
      st.y = 0
      st.x=rnd(128)
    end
  end
end


function changelevel()
  if ctime.s >= time_per_level or skip_level then
    life_saved=false
    if skip_level then
      life_saved=true
    end
    skip_level = false
    transition = transition + 1
  end
end


function screenaftergame()
  transition =  transition + 1
  if transition > 150 then
    hyperspace=0
    transition = 0
    if level == 0 then
      _update = update_heroine
      _draw = draw_hamilton
      nextdraw = draw_quizz2
      nextupdate = update_menu
    elseif level == 1 then
      _update = update_heroine
      _draw = draw_katie
      nextdraw = draw_quizz3
      nextupdate = update_menu
    elseif level == 2 then
      _update = update_heroine
      _draw = draw_ada
      nextdraw = draw_over
      nextupdate = update_over
    end
    ctime.s = 0
    ctime.ms = 0
    tlevel = 0
  end
end

function dogametomenutransition()

  if transition > 70 then
    for j=1,3 do
      add(smoke, { x=ship.x + 4 - 4 + rnd(8), y= ship.y+8 , size = 4+rnd(4), col = 5 + rnd(2) + 0.5, draw = drawsmoke})
    end
  end
  if transition > 90 then
    ship.x = ship.x + (64-ship.x) / 30
    ship.y = ship.y - (transition - 90)/10
  end
  hyperspace = flr(transition / 10)

  for b in all(bullets) do
    if b.x < 64 then
      b.x = b.x - transition / 50
    else
      b.x = b.x + transition / 50
    end
    b.y=b.y - 2
    if b.x < 0 or b.x > 128 or
      b.y < 0 or b.y > 128 then
      del(bullets,b)
    end
  end
  for b in all(ebullets) do
    if b.x < 64 then
      b.x = b.x - transition / 50
    else
      b.x = b.x + transition / 50
    end
    b.y=b.y - 2
    if b.x < 0 or b.x > 128 or
      b.y < 0 or b.y > 128 then
      del(bullets,b)
    end
  end

  for e in all(enemies) do
    if e.x < 64 then
      e.x = e.x - transition / 50
    else
      e.x = e.x + transition / 50
    end
    if e.y < ship.y then
      e.y = e.y - transition / 50
    else
      e.y = e.y + transition / 50
    end
  end
end

function explosionstimer()
  for ex in all(explosions) do
    ex.t=ex.t + 1
    if ex.t > 2 and rnd(100) > 60 then
      ex.f = ex.f + 1
    end
    if ex.f == 4 then
      del(explosions, ex)
    end
  end
end

function ship_hitted()
  ship.imm = true
  ship.h = ship.h - 1
  sfx(1)
  if ship.h <= 0 then
    --game_over()
    skip_level = true
  end
  
  local fade={fadeship, fadeship, fadeship, fadegrey, fadeyellow}
  for i =0,32 do
  for j=1,5 do
      add(smoke, rmachine(ship.x+rnd(8), ship.y+rnd(16), fade[j], 0))
    end 
  end
  skip_frame = true
  screenshake(2)
  explodeonscreen = 100
end

function update_game()
  if skip_frame then
    skip_frame = false
    skip_draw = true
    return
  end

  time_manager()

  changelevel()

  movestars()
  explosionstimer()

  if transition > 0 then
    dogametomenutransition()
    screenaftergame()
    return
  end

  local hasbig = false
  local nbstone = 0
  for e in all(enemies) do
    if e.type==1 or e.type == 2 then
      hasbig = true
    elseif e.type==-1 then
      nbstone = nbstone + 1
    end
  end

  if tlevel % 150 == 0 and not hasbig then
    spawnbig()
  end

  if level > 0 and tlevel % 80 == 0 and not hasbig  then
    spawnbig2()
  end

  if tlevel % 90 == 0 and nbstone <= level then
    spawnbig_stone()
  end

  if t%100 == 0 or #enemies < level then
    respawn_line(level)
  end

  -- manage immune ship
  if ship.imm then
    ship.t = ship.t + 1
    if ship.t >30 then
      ship.imm = false
      ship.t = 0
    end
  end

  for e in all(enemies) do
    e.move(e)

    -- collision ?
    if coll(ship,e) and not ship.imm then
      ship_hitted()
    end

    if e.y > 150 then
      del(enemies,e)
    else
      e.shoot(e)
    end

  end

  for b in all(bullets) do
    b.x=b.x+b.dx
    b.y=b.y+b.dy
    if b.ttl then
      b.ttl= b.ttl -1
      if b.ttl < 1 then
        del(bullets, b)
      end
    end
    if b.x < 0 or b.x > 128 or
      b.y < 0 or b.y > 128 then
      del(bullets,b)
    end

    for e in all(enemies) do
      if coll(b,e) then
        hit_ennemy(e, b)
        del(bullets,b)
        e.explode(e, b)
      end
    end
  end

  for b in all(ebullets) do
    b.x=b.x+b.dx
    b.y=b.y+b.dy
    if b.x < 0 or b.x > 128 or
      b.y < 0 or b.y > 128 then
      del(ebullets,b)
    end

    -- shooted down ?
--    for e in all(bullets) do
--      if coll(b,e) then
--        del(bullets,e)
--        del(ebullets,b)
--        explode(b.x, b.y, true)
--      end
--    end
    -- collision ?
    if coll(ship,b) and not ship.imm then
      ship_hitted()
      del(ebullets, b)
    end


  end
  move_ship()

end


function move_ship()
  if btn(0) then
    ship.x=ship.x - (1 + ship.hvel/3)
    ship.dir=1
    if ship.hvel< 6 then
      ship.hvel=ship.hvel+1
    end
  elseif btn(1) then
    ship.x= ship.x + (1 + ship.hvel/3)
    ship.dir=2
    if ship.hvel< 6 then
      ship.hvel=ship.hvel+1
    end
  else
    if ship.dir == 1 then
      ship.x=ship.x - 1
    elseif ship.dir == 1 then
      ship.x=ship.x + 1
    end
    ship.dir=0
    ship.hvel = 0;
  end
  if btn(2) then
    ship.y=ship.y - (1 + ship.vvel/3)
    if ship.vvel< 6 then
      ship.vvel=ship.vvel+1
    end
  elseif btn(3) then
    ship.y= ship.y + (1 + ship.vvel/3)
    if ship.vvel< 6 then
      ship.vvel=ship.vvel+1
    end
  else
    ship.vvel = 0;
  end
  if btnp(4) then fire() end
  if btnp(5) then firex() end

  ship.tho = max(0, ship.tho - 1)
  ship.thx = max(0, ship.thx - 1)

  if ship.x < 1 then ship.x = 1 end
  if ship.x > 120 then ship.x = 120 end
  if ship.y < 1 then ship.y = 1 end
  if ship.y > 120 then ship.y = 120 end
end


function camera_pos()
  if (scr.shake > 0) then
    scr.x = (rnd(2)-1)*(scr.intensity-scr.shake/2)
    scr.y = (rnd(2)-1)*(scr.intensity-scr.shake/2)
    scr.shake = scr.shake - 1
  else
    scr.x = 0
    scr.y = 0
  end
  camera(scr.x,scr.y)
end


function draw_explosion(ex)
  local hflip = false
  local vflip = false
  if rnd(100)>50 then
    hflip = true
  end
  if rnd(100)>50 then
    vflip = true
  end
  if ex.smoke then
    pal(10,7)
    pal(9,6)
    pal(4,5)
  end
  if ex.green then
    pal(10,11)
    pal(9,3)
    pal(4,5)
  end
  --spr(68 + ex.f*2, ex.x, ex.y,2,2, hflip, vflip)
  sspr(32 + ex.f*16, 32,16,16, ex.x, ex.y, ex.size, ex.size, hflip, vflip)
  pal()
end


function drawstars()
  for st in all(stars) do
    if st.b < 80 +hyperspace *50 then
      pset(st.x,st.y,5)
    elseif st.b < 100 - hyperspace * 50 then
      pset(st.x,st.y,1)
    elseif st.b < 110 - hyperspace * 40 then
      pset(st.x,st.y,12)
    elseif st.b < 150 - hyperspace * 50 then
      pset(st.x,st.y,7)
    else
      pset(st.x,st.y,6)
    end
  end
end

function drawship()
  if transition > 10 or _draw == draw_menu then
    local hflip = false
    if rnd(100)>50 then
      hflip = true
    end
    spr(211 + rnd(2),ship.x,ship.y + 4+rnd(5), 1, 1, hflip, false)
    spr(195 + rnd(2),ship.x,ship.y, 1, 1, hflip, false)
  elseif not ship.imm or t%8 < 4 then
    if ship.dir == 0 then
      local hflip = false
      if rnd(100)>50 then
        hflip = true
      end
      spr(ship.sp + (t%2)*16,ship.x,ship.y, 1, 1, hflip, false)
    else
      spr(ship.sp+ship.dir+(t%2)*16,ship.x,ship.y)
    end
  elseif ship.imm and ship.t < 10 then
    pal(8, 7)
    pal(14, 7)
    pal(6, 7)
    pal(1, 7)
    pal(5, 7)
    pal(4, 6)
    spr(ship.sp+ship.dir+(t%2)*16,ship.x,ship.y)
    pal()
  end
end

function drawhearts(dy)
  local decal = 0
  if dy then
    decal = dy
  end
  for i=1,4 do
    if i<=ship.h or (i==ship.h+1 and ship.imm and (t%8)<4) then
      spr(36,80+8*i,0 + decal)
    else
      draw_with_palette(letter_gray_pal, function()  spr(36,80+8*i,0 + decal) end)
    end
  end
end

function drawscore(dy, hidezero)
  local decal = 0
  if dy then
    decal = dy
  end
  local score = ship.p
  for i= 1,5 do
    local spritechiffre = 198 + (score%10);
    if score == 0 and i > 1 and not hidezero then
      pal(10,6)
      pal(9,5)
      pal(4,1)
      spr(spritechiffre, 40-8*i, decal)
      pal()
    elseif score == 0 and i > 1 and hidezero then
    elseif scoreup > 0 and flr(t/5)%3 == 0 then
      pal(10,7)
      pal(9,7)
      pal(4,7)
      spr(spritechiffre, 41-8*i, decal)
      pal(4,6)
      spr(spritechiffre, 40-8*i, decal)
      pal()
    elseif scoreup > 0 and flr(t/5)%3 == 1 then
      pal(10,14)
      pal(9,8)
      pal(4,4)
      spr(spritechiffre, 41-8*i, decal)
      pal(4,8)
      spr(spritechiffre, 40-8*i, decal)
      pal()
    else
      spr(spritechiffre, 41-8*i, decal)
      pal(4,10)
      spr(spritechiffre, 40-8*i, decal)
      pal()
    end
    score = flr(score / 10)
  end
end

function drawanimheartspoints()
  for i=1,4 do
    if i<=ship.h then
      if transition == i*20 then
        ship.p = ship.p + 10*i
        scoreup = 10
      end
      if transition < i*20 then
        spr(36,80+8*i, 1)
      elseif transition < i*20 + 70 then
        if (transition > i*20 + 10 and (t%9==4 or t%9==5)) or (transition > i*20 + 15 and t%3>0) or (transition > i*20 + 25 and t%7>0) then
          spr(36,4+80+8*i + sin((transition - i*20)/160)*60, 5+transition - i * 20, 1, 1)
        else  
          spr(14,80+8*i + sin((transition - i*20)/160)*60, transition - i * 20, 2, 2)
        end
        pal()
      end

      if transition > i*20 + 10 and transition < i*20 + 70 then
        local n4 = 8
        if flr(i+t/2)%5 <3 then
          pal(10,14)
          pal(9,8)
          pal(4,4)
          n4=4
        elseif flr(i+t/2)%5 == 3 then
          pal(10,7)
          pal(9,7)
          pal(4,7)
          n4=5
        else
          pal(10,0)
          pal(9,0)
          pal(4,0)
          n4=0
        end
        local sin40 = sin((transition - i*20)/160)*40
        spr(197, 80+8*i + sin40 , transition - i * 20 + 10);
        spr(198+i, 80+8*i + sin40 + 8, transition - i * 20 + 10);
        spr(198, 80+8*i + sin40 + 16, transition - i * 20 + 10);
        pal(4,n4)
        spr(197, 80+8*i + sin40 + 1, transition - i * 20 + 10);
        spr(198+i, 80+8*i + sin40 + 9, transition - i * 20 + 10);
        spr(198, 80+8*i + sin40 + 17, transition - i * 20 + 10);
        pal()
      end
    end
  end
end

function draw_game()
  if skip_draw then
    skip_draw = false
    return
  end
  cls()
  camera_pos()

  if explodeonscreen > 0 then
--    for n=1,10 + explodeonscreen do
--      circfill(rnd(128), rnd(128), 2 + rnd(10*explodeonscreen), 6 + rnd(2))
--    end
--    explodeonscreen= 0 *explodeonscreen / 2 - 1
    if (flr(rnd(5))>0) then
      explodeonscreen = 0
    end
    rectfill(0, 0, 128, 128, 7)
  end

  if hyperspace > 0 then
    pal(7, 6)
    drawstars()
    for i=0,hyperspace do
      movestars(true)
      drawstars()
    end
    pal()
  else
    drawstars()
  end

  for s in all(smoke) do
    s.draw(s)
  end

  for ex in all(explosions) do
    draw_explosion(ex)
  end
  
  drawship()

  for b in all(bullets) do
    b.draw(b)
  end
  

  for b in all(ebullets) do
    if b.red then
      pal(3, 8)
      pal(11, 14)
    end
    spr(119 + rnd(4), b.x,b.y)
    pal()
  end

  for e in all(enemies) do
    e.draw(e)
  end

  camera()

  if transition > 0 then
    drawanimheartspoints()
  else
    drawhearts(1)
  end

  drawscore()

  for h in all(msgs) do
    if h.hit then
      h.timer = h.timer - 1
      if h.timer < 0 then
        del(msgs, h)
      end
      if  flr((t+h.dt)/3)%3 == 1 then
        print2("hit", h.x, h.y)      
--        spr(217, h.x + 16, h.y)
--        spr(216, h.x + 8, h.y)
--        spr(215, h.x, h.y)
        pal(4,10)
        print2("hit", h.x+1, h.y)      
        pal()
      elseif  flr((t+h.dt)/3)%3 == 2 then
        if h.bonus == 0 then
          pal(10,11)
          pal(9,3)
          pal(4,1)
        else
          pal(10,14)
          pal(9,8)
          pal(4,4)
        end
        print2("hit", h.x, h.y)      

        if h.bonus == 0 then
          pal(4,3)
        else
          pal(4,8)
        end
        print2("hit", h.x+1, h.y)      
        pal()

      else
      end
    end
  end

  for h in all(hits) do
    local cc = h.bonus
    local flrcc = flr(cc / 10)%10
    if  flr((t+h.dt)/3)%3 == 1 then
      spr(214, h.x, h.y)
      if cc > 10 then
        spr(198 + flrcc, h.x + 8, h.y)
        spr(198 + (cc % 10), h.x + 16, h.y)
      else
        spr(198 + (cc % 10), h.x + 8, h.y)
      end
      pal(4,10)
      spr(214, h.x+1, h.y)
      if cc > 10 then
        spr(198 + flrcc, h.x + 8 + 1, h.y)
        spr(198 + (cc % 10), h.x + 16 +1, h.y)
      else
        spr(198 + (cc % 10), h.x + 8 + 1, h.y)
      end
    elseif  flr((t+h.dt)/3)%3 == 2 then
      pal(10,14)
      pal(9,8)
      pal(4,4)
      spr(214, h.x, h.y)
      if cc > 10 then
        spr(198 + flrcc, h.x + 8, h.y)
        spr(198 + (cc % 10), h.x + 16, h.y)
      else
        spr(198 + (cc % 10), h.x + 8, h.y)
      end
      pal(4,8)
      spr(214, h.x+1, h.y)
      if cc > 10 then
        spr(198 + flrcc, h.x + 8 + 1, h.y)
        spr(198 + (cc % 10), h.x + 16 +1, h.y)
      else
        spr(198 + (cc % 10), h.x + 8 + 1, h.y)
      end
      pal()
    else
    end
    h.y = h.y - (0.2 + (t-h.dt)/10)
  end


end

__gfx__
00000000000000000000000000000000000008800033304000666600006666111111111111111117717771111711111110000000000880000288882002888220
0000000000000000009000e000aaaa000008800003333304066ff0000666ff111111111117777717117111717717777710000000008008002888888248ee8822
0000000000000000089a0ce20aaaaaa0000ff0000f0f0f04666ccccf666fff611111111117111717711177771717111710000000008bb800888888888efee882
0000000000000000889abce2aa0000aa000330000fffff0466ccc000666ccc66111111111711171711717171771711171000000008888880888888888e7fe888
0000000000000000889abce2aaaaaaaa0f3333f03333333f601d100066611116111111111711171777171177171711171000000008800880888888888e7ee888
0000000000000000089abce20aaaaaa000033000f446440400ccc000660ccc111111111117777717171771117717777710000000080000808888888888ee8888
0000000000000000009abce000aaaa00003003000333330400c0c000000c0c111111111111111117171717171711111110000000000000008888888888888888
0000000000000000000abc0000000000005005000500054000101000000101111111111177777777777717171777777770000000000000002888888888888882
00000000000000000000000000000000009aa7000000000000aaa0000000000000aaa00a11111711111711177171717170000000777777772888888888888820
00000000000000000000660000a66a0009aaaa70000000004aaaaa77000000004aaaaaa011117171717777777771777170000000000000070288888888888200
00000000000000006d00d660aa6006aa9a1aa1a70000aaaaa40000660000aaaaa400000017171711117111711111717110000000077700070028888888882000
00000000000000006dd00d66adddddda9aaaaaaa000aaaaaaa000000000aaaaaaa00000071177777711177777111177710000000700070070002888888820000
0000000000000000ddd00066a00aa00a9a1111aa00009999aa00000000009999aa00000011777111717171111117171110000000000700070000288888200000
000000000000000060000066000000009aa11aaa0000ffff9a0000000000ffff9a00000011177171711711771171717170000000007000070000028882000000
00000000000000006bd0b0d60000000009aaaaa00000cfcf9a0000000000cfcf9a00000017711711117777111711117110000000070000070000002820000000
000000000000000066b0bdd600000000009999000000ffff9a0000000000ffff9a00000017117171717717717771177710000000700070070000002200000000
0ddd00000000ccc0d66666660000000008e088000b00feff900000000b00feff90000000171711117177111711111717700000006777666700aab0bbbb0bbb00
0ddd00000000ccc066b0bdd6000000008888e7803ff00990000000003ff009900000000077777777111111711777117770000000666666670064044488808600
0ddd00000000ccc06bd0b0d6000aa00088888e80000f8ff8f000000000068ff86000000011111117171111171717171110000000677766670006aaaaaabb6000
000000000000000060000006000aa00088888880000088880f000000000088880f00000017777717711177171777117710000000667666670000666666660000
00d0000000000c00ddd00006000aa00008888800000088880f000000000088880f00000017111717111111111111171770000000667666670000000000000000
0ddd00000000ccc06dd00d6600000000008880000000222200f000000005222250f0000017111717111717717117111110000000667666670000000000000000
0dddd000000cccc06d00d66000000000000800000000200200000000005525525500000017111717111771177777711710000000666666670000000000000000
0ddddd0000ccccc00000660000000000000000000009900990000000000990099000000017777717177177171771117710000000777777770000000000000000
0dddddd00cccccc00000000000000650000000000000011100011000111111111111111111111117171111777111111110000000000000000000000000000000
0dddddddccccccc00011000000050000000000000110011100011000111111111111111100000000000000000000000000000000000000000000000000000000
0dddddddccccccc00111110000660000000051000110011101111000111111111111111100000000000000000000000000000000000000000000000000000000
0dddddddccccccc00100011000000000010000000110011101111000111111111111111100000000000000000000000000000000000000000000000000000000
0dddddddccccccc00000001000000000650000000110011111111100111111111100011100000000000000000000000000000000000000000000000000000000
0dddddddccccccc00000001000111000000000100111011111111100111111111100000100000000000000000000000000000000000000000000000000000000
00ddddddcccccc000500000001101100000006501111111111111111111111110100000100000000000000000000000000000000000000000000000000000000
000000000000000000000000010001100000000011111111111111111111111100000000000000000000000000000000000000055fffff9999fffff550000000
0000000003bbbb33000000000000000000000000000000000000000000000000099000444000040000000044440000000faaa000000000000000000aaa000000
00000003bbbbbbab33000860000000000000000000000000000000000000000009904499940000040000449999440000aa440a0000000000000000a044f00000
0000003baaaaaabb333084960000000000000000000000000000000000009900000049aaa90000040000490000994000a90000449aaaaaffffffaa0000aa0000
000003bbaaaaabbbbb330096000000000000000000000000000000999000990000049aaaaa9400040004900000099400a90000449aaafffffaaaaa00009a0000
00000baaaabbbbbbbbb33c66000000000000000000000000000009999990000000099aa0aaa944000009900000000940a90000449aaaaaaaaaaaa900009a0000
00003baaabbbbbbbbbb3ccc0000000000000000000000000000099aaa99000000499aa000a4440000490000000000940a90000049999999999999000009a0000
0000bbbbbbbbbbbbbb3dcc0000000000000000999000000000099aaaaa99000049aaa00000aaa9004900000000000040aa900004444444444444400009aa0000
0003bbbbbbbbbbbb33dcc300000000000000099a990000000009aaaaaaa9900049aa000000aaaa94490000000000004000a0000499aaaaaaaaaaa0000a000000
0003bbbbbbbbbbb3dddb330000000000000009aaa90000000099aaaaaaa9900009999000000aaa944900000000000004000a000499aaaaaaffaaa000a0000000
0003bbbbbbbbb33dddbb3300000000000099099a990000000999aaaaaaa90000099aaa00000aaa9449000000000000400000a00049aaaaaaffaa000a00000000
0003bbbbbbb33eeebbbb330000000000009900999000000009999aaaaa99000004aaaaa000aaa940449000000000000000000a0049aaaaaaffaa00a000000000
0000bbbbbb3ffeebbbb33300000000000000000000000000009999aaa99000000499aaaa0aaa99000449000000000000000000a049aaaaaaffaa0a0000000000
00003bbbb33feebbbbb33300000000000000000000000000000009aaa900000040009aaaaaaa940000449000000000000000000a49aaaaaaffaaa00000000000
000073bb3ff2bbbbbbb330000000000000000000000000000000099a99000000400094aaaaa940000044900000000000000000a049aaaaaaffaa0a0000000000
000790332f2bbbbbbb3300000000000000000000000000000000009990000000440044999990000000044909440000000000000049aaaaafffaa000000000000
0079000222bbbbbbb33000000000000000000000000000000000000000000000044444444440000000000444000000000000000049aaaaffffaa000000000000
001991112bbbbbb333000000000000000001100000000000000282000001c1000000000000000000000000000000000000000000049aaaaaaaa9000000000000
0001110003bbb3330000000000000000701a11100000000000086800001ccc100000000000000000000000000000000000000000004999999990000000000000
0000000000000000000000000000000070a8aa000000000000066600001cc6100007700000066000000bb0000003300000000000000044444000000000000000
00000000000000000000000000000000701f1f660000000000566650008c67800007700000066000000bb0000003300000000000000049aaa000000000000000
0000000000000000000000000000000076fff1100000000005669665008cc6800007700000066000000bb0000003300000000000000049aaa000000000000000
000000000000000000000000000000006111111000000000000eae00008cc6800000000000000000000000000000000000000000000049aaa000000000000000
00000000000000000000000000000000f01001f0000000000000f000000ccc000000000000000000000000000000000000000000000049aaa000000000000000
0000000000000000000000000000000000600600000000000000f0000001c1000000000000000000000000000000000000000000000049aaa000000000000000
000a0aa0a000aaa0aaa0aaa0aaa0aaa0000000000000000000005555053335000053500000030000000000000000000000000000000049aaa000000000000000
00000aaaa000aa00a0a0a0a0a000aa0000000000000000000005666653bab350003b300000030000000300000000000000000000000499aaaa00000000000000
000a0a0aa00000a0aaa0aaa0a000a00000000000000000000056dddd3ba7ab3053bab350003a3000003b30000003000000000000000444444400000000000000
000a0a0aa000aaa0a000a0a0aaa0aaa00000000000000000056ddddd3a777a303ba7ab3533a7a33003bab300003b30000000000049aaaaaaaaaaa00000000000
000000000000000000000000000000000000000000000000056ddddd3ba7ab3053bab350003a3000003b3000000300000000000049aaaaaaaaaaa00000000000
000000000000000000000000000000000000000000000000056ddddd53bab350003b300000030000000300000000000000000000499999999999900000000000
000000000000000000000000000000000000000000000000056666dd053335000053500000030000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000005464556d000000000005000000000000000000000000000000000000000000000000000000000000
000008008800000000000bbbbbb00000004604000000000000005555550000000000555555000000000000000000000000000000000000000000000000000000
0000088998000000000bb733337bb0000e4dd4e0000000000005666666555500000566666665550000a66a0000a66a0000a66a0000a66a0000a66a0000a66a00
00000888880000000bb7383838087bb088e55e880000000000566667777666500056669466664650a966669aa9d666aaaadd66aaaa6dd6aaaa66ddaaaa666d9a
0000080008000000b77333833383377b9981c8990000000005666666667666650566694666666665a1dddd1aa11ddddaad11dddaadd11ddaaddd11daadddd11a
0000089098000000b73338383838337b0091c9000000000005666666666666650566644666666965a00aa00aa00aa00aa00aa00aa00aa00aa00aa00aa00aa00a
0000880008800000b33333333333333b0001c0000000000005666666666666650564666646496665000000000000000000000000000000000000000000000000
0008000000080000b33838333383833b0000c0000000000005666656666566650566669944666645000000000000000000000000000000000000000000000000
0008000000080000b73383333338337b000000000000000055165556666666655454dda469669665000000000000000000000000000000000000000000000000
00080000000800000b380833338083b0000000000000000055155556666666655551566994966665055555500555000000000000000000000000000000000000
000800000008000000b00b3bb3b00b00000000000000000055151156665d66655151156665665995056666505666750000000000000000000000000000000000
0008000000080000008bb8b88b8bb800000000000000000051111116665555505154111166645550567766655656675000000000000000000000000000000000
00088000008800000088008000808800000000000000000005511116555551500551455114551450576666655665665500000000000000000000000000000000
00088008008800000008008008800800000000000000000000051555555111000005114411111500566566555656666500000000000000000000000000000000
00088008008800000000800008008000000000000000000000005511551155000000551141154500565566655566615000000000000000000000000000000000
00008008008000000000080000080000000000000000000000000055115550000000005511145000511661100566100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000555500000000000055550000000111000011100000000000000000000000000000000000
000000000000000000000006666666000006666666666600006666666000000000000bbbbbb0000000000bbbbbb0000000000bbbbbb0000000000bbbbbb00000
00066000000066000000000000ddd660006666dd6dd00660066ddd00000ddd00000bb73333abb000000bb73333abb000000bb73333abb000000bb73333abb000
0066d00d6d00d660000ddd00000ddd66066d000d6d000d6666dddd0b0000d6d00bb738383838abb00bb738383838abb00bb734343434abb00bb738383838abb0
066d00dd6dd00d6600d6d000000b0dd606d000bb6bb000d66dd0b6b000006dd0b773338333833aabb773334333433aabb773334333433aabb773334333433aab
066000ddddd0006600dd60000000bdd600000000600000006ddb0660d00600d0b7333838383833abb7333838383833abb7333434343433abb7333838383833ab
066000006000006600d00600d0066dd6000dd0db6bd0dd006d00006b6b600000b33333333333333bb33333333333333bb33333333333333bb33333333333333b
06d0b0db6bd0b0d60000006b6b66b00600ddd0b666b0ddd0600000b666b00006b33838333383833bb33834333343833bb33434333343433bb33438333383433b
06ddb0b666b0bdd6060000b666b00b060066d666d666d66060000d66d66d00d6b7333333333333abb7333333333333abb7333333333333abb7333333333333ab
06666666d666666606000d66d66d000600ddd0b666b0ddd0600000b666600bd60b331333333133b00b331333333133b00b335333333533b00b331333333133b0
06ddb0b666b0bdd66d0000b666b00000000dd0db6bd0dd000000006b6b66b0d600b16b3bb3b61b0000b17b3bb3b71b0000b5733bb3375b0000b17b3bb3b71b00
06d0b0db6bd0b0d66d0b00666b600000000000006000000000d00600d00660d6008bb8b88b8bb800008bb8b88b8bb800008b58b88b85b800008bb8b88b8bb800
06000000600000066d00b660d00600d006d000bb6bb000d600dd6000000bddd60088008000808800008800800080880000880080008008800088008000808800
060000ddddd0000606ddd6b000006dd0066d000d6d000d6600d6d00000b0dd660008008008800800000800800080008000080080008000800008008000800080
066d00dd6dd00d66066dd00b0000d6d0006666dd6dd00660000ddd000000d660000080000e008000000e00e000e000800080008000080080000e00e000e00080
0066d00d6d00d6600066ddddd00ddd000006666666666600000000066ddd660000000e00000800000000e0000000080000e00e00000e000e0000e00000000800
0006600000006600000666666600000000000000000000000000000006660000000000000000000000000000000000000e000000000000000000000000000000
00088000000880000008800000088000000880000000000000aaaa00000aaa0000aaaa000a9aaaa00000aa0000aaaa0000aaa9000aaaa0a0004aaa0000aaaa00
0086680000866800008668000086680000866800000aa0000400004000a0040004000040004000a0000a04000040000004000040040004400400004004000040
04e55e4004855ef00fe5584004e55e4004e55e40000440000400004000000400090000400000040000040400004000000400000000000040090000a009000040
48e11e8442811e8ff8e1182448e11e8448e11e840999499009000090000009000000090000004000009009000099990009099900000009000099990000999990
88e66e8822866e8888e6682288e66e8888e66e880a999990090000900000090000099000000999900900090000000090099000a0000090000900009000000090
e84a748e824a7f8ee8fa7428e847748ee84a748e000a9000090000900000090000900000090000900999999009000090090000a0000090000900009000000090
8809a0882209a0888809a022880a7088880aa088000aa0000900009000000900099990900a000990000009000a000090090000a0000900000a0000900a000900
e800908e8200908ee8009028e80aa08ee809a08e0000000000999a0000a999a00900099000a999000000aaa000aa990000999a000009000000a9990000a99000
0008800000088000000880000009a000000a90000000000000000000aaa00aaa0aa9aa00aaaaaaa000aaaaa00aaaaa000aaaaa000aaa00000aaaaaa00aa00aaa
008668000086680000866800000a90000009a00000000000aa0004a0040000400004000040040040040000400040004000400040004000000400004000440040
04e55e4004855ef00fe55840000aa000000a900000000000044044000400004000040000000400000400000000400090004000400040000000000400004040a0
48e11e8442811e8ff8e118240009a0000009400000000000009aa0000900009000040000000900000900000000900090009999400090000000009000009090a0
88e66e8822866e8888e6682200099000000a40000000000000a990000999999000090000000900000900999000999900009090000090000000090000009009a0
e847a48e8247af8ee8f7a4280009a00000095000000000000a9099000900009000090000000900000900009000900000009009000090000000900000009009a0
880a9088220a9088880a90220009400000040000000000000a0009000900009000090000000900000900a99000900000009000a0009000a0090000a0009000a0
e809008e8209008ee8090028000400000005000000000000a90009a0aaa00a990a99aa0000a9900000aa90a00aaa00000aaa009a0a999aa009999aa0099a0090
83838383838383830000000000000000000000000000000000aa0a00000a000000aa04000aaaaa40aa000aa0aa40a440a4a0aaa0aaaaaa00aaaaa000aaa0aaa0
00000000000000000000000000000000000000000000000004044900000400000400440000400040044044000400040004000400040000400400040004000400
00000414243400000000000000000000000000000000000009000000004040000900040000400000094044000400090009000400040000900400009004000400
0000000000000000000000000000000000000000000000000900000000904000090000000090a000099099000900090009009000099999000400009000904000
00000515253500000000000000000000000000005300000000999000099999000900000000999000090909000900090009090000090000900900009000909000
0000000000000000000000000000000000000000000000000000090009000900090009000090900009090a00090009000990900009000090090000a000090000
0000061626310000000000000000530000000073737300000a900a0009000a0009000a0000900090090a0a0009000a0009000a000a00009009000a0000090000
0000000000000000000000000000000000000000000000000a0aa00099a0aaa0009aa0000a99aa900a0a0a00009aa00099a0aaa0aaaa990099aaa000000a0000
00e007172737004400000000737373730000007373737300aaaaaaa00004a0000073737300737373007373000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000004000040000440000000000000000000000000000000000000000000000000000000000000000000
00003131313135000000007373737373007373737373737304000000000940007373737303737373737373737373000000007300000000000000000000000000
00000000000000000000000000000000000000000000000009090000000990000000000000000000000000000000000000000000000000000000000000000000
00006353636300466373737373737373737373737373737309990000000a90007373737303737373737373737373007373007300000000000000000000000000
000000000000000000000000000000000000000000000000090a0000000000000000000000000000000000000000000000000000000000000000000000000000
63537373737363737373737373737373737373737373737309000000000940007373737303737373737373737373737373737300000000000000000000000000
0000000000000000000000000000000000000000000000009aa00000000a90000000000000000000000000000000000000000000000000000000000000000000
__label__
0000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006005000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000003bbbb3300000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000
0070000000003bbbbbbab33000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000003baaaaaabb3330a49a000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000
00000000003bbaaaaabbbbb33009a000000000000000000000000000000000000000000000000004940000000000000000006000000000000000000000000000
0000000000baaaabbbbbbbbb33aaa000000000000000000000000000000000000000000000000049a94000000000000000000000000000000000000000000010
0000000003baaabbbbbbbbbb3aaa00000000000000aaaaaa0aaa9aa00aaaaaa00aaaa0000aaaaaa4940000000000000000000000000000000000000000000700
000000000bbbbbbbbbbbbbb3aaa00000000000000475554700547550004755470047500004755547400000000000000000000000000000000000000000000000
000000003bbbbbbbbbbbb33aaa300000000000000470111510047111004711470047110000511475100000000000000000000000000000000000000000000000
000000003bbbbbbbbbbb3aaab3300000000000000991000010047100009999971099100000019950100000000000000000000000000000000000000000000000
000000003bbbbbbbbb33aaabb3300000000000000991999900099100009999551099100000099501000000000000000000000000000000000000000000000000
000000003bbbbbbb33aaabbbb3300000000000000991059900099100009919911099100000995010000000000000000000000000000000000000000000000000
000000000bbbbbb3aaaabbbb33300000006000000991aa9910099100009910aa009910aa099501aa000000000060000000000000000000000000000000000000
0000000003bbbb33aaabbbbb333000000000000000aaa9aa1aa99aa00aaaa099aaa999aa099999aa000000000000000000000000000000075600000000000000
000000000a3bb3aaabbbbbbb33000000000000000005551510555550005550055055555510555555100000000000000000000000000000056500000000000000
00000000a9033aaabbbbbbb330000000000000000000111010011111000111001101111110011111100000000000000000000000000000567650000000000000
0000000a9000aaabbbbbbb330000000600000000000000000aaa9aa00aaa0aaaa500600000aaaaa00aaaaaa0000aa00000aaa4700aaaaaa56500000000000000
0000000999999abbbbbb333000000000000000000000000000547550004770475000000004747790004755470004700004754770004755475000000000000000
000000009990003bbb33300000000000000000000000000000047111004747aa1100000009905551004711990047470009901471004711151000000000000000
00000000000000000000000000000000000000000000000000047100009999aa10000000099101110099109910994700099100510099aa001000000000000000
000000000000000000000000000000000006000000000000000991000099199a1000000000999900009999951999999009910001009999000000000000000000
000000000000000000000000000000000000000000000000000991000099199a1000000000055990009955501995599009910990009999100000000000006060
00000000000000000000000000000000000000000000000000099100009910aa100000000aa91aa00099111109911aa109910aa0009915990000000000000000
0000000000000000000000000000000000000000000000000aa99aa00999a099100000000aaaaa510aaaa000999aaaaa0099aa510aa99aa90000000000000000
00000000000000000000000000000000000000000000000000555550005550051000000000515501005550000555055500055501065555551000000000000000
00000000000000000000000000000000006000000000000000011111000111001000000000010110000111000011101110001110000111111000000000000000
000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbb0000070000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000bb73333abb00000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000bb738383838abb000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000b773338333833aab00000000000000000000000000000000
00000000000000000000000000050000000000000000000000000000000000000000000000000000b7333838383833ab00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000b33333333333333b00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000b33838333383833b00000000000000000000000000000000
00000000000000000000000000000000000000000000000000700000000000000000000000000000b7333333333333ab00000000000000000000000000000000
000000000001000000000000000000000000000600000007000000000000000000000000000000000b331333333133b000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000b16b3bb3b61b0000000000000000000000000000000000
00000000000000060000000000000000000000000000000000000000000000000000000000000000008bb8b88b8bb80000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008800800080880000000000000000060000000000000000
00000000000000000000000000000000006000000000000000000000000000000000000000000000000800800880080000000000050000000000000000600000
00000000000000000000000000000000000000000000000000000000000000000000000c00000000000080000e00800000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000008000000000000000000000000000000000000
00000000000000000000000000066666660000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000
000000100000000000000000000000ddd66000000000000060000000000000000000000000000000000000000000500000000000000000000000000000000000
00000000000000000000000ddd00000ddd6600000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000
0000000000000060000000d6d000000b0dd600000000000000000000000000000600000000000000000000000000000000000600000000000000000000000000
0000000000000000000000dd60000000bdd60000000000000000c000000000000000000600000000000000000000000000000000000000000000000000000000
0000000000000000000000d00600d0066dd600000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000
000000000000000000000000006b6b66b00600000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000
00000000000000000000060000b666b00b060000000000000000000700000000008668000000000000a66a000000000000a66a000000000600a66a0000000000
0000000000000000000006000d66d66d0006000000000000000000000000000004e55e4000000000aa6dd6aa00000000aa6dd6aa00000000aa6dd6aa00000000
000000000000000000006d0000b666b00000000000000000000000000000000048e11e8400000000add11dda00000000add11dda00000000add11dda00000000
000000000000000000006d0b00666b600000000000000000000000000000000088e66e8800000000a06aa00a00000000a00aa00a00010000a00aa00a00000000
000000000000000000006d00b660d00610d00000000000000000000000000000e84a748e00000000000000000000000000000000000000000000000000000000
0000000000000000000006ddd6b000006dd00000000000600000000000000000880aa08800000000000000000000000000000000000000000000000000000000
00000000000000000000066dd00b0000d6d00000000000000000000000000000e809a08e00000000000000000000000000000000006000000000000000000000
000000000000000000000066ddddd00ddd000000000000000000000000000000000aa00000000000000000000000000000000000000600000000000000000000
00000000000000000000001666666600000000000000000000000000000000000009a00000000000000000000000000000000500000000000000000000000000
00000000000000000000000000000000000000000000500000000000000000000009900000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009a00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009400000000000000000000000000000006000000000000600000000000000
00000000000000000000000000000006000000000000000000000000000000000004000000000000000000000006000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
00000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000
00000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000070000000000000000000050
00000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000
00000000070007770000077707770077007707770777077707770777000007770777007707000700007700000770077700000777077707770077007707770000
00000000075007555000075757575707570557575757577757775755500007575757570757500750070750000757075550000757575557575707570557555000
0000000007500770000007775770575757500770577757575757577000c007775777575757560750075750000757577000000770577007775757577707700000
00000000075007550000075557570757575707570757575757575755000007575755575757500750075750000757575500000757075507555757505757550000
00000000077707770000075007575770577757575757575757575777000007575750077057770777077050000757577700000757577707500770577057770000
10000000005550555000005000505055005550505050505050505055500000505050005500555055505500000050505550000050505550500055005500555000
00000000000000000000000000700707077700000077070707770000077007770077000007070077077707770777007700000777000000000000000000000000
00000000000000000000000007070757575550000705575757575000075707555705500007575707577757775755570550000057500000000000000000000000
00000000000000000000000007575757577000000777075757705000075757700777000007775757575757575770077700000077500000000000000000000500
00000000000000000000000007705757575500000057575757570000075757550057500007575757575757575755005750000005500000000000000000060000
00000000000000000000000000770077577700000770507757575000077757770770500007575770575757575777077050000070000000000000000000000000
00000000000000000000000007055005505550000055000550505000005550555055000000505055005050505055505500000005000000000000000000000000
00007000050600000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00500000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000007000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000060000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777777
00000000000000000000000000000000000000000000070000000000000000000000000000000000000006000000000000000700000007707770000700000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707777707007000707707777707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000707000707700077770707000707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000707007070707707000707
00000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000707770700770707000707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707777707070770007707777707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000007070707070700000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777707070777777777
00011100000000ccc000000006660666066606660666000001010000066600660606066600000606066606660666007000000700000700000700077070707077
00011100000000ccc000000000655656565656555056500001515000065656065656565650000656565656565065500000000700007070707777777770777077
00011100000000ccc000000000650666566656600060500000105000066656565656566050000656566056665065000000000707070700007000700000707007
00000000000000000000000000650656565556550605000001010000065556565656565600000666565606565065000000000770077777700077777000077707
000010000000000c0000000000650656565006660666000001515000065006605066565650000065565656565666000000000700777000707070000007070007
00011100000000ccc000000000050050505000555055500000505000005000550005505050000005005050505055500000000700077070700700770070707077
0001111000600cccc000000007770777077707770777000000220000077700770707077700000777077707070707000000000707700700007777000700007007
000111110000ccccc000000000755757575757555057500062055000075757075757575750000755575757575757500005000707007070707707707770077707
00011111100cccccc000000000750777577757700070500002500000077757575757577050000770077757575070500000000707070000707700070000070777
0001111111ccccccc000000000750757575557550705000002500000075557575757575700000755075757575707000000000777777777000000700777007777
0001111111ccccccc000000000750757575007770777000000220000075007705077575750000750075750775757500000000700000007070000070707070007
0001111111ccccccc000000000050050505000555055500000055000005000550005505050000050005050055050500000000707777707700077070777007707
0001111111ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000707000000000000070777
0001111111ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000707000707707007000007
0000111111cccccc0000000000000000000000000000000000000000000007000000000000000000000000000000000000000707000707000770077777700707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707777707077077070770007707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000007070000777000000007
00000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777777

__gff__
0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
44454445444544454445444544454444003c0000000000313c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545554555455545554555455545554440000000040414200343c000000000000000000003300000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4646464646464646464646464646464600000000505152003c31000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000606162003c3c000000000000000000000000000000000000000011120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647464746474647464746474647464600000000000000313c3c000000000000000000000000000424000000000021220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657565756575657565756575657564600000000000034000010430000310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848484848484848484848484848484800000000000000000010530031000000000000000000000000000000000000008283000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4646464646464646464646464646464600000000000000101000000000000000000000000000000000000000000000009293000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4849484948494849484948494849484900000000000000000000000000000000000000000000000000007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
585958595859585958595859585958490000000000000000313c0000000000000000000000c00000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a64646400310000003c3c310000340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4848484848484848494949494848484900000000003100003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4b4a4b4a4b4a5b5b5b5b5b5b4b4a4a00000000000000003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a5b5a5b5a4c4c4c4c4c4c4c4c4c5a5b00000000000000003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4b4a4b4a4c4c4c4c4c4c4c4c4c4a5b00000000000000003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a5b5a5b4c4c4c4c4c4c4c4c4c4c4c4c00000000000000003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e00000000000000003c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
484848585958595859585958595859490000003c003c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445444544454445444544454445444500003c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545554555455545554555455545554453c003c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c00000000003c3c3c433c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c00000000003c3c3c533c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c00000000003c0062633c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000703c3c730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000000001a60019000190001900019000190001300011000100000e0000a000070000300001000066000360003600016000f6000c600086001600013000100000f0000d0000c0000900008000070000000000000
00020000030500405006050090600c0600f0501105012040130401403017030140201402013010120501205011050050500c0500a0500605003050010501b0501d05000000000000000000000000000000000000
010001013b0503b0503905037050330402f0402a02025010200501b050180501505014050120500c0500f0500d0500b0500a050080500605005050031500105001050000002b0000000000000000000000000000
000000001b6301c660046501f6301f60004660056501e6301e60002600126001b600216400367005660046001f60015600126601165012600146001a6001d620216501b6701962017600276002d630326702a670
01000000100600c060311500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000091500b1500c1500e1500f1501115013150141501415014150141501415012150111500f1500c15007150021501615013150111500e1500b1500915005150031500215001150000000000000000
01000101000000000000000000000000000000061500515005150051500515005150051500515005150051500615008150091500a1500d15010150111501715013150111500f1500c15009150061500000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100000c050050500605000000140501406000000000000c050050500000000000010500a05000000000000c050050500605000000010500000000000000000c050050500000000000010500a0500000000000
010000000105003050010501405001060010600106001060160600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00000000
00 00000000
00 00000000
00 00000000
00 00404040
00 00000000
00 00000000
00 00000000
00 00404040
00 00000000
00 40404040
03 0a404040
00 40404040
00 00000000
00 00404040
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
02 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000

