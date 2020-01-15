pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
----------------------------------------------------------------
--black jack project
----------------------------------------------------------------


------------------------------------------
---------------initial--------------------
------------------------------------------

function make_player()
    player = {}
    player.burst = false
    player.first = true
    player.sum = 0

    playerN = {}
    playerC = {}
end

function make_dealer()
    dealer = {}
    dealer.burst = false
    dealer.first = false
    dealer.sum = 0
    dealer.turn_end = false

    dealerN = {}
    dealerC = {}
end

function havecard(_a, _b)
    local point ={}
        point.suit = _a
        point.rank = _b
    return point
end

--point = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10 ,10}
--card = {"A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"}

-----make cards-----

function make_deck()
    trump = {}

    for i = 1, 4 do
        trump[i] = {}
        for j = 2, 14 do
            trump[i][j] = j-1 
        end
    end

    trump[1][1] = "spade"
    trump[2][1] = "diamond"
    trump[3][1] = "clover"
    trump[4][1] = "heart"
end


function _init()
    --initial bool setting
    cls(0)
    is_OP = true
    player_turn = false
    dealer_turn = false
    state = 0
    choice = 30
    delay = 20
    result = -1
    t = 0
    next = -1
    final_check = false

    make_player()
    make_dealer()
    make_deck()

end

function drawcard()
    local a
    local b
    repeat
        a = flr(rnd(4)+1)
        b = flr(rnd(13)+1)
        until trump[a][b] != nil
    if(player_turn) then
        add(playerC, a)
        add(playerN, b)
    elseif(dealer_turn) then
        add(dealerC, a)
        add(dealerN, b)
    end
    trump[a][b] = nil
    sum_cards(b)
end

function sum_cards(b)
    if(b > 10) then
        b = 10
    end
    if(player_turn) then
        player.sum = player.sum + b
    elseif(dealer_turn) then
        dealer.sum = dealer.sum + b
    end
end

function check_cards()
    if(player_turn) then
        if(player.sum > 21) then
            result = 3
            state = -1
        end 
    elseif(dealer_turn) then
        if(dealer.sum > 21) then
            result = 4
            state = -1
        end
    end

end

function dealer_check()
    if(dealer.sum >= 17) then
        dealer.turn_end = true
        dealer_turn = false
        state = 4
    end
end

----------------------------------------
--------------update--------------------
----------------------------------------

    
function _update()
    -- OP
    if(is_OP) then  
        if(btn(5)) then -- x
            is_OP = false
            player_turn = true
            cls(3)
            draw_field()
        end
    end

    if(btn(2)) then
        _init()
    end
       
    -- player turn
    if(player_turn) then
        if(player.first) then
            for i = 1, 2 do
                drawcard()
                check_cards()
            end
            player.first = false
            dealer.first = true
            player_turn = false
            dealer_turn = true
--            print("hello",12,12)
        end
        if(dealer.first) then
            for i = 1, 2 do
                drawcard()
                check_cards()
                dealer_check()
--                print("how",28, 28)
            end
            dealer.first = false
            player_turn = true
            dealer_turn = false
            state = 1
        end
    end

    if(state == 1) then
        update_choice()
        if (next == 1) then  -- <- 
            drawcard()
            check_cards()
            state = 3
            next = -1
            t = 0
        elseif(next == 0) then  -- ->
            player_turn = false
            dealer_turn = true
            state = 2
            check_cards()
            dealer_check()
--          print("wow",20, 20)
        end
    end

    -- dealer turn
    if(state == 2) then
        if(not dealer.turn_end) then 
            drawcard()
            check_cards()
            dealer_check()
--            print("end", 50, 50)
        end    
    end

    if(state == 3) then 
        t = t + 1
        if(t == 30) then
            state = 1
        end
    end

    if(state == 4) then
        state = 5
    end

    if(state >= 4 and (not(result > 2))) then
        if(player.sum == dealer.sum) then
            result = 0  -- drow
            state = -1
        elseif(player.sum > dealer.sum) then
            result = 1  -- you win
            state = -1
        elseif(player.sum < dealer.sum) then
            result = 2  -- you lose
            state = -1
        end    
        
    end

end

function update_choice()
    if(btn(0)) then
        choice = 30
    end
    if(btn(1)) then
        choice = 71
    end
    if(btn(4)) then
        if(choice == 30) then 
            next = 1
        elseif(choice == 71) then
            next = 0
        end
    end
end

---------------------------------------------
-----------------draw------------------------
---------------------------------------------


function _draw()
    palt(2, true)
    palt(0, false)

    draw_field()

    if(is_OP) then
        draw_OP()
    end

    draw_player_card()
    draw_dealer_card()

-- ((state == 1) and (state <= 3))

    if((state == 1) and (state <= 3) and (result < 0)) then
        draw_again()
    end

    draw_sum()
    draw_result()

end

function draw_field()
    cls(3)
    circ(60, 65, 30, 7)
end

function draw_OP()
    spr(193, 35, 45, 7, 4)
--    print("black jack", 37, 64, 0)
    print("press ❎ to play", 30, 75, 1)
end

