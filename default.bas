 rem Generated 3/4/2010 2:36:53 PM by Visual bB Version 1.0.0.550
 rem **********************************
 rem *<filename>                      *
 rem *<description>                   *
 rem *<author>                        *
 rem *<contact info>                  *
 rem *<license>                       *
 rem **********************************
 

 rem minikernel hud initialization
 include 6lives.asm
 include div_mul.asm
 set smartbranching on

 rem cut up the score variable so you can use it later to determine level
 dim sc1=score
 dim sc2=score+1
 dim sc3=score+2


 rem player sprite
 player1:
 %10000001
 %11011011
 %01111110
 %00011000
 %00011000
 %00111100
 %00111100
 %00011000
end

 rem initial variables setup
 player1x = 80
 player1y = 88
 lives = 96
 lifecolor = 0
 score = 0 
 rem variable l is for level
 l = 1
 rem variable e is for enemy on the screen
 e = 0
 rem variable f is for player fired
 f = 0
 rem variable t is for tone multiplier
 t = 0
 rem h is for horizontal movement
 h = 1
 rem v is for vertical movement
 v = 1
 rem w is for enemy fire
 w=0
 rem z is for enemy tone
 z=0
 rem y is to multiply level
 x=0
 rem x is to assign rand
 b=0
 rem b is a loop variable.  It can be reused
 s=0
 rem s is the start screen flag.  if on, show the start screen
 z=0
 rem z is a locking mechanism.  It can be reused.
 r=0
 rem r is to reverse the boss.
 c=0
 rem c is fireball flag.
 a=0
 rem a is for boss hits.  
main_loop

 rem life icon
 lives:
 %10000001
 %11011011
 %01111110
 %00011000
 %00011000
 %00111100
 %00111100
 %00011000
end

 rem call subroutines and draw screen
 
 if s = 0 then gosub startscreen
 COLUP1 = 14
 COLUBK = 0 
 lifecolor = 6
 scorecolor = 30
 gosub levelup
 gosub pmove
 gosub pfire
 if e = 0 then gosub enemystart
 if e = 1 then gosub enemymove
 gosub coldet
 drawscreen

 if lives > 31 goto main_loop

 rem endgame stuff goes in here
 player0x = 0
 player0y = 0
 player1x = 0
 player1y = 0
 missile1x = 0
 missile1y = 0 
 
 playfield:
 .XXXX...X...X...X.XXXXX.........
 X......X.X..XX.XX.X.............
 X.XXX.XXXXX.X.X.X.XXXX..........
 X...X.X...X.X...X.X.............
 .XXX..X...X.X...X.XXXXX.........
 ................................
 ......XXX..X...X.XXXXX.XXXX.....
 .....X...X.X...X.X.....X...X....
 .....X...X.X...X.XXXX..XXXX.....
 .....X...X..X.X..X.....X...X....
 ......XXX....X...XXXXX.X...X....
end

 COLUBK = 64
 COLUPF = 68
 gosub joywait
 rem main game loop end

bosshit
 a = a + 1
 missile1x = 0
 missile1y = 0
 AUDV0=0
 f=0
 t=0
 COLUP0 = 64
 drawscreen
 COLUP0 = 8
 if a<>5 then bossdied
 score = score + 5000
 player0x = 0 
 player0y = 0 
 missile0x = 0
 missile0y = 0
 ballx = 0
 bally = 0
 e = 0 
 w = 0 
 AUDV0 = 0
 c = 0
 a = 0
bossdied
 return

coldet
 if !collision(player0,missile1) then pmc1
 score = score + 100
 if l=5 then gosub bosshit : return
 player0x = 0 
 player0y = 0 
 missile1x = 0 
 missile1y = 0 
 missile0x = 0
 missile0y = 0
 e = 0 
 f = 0
 t = 0
 w = 0 
 AUDV0 = 0
pmc1

 if !collision(player0,player1) then pmc2 
 lives = lives -32
 player1x = 80
 player1y = 88
 player0x = 0
 player0y = 0
 missile1x = 0
 missile1y = 0
 missile0x = 0
 missile0y = 0
 ballx = 0
 bally = 0
 e = 0
 f = 0
 t = 0
 w = 0
 c = 0
 AUDV0 = 0
 if lives > 31 gosub joywait
