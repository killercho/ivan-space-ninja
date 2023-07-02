" bullet sprite ۞  -- space shuriken
" retry ↻ icon
"
" use the highlighting to make better unicode characters

const s:ready_timeout = 1000
const s:ninja_zindex = 100
const s:ninja_speed = 1
const s:ninja_width = 3
const s:ninja_height = 3
const s:ninja_anim = 100

const s:shuriken = '۞'

"TODO: Make better animations for walking. Maybe include a middle one between
"the idle and a side walk

const s:ninjaSprites = [[
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

const s:ninjaSpriteMasks = [[
            "\ First sprite - idle/up/down/ walking
            \ ' x ',
            \ 'xxx',
            \ 'xxx'], [
            "\ Second sprite - left walking
            \ ' xx',
            \ 'xxx',
            \ 'xxx'], [
            "\ Third sprite - right walking
            \ 'xx ',
            \ 'xxx',
            \ 'xxx'], [
            "\ Death sprite first - go to idle
            "\ Death sprite second
            \ ' x ',
            \ 'xxx',
            \ 'xxx'], [
            "\ Death sprite third
            \ ' x ',
            \ ' x ',
            \ 'xxx'], [
            "\ Death sprite forth
            \ ' x ',
            \ ' x ',
            \ '   '], [
            "\ Death sprite fifth
            \ '   ',
            \ ' x ',
            \ ' x '], [
            "\ Death sprite sixth
            \ '   ',
            \ '   ',
            \ ' x ']]

let s:ninjaMasks = []

const s:enemySprites = [[
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

const s:enemySpriteMasks = [[
            "\ First sprite
            \ ' x ',
            \ 'xxx',
            \ 'xxx'],[
            "\ Second sprite
            \ ' x ',
            \ 'xxx',
            \ 'xxx'],[
            "\ Death sprite first
            \ ' x ',
            \ '   ',
            \ 'xxx',
            \ 'xxx'],[
            "\ Death sprite second
            \ '   ',
            \ 'xxx',
            \ 'x x'],[
            "\ Death sprite third
            \ '   ',
            \ '   ',
            \ 'xxx']]

let s:enemyMasks = []

func s:GetMask(l)
    let mask = []
    for r in range(len(a:l))
        let s = 0
        let e = -1
        let l = a:l[r]

        for c in range(len(l))
            if l[c] == ' '
                let e = c
            elseif e >= s
                call add(mask, [s + 1, e + 1, r + 1, r + 1])
                let s = c + 100
                let e = c
            else
                let s = c + 1
            endif
        endfor
        if e >= s
            call add(mask, [s + 1, e + 1, r + 1, r + 1])
        endif
    endfor
    return mask
endfunc

func space_ninja#Start()
    call s:Init()
    call s:Intro()
endfunc

func s:Init()
    " highlight the different parts and sprites
    hi def NinjaVisor ctermbg=red guibg=red
    hi def NinjaBelt ctermbg=red guibg=red
    hi def NinjaBody ctermbg=black guibg=black
    hi def NinjaShuriken ctermbg=yellow guibg=yellow

    hi def EnemyHead1 ctermbg=green guibg=green
    hi def EnemyHead2 ctermbg=blue guibg=blue
    hi def EnemySmoke ctermbg=gray guibg=gray
    hi def EnemyLegs ctermbg=black guibg=black

    for i in s:ninjaSpriteMasks
        call add(s:ninjaMasks, s:GetMask(i))
    endfor

    for i in s:enemySpriteMasks
        call add(s:enemyMasks, s:GetMask(i))
    endfor
endfunc

func s:NoProp(text)
    return #{text: a:text, props: []}
endfunc

func s:Intro()
    exec 'enew'
    hi NinjaTitle cterm=bold gui=bold
    call prop_type_delete('ninja_title')
    call prop_type_add('ninja_title', #{highlight: 'NinjaTitle'})
        let s:intro_popup = popup_create([
                    \   #{text: '       The robots are coming to get you Ivan!',
                    \     props: [#{col: 8, length: 37, type: 'ninja_title'}]},
                    \   s:NoProp(''),
                    \   s:NoProp('  To play you need to move and shoot...'),
                    \   s:NoProp('  Moving uses the normal movement keybinds in vim:'),
                    \   #{text: '       h          move right',
                    \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                    \   #{text: '       l          move left',
                    \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                    \   #{text: '       j          move down',
                    \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                    \   #{text: '       k          move up',
                    \     props: [#{col: 8, length: 1, type: 'ninja_title'}]},
                    \   #{text: '    <Space>       shoot',
                    \     props: [#{col: 5, length: 6, type: 'ninja_title'}]},
                    \   s:NoProp('  To shoot in a direction just look at that direction.'),
                    \   s:NoProp(''),
                    \   #{text: ' To start the game press   s   or press    q   to leave. ',
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
    if a:key == 's' || a:key == 'S'
        call s:Clear()
        let s:score = 0
        let s:ready = popup_create('IVAN GO!', #{border: [], padding:[2, 4, 2, 4]})
            echo 'Game started!'
        call timer_start(s:ready_timeout, { -> s:StartGame()})
    elseif a:key == 'q' || a:key == 'Q'
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
    " Begin game after the timeout of the intro
    call s:Clear()
    let s:ninja = popup_create(s:ninjaSprites[0], #{
                \ line: &lines / 2,
                \ highlight: 'NinjaBody',
                \ filter: function('s:MoveNinja'),
                \ zindex: s:ninja_zindex,
                \ mask: s:ninjaMasks[0],
                \ mapping: 0
                \ })
    echo 'Game is starting'
    call s:AnimateNinja(s:ninja, 0)
endfunc

func s:Clear()
    call popup_clear()
endfunc

func s:AnimateNinja(id, state)
    "State changes between 1 and 0 for moving -> idle -> moving
    "Starting with moving
    let direction = getwinvar(a:id, 'direction')
    if direction == 0 || a:state == 0
        "Idling
        call popup_settext(a:id, s:ninjaSprites[0])
        call popup_setoptions(a:id, #{mask: s:ninjaMasks[0]})
            elseif direction == 1
        "Moving left
        call popup_settext(a:id, s:ninjaSprites[2])
        call popup_setoptions(a:id, #{mask: s:ninjaMasks[2]})
            elseif direction == 2
        "Moving right
        call popup_settext(a:id, s:ninjaSprites[1])
        call popup_setoptions(a:id, #{mask: s:ninjaMasks[1]})
            endif
        call timer_start(s:ninja_anim, {x -> s:AnimateNinja(a:id, a:state == 0 ? 1 : 0)})
endfunc

func s:MoveNinja(id, key)
    let pos = popup_getpos(a:id)
    let move_col = pos.col
    let move_line = pos.line
    let left_anim = 0
    let right_anim = 0

    if a:key == 'l' && pos.col < &columns - s:ninja_width
        let move_col = pos.col + s:ninja_speed
        let left_anim = 1
    elseif a:key == 'h' && pos.col > s:ninja_width
        let move_col = pos.col - s:ninja_speed
        let right_anim = 1
    endif

    if a:key == 'j' && pos.line < &lines - s:ninja_height
        let move_line = pos.line + s:ninja_speed
    elseif a:key == 'k' && pos.line > s:ninja_height
        let move_line = pos.line - s:ninja_speed
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

    if a:key == ' '
        echo 'Firing shuriken'
    elseif a:key == 'q' || a:key == '<Esc>'
        call s:Clear()
        echo 'Game quited'
    endif
endfunc

