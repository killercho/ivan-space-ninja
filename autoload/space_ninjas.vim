"Z-indexes
const s:ninja_zindex = 100
const s:enemy_zindex = 90
const s:shuriken_zindex = 80

"Timeout of the message at prepare screen
const s:ready_timeout = 1000

"Ninja constants
const s:ninja_speed = 1
const s:ninja_width = 3
const s:ninja_height = 3
const s:ninja_anim_timeout = 100

"Shuriken constants
const s:shuriken_speed = 1
const s:shuriken_move_delay = 30

"Enemy constants
const s:enemy_death_delay = 100
const s:enemy_speed = 1
const s:enemy_max_move_delay = 200
const s:enemy_move_delay_decrem = 5
const s:enemy_min_move_delay = 50

"Enemy spawn constants
const s:start_spawn_timer = 1500
const s:spawn_decrem = 10
const s:spawn_timer_min = 250

const s:score_per_kill = 20

"Thresholds for the additional messages at the end
const s:low_score = 500
const s:low_difference_score = 60

"Binds player 1
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

"Binds for quiting and starting the game
const s:quit = 'q'
const s:start = 's'

"Sprites
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
    "Helper function for easier menu creating
    return #{text: a:text, props: []}
endfunc

func s:Intro()
    hi NinjaTitle cterm=bold gui=bold
    call prop_type_delete('ninja_title')
    call prop_type_add('ninja_title', #{highlight: 'NinjaTitle'})
        let move_right_text = s:move_right_p1 == '<right>' ? '>' : s:move_right_p1
    let move_left_text = s:move_left_p1 == '<left>' ? '<' : s:move_left_p1
    let move_up_text = s:move_up_p1 == '<up>' ? '^' : s:move_up_p1
    let s:intro_popup = popup_create([
                \   #{text: '       The robots are coming to get you Ivans!',
                \     props: [#{col: 8, length: 38, type: 'ninja_title'}]},
                \   s:NoProp(''),
                \   s:NoProp('  To play you need to move and shoot...'),
                \   s:NoProp('  For movement the first player (the black one) uses the keys'),
                \   s:NoProp('  that are on the right side of ''|'' and the second player (gray) uses the left side:'),
                \   #{text: '   ' .. s:move_right_p2 .. '        |   ' .. move_right_text .. '   move right',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:move_left_p2 .. '        |   ' .. move_left_text .. '   move left',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:move_up_p2 .. '        |   ' .. move_up_text .. '   move up',
                \     props: [#{col: 4, length: 1, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:move_down_p2 .. '        |   ' .. s:move_down_p1 .. '   move down',
                \     props: [#{col: 4, length: 6, type: 'ninja_title'}, #{col: 17, length: 1, type: 'ninja_title'}]},
                \   #{text: '   ' .. s:shoot_p2 .. '        |   ' .. s:shoot_p1 .. '   shoot',
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
    "Function responsible for handling the input from the intro
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
                \ filter: function('s:HandleInput'),
                \ zindex: s:ninja_zindex,
                \ mapping: 0
                \ })
    let s:ninja_2_id = popup_create(s:ninja_sprites[0], #{
                \ line: &lines / 2,
                \ col: &columns / 2 - 6,
                \ highlight: 'NinjaBody2',
                \ filter: function('s:HandleInput'),
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
    "Clearing all popups and reseting all values to default
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
endfunc

func s:HandleInput(id, key)
    "Function handling the input from the players after the game started
    if a:key == s:move_up_p1 ||
                \ a:key == s:move_down_p1 ||
                \ a:key == s:move_right_p1 ||
                \ a:key == s:move_left_p1 ||
                \ a:key == s:shoot_p1
        call s:MoveNinja(s:ninja_1_id, a:key)
    elseif a:key == s:move_up_p2 ||
                \ a:key == s:move_down_p2 ||
                \ a:key == s:move_right_p2 ||
                \ a:key == s:move_left_p2 ||
                \ a:key == s:shoot_p2
        call s:MoveNinja(s:ninja_2_id, a:key)
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    else
        call setwinvar(a:id, 'direction', 0)
    endif
    return 1
endfunc

func s:PlayerKilled(id)
    "Function responsible for the end message
    if s:players_left == 0
        call timer_stopall()
        call popup_clear(1)
        let game_overview_l1 = ''
        let game_overview_l2 = ''
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
                if abs(s:score_1 - s:score_2) < s:low_difference_score
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
    "Function handling the input from the death screen
    if a:key == s:start || a:key == toupper(s:start)
        call s:Clear()
        call s:Intro()
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:QuitGame()
    endif
    return 1
endfunc

func s:MoveNinja(id, key)
    "Function responsible for moving the players
    let pos = popup_getpos(a:id)
    if empty(pos)
        return
    endif
    let move_col = pos.col
    let move_line = pos.line
    let left_anim = 0
    let right_anim = 0

    if a:id == s:ninja_1_id
        let move_left = s:move_left_p1
        let move_right = s:move_right_p1
        let move_up = s:move_up_p1
        let move_down = s:move_down_p1
        let shoot = s:shoot_p1
    elseif a:id == s:ninja_2_id
        let move_left = s:move_left_p2
        let move_right = s:move_right_p2
        let move_up = s:move_up_p2
        let move_down = s:move_down_p2
        let shoot = s:shoot_p2
    endif

    if a:key == move_right && pos.col < &columns - s:ninja_width
        let move_col = pos.col + s:ninja_speed
        let left_anim = 1
        call setwinvar(a:id, 'last_facing', 3)
    elseif a:key == move_left && pos.col > s:ninja_width
        let move_col = pos.col - s:ninja_speed
        let right_anim = 1
        call setwinvar(a:id, 'last_facing', 1)
    endif

    if a:key == move_down && pos.line < &lines - s:ninja_height - 1
        let move_line = pos.line + s:ninja_speed
        call setwinvar(a:id, 'last_facing', 0)
    elseif a:key == move_up && pos.line > s:ninja_height - 1
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

    if a:key == shoot
        call s:FireShuriken(a:id, pos.line, pos.col)
    endif
endfunc

func s:FireShuriken(id, line, col)
    if a:id == s:ninja_1_id
        let player = 1
        let shuriken_highlight = 'NinjaShuriken1'
        let last_facing = getwinvar(s:ninja_1_id, 'last_facing')
    elseif a:id == s:ninja_2_id
        let player = 2
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
    call s:MoveShuriken(0, shuriken_id, last_facing, player)
endfunc

func s:MoveShuriken(x, id, direction, origin)
    "Function handling the movement and enemy detection of the shuriken
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
    "Function responsible for the last moments before an enemy dies
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
    "Function handling the spawning of the enemies
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
    "Function responsible for creating the enemy
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
    "Function handling the movement of the enemy towards the players
    "Only one player can be 'attractive' to the enemy at any point
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
