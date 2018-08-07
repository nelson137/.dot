" General

set autoread                " Automatically read changes made on disk
set backspace=indent,eol,start
set encoding=utf-8
set history=500             " Remember 500 ex commands
set nocompatible            " Be iMproved
set noswapfile              " I like to live dangerously
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
set smartindent     " Let's try smartindent again
set softtabstop=4   " Backspace deletes 4 spaces
set cindent         " \
set cinkeys-=0#     "  > Don't eat spaces before #
set indentkeys-=0#  " /



" Graphics

syntax on
colorscheme default
set number         " Turn on line numbers
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
        \     call delete('$HOME/.vim/.netrwhist') |
        \ endif  
augroup end



" Filetype Configs

" Set indentation rules for HTML files
au BufRead,BufNewFile *.html set ts=2 sw=2 sts=2

" Show ruler for specific filetypes
autocmd FileType cpp,javascript,python,sh,vim,zsh
    \ setlocal colorcolumn=+1 textwidth=79



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
    elseif l:filetype == 'sh' || l:filetype == 'zsh'
        if !IsX()
            let l:prompt = '"Do you want to make this file executable [y/n]? "'
            exe 'let l:choice = input('.l:prompt.')'
            if l:choice == 'y' | silent exe '!chmod +x %' | endif
            silent exe 'redraw!'
        endif
        exe 'AsyncRun ./%'
    else
        exe 'call Error("Error: I don''t know how to run' l:filetype 'files")'
    endif
endfunction

function! Error(msg)
    echohl ErrorMsg | echo a:msg | echohl None
endfunction

function! Info(msg)
    echohl MoreMsg | echo a:msg | echohl None
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
    return v:shell_error ? 0 : 1
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

function! OpenVimrc()
    topleft new
    edit $MYVIMRC
endfunction



" Key bindings

let mapleader = ','

" Because holding shift is sooo annoying
nnoremap   ;   :

" For when I forget to open a file with sudo
" Thank you Steve Losh
cnoremap   w!!   w !sudo tee >/dev/null %<CR>

" Better window nav
inoremap   <C-h>   <Esc><C-w>h
inoremap   <C-j>   <Esc><C-w>j
inoremap   <C-k>   <Esc><C-w>k
inoremap   <C-l>   <Esc><C-w>l

" jj == <Esc> in insert mode
" Thank you Derek Wyatt
inoremap   jj   <Esc>

" Quickly save without leaving insert mode
inoremap   jw   <Esc>:w<CR>li

" Better paste in insert mode
inoremap   <C-p>   <C-r>"

" Encodes selected text in Base64 and replaces it
vnoremap   <Leader>64   c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>

" Don't swap selection and register " when pasting
xnoremap   p   pgvy

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
noremap   <C-j>   <C-w>j
noremap   <C-k>   <C-w>k
noremap   <C-l>   <C-w>l

" Better window resizing
noremap   <C-w><C-h>   <C-w><
noremap   <C-w><C-j>   <C-w>-
noremap   <C-w><C-k>   <C-w>+
noremap   <C-w><C-l>   <C-w>>

" New tab
noremap <silent>   <Leader>t   :tabnew<CR>

" Tab next
noremap <silent>   <Leader>tn   :tabn<CR>

" Tab previous
noremap <silent>   <Leader>tp   :tabp<CR>

" New window below
noremap <silent>   <Leader>wn   :new<CR>

" New window to the right
noremap <silent>   <Leader>wv   :vnew<CR>

" Toggle line numbers
noremap <silent>   <Leader>n   :set nu!<CR>

" Don't fuck up indentation when pasting
noremap <silent>   <F2>   :set paste!<CR>

" Open man page for word under cursor
noremap <silent>   <Leader>m   :Man <cword><CR>

" Gundo mapping
noremap <silent>   <Leader>u   :GundoToggle<CR>

