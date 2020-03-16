function! vimrc#Open()
    tabedit $MYVIMRC
endfunction

function! vimrc#Source()
    source $MYVIMRC
    call lightline#colorscheme()
    redraw
    call Info('Sourced vimrc')
endfunction

function! vimrc#AutoSource()
    if get(g:, 'vimrc_changed')
        call vimrc#Source()
    endif
    let g:vimrc_changed = 0
endfunction