pmc2 

 if !collision(missile0,player1) then pmc3 
 lives = lives -32
 player1x = 80
 player1y = 88
 player0x = 0
 player0y = 0
 missile1x = 0
 missile1y = 0
 missile0x = 0
 missile0y = 0
 ballx = 0
 bally = 0
 e = 0
 f = 0
 t = 0
 w = 0
 c = 0
 AUDV0 = 0
 if lives > 31 gosub joywait
pmc3

 if !collision(ball,player1) then pmc4 
 lives = lives -32
 player1x = 80
 player1y = 88
 player0x = 0
 player0y = 0
 missile1x = 0
 missile1y = 0
 missile0x = 0
 missile0y = 0
 ballx = 0
 bally = 0
 e = 0
 f = 0
 t = 0
 w = 0
 c = 0
 AUDV0 = 0
 if lives > 31 gosub joywait
pmc4

 if !collision(ball,missile1) then pmc5 
 missile1x = 0
 missile1y = 0
 ballx = 0
 bally = 0
 f = 0
 t = 0
 c = 0
 AUDV0 = 0
pmc5
 return

joywait
 COLUP1=14
 drawscreen
 b=b+1 : if b>50 then b=50 : if b=50 && joy0fire then b=0 : return
 goto joywait

enemystart
 if l <>1 then level1enemy
 player0:
 %00111100
 %01100110
 %11111111
 %11011011
 %10011001
 %00011000
 %10111101
 %11111111
 %11111111
 %10111101
 %10011001
 %00111100
end
level1enemy

 if l <>2 then level2enemy
level2sprite
 player0:
 %00010000
 %00111000
 %00010000
 %10111010
 %11101110
 %11000110
 %01111100
 %00111000
end
level2enemy

 if l <>3 then level3enemy
level3sprite
 player0:
 %00011000
 %00111100
 %00011000
 %00011000
 %10111101
 %11111111
 %11011011
 %10000001
end
level3enemy

 if l<>4 then level4enemy
level4sprite
 player0:
 %00010000
 %00111000
 %00010000
 %00010000
 %00010000
 %00111000
 %01111100
 %00010000
end
level4enemy

 if l<>5 then level5enemy
level5sprite
 player0:
 %00111100
 %01100110
 %11011011
 %11111111
 %01111110
 %00100100
 %00100100
 %00111100
 %00011000
 %01011010
 %11011011
 %11011011
 %11111111
 %11111111
 %11111111
 %11100111
 %11000011
 %11000011
 %11000011
 %11000011
end
level5enemy

100 x=rand : rem I am using a line number here so I can call back to it if the number is out of bounds
 if x < 40 || x > 110 then goto 100 : rem this should put the ships closer to the screen 
 if l<>5 then COLUP0=14+(16*l) : player0x = x : player0y = 12 : NUSIZ0=$00
 if l=5 then COLUP0=8 : player0x= 100 : player0y=20 : NUSIZ0 = $15
 e =1 
return

enemymove
 if l<>5 then COLUP0=14+(16*l) : NUSIZ0=$00
 if l=5 then COLUP0 = 8 : NUSIZ0=$15
 x = rand 
 y = 5 * l
 rem for level 4, we don't want to shoot
 if l=4 then y=0
 if x < y && w=0 then gosub mis0draw
 if w = 1 then gosub mis0flight
 if l = 5 && x < 10 && c=0 then gosub fireball
 if c=1 then gosub fbflight

 rem Level 1 movement for transports (Cowardly)
 if l<>1 then Move1
 v = 1
 if x < 30 && player1x > player0x then player0x = player0x - 1
 if x > 235 && player1x < player0x then player0x = player0x + 1
 if player0x < 1 then player0x = 1
 if player0x > 153 then player0x =153
 player0y = player0y+v
 if player0y > 88 then player0y = 0 : player0x = 0 : e = 0 : w = 0 : missile0x = 0 : missile0y = 0
Move1

 rem Level 2 movement for drones (Curve In)
 if l<>2 then Move2
 v = 1
 if player0y > 40 && player1x > player0x then player0x = player0x + l
 if player0y > 40 && player1x < player0x then player0x = player0x - l
 if player0x < 1 then player0x = 1
 if player0x > 153 then player0x =153
 player0y = player0y+v
 if player0y > 88 then player0y = 0 : player0x = 0 : e = 0 : w = 0 : missile0x = 0 : missile0y = 0
