func space_ninja#Start()
    echo "Game started!"
endfunc

" bullet sprite ۞  -- space shuriken
" retry ↻ icon
"
" use the highlighting to make better unicode characters

const s:playerSprites = [[
            " First sprite - idle/up/down/ walking
            \ ' ◯ ',
            \ '┍█┑',
            \ '⎛▔⎞'], [
            " Second sprite - left walking
            \ ' ◯ੀ',
            \ '┍█┑',
            \ '⎧▔⎞'], [
            " Third sprite - right walking
            \ 'ਿ◯ ',
            \ '┍█┑',
            \ '⎛▔⎫'], [
            " Death sprite first - go to idle
            " Death sprite second
            \ ' X ',
            \ '┍█┑',
            \ '⎛▔⎞'], [
            " Death sprite third
            \ ' X ',
            \ ' █ ',
            \ '⎛▔⎞'], [
            " Death sprite forth
            \ ' X ',
            \ ' █ ',
            \ '   '], [
            " Death sprite fifth
            \ '   ',
            \ '   ',
            \ ' X '], [
            ]]

const s:playerSpriteMasks = [[
            " First sprite - idle/up/down/ walking
            \ ' x ',
            \ 'xxx',
            \ 'xxx'], [
            " Second sprite - left walking
            \ ' xx',
            \ 'xxx',
            \ 'xxx'], [
            " Third sprite - right walking
            \ 'xx ',
            \ 'xxx',
            \ 'xxx'], [
            " Death sprite first - go to idle
            " Death sprite second
            \ ' x ',
            \ 'xxx',
            \ 'xxx'], [
            " Death sprite third
            \ ' x ',
            \ ' x ',
            \ 'xxx'], [
            " Death sprite forth
            \ ' x ',
            \ ' x ',
            \ '   '], [
            " Death sprite fifth
            \ '   ',
            \ '   ',
            \ ' x '], [
            ]]

const s:enemySprites = [[
            " First sprite
            \ ' ◈ ',
            \ '▀▀▀',
            \ '╯ ൢ╰'],[
            " Second sprite
            \ ' ◈ ',
            \ '▀▀▀',
            \ '╯ ൣ╰'],[
            " Death sprite first
            \ ' ◈ ',
            \ '   ',
            \ '▀▀▀',
            \ '╯ ൣ╰'],[
            " Death sprite second
            \ '   ',
            \ '▀▀▀',
            \ '╯ ╰'],[
            " Death sprite third
            \ '   ',
            \ '   ',
            \ '___']]

const s:enemySpriteMasks = [[
            " First sprite
            \ ' x ',
            \ 'xxx',
            \ 'xxx'],[
            " Second sprite
            \ ' x ',
            \ 'xxx',
            \ 'xxx'],[
            " Death sprite first
            \ ' x ',
            \ '   ',
            \ 'xxx',
            \ 'xxx'],[
            " Death sprite second
            \ '   ',
            \ 'xxx',
            \ 'x x'],[
            " Death sprite third
            \ '   ',
            \ '   ',
            \ 'xxx']]
