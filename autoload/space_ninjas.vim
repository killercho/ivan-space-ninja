" bullet sprite ۞  -- space shuriken
" retry ↻ icon
"
" use the highlighting to make better unicode characters

const s:ninja_zindex = 100
const s:enemy_zindex = 90
const s:shuriken_zindex = 80

const s:ready_timeout = 1000

const s:ninja_speed = 1
const s:ninja_width = 3
const s:ninja_height = 3
const s:ninja_anim_timeout = 100

const s:shuriken_cd = 500
const s:shuriken_speed = 1
const s:shuriken_move_delay = 30

const s:enemy_death_delay = 100
const s:enemy_speed = 1
const s:enemy_max_move_delay = 350
const s:enemy_move_delay_decrem = 2
const s:enemy_min_move_delay = 50

const s:start_spawn_timer = 2000
const s:spawn_decrem = 10
const s:spawn_timer_min = 250

const s:score_per_kill = 20

const s:low_score = 300
const s:low_difference_score = 60

"Binds player 1
"const s:move_left_p1 = 'left'
"const s:move_right_p1 = 'right'
"const s:move_up_p1 = 'up'
"const s:move_down_p1 = 'down'
"const s:shoot_p1 = 'l'

const s:move_left_p1 = 'l'
const s:move_right_p1 = ''''
const s:move_up_p1 = 'p'
const s:move_down_p1 = ';'
const s:shoot_p1 = 'j'

"Binds player 2
const s:move_left_p2 = 'a'
const s:move_right_p2 = 'd'
const s:move_up_p2 = 'w'
const s:move_down_p2 = 's'
const s:shoot_p2 = 'g'

const s:quit = 'q'
const s:start = 's'

"TODO: BUG: The arrows are not recognised as a key so player one cannot move

"TODO: BUG: After quiting the game the 'q' key still remembers that it was
"pressed

"TODO: BUG: Fix the spawns of enemies going out of bounds

"TODO: VISUAL: Make better animations for walking. Maybe include a middle one between
"the idle and a side walk

"TODO: VISUAL: Change the highlighting of the enemies and the shuriken

"Old shuriken:
"const s:shuriken = '۞'
const s:shuriken = '*'

const s:ninja_sprites = [[
            "\ First sprite - idle/up/down/ walking
            \ ' ◯ ',
            \ '┍█┑',
            \ '⎛▔⎞'], [
            "\ Second sprite - left walking
            \ ' ◯ੀ',
            \ '┍█┑',
            \ '⎧▔⎞'], [
            "\ Third sprite - right walking
            \ 'ਿ◯ ',
            \ '┍█┑',
            \ '⎛▔⎫'], [
            "\ Death sprite first - go to idle
            "\ Death sprite second
            \ ' X ',
            \ '┍█┑',
            \ '⎛▔⎞'], [
            "\ Death sprite third
            \ ' X ',
            \ ' █ ',
            \ '⎛▔⎞'], [
            "\ Death sprite forth
            \ ' X ',
            \ ' █ ',
            \ '   '], [
            "\ Death sprite fifth
            \ '   ',
            \ ' X ',
            \ ' █ '], [
            "\ Death sprite sixth
            \ '   ',
            \ '   ',
            \ ' X ']]

const s:enemy_sprites = [[
            "\ First sprite
            \ ' ◈ ',
            \ '▀▀▀',
            \ '╯ ൢ╰'],[
            "\ Second sprite
            \ ' ◈ ',
            \ '▀▀▀',
            \ '╯ ൣ╰'],[
            "\ Death sprite first
            \ ' ◈ ',
            \ '   ',
            \ '▀▀▀',
            \ '╯ ൣ╰'],[
            "\ Death sprite second
            \ '   ',
            \ '▀▀▀',
            \ '╯ ╰'],[
            "\ Death sprite third
            \ '   ',
            \ '   ',
            \ '___']]

func space_ninjas#Start()
    call s:Init()
    call s:Intro()
endfunc

func s:Init()
    exec 'tabnew'

    hi def NinjaBody1 ctermbg=black guibg=black
    hi def NinjaShuriken1 ctermbg=yellow guibg=yellow

    hi def NinjaBody2 ctermbg=gray guibg=gray
    hi def NinjaShuriken2 ctermbg=red guibg=red

    hi def EnemyCol1 ctermbg=green guibg=green
    hi def EnemyCol2 ctermbg=blue guibg=blue
endfunc

func s:NoProp(text)
    return #{text: a:text, props: []}
endfunc

func s:RemoveMappings()
    mapclear <buffer>

    for key in ['s', 'i', 'a', 'v', 'c', 'x', 'd']
        exec 'map <buffer> ' .. key .. ' <nop>'
        exec 'map <buffer> ' .. toupper(key) .. ' <nop>'
    endfor
endfunc

func s:Intro()
    call s:RemoveMappings()
    hi NinjaTitle cterm=bold gui=bold
    call prop_type_delete('ninja_title')
    call prop_type_add('ninja_title', #{highlight: 'NinjaTitle'})
        let move_right_text = s:move_right_p1 == '<right>' ? '>' : s:move_right_p1
    let move_left_text = s:move_left_p1 == '<left>' ? '<' : s:move_up_p1
    let move_up_text = s:move_up_p1 == '<up>' ? '^' : s:move_up_p1
    let s:intro_popup = popup_create([
                \   #{text: '       The robots are coming to get you Ivans!',
                \     props: [#{col: 8, length: 38, type: 'ninja_title'}]},
                \   s:NoProp(''),
                \   s:NoProp('  To play you need to move and shoot...'),
                \   s:NoProp('  For movement the first player (the black one) uses the keys'),
                \   s:NoProp('  that are on the left side of ''|'' and the second player (gray) uses the rest:'),
                \   #{text: '   ' .. move_right_text .. '        |   ' .. s:move_right_p2 .. '   move right',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. move_left_text .. '        |   ' .. s:move_left_p2 .. '   move left',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. move_up_text .. '        |   ' .. s:move_up_p2 .. '   move up',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:move_down_p1 .. '   |   ' .. s:move_down_p2 .. '   move down',
                \     props: [#{col: 4, length: 6, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:shoot_p1 .. '        |   ' .. s:shoot_p2 .. '   shoot',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   s:NoProp('  To shoot in a direction just look at that direction.'),
                \   s:NoProp(''),
                \   #{text: ' To start the game press   ' .. s:start .. '   or press    ' .. s:quit .. '   to leave. ',
                \     props: [#{col: 28, length: 1, type: 'ninja_title'},
                \             #{col: 44, length: 1, type: 'ninja_title'}]},
                \ ], #{
                \   filter: function('s:IntroFilter'),
                \   callback: function('s:Clear'),
                \   border: [],
                \   padding: [],
                \   mapping: 0,
                \   drag: 1,
                \   close: 'button',
                \   })
endfunc

func s:IntroFilter(id, key)
    if a:key == s:start || a:key == toupper(s:start)
        call s:Clear()
        let s:ready = popup_create('MANY IVANS GO!', #{border: [], padding:[2, 4, 2, 4]})
            call timer_start(s:ready_timeout, { -> s:StartGame()})
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    endif
    return 1
endfunc

func s:StartGame()
    call s:Clear()
    let s:ninja_1_id = popup_create(s:ninja_sprites[0], #{
                \ line: &lines / 2,
                \ col: &columns / 2 + 6,
                \ highlight: 'NinjaBody1',
                \ filter: function('s:HandleInputNinja1'),
                \ zindex: s:ninja_zindex,
                \ mapping: 0
                \ })
    let s:ninja_2_id = popup_create(s:ninja_sprites[0], #{
                \ line: &lines / 2,
                \ col: &columns / 2 - 6,
                \ highlight: 'NinjaBody2',
                \ filter: function('s:HandleInputNinja2'),
                \ zindex: s:ninja_zindex,
                \ mapping: 0
                \ })
    call s:AnimateNinja(s:ninja_1_id, 0)
    call s:AnimateNinja(s:ninja_2_id, 0)
    call s:SpawnEnemiesFact()
    let s:score_popup_1_id = popup_create(string(s:score_1), #{
                \ line: 1,
                \ col: &columns - 4,
                \ border: [],
                \ padding: [0, 1, 0, 1],
                \ zindex: 3000,
                \ })
    let s:score_popup_2_id = popup_create(string(s:score_2), #{
                \ line: 1,
                \ col: 4,
                \ border: [],
                \ padding: [0, 1, 0, 1],
                \ zindex: 3000,
                \ })
endfunc

func s:Clear()
    call popup_clear(1)
    let s:spawn_timer = s:start_spawn_timer
    let s:shuriken_avaliable = 1
    let s:score_1 = 0
    let s:score_2 = 0
    let s:enemy_move_delay = s:enemy_max_move_delay
    let s:spawn_timer = s:start_spawn_timer
    let s:spawn_enemies = 1
    let s:players_left = 2
endfunc

func s:AnimateNinja(id, state)
    let direction = getwinvar(a:id, 'direction')
    if direction == 0 || a:state == 0
        "Idling
        call popup_settext(a:id, s:ninja_sprites[0])
    elseif direction == 1
        "Moving left
        call popup_settext(a:id, s:ninja_sprites[2])
    elseif direction == 2
        "Moving right
        call popup_settext(a:id, s:ninja_sprites[1])
    endif
    call timer_start(s:ninja_anim_timeout, {x -> s:AnimateNinja(a:id, a:state == 0 ? 1 : 0)})
endfunc

func s:QuitGame()
    call s:Clear()
    let s:spawn_enemies = 0
    echo 'Game closed! Thanks for playing!'
    sleep
    exec 'bd'
    "exec tabclose might work better
endfunc

func s:HandleInputNinja1(id, key)
    if a:key == s:move_up_p1 ||
                \ a:key == s:move_down_p1 ||
                \ a:key == s:move_right_p1 ||
                \ a:key == s:move_left_p1 ||
                \ a:key == s:shoot_p1
        call s:MoveNinja1(a:id, a:key)
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    else
        call setwinvar(a:id, 'direction', 0)
    endif
    return 1
endfunc

func s:HandleInputNinja2(id, key)
    if a:key == s:move_up_p2 ||
                \ a:key == s:move_down_p2 ||
                \ a:key == s:move_right_p2 ||
                \ a:key == s:move_left_p2 ||
                \ a:key == s:shoot_p2
        call s:MoveNinja2(a:id, a:key)
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    else
        call setwinvar(a:id, 'direction', 0)
    endif
    return 1
endfunc

func s:PlayerKilled(id)
    if s:players_left == 0
        call timer_stopall()
        call popup_clear(1)
        let insult_1 = ''
        let insult_2 = ''
        let insult_1_2 = #{text: '    To play the game again press   ' .. s:start .. '   or press   ' .. s:quit .. '   to leave. ',
                    \     props: [#{col: 36, length: 1, type: 'ninja_title'},
                    \             #{col: 51, length: 1, type: 'ninja_title'}]}
        if s:score_1 < s:low_score && s:score_2 < s:low_score
            let insult_1_2 = #{text: 'Damn you are both trash. Make the robots a favour and don''t come back...', props: []}
                elseif s:score_1 < s:low_score
            let insult_1 = 'WOW you realy struggled out there player ONE. It''s good that you had a buddy.'
                elseif s:score_2 < s:low_score
                    let insult_2 = 'It''s good that you are player TWO and not player ONE since you can''t be the main character.'
                endif
                if s:score_1 - s:score_2 < s:low_difference_score
                    let game_overview_l1 = 'The game was closer than expected.'
                    let game_overview_l2 = 'Go on try it again. Resolve the dispute'
                    if insult_1_2 == #{text: 'Damn you are both trash. Make the robots a favour and don''t come back...', props: []}
                            let game_overview_l2 = 'Maybe it will be best if you both just leave gaming for now...'
                    endif
                endif
                let death_popup = popup_create([
                            \   s:NoProp('Game Over!'),
                            \   s:NoProp(''),
                            \   s:NoProp('In the end player one had ' .. s:score_1 .. ' points and player two had ' .. s:score_2 .. ' points.'),
                            \   s:NoProp('' .. insult_1),
                            \   s:NoProp('' .. insult_2),
                            \   s:NoProp('' .. game_overview_l1),
                            \   s:NoProp('' .. game_overview_l2),
                            \   insult_1_2,
                            \ ], #{
                            \   filter: function('s:DeathFilter'),
                            \   callback: function('s:Clear'),
                            \   border: [],
                            \   padding: [],
                            \   mapping: 0,
                            \   drag: 1,
                            \   close: 'button',
                            \   })
    elseif s:players_left == 1
        call popup_close(a:id)
    endif
endfunc

func s:DeathFilter(id, key)
    if a:key == s:start || a:key == toupper(s:start)
        call s:Clear()
        call s:Intro()
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    endif
endfunc

func s:MoveNinja1(id, key)
    let pos = popup_getpos(a:id)
    let move_col = pos.col
    let move_line = pos.line
    let left_anim = 0
    let right_anim = 0

    if a:key == s:move_right_p1 && pos.col < &columns - s:ninja_width
        let move_col = pos.col + s:ninja_speed
        let left_anim = 1
        call setwinvar(a:id, 'last_facing', 3)
    elseif a:key == s:move_left_p1 && pos.col > s:ninja_width
        let move_col = pos.col - s:ninja_speed
        let right_anim = 1
        call setwinvar(a:id, 'last_facing', 1)
    endif

    if a:key == s:move_down_p1 && pos.line < &lines - s:ninja_height - 1
        let move_line = pos.line + s:ninja_speed
        call setwinvar(a:id, 'last_facing', 0)
    elseif a:key == s:move_up_p1 && pos.line > s:ninja_height - 1
        let move_line = pos.line - s:ninja_speed
        call setwinvar(a:id, 'last_facing', 2)
    endif

    if move_line != 0 || move_col != 0
        call popup_move(a:id, #{col: move_col, line: move_line})
            if left_anim == 1
        call setwinvar(a:id, 'direction', 1)
            elseif right_anim == 1
                call setwinvar(a:id, 'direction', 2)
            else
                call setwinvar(a:id, 'direction', 0)
            endif
    endif

    if a:key == s:shoot_p1
        call s:FireShuriken(1, pos.line, pos.col)
    endif
endfunc

func s:MoveNinja2(id, key)
    let pos = popup_getpos(a:id)
    let move_col = pos.col
    let move_line = pos.line
    let left_anim = 0
    let right_anim = 0

    if a:key == s:move_right_p2 && pos.col < &columns - s:ninja_width
        let move_col = pos.col + s:ninja_speed
        let left_anim = 1
        call setwinvar(a:id, 'last_facing', 3)
    elseif a:key == s:move_left_p2 && pos.col > s:ninja_width
        let move_col = pos.col - s:ninja_speed
        let right_anim = 1
        call setwinvar(a:id, 'last_facing', 1)
    endif

    if a:key == s:move_down_p2 && pos.line < &lines - s:ninja_height - 1
        let move_line = pos.line + s:ninja_speed
        call setwinvar(a:id, 'last_facing', 0)
    elseif a:key == s:move_up_p2 && pos.line > s:ninja_height - 1
        let move_line = pos.line - s:ninja_speed
        call setwinvar(a:id, 'last_facing', 2)
    endif

    if move_line != 0 || move_col != 0
        call popup_move(a:id, #{col: move_col, line: move_line})
            if left_anim == 1
        call setwinvar(a:id, 'direction', 1)
            elseif right_anim == 1
                call setwinvar(a:id, 'direction', 2)
            else
                call setwinvar(a:id, 'direction', 0)
            endif
    endif

    if a:key == s:shoot_p2
        call s:FireShuriken(2, pos.line, pos.col)
    endif
endfunc

func s:FireShuriken(id, line, col)
    if a:id == 1
        let shuriken_highlight = 'NinjaShuriken1'
        let last_facing = getwinvar(s:ninja_1_id, 'last_facing')
    elseif a:id == 2
        let shuriken_highlight = 'NinjaShuriken2'
        let last_facing = getwinvar(s:ninja_2_id, 'last_facing')
    endif
    if s:shuriken_avaliable == 0
        return
    endif
    let correction_cols = last_facing == 1 ? -1 : last_facing == 3 ? 1 : 0
    let correction_lines = last_facing == 2 ? -1 : last_facing == 0 ? 1 : 0
    let spawn_col = a:col + 1 + correction_cols
    let spawn_line = a:line + 1 + correction_lines
    let shuriken_id = popup_create(s:shuriken, #{
                \ col: spawn_col,
                \ line: spawn_line,
                \ highlight: shuriken_highlight,
                \ zindex: s:shuriken_zindex,
                \ })
    call s:MoveShuriken(0, shuriken_id, last_facing, a:id)
endfunc

func s:MoveShuriken(x, id, direction, origin)
    let pos = popup_getpos(a:id)
    if empty(pos)
        call timer_stop(a:x)
        return
    endif
    if pos.line <= 2 || pos.line > &lines - 3 || pos.col <= 2 || pos.col > &columns - 2
        call timer_stop(a:x)
        call popup_close(a:id)
        return
    else
        let new_col = pos.col + (a:direction == 1 ? -s:shuriken_speed : a:direction == 3 ? s:shuriken_speed : 0)
        let new_line = pos.line + (a:direction == 2 ? -s:shuriken_speed : a:direction == 0 ? s:shuriken_speed : 0)
        call popup_move(a:id, #{
                    \ col: new_col,
                    \ line: new_line,
                    \ })
        let popup_on_location = popup_locate(new_line, new_col)
        if popup_on_location != 0
                    \ && popup_on_location != a:id
                    \ && popup_on_location != s:ninja_1_id
                    \ && popup_on_location != s:ninja_2_id
            call s:KillEnemy(0, popup_on_location, 0)
            if a:origin == 1
                let s:score_1 += s:score_per_kill
            elseif a:origin == 2
                let s:score_2 += s:score_per_kill
            endif
            call popup_settext(s:score_popup_1_id, string(s:score_1))
            call popup_settext(s:score_popup_2_id, string(s:score_2))
            call popup_close(a:id)
        endif
    endif

    call timer_start(s:shuriken_move_delay, {x -> s:MoveShuriken(x, a:id, a:direction, a:origin)})
endfunc

func s:KillEnemy(x, id, state)
    let pos = popup_getpos(a:id)
    if empty(pos)
        call timer_stop(a:x)
        return
    endif
    if a:state == 3
        call popup_close(a:id)
        call timer_stop(a:x)
        return
    endif
    call popup_settext(a:id, s:enemy_sprites[a:state + 2])
    call popup_setoptions(a:id, #{
                \ line: pos.line,
                \ col: pos.col,
                \ })
    call timer_start(s:enemy_death_delay, {x -> s:KillEnemy(x, a:id, a:state + 1)})
endfunc

func s:SpawnEnemiesFact()
    if s:spawn_timer <= 0 || s:spawn_enemies == 0
        return
    endif
    let seed = srand()
    let correct_placement = 0
    while correct_placement == 0
        let correct_placement = 0
        let rand_line = rand(seed) % &lines
        let correct_placement = rand_line > s:ninja_height - 3 && rand_line < &lines - s:ninja_height - 1 ? 1 : 0
        let rand_col = rand(seed) % &columns
        let correct_placement += rand_col > s:ninja_width - 1 && rand_col < &columns - s:ninja_width - 1 ? 1 : 0
    endwhile
    let rand_color_num = rand(seed) % 2
    if rand_color_num == 0
        let rand_color = 'EnemyCol1'
    elseif rand_color_num == 1
        let rand_color = 'EnemyCol2'
    endif
    call s:SpawnEnemy(rand_line, rand_col, rand_color)
    if s:spawn_timer > s:spawn_timer_min
        let s:spawn_timer -= s:spawn_decrem
    endif
    call timer_start(s:spawn_timer, { -> s:SpawnEnemiesFact()})
endfunc

func s:SpawnEnemy(line, col, color)
    let enemy_id = popup_create(s:enemy_sprites[0], #{
                \ line: a:line,
                \ col: a:col,
                \ highlight: a:color,
                \ fixed: 1,
                \ zindex: s:enemy_zindex,
                \ wrap: 0
                \ })
    if s:enemy_move_delay > s:enemy_min_move_delay
        let s:enemy_move_delay -= s:enemy_move_delay_decrem
    endif
    call s:MoveEnemy(0, enemy_id, s:enemy_move_delay)
endfunc

func s:AnimateEnemy(x, id, state)
    let pos = popup_getpos(a:id)
    if empty(pos)
        call timer_stop(a:x)
        return
    endif
    if a:state == 1
        call popup_settext(a:id, s:enemy_sprites[0])
    else
        call popup_settext(a:id, s:enemy_sprites[1])
    endif
    call timer_start(s:enemy_move_delay, {x -> s:AnimateEnemy(x, a:id, a:state == 0 ? 1 : 0)})
endfunc

func s:MoveEnemy(x, id, move_delay)
    let pos = popup_getpos(a:id)
    if empty(pos)
        call timer_stop(a:x)
        return
    endif
    let seed = srand()
    let rand_ninja = rand(seed) % 2
    if s:players_left == 2
        if rand_ninja == 0
            let player_pos = popup_getpos(s:ninja_1_id)
        elseif rand_ninja == 1
            let player_pos = popup_getpos(s:ninja_2_id)
        endif
    elseif s:players_left == 1
        let player_pos = popup_getpos(s:ninja_1_id)
        if empty(player_pos)
            let player_pos = popup_getpos(s:ninja_2_id)
        endif
    endif

    let popup_on_location = popup_locate(pos.line, pos.col)
    if popup_on_location == s:ninja_1_id || popup_on_location == s:ninja_2_id
        let s:players_left -= 1
        call s:PlayerKilled(popup_on_location)
        call timer_stop(a:x)
        call popup_close(a:id)
        return
    endif

    let move_horizontal = pos.col
    let move_vertical = pos.line
    if pos.line < player_pos.line
        let move_vertical += s:enemy_speed
    elseif pos.line > player_pos.line
        let move_vertical -= s:enemy_speed
    endif

    if pos.col < player_pos.col
        let move_horizontal += s:enemy_speed
    elseif pos.col > player_pos.col
        let move_horizontal -= s:enemy_speed
    endif

    call popup_move(a:id, #{
                \ col: move_horizontal,
                \ line: move_vertical,
                \ })
    call s:AnimateEnemy(0, a:id, 0)
    call timer_start(s:enemy_move_delay, {x -> s:MoveEnemy(x, a:id, a:move_delay)})
endfunc
