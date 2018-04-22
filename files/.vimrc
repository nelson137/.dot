" General
    set whichwrap+=<,>,h,l,[,]  " EOL wrapping
    set backspace=indent,eol,start
    set autoread  " Automatically read when changes are made on disk
    set noswapfile
    set undofile  " Persistent file history
    set undodir=~/.vim/undodir
    runtime ftplugin/man.vim  " Man plugin
    au VimLeave * if filereadable("$HOME/.vim/.netrwhist") | call delete("$HOME/.vim/.netrwhist") | endif  " No ~/.vim/.netrwhist file



" Vundle
    set nocompatible  " Be iMproved
    filetype off

    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    Plugin 'VundleVim/Vundle.vim'
    Plugin 'scrooloose/nerdtree'
    Plugin 'skammer/vim-css-color'
    Plugin 'itchyny/lightline.vim'
    " Plugin 'Raimondi/delimitMate'

    call vundle#end()
    filetype plugin indent on



" Graphics
    syntax on
    colorscheme default
    set number
    set laststatus=2   " Keep status bar always visible
    set statusline=%t  " Put file name in status bar
    set ruler          " Enable bar with cursor positions



" Indentation
    set expandtab       " Tabs to spaces
    set tabstop=4       " Tab width = 4
    set shiftwidth=4    " Indentation size = 4
    set autoindent      " Fix indentation
    set copyindent      " Use previous line's indentation
    set softtabstop=4   " Backspace deletes 4 spaces
    set cindent         " \
    set cinkeys-=0#     "  > Don't eat spaces before #
    set indentkeys-=0#  " /
    set visualbell      " No beep beep



" Key bindings
    let mapleader=","
    
    " .n Toggles line numbers
    nnoremap  <Leader>n  :set number!<CR>
    
    " H Goes to beginning of line
    noremap  H  ^

    " L Goes to end of line
    noremap  L  $

    " J Goes to bottom of file
    noremap  J  G

    " K Goes to top of file
    noremap  K  gg

    nnoremap  <Leader>m  :Man <cword><CR>

    " ,ev or ,sv Opens or sources .vimrc
    " Thank you Derek Wyatt
    nnoremap <silent>  <Leader>ev  :e $MYVIMRC<CR>
    nnoremap <silent>  <Leader>sv  :so $MYVIMRC<CR>

    " for when you forgot to open the file with sudo
    " Thank you Steve Losh
    cnoremap  w!!  w !sudo tee >/dev/null %
    cnoremap  x!!  w!!<CR>:q!

    " ,64 Base64 decodes selected text and replaces it
    vnoremap  <Leader>64  c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>



" Return to the line you were on last time
    augroup line_return
        au!
        au BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \     execute 'normal! g`"zvzz' |
            \ endif
    augroup END



" TODO files config
    au BufRead,BufNewFile TODO,*.TODO set noexpandtab shiftwidth=8 tabstop=8 softtabstop=0
    au BufRead,BufNewFile *.html set expandtab tabstop=2 shiftwidth=2 smartindent autoindent softtabstop=2
