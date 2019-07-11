" General

set autoread                " Automatically read changes made on disk
set backspace=indent,eol,start
set clipboard=unnamedplus   " Use the system clipboard (requires vim-gtk*)
set encoding=utf-8
set history=500             " Remember 500 ex commands
set ignorecase              " Ignore case in searches
set incsearch               " Highlight search matches while typing
set list
set listchars=tab:>~        " Show tabs as >~~~
set nocompatible            " Be iMproved
set noswapfile              " I like to live dangerously
set scrolloff=4             " Keep cursor 4 lines from top & bot when scrolling
set shell=zsh               " Shell to use for !
set showmode                " Show current mode (normal, visual, insert, etc)
set smartcase               " Ignore ignorecase when capital letters are used
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
set laststatus=2   " Always show status line
set nohlsearch     " Don't highlight all search matches
set number         " Turn on line numbers



" Autocmd

let g:last_closed_file = 'DEFAULT'
augroup mine
    au!

    " Open file to the same line I was on last time
    au BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line('$') |
        \     exe 'normal! g`"' |
        \ endif

    " No ~/.vim/.netrwhist file
    au VimLeave *
        \ if filereadable('$HOME/.vim/.netrwhist') |
        \     call delete('$HOME/.vim/.netrwhist') |
        \ endif

    " Disable ALE in ~/.zsh_history
    au BufEnter .zsh_history call ale#toggle#Disable()

    " Close the quickfix window when exiting
    au BufUnload * if len(getqflist()) | exe ':cclose' | endif

    " Disable listchars
    au FileType gitcommit,make,man,qf set nolist

    " Set indentation rules for HTML files
    au BufRead,BufNewFile *.html set ts=2 sw=2 sts=2

    " Show ruler for specific filetypes
    au FileType c,cpp,javascript,python,sh,vim,zsh
        \ setlocal colorcolumn=+1 textwidth=79

    au FileType asm ALEDisable

    au BufWrite .vimrc let g:vimrc_changed = 1
    au BufEnter * call vimrc#AutoSource()
augroup end



" Functions

function! CompileAndRun()
    if expand('%:t') == ''
        call Error('Error: file has no name')
        return
    else
        let l:filetype = &filetype == '' ? expand('%:e') : &filetype
    endif

    if l:filetype == 'c' || l:filetype == 'cpp' || l:filetype == 'asm'
        exe 'AsyncRun to cero %' system('mktemp --dry-run')
    elseif l:filetype == 'sh' || l:filetype == 'zsh'
        if !IsX()
            let l:prompt = 'File is not executable. Change permissions [y/n]? '
            if input(l:prompt) != 'y' | redraw! | return | endif
            redraw!
            exe 'call system("chmod +x '.expand('%:p').'")'
        endif
        exe 'AsyncRun ./%'
    elseif l:filetype == 'tex'
        exe 'AsyncRun pdflatex %'
    else
        exe 'call Error("Error filetype not supported: '.l:filetype.')'
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
    let l:perms = getfperm(expand('%:p'))

    if !strlen(l:perms)
        return 0
    endif

    if l:perms[2] == 'x'  " Owner has execute permissions
        let l:owner = trim(system('stat -c "%U" '.expand('%:p')))
        return l:owner == $USER
    elseif l:perms[5] == 'x'  " Group has execute permissions
        let l:group = system('stat -c "%G" '.expand('%:p'))
        let l:user_groups = split(system('groups '.$USER))[2:]
        return index(l:user_groups, l:group) >= 0
    elseif l:perms[8] == 'x'  " Everyone else has execute permissions
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

function! GetPythonVersion()
    let l:shebang = system('head -1 "'.expand('%').'"')
    if l:shebang[:1] == "#!"
        let l:cmd = l:shebang[2:][:-2] . ' --version 2>&1'
        let l:vnum = split(system(l:cmd))[1]
        if l:vnum[0] == '3'
            return 'python3'
        elseif l:vnum[0] == '2'
            return 'python2'
        else
            return 'unrecognized version'
        endif
    else
        " Default to python3 if there is no shebang
        return 'python3'
    endif
endfunction

function! VimSupportsYouCompleteMe()
    return empty(matchstr(system('uname -m'), '\varmv\dl')) &&
    \    v:version >= 800 || (v:version >= 704 && has('patch1578'))
endfunction



" Key bindings

let mapleader = ','

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

" Better paste in insert mode
inoremap   <C-p>   <C-r>"

