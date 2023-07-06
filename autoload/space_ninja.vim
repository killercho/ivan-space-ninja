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

const s:start_spawn_timer = 2000
const s:spawn_decrem = 10

const s:score_per_kill = 20
const s:enemies_per_level = 20

"Binds
const s:move_left = 'h'
const s:move_right = 'l'
const s:move_up = 'k'
const s:move_down = 'j'
const s:shoot = ' '
const s:quit = 'q'
const s:start = 's'

"TODO: BUG: Fix the spawns of enemies going out of bounds

"TODO: Add a timer? to return the ability to shoot to the player

"TODO: Fix animations not ending when a key is not pressed (maybe use
"timer_stop)

"TODO: Make better animations for walking. Maybe include a middle one between
"the idle and a side walk

"TODO: Change the highlighting of the enemies and the shuriken

"TODO: Block other mappings

"Sprites
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

func space_ninja#Start()
    call s:Init()
    call s:Intro()
endfunc

func s:Init()
    if filereadable(bufname('%'))
        exec 'w'
    endif
    exec 'enew'

    hi def NinjaBody ctermbg=black guibg=black
    hi def NinjaShuriken ctermbg=yellow guibg=yellow

    hi def EnemyCol1 ctermbg=green guibg=green
    hi def EnemyCol2 ctermbg=blue guibg=blue

    let s:spawn_timer = s:start_spawn_timer
    let s:enemies_left = 0
    let s:spawn_enemies = 1

    " 0 -> facing down, 1 -> left, 2 -> up, 3 -> right
    let s:last_facing = 0
endfunc

func s:NoProp(text)
    return #{text: a:text, props: []}
endfunc

