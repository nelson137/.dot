" General

set autoread                " Automatically read changes made on disk
set backspace=indent,eol,start
set encoding=utf-8
set history=500             " Remember 500 ex commands
set nocompatible            " Be iMproved
set noswapfile
set scrolloff=4             " Keep cursor 4 lines from top & bot when scrolling
set shell=zsh               " Shell to use for !
set showmode                " Show current mode (normal|visual|insert|...)
set splitbelow              " Open horizontal splits below
set splitright              " Open vertical splits to the right
set timeoutlen=500          " Max period of 500ms between keystrokes
set undodir=~/.vim/undodir  " Put undo files in ~/.vim/undodir
set undofile                " Persistent file history
set undolevels=1000         " Remember 1000 changes to file
set visualbell              " No beep beep
set wildmenu                " Zsh-like buffer completion
runtime ftplugin/man.vim    " Enable man plugin



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



" Graphics

syntax on
colorscheme default
set number
set laststatus=2   " Always show status line



" Autocmd

" Open file to the same line I was on last time
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line('$') |
        \     exe 'normal! g`"' |
        \ endif
augroup end

" No ~/.vim/.netrwhist file
augroup vimleave
    au!
    au VimLeave *
        \ if filereadable('$HOME/.vim/.netrwhist') |
        \     call delete('$HOME/.vim/.netrwhist')
        \ endif  
augroup end



" Filetype Configs

au BufRead,BufNewFile *.html set et ts=2 sw=2 sts=2 si ai



" Functions

function! CompileAndRun()
    if expand('%:t') == ''
        call Error('Error: file has no name')
        return
    else
        let l:filetype = &filetype != '' ? &filetype : expand('%:e')
    endif

    exe 'w'
    if l:filetype == 'cpp'
        " % = filename, %< = filename sans extension
        exe 'AsyncRun g++ % -o %<; ./%<'
    elseif l:filetype == 'python'
        exe 'AsyncRun python3 %'
    elseif l:filetype == 'sh'
        if !IsX()
            let l:prompt = '"Do you want to make this file executable [y/n]? "'
            exe 'let l:choice = input('.l:prompt.')'
            if l:choice == 'y' | silent exe '!chmod +x %' | endif
        endif
        exe 'AsyncRun ./%'
    else
        exe 'call Error("Error: I don''t know how to run' l:filetype 'files")'
    endif
endfunction

function! Error(msg)
    exe 'echohl ErrorMsg | echo "'.a:msg.'" | echohl None'
endfunction

function! Info(msg)
    exe 'echohl MoreMsg | echo "'.a:msg.'" | echohl None'
endfunction

function! GetTodo()
    let l:cwd = glob('todo')
    let l:home = glob('$HOME/todo')
    if !empty(l:cwd)
        return l:cwd
    elseif !empty(l:home)
        return l:home
    endif
endfunction

function! IsX()
    silent exe '!test -x' expand('%:p')
    silent exe 'redraw!'
    if v:shell_error
        " Return status was non-zero
        return 0
    else
        " Return status was zero
        return 1
    endif
endfunction

function! OnExitVimrm(...)
    let l:fn = a:0 == 0 ? '%' : a:1
    let l:prompt_fn = l:fn == '%' ? 'this file' : a:1
    exe 'let l:choice = input("Do you want to delete' l:prompt_fn '[y/n]? ")'
    if l:choice == 'y' | silent exe '!rm' l:fn | endif
endfunction

function! OnExitChhn()
    call OnExit('~/hosts.bak')
    silent exe ':xa'
endfunction

function! ToggleTodo()
    let l:todo = GetTodo()
    if empty(l:todo)
        echo 'No todo file found'
        return
    endif

    let l:last = winnr()
    100 wincmd h
    if expand('%:t') == 'todo'
        exe 'x'
        let l:last -= 1
    else
        exe 'topleft vnew' l:todo
        vertical resize 50
        let l:last += 1
    endif
    exe l:last 'wincmd w'
endfunction

function! OpenVimrc()
    topleft new
    edit $MYVIMRC
endfunction



" Key bindings

let mapleader = ','

" For when I forget to open a file with sudo
" Thank you Steve Losh
cnoremap   w!!   w !sudo tee >/dev/null %<CR>

" Because holding shift is sooo annoying
nnoremap   ;   :

" Move down/up rows in buffer, not up/down lines
noremap   j   gj
noremap   k   gk

" H goes to beginning of line
noremap   H   ^

" J goes to bottom of file
noremap   J   G

" K goes to top of file
noremap   K   gg

" L goes to end of line
noremap   L   $

" Better window nav
noremap   <C-h>   <C-w>h
inoremap   <C-h>   <Esc><C-w>h
noremap   <C-j>   <C-w>j
inoremap   <C-j>   <Esc><C-w>j
noremap   <C-k>   <C-w>k
inoremap   <C-k>   <Esc><C-w>k
noremap   <C-l>   <C-w>l
inoremap   <C-l>   <Esc><C-w>l

" Better window resizing
noremap   <C-w><C-h>   <C-w><
noremap   <C-w><C-j>   <C-w>-
noremap   <C-w><C-k>   <C-w>+
noremap   <C-w><C-l>   <C-w>>

" ,<F2> Don't fuck up indentation when pasting
noremap <silent>   <Leader><F2>   :set invpaste<CR>

" ,m Open man page for word under cursor
nnoremap   <Leader>m   :Man <cword><CR>

" ,ev or ,sv Opens or sources .vimrc
" Thank you Derek Wyatt
nnoremap <silent>   <Leader>ev   :call OpenVimrc()<CR>
nnoremap <silent>   <Leader>sv   :so $MYVIMRC<CR>:call Info('Done')<CR>

" AsyncRun file
nnoremap <silent>   <Leader>r   :call CompileAndRun()<CR>

" Open todo
nnoremap   <Leader>t   :call ToggleTodo()<CR>

" ,64 Base64 decodes selected text and replaces it
vnoremap   <Leader>64   c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>

" Better paste in insert mode
inoremap   <C-p>   <C-r>"

" jj == <Esc> in insert mode
inoremap   jj   <Esc>

" Make {<CR> set up brackets like an IDE would
imap   {<CR>   {<CR>}<Esc>ko

" Gundo mapping
nnoremap <Leader>u :GundoToggle<CR>



" Vundle

filetype off
if !empty(glob('$HOME/.vim/bundle/Vundle.vim'))
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    if empty(matchstr(system('uname -m'), '\varmv\dl'))
        " Enable YouCompleteMe if architecture isn't arm
        Plugin 'Valloric/YouCompleteMe'
    endif
    Plugin 'Raimondi/delimitMate'
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



" Plugin Configs

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

" python-mode
let g:pymode_python = 'python3'
highlight pythonSelf ctermfg=68 guifg=#5f87d7 cterm=bold gui=bold
" TODO: add more python highlighting
let g:pymode_doc_bind = ''
let g:pymode_lint_on_write = 0  " Don't lint on write
" Linter ignore:
"   E265: block comment should start with "# "
"   E401: multiple imports on one line
"   E701: multiple statements on one line
"   C901: function is too complex
let g:pymode_lint_ignore = ['E265', 'E401', 'E701', 'C901']

" NERDCommenter
let NERDRemoveExtraSpaces = 1
let NERDSpaceDelims = 1
let NERDTrimTrailingWhitespace = 1
" Only put 1 space between # and comment content
let g:NERDCustomDelimiters = {
    \ 'python': { 'left': '#' },
\ }

" Gundo
let g:gundo_help = 0
let g:gundo_prefer_python3 = 1

" AsyncRun
let g:asyncrun_open = 8