" Encodes selected text in Base64 and replaces it
vnoremap   <Leader>64   c<C-r>=system('base64 --decode', @")<CR><C-h><Esc>

" Don't swap selection and register " when pasting
xnoremap   p   pgvy

" Replace f and F with sneak
noremap   <Leader>f   <Plug>Sneak_s
noremap   <Leader>F   <Plug>Sneak_S

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
noremap <silent>   tn   :tabnew<CR>

" Tab next
noremap <silent>   tl   :tabn<CR>

" Tab previous
noremap <silent>   th   :tabp<CR>

" New window below
noremap <silent>   <Leader>wn   :new<CR>

" New window to the right
noremap <silent>   <Leader>wv   :vnew<CR>

" Toggle line numbers
noremap <silent>   <Leader>n   :set nu!<CR>

" Toggle the colorcolumn
noremap <silent>   <Leader>gt  :let &cc = &cc == '' ? '+1' : ''<CR>

" Don't fuck up indentation when pasting
noremap <silent>   <F2>   :set paste!<CR>

" Open man page for word under cursor
noremap <silent>   <Leader>m   :Man <cword><CR>

" Gundo mapping
noremap <silent>   <Leader>u   :GundoToggle<CR>

" Opens and sources .vimrc
" Thank you Derek Wyatt
noremap <silent>   <Leader>ev   :call vimrc#Open()<CR>
noremap <silent>   <Leader>sv   :call vimrc#Source()<CR>

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

" Toggle ALE linting
noremap <silent>   <Leader>at   :ALEToggle<CR>



" Vundle

filetype off
if !empty(glob('$HOME/.vim/bundle/Vundle.vim'))
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'          " Package manager
    if VimSupportsYouCompleteMe()
        Plugin 'Valloric/YouCompleteMe'    " Code completion engine
    endif
    Plugin 'ap/vim-css-color'              " Show colors of CSS color codes
    Plugin 'apeschel/vim-syntax-apache'    " Syntax highlighting for apache
    Plugin 'elzr/vim-json'                 " JSON highlighting and quote hiding
    Plugin 'godlygeek/tabular'             " Handles md tables for you
    Plugin 'iamcco/markdown-preview.vim'   " Preview markdown files live
    Plugin 'itchyny/lightline.vim'         " The pretty statusline
    Plugin 'jiangmiao/auto-pairs'          " Manage quotes, parens, etc in pair
    Plugin 'justinmk/vim-sneak'            " The missing vim motion
    Plugin 'mhinz/vim-signify'             " Show added/modified/removed lines
    Plugin 'octol/vim-cpp-enhanced-highlight'  " Better C++ syntax highlighting
    Plugin 'python-mode/python-mode'       " Python IDE
    Plugin 'scrooloose/nerdcommenter'      " Quickly (un)comment lines
    Plugin 'scrooloose/nerdtree'           " File system explorer
    Plugin 'sjl/gundo.vim'                 " Vim undo tree viewer
    Plugin 'skywind3000/asyncrun.vim'      " Run/Execute files in vim
    Plugin 'terryma/vim-multiple-cursors'  " I think this one's pretty obvious
    Plugin 'tommcdo/vim-exchange'          " Easily swap 2 regions of text
    Plugin 'tpope/vim-surround'            " Surrounds selected text for you
    Plugin 'vim-scripts/a.vim'             " Switch between source/header files
    Plugin 'w0rp/ale'                      " Asynchronous Lint Engine
    call vundle#end()
endif
filetype plugin indent on



" Plugin Configs

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_show_diagnostics_ui = 0

" vim-json
let g:vim_json_syntax_conceal = 0

" markdown-preview.vim
let g:mkdp_path_to_chrome = 'google-chrome --new-window'

" vim-cpp-enhanced-highlight
" let g:cpp_member_variable_highlight = 1

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
let g:asyncrun_save = 2

" ALE
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_change = 'always'
let g:ale_c_parse_makefile = 1
let g:ale_c_gcc_options =
\    '-std=c11 -O3 -Wall -Werror ' .
\    system('echo -n $C_SEARCH_LIBS')
let g:ale_cpp_gcc_options =
\    '-std=c++17 -Wall -Werror' .
\    system('echo -n $CPLUS_SEARCH_LIBS')
let g:ale_linters = { 'python': ['flake8', 'pycodestyle', 'pylint', 'pyls'] }
let g:ale_use_global_executables = 1
let g:ale_python_flake8_executable = GetPythonVersion()
let g:ale_python_pylint_executable = g:ale_python_flake8_executable
let g:ale_command_wrapper = 'nice -n 3'
let g:ale_echo_msg_format = '%linter%: %code: %%s'
let g:ale_loclist_msg_format = g:ale_echo_msg_format
let s:pylint_disabled = [
\    'eval-used',
\    'exec-used',
\    'invalid-name',
\    'line-too-long',
\    'missing-docstring',
\    'multiple-imports',
\    'no-else-return',
\    'no-self-use',
\    'possibly-unused-variable',
\    'protected-access',
\    'redefined-outer-name',
\    'too-few-public-methods',
\    'too-many-branches',
\    'too-many-locals',
\    'too-many-instance-attributes',
\    'unused-argument'
\]
let g:ale_python_pylint_options = '--disable=' . join(s:pylint_disabled, ',')
" The first line of errors and warnings is what is ignored by default,
" however, --ignore overrides the default
" My flake8 ignores:
"     D107: missing docstring in __init__
"     D413: missing blank line after last section
"     E114: indentation is not a multiple of four (comment)
"     E115: expected an indented block (comment)
"     E116: unexpected indentation (comment)
let g:ale_python_flake8_options = '--ignore=' .
\    'E121,E123,E126,E226,E24,E704,W503,W504,' .
\    'D107,D413,E114,E115,E116'
let g:ale_fixers = {
\    'python': ['isort', 'remove_trailing_lines', 'trim_whitespace'],
\    '*': ['remove_trailing_lines', 'trim_whitespace']
\}
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:ale_change_sign_column_color = 1