" Opens and sources .vimrc
" Thank you Derek Wyatt
noremap <silent>   <Leader>ev   :call OpenVimrc()<CR>
noremap <silent>   <Leader>sv   :so $MYVIMRC<CR>:call Info('Done')<CR>

" Show map-modes
noremap <silent>   <Leader>mm   :h map-modes<CR>

" AsyncRun file
noremap <silent>   <Leader>r   :call CompileAndRun()<CR>

" Python-mode lint
noremap <silent>   <Leader>pl   :call pymode#lint#check()<CR>

" Preview markdown file
noremap <silent>   <Leader>mp   :MarkdownPreview<CR>

" Stop previewing markdown file
noremap <silent>   <Leader>ms   :MarkdownPreviewStop<CR>



" Vundle

filetype off
if !empty(glob('$HOME/.vim/bundle/Vundle.vim'))
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'          " Package manager
    " Enable YouCompleteMe if architecture isn't arm
    if empty(matchstr(system('uname -m'), '\varmv\dl'))
        Plugin 'Valloric/YouCompleteMe'    " Code completion engine
    endif
    Plugin 'ap/vim-css-color'              " Show colors of CSS color codes
    Plugin 'apeschel/vim-syntax-apache'    " Syntax highlighting for apache
    Plugin 'elzr/vim-json'                 " JSON highlighting and quote hiding
    Plugin 'godlygeek/tabular'             " Handles md tables for you
    Plugin 'iamcco/markdown-preview.vim'   " Preview markdown files live
    Plugin 'itchyny/lightline.vim'         " The pretty statusline
    Plugin 'jiangmiao/auto-pairs'          " Manage quotes, parens, etc in pair
    Plugin 'neovimhaskell/haskell-vim'     " Haskell highlighting & indentation
    Plugin 'python-mode/python-mode'       " Python IDE
    Plugin 'scrooloose/nerdcommenter'      " Quickly (un)comment lines
    Plugin 'scrooloose/nerdtree'           " File system explorer
    Plugin 'sjl/gundo.vim'                 " Vim undo tree viewer
    Plugin 'skywind3000/asyncrun.vim'      " Run/Execute files in vim
    Plugin 'terryma/vim-multiple-cursors'  " I think this one's pretty obvious
    Plugin 'tommcdo/vim-exchange'          " Easily swap 2 regions of text
    Plugin 'tpope/vim-fugitive'            " Git wrapper
    Plugin 'tpope/vim-surround'            " Surrounds selected text for you
    Plugin 'w0rp/ale'                      " Asynchronous Lint Engine
    call vundle#end()
endif
filetype plugin indent on



" Plugin Configs

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/' .
\    'ycmd/.ycm_extra_conf.py'

" markdown-preview.vim
let g:mkdp_path_to_chrome = 'google-chrome --new-window'

" python-mode
let g:pymode_doc_bind = 'pd'
let g:pymode_lint = 0
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
let g:NERDCustomDelimiters = { 'python': {'left': '#'} }

" Gundo
let g:gundo_help = 0
let g:gundo_prefer_python3 = 1

" AsyncRun
let g:asyncrun_open = 8

" ALE
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_change = 'never'
let g:ale_linters = { 'python': ['flake8', 'pycodestyle', 'pylint', 'pyls'] }
let g:ale_use_global_executables = 1
let g:ale_command_wrapper = 'nice -n 3'
let g:ale_echo_msg_format = '%linter%: %code: %%s'
let g:ale_loclist_msg_format = g:ale_echo_msg_format
let g:ale_python_pylint_options = '--disable=invalid-name,no-else-return,' .
\    'missing-docstring,redefined-outer-name,too-many-branches,' .
\    'multiple-imports'
" The first line of errors and warnings is what is ignored by default,
" however, --ignore overrides the default
let g:ale_python_flake8_options = '--ignore=' .
\    'E121,E123,E126,E226,E24,E704,W503,W504,' .
\    'E116'
let g:ale_fixers = { 'python': ['remove_trailing_lines', 'trim_whitespace'] }
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_change_sign_column_color = 1
