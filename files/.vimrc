" General
    set timeoutlen=500  " Max period of 500ms between keystrokes
    set whichwrap+=<,>,h,l,[,]  " EOL wrapping
    set backspace=indent,eol,start
    set autoread  " Automatically read when changes are made on disk
    set noswapfile
    set undofile  " Persistent file history
    set undodir=~/.vim/undodir
    set wildmenu  " Zsh-like buffer completion
    runtime ftplugin/man.vim  " Man plugin
    au VimLeave * if filereadable("$HOME/.vim/.netrwhist") | call delete("$HOME/.vim/.netrwhist") | endif  " No ~/.vim/.netrwhist file



" Vundle
    set nocompatible  " Be iMproved

    filetype off
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    Plugin 'Raimondi/delimitMate'
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'apeschel/vim-syntax-apache'
    Plugin 'elzr/vim-json'
    Plugin 'godlygeek/tabular'
    Plugin 'itchyny/lightline.vim'
    Plugin 'scrooloose/nerdtree'
    Plugin 'scrooloose/nerdcommenter'
    Plugin 'sjl/gundo.vim'
    Plugin 'skammer/vim-css-color'
    Plugin 'suan/vim-instant-markdown'
    Plugin 'terryma/vim-multiple-cursors'
    Plugin 'tpope/vim-fugitive'
    Plugin 'tpope/vim-surround'
    call vundle#end()
    filetype plugin indent on



" Graphics
    syntax on
    colorscheme default
    set number
    set laststatus=2   " Keep status bar always visible
    set statusline=%t  " Put file name in status bar



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

    " Because holding shift is sooo annoying
    nnoremap  ;  :

    " Move down/up rows in buffer, not up/down lines
    noremap  j  gj
    noremap  k  gk
    
    " H Goes to beginning of line
    noremap  H  ^

    " J Goes to bottom of file
    noremap  J  G

    " K Goes to top of file
    noremap  K  gg

    " L Goes to end of line
    noremap  L  $

    " ,<F2> Don't fuck up indentation when pasting
    noremap <silent>  <Leader><F2>  :set invpaste<CR>

    " ,m Open man page for word under cursor
    nnoremap  <Leader>m  :Man <cword><CR>

    " ,ev or ,sv Opens or sources .vimrc
    " Thank you Derek Wyatt
    nnoremap <silent>  <Leader>ev  :e $MYVIMRC<CR>
    nnoremap <silent>  <Leader>sv  :so $MYVIMRC<CR>

    " for when you forget to open the file with sudo
    " Thank you Steve Losh
    cnoremap  w!!  w !sudo tee >/dev/null %<CR>

    " ,64 Base64 decodes selected text and replaces it
    vnoremap  <Leader>64  c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>

    " Better window nav
    noremap  <C-h>  <C-w>h
    noremap  <C-j>  <C-w>j
    noremap  <C-k>  <C-w>k
    noremap  <C-l>  <C-w>l



" Return to the line you were on last time
    augroup line_return
        au!
        au BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \     execute 'normal! g`"zvzz' |
            \ endif
    augroup END



" NERDTree
    let NERDRemoveExtraSpaces=1
    let NERDSpaceDelims=1
    let NERDTrimTrailingWhitespace=1



" TODO files config
    au BufRead,BufNewFile *.html set et ts=2 shiftwidth=2 si ai sts=2
