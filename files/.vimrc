" General
    set whichwrap+=<,>,h,l,[,]  " EOL wrapping
    set backspace=indent,eol,start
    set autoread  " auto read when changes are made to file from outside
    set noswapfile
    au VimLeave * if filereadable("$HOME/.vim/.netrwhist") | call delete("$HOME/.vim/.netrwhist") | endif  " no ~/.vim/.netrwhist file



" Vundle
    set nocompatible  " be iMproved
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
    set laststatus=2  " status bar always visible
    set statusline=%t  " file name in status bar
    set ruler  " bar with cursor positions



" Indentation
    set expandtab       " tabs to spaces
    set tabstop=4       " tab width = 4
    set shiftwidth=4    " indentation size = 4
    set autoindent      " fix indentation
    set softtabstop=4   " backspace deletes 4 spaces
    set cindent         " \
    set cinkeys-=0#     "  > don't eat spaces before #
    set indentkeys-=0#  " /



" Key bindings
    let mapleader=" "
    
    " .n toggles line numbers
    nnoremap <Leader>n :set number!<CR>
    
    " H goes to beginning of line
    noremap H ^

    " L goes to end of line
    noremap L $

    " J goes to bottom of file
    noremap J G

    " K goes to top of file
    noremap K gg

    " w!! saves file even if you forgot to open it with sudo
    cnoremap w!! w !sudo tee >/dev/null %
    cnoremap x!! w!!<CR>:q!<CR>

    " <Leader>64 base64 decodes selected text and replaces it
    vnoremap <Leader>64 c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>



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