Move2

 rem Level 3 movement for drones (Zig-Zag)
 if l<>3 then Move3
 v=1
 if player0y < 10 then player0x = player0x + 1
 if player0y > 9 && player0y < 30 then player0x = player0x + 1
 if player0y > 29 && player0y < 50 then player0x = player0x - 1
 if player0y > 49 && player0y < 70 then player0x = player0x + 1
 if player0y > 69 && player0y < 90 then player0x = player0x - 1
 if player0x < 2 then player0x = 2
 if player0x > 152 then player0x =152
 player0y = player0y+v
 if player0y > 88 then player0y = 0 : player0x = 0 : e = 0 : w = 0 : missile0x = 0 : missile0y = 0
Move3

 rem Level 4 movement for the missile storm (straight and fast)
 if l<>4 then Move4
 v = 3
 player0y = player0y+v
 if player0y > 88 then player0y = 0 : player0x = 0 : e = 0 : w = 0 : missile0x = 0 : missile0y = 0
Move4

 rem Level 5 movement for the boss (Figure 8)
 if l<>5 then Move5 
 if player0x > 140 then r = 1 : player0x = 140
 if player0x < 10 then r = 0 : player0x = 10
 if r=0 then player0x = player0x + 2 
 if r=1 then player0x = player0x - 2
 
 if player0y > 88 then player0y = 0 : player0x = 0 : e = 0 : w = 0 : missile0x = 0 : missile0y = 0
Move5
 return

 rem move player
pmove
 COLUP1=14 
 if joy0left then player1x = player1x -1
 if joy0right then player1x = player1x+1
 if player1x > 153 then player1x = 153
 if player1x < 1 then player1x = 1
 return

 rem player fires missile
pfire
  if joy0fire && f=0 then gosub mis1draw
  if f=1 then gosub mis1flight
  return

 rem draw player missile
mis1draw
 missile1x=player1x + 4
 missile1y=player1y - 4
 missile1height=4
 f = 1
 return

 rem missile in flight
mis1flight
 t = t+3
 if t > 30 then t = 30
 missile1y=missile1y - 4
 AUDV0 = 10 : AUDC0 = 15 : AUDF0 = t
 if missile1y > 0 then return
 rem send missile off screen if it hits the top
 missile1x=0
 missile1y=0
 AUDV0 = 0
 f=0
 t=0
 return

levelup
 if sc1 = $00 && sc2 > $14 then l=2
 if sc1 = $00 && sc2 > $34 then l=3
 if sc1 = $00 && sc2 > $59 then l=4
 if sc1 = $00 && sc2 > $74 then l=5
 if sc1 = $12 && sc2 > $49 then lives = 0
 return
 
mis0draw
 missile0x=player0x + 4
 if l = 5 then missile0x=player0x + 9
 missile0y=player0y
 missile0height=4
 w = 1
 return

mis0flight
 z = z+3
 if z > 30 then z = 30
 missile0y=missile0y + 4
 AUDV0 = 10 : AUDC0 = 15 : AUDF0 = z
 if missile0y < 88 then return
 rem send missile off screen if it hits the top
 missile0x=0
 missile0y=0
 AUDV0 = 0
 w=0
 z=0
 return

startscreen
 player1x = 0
 player1y = 0
 COLUPF = 192
 playfield:
 .XXX.X..................X.X.X...
 X....XXX..X...X.XX.......XXX....
 .XX..X...X.X..XX.......XXXXXXX..
 ...X.X...X.X..X..........XXX....
 XXX...XX..X.X.X.........X.X.X...
 ................................
 XXXX.X..XXX.X....X....XX..X.XX..
 X......X..X.X....XXX.XXXX.XX....
 XXX..X..XXX.XXX..X...X....X.....
 X....X....X.X..X.X...X..X.X.....
 X....X.XXX..X..X..XX..XX..X.....
end
 gosub joywait
 drawscreen
 COLUPF = 0
 playfield:
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
 player1x = 80
 player1y = 88
 s = 1
 return

fireball
 ballx=player0x+6
 bally=player0y-6
 ballheight=4
 COLUPF=30
 CTRLPF=$21
 c=1
 return

fbflight
 z = z+3
 if z > 30 then z = 30
 bally=bally + 4
 if player1x < ballx then ballx = ballx - 2
 if player1x > ballx then ballx = ballx + 2 
 rem  AUDV0 = 10 : AUDC0 = 15 : AUDF0 = z
 if bally < 88 then return
 rem send missile off screen if it hits the top
 ballx=0
 bally=0
 rem AUDV0 = 0
 c=0
 z=0
 return