func s:Intro()
    hi NinjaTitle cterm=bold gui=bold
    call prop_type_delete('ninja_title')
    call prop_type_add('ninja_title', #{highlight: 'NinjaTitle'})
        let shoot_text = s:shoot == ' ' ? '<Space>' : a:shoot
    let s:intro_popup = popup_create([
                \   #{text: '       The robots are coming to get you Ivan!',
                \     props: [#{col: 8, length: 37, type: 'ninja_title'}]},
                \   s:NoProp(''),
                \   s:NoProp('  To play you need to move and shoot...'),
                \   s:NoProp('  Moving uses the normal movement keybinds in vim:'),
                \   #{text: '       ' .. s:move_right .. '          move right',
                \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                \   #{text: '       ' .. s:move_left .. '          move left',
                \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                \   #{text: '       ' .. s:move_down .. '          move down',
                \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                \   #{text: '       ' .. s:move_up .. '          move up',
                \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                \   #{text: '    ' .. shoot_text .. '       shoot',
                \     props: [#{col: 5, length: 6, type: 'ninja_title'}]},
                \   s:NoProp('  To shoot in a direction just look at that direction.'),
                \   s:NoProp(''),
                \   #{text: ' To start the game press   ' .. s:start .. '   or press    ' .. s:quit .. '   to leave. ',
                \     props: [#{col: 27, length: 1, type: 'ninja_title'},
                \             #{col: 43, length: 1, type: 'ninja_title'}]},
                \ ], #{
                \   filter: function('s:IntroFilter'),
                \   callback: function('s:IntroClose'),
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
        let s:ready = popup_create('IVAN GO!', #{border: [], padding:[2, 4, 2, 4]})
            echo 'Game started!'
        call timer_start(s:ready_timeout, { -> s:StartGame()})
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:Clear()
        echo 'Game quited!'
    endif
    return 1
endfunc

func s:IntroClose(id, res)
    call s:Close()
    echo 'Closed intro'
endfunc

func s:StartGame()
    call s:Clear()
    let s:score = 0

    let s:ninja_id = popup_create(s:ninja_sprites[0], #{
                \ line: &lines / 2,
                \ highlight: 'NinjaBody',
                \ filter: function('s:HandleInput'),
                \ zindex: s:ninja_zindex,
                \ mapping: 0
                \ })
    echo 'Game is starting'
    call s:AnimateNinja(s:ninja_id, 0)
    call s:SpawnEnemiesFact()
    let s:score_popup_id = popup_create(string(s:score), #{
                \ line: 1,
                \ col: &columns - 4,
                \ border: [],
                \ padding: [0, 1, 0, 1],
                \ zindex: 3000,
                \ })

endfunc

func s:Clear()
    call popup_clear()
    let s:spawn_timer = s:start_spawn_timer
    let s:shuriken_avaliable = 1
    let s:score = 0
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

func s:HandleInput(id, key)
    if a:key == s:move_up ||
                \ a:key == s:move_down ||
                \ a:key == s:move_right ||
                \ a:key == s:move_left ||
                \ a:key == s:shoot
        call s:MoveNinja(a:id, a:key)
    elseif a:key == s:quit || a:key == toupper(s:quit)
        call s:Clear()
        let s:spawn_enemies = 0
        echo 'Game quited'
    endif
endfunc

func s:MoveNinja(id, key)
    let pos = popup_getpos(a:id)
    let move_col = pos.col
    let move_line = pos.line
    let left_anim = 0
    let right_anim = 0

    if a:key == s:move_right && pos.col < &columns - s:ninja_width
        let move_col = pos.col + s:ninja_speed
        let left_anim = 1
        let s:last_facing = 3
    elseif a:key == s:move_left && pos.col > s:ninja_width
        let move_col = pos.col - s:ninja_speed
        let right_anim = 1
        let s:last_facing = 1
    endif

    if a:key == s:move_down && pos.line < &lines - s:ninja_height - 1
        let move_line = pos.line + s:ninja_speed
        let s:last_facing = 0
    elseif a:key == s:move_up && pos.line > s:ninja_height - 1
        let move_line = pos.line - s:ninja_speed
        let s:last_facing = 2
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

    if a:key == s:shoot
        call s:FireShuriken(pos.line, pos.col)
    endif
endfunc

func s:FireShuriken(line, col)
    if s:shuriken_avaliable == 0
        return
    endif
    let correction_cols = s:last_facing == 1 ? -1 : s:last_facing == 3 ? 1 : 0
    let correction_lines = s:last_facing == 2 ? -1 : s:last_facing == 0 ? 1 : 0
    let spawn_col = a:col + 1 + correction_cols
    let spawn_line = a:line + 1 + correction_lines
    let shuriken_id = popup_create(s:shuriken, #{
                \ col: spawn_col,
                \ line: spawn_line,
                \ highlight: 'NinjaShuriken',
                \ zindex: s:shuriken_zindex,
                \ })
    call s:MoveShuriken(0, shuriken_id, s:last_facing)
endfunc

func s:MoveShuriken(x, id, direction)
    let pos = popup_getpos(a:id)
    if pos == {}
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
        if popup_on_location != 0 && popup_on_location != a:id
            call s:KillEnemy(popup_on_location, 0)
            let s:score += s:score_per_kill
            call popup_settext(s:score_popup_id, string(s:score))
            call popup_close(a:id)
        endif
    endif

    call timer_start(s:shuriken_move_delay, {x -> s:MoveShuriken(x, a:id, a:direction)})
endfunc

func s:KillEnemy(id, state)
    let pos = popup_getpos(a:id)
    if pos == {}
        return
    endif
    if a:state == 3
        let s:enemies_left -= 1
        call popup_close(a:id)
        if s:enemies_left == 0
            echo 'Game over!'
        endif
        return
    endif
    call popup_settext(a:id, s:enemy_sprites[a:state + 2])
    call popup_setoptions(a:id, #{
                \ line: pos.line,
                \ col: pos.col,
                \ })
    call timer_start(s:enemy_death_delay, {x -> s:KillEnemy(a:id, a:state + 1)})
endfunc

func s:SpawnEnemiesFact()
    if s:spawn_timer <= 0 || s:spawn_enemies == 0
        return
    endif
    let seed = srand()
    let correct_placement = 0
    while correct_placement == 0
        let rand_line = rand(seed) % &lines
        let correct_placement = rand_line > s:ninja_height - 1 && rand_line < &lines - s:ninja_height - 1 ? 1 : 0
        let rand_col = rand(seed) % &columns
        let correct_placement += rand_col > s:ninja_width && rand_col < &columns - s:ninja_width ? 1 : 0
    endwhile
    let rand_color_num = rand(seed) % 2
    if rand_color_num == 0
        let rand_color = 'EnemyCol1'
    elseif rand_color_num == 1
        let rand_color = 'EnemyCol2'
    endif
    call s:SpawnEnemy(rand_line, rand_col, rand_color)
    let s:enemies_left += 1
    let s:spawn_timer -= s:spawn_decrem
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
    let s:enemies_left += 1
endfunc