function draw_player_card()
    for i = 1, #playerN do
        rectfill(1+i*12, 89, 23+i*12, 121, 0)
        rectfill(2+i*12, 90, 22+i*12, 120, 7)
        if(playerC[i] >= 3) then
            spr(playerN[i]+4, 3+i*12, 100)
        elseif(playerC[i] < 3) then
            spr(playerN[i]+17, 3+i*12, 100)
        end
    end
    for i = 1, #playerC do
        spr(playerC[i], 3+i*12, 91)
    end
end

function draw_dealer_card()
    if(result < 0) then
        for j = 1, #dealerN do
            if(j == 1) then
                rectfill(1+j*12, 19, 23+j*12, 51, 0)
                rectfill(2+j*12, 20, 22+j*12, 50, 7)
                if(dealerC[j] >= 3) then
                    spr(dealerN[j]+4, 3+j*12, 30)
                elseif(dealerC[j] < 3) then
                    spr(dealerN[j]+17, 3+j*12, 30)
                end
            elseif(j != 1) then
                rectfill(1+j*12, 19, 23+j*12, 51, 0)
                rectfill(2+j*12, 20, 22+j*12, 50, 2)
            end
        end
        for j = 1, #dealerC do
            if(j == 1) then
                spr(dealerC[j], 3+j*12, 21)
            end
        end
    elseif(result >= 0) then
        for j = 1, #dealerN do
            rectfill(1+j*12, 19, 23+j*12, 51, 0)
            rectfill(2+j*12, 20, 22+j*12, 50, 7)
            if(dealerC[j] >= 3) then
                spr(dealerN[j]+4, 3+j*12, 30)
            elseif(dealerC[j] < 3) then
                spr(dealerN[j]+17, 3+j*12, 30)
            end
        end
        for j = 1, #dealerC do
            spr(dealerC[j], 3+j*12, 21)
        end
    end
end

function draw_sum()
    print(player.sum, 110, 80, 0)
 --   rectfill(100, 80, 110, 90, 3)
    if(result >= 0) then
        print(dealer.sum, 110, 10, 2)
    end
end

function draw_again()
    rectfill(20, 60, 100, 80, 0)
    print("morecard   turnend", 25, 69, 7)
    rect(choice, 65, choice+22, 75, 12)
end

function draw_result()
    if(result >= 0) then
        if(result == 0) then
            print("drow", 44, 60, 4)
        elseif(result == 1) then
            print("you win", 43, 60, 10)
        elseif(result == 2) then
            print("you lose", 43, 60, 9)
        elseif(result == 3) then
            print("player burst you lose", 22, 60, 9)
        elseif(result == 4) then
            print("dealer burst you win", 22, 60, 9)
        end
        print("play again ⬆️", 35, 72, 10)
    end
end


__gfx__
00000000222002222220022228222282222882222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
0000000022055022220550228e8228e8228ee8222228822222288822222882222282222222288822222888222288882222288222222888222282288222888822
007007002075550222070022ee788eee28e7ee822282282222822822228228222282222222822222228222222282282222822822228228222882828222228222
00077000075555500020720087eeeee88e7eeee82282282222222822222228222282822222822222228882222222282222822822228228222282828222228222
0007700005555550050000508eeeeee88eeeeee82288882222228222222882222288882222288822228228222222822222288222222888222282828222828222
00700700050000500020520028eeee8228eeee822282282222282222222228222222822222222822228228222222822222822822222228222282888222828222
000000000020020022205222228ee822228ee8222282282222888822228888222222822222888822222888222228222222888822222882222282288222288222
00000000220000222000000222288222222882222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
22288222228228222220022222200022222002222202222222200022222000222200002222200222222000222202200222000022222002222202202200000000
22822822228288222202202222022022220220222202222222022222220222222202202222022022220220222002020222220222220220222202002200000000
22822822228882222202202222222022222220222202022222022222220002222222202222022022220220222202020222220222220220222200022200000000
22828822228282222200002222220222222002222200002222200022220220222222022222200222222000222202020222020222220200222202022200000000
22828822228228222202202222202222222220222222022222222022220220222222022222022022222220222202000222020222220200222202202200000000
22288282228228222202202222000022220000222222022222000022222000222220222222000022222002222202200222200222222002022202202200000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
00000000000000000000000000000000000000000000000022000222220000000222222222222200000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000222220000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222000002200222222222000222200000220022000022222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222000000200222222200000022000000020020000022222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222002200200222222200220020000000020000000222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222002200200222222000220020002222220000022222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222000002200222222000000020002222220000222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222002200200222222000000020002222220000022222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222002200200222222002220020002220020000022222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222000000200000020002220020000000020020000022222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222000002200000020002220022000000020022000022222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222288888882222882222222888882228822228820000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222288888882228882222228888888228822288820000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222288822288888222288882288228822888220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222288222288228222288222222228828882220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222288222288228822288222222228888822220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222882288222888888822288222222228888222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222228882288222888888822288222228228888822220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222228888888222882228822288822288228828882220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222888888222882228882228888888228822288820000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222288882222882228882222888882228822228820000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
