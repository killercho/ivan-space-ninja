command IvanGo call s:StartIvanSpaceNinja()

func s:StartIvanSpaceNinja()
    if !has('popupwin')
        call s:WarningMessage('Sorry, but to run the game you need to have the +popupwin feature!')
        return
    endif
    if !has('textprop')
        call s:WarningMessage('Sorry, but to run the game you need to have the +textprop feature!')
        return
    endif
    call space_ninja#Start()
endfunc

func s:WarningMessage(msg)
    echohl WarningMsg
    echo a:msg
    echohl None
endfunc
