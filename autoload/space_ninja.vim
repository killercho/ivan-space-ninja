" bullet sprite ۞  -- space shuriken
" retry ↻ icon
"
" use the highlighting to make better unicode characters

const s:ready_timeout = 1000

const s:shuriken = '۞'

const s:playerSprites = [[
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

const s:playerSpriteMasks = [[
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


func space_ninja#Start()
    call s:Init()
    call s:Intro()
endfunc

func s:Init()
    " highlight the different parts and sprites
    hi def NinjaVisor ctermbg=red guibg=red
    hi def NinjaBelt ctermbg=red guibg=red
    hi def NinjaBody ctermbg=gray guibg=gray
    hi def NinjaShuriken ctermbg=yellow guibg=yellow

    hi def EnemyHead1 ctermbg=green guibg=green
    hi def EnemyHead2 ctermbg=blue guibg=blue
    hi def EnemySmoke ctermbg=gray guibg=gray
    hi def EnemyLegs ctermbg=black guibg=black

endfunc

func s:NoProp(text)
    return #{text: a:text, props: []}
endfunc

func s:Intro()
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
    echo 'Game is starting'
endfunc

func s:Clear()
    call popup_clear()
endfunc

