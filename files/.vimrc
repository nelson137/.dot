" Functions

function! CompileAndRun()
    exec 'w'
    if &filetype == 'cpp'
        exec 'AsyncRun g++ % -o %<; ./%<'
    elseif &filetype == 'python'
        exec 'AsyncRun python3 %'
    elseif &filetype == 'sh'
        exec 'AsyncRun ./%'
    else
        echo 'No AsyncRun rule exists for filetype' &filetype
    endif
endfunction

function! GetTodo()
    let l:cwd = glob("todo")
    let l:home = glob("$HOME/todo")
    if !empty(l:cwd)
        return l:cwd
    elseif !empty(l:home)
        return l:home
    endif
endfunction

function! OpenTodo()
    exe "topleft vnew" GetTodo()
    vertical resize 50
endfunction

function! OpenVimrc()
    new
    exe 'normal! '.winnr().'<C-w>w'
    edit $MYVIMRC
endfunction



" General

set nocompatible  " Be iMproved
set timeoutlen=500  " Max period of 500ms between keystrokes
set whichwrap+=<,>,[,]  " EOL wrapping
set backspace=indent,eol,start
set autoread  " Automatically read when changes are made on disk
set noswapfile
set undofile  " Persistent file history
set undodir=~/.vim/undodir
set wildmenu  " Zsh-like buffer completion
set splitright  " Open vertical splits to the right
set splitbelow  " Open horizontal splits below
runtime ftplugin/man.vim  " Man plugin
au VimLeave * if filereadable('$HOME/.vim/.netrwhist') | call delete('$HOME/.vim/.netrwhist') | endif  " No ~/.vim/.netrwhist file



" Vundle

filetype off
if !empty(glob('$HOME/.vim/bundle/Vundle.vim'))
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    Plugin 'Raimondi/delimitMate'
    Plugin 'Valloric/YouCompleteMe'
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'apeschel/vim-syntax-apache'
    Plugin 'elzr/vim-json'
    Plugin 'godlygeek/tabular'
    Plugin 'itchyny/lightline.vim'
    Plugin 'python-mode/python-mode'
    Plugin 'scrooloose/nerdtree'
    Plugin 'scrooloose/nerdcommenter'
    Plugin 'sjl/gundo.vim'
    Plugin 'skammer/vim-css-color'
    Plugin 'skywind3000/asyncrun.vim'
    Plugin 'suan/vim-instant-markdown'
    Plugin 'terryma/vim-multiple-cursors'
    Plugin 'tpope/vim-fugitive'
    Plugin 'tpope/vim-surround'
    call vundle#end()
endif
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

let mapleader=','

" For when you forget to open the file with sudo
" Thank you Steve Losh
cnoremap  w!!  w !sudo tee >/dev/null %<CR>

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

" Better window nav
noremap  <C-h>  <C-w>h
noremap  <C-j>  <C-w>j
noremap  <C-k>  <C-w>k
noremap  <C-l>  <C-w>l

" ,<F2> Don't fuck up indentation when pasting
noremap <silent>  <Leader><F2>  :set invpaste<CR>

" ,m Open man page for word under cursor
nnoremap  <Leader>m  :Man <cword><CR>

" ,ev or ,sv Opens or sources .vimrc
" Thank you Derek Wyatt
nnoremap <silent>  <Leader>ev  :call OpenVimrc()<CR>
nnoremap <silent>  <Leader>sv  :so $MYVIMRC<CR>

" AsyncRun file
nnoremap <silent>  ,r  :call CompileAndRun()<CR>

" Open todo
nnoremap  <Leader>t  :call OpenTodo()<CR>

" ,64 Base64 decodes selected text and replaces it
vnoremap  <Leader>64  c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>

" Better paste in insert mode
inoremap  <C-p>  <C-r>"

" jj == <Esc> in insert mode
inoremap  jj  <Esc>



" Open file to the same place you were last time

augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line('$') |
        \     exe 'normal! g`"' |
        \ endif
augroup END



" python-mode

let g:pymode_python = 'python3'
highlight pythonSelf ctermfg=68 guifg=#5f87d7 cterm=bold gui=bold
let g:pymode_doc_bind = ''
let g:pymode_lint_on_write = 0  " Don't lint on write

" Linter ignore:
"   E265: block comment should start with '# '
"   E401: multiple imports on one line
"   E701: multiple statements on one line
"   C901: function is too complex
let g:pymode_lint_ignore = ['E265', 'E401', 'E701', 'C901']



" NERDTree

let NERDRemoveExtraSpaces=1
let NERDSpaceDelims=1
let NERDTrimTrailingWhitespace=1



" AsyncRun

let g:asyncrun_open = 8



" Filetype Configs

au BufRead,BufNewFile *.html set et ts=2 shiftwidth=2 si ai sts=2
