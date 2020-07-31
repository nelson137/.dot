" General

set autoread                " Automatically read changes made on disk
set backspace=indent,eol,start
set clipboard=autoselect,autoselectplus " Always use the system clipboard
set encoding=utf-8
set history=500             " Remember 500 ex commands
set ignorecase              " Ignore case in searches
set incsearch               " Highlight search matches while typing
set list
exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set modeline                " Check for comments with settings
set nocompatible            " Be iMproved
set noshowmode              " Lightline plugin takes care of this
set noswapfile              " I like to live dangerously
set rtp+=~/.dot/components/fzf
set scrolloff=4             " Keep cursor 4 lines from top & bot when scrolling
set signcolumn=yes
set shell=zsh               " Shell to use for !
set shortmess=aoOtT
set smartcase               " Ignore ignorecase when capital letters are used
set splitbelow              " Open horizontal splits below
set splitright              " Open vertical splits to the right
set timeoutlen=500          " Max period of 500ms between keystrokes
set undodir=~/.vim/undodir  " Put undo files in ~/.vim/undodir
set undofile                " Persistent file history
set undolevels=1000         " Remember 1000 changes to file
set updatetime=100          " Timeout in ms with no typing (for plugins)
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
set background=dark  " Fix colors changing with terminal opacity
set laststatus=2     " Always show status line
set nohlsearch       " Don't highlight all search matches
set number           " Turn on line numbers



" Color Column

highlight ColorColumn cterm=reverse
match ColorColumn /\%80v[^\n]\+/



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

    " Close the quickfix window when exiting
    au BufUnload * if len(getqflist()) | exe ':cclose' | endif

    " Disable listchars
    au FileType gitcommit,make,man,qf set nolist

    " Set indentation rules for HTML files
    au BufRead,BufNewFile *.html,*.yml,*.yaml set ts=2 sw=2 sts=2

    au FileType pdf
        \ silent execute "!zathura --fork" expand('%') |
        \ execute 'q'

    au BufWrite *.py exe ':CocCommand python.sortImports'

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
        exe 'AsyncRun latexmk % && latexmk -c 2>/dev/null'
    else
        exe 'call Error("Error filetype not supported: '.l:filetype.'")'
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

function! HLNext(blinktime)
    set cursorline
    redraw
    exec 'sleep ' . float2nr(a:blinktime) . 'm'
    set nocursorline
    redraw
endfunction

function! VimSupportsYouCompleteMe()
    return empty(matchstr(system('uname -m'), '\varmv\dl')) &&
    \    v:version >= 800 || (v:version >= 704 && has('patch1578'))
endfunction



" Key bindings

let mapleader = ','

nnoremap <silent>   n   n:call HLNext(200)<CR>
nnoremap <silent>   N   N:call HLNext(200)<CR>

" Better window nav
inoremap   <C-h>   <Esc><C-w>h
inoremap   <C-j>   <Esc><C-w>j
inoremap   <C-k>   <Esc><C-w>k
inoremap   <C-l>   <Esc><C-w>l

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

" Buffer nav
noremap <silent>   gl   :bn<CR>
noremap <silent>   gh   :bp<CR>
noremap <silent>   gq   :bd<CR>
noremap <silent>   gx   :w<CR>:bd<CR>

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

" Tab first
noremap <silent>   tH   :tabfirst<CR>

" Tab last
noremap <silent>   tL   :tablast<CR>

" Tab move left
noremap <silent>   Th   :tabm -<CR>

" Tab move right
noremap <silent>   Tl   :tabm +<CR>

" Tab move to beginning
noremap <silent>   TH   :tabm 0<CR>

" Tab move to end
noremap <silent>   TL   :tabm $<CR>

" New window below
noremap <silent>   <Leader>wn   :new<CR>

" New window to the right
noremap <silent>   <Leader>wv   :vnew<CR>

" Open fzf
noremap <silent>   <C-f>   :Files<CR>

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



" Vundle

filetype off
if !empty(glob('$HOME/.vim/bundle/Vundle.vim'))
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'          " Package manager
    Plugin 'ap/vim-css-color'              " Show colors of CSS color codes
    Plugin 'apeschel/vim-syntax-apache'    " Syntax highlighting for apache
    Plugin 'gabrielelana/vim-markdown'     " Better Markdown syntax highlight
    Plugin 'godlygeek/tabular'             " Handles md tables for you
    Plugin 'iamcco/markdown-preview.vim'   " Preview markdown files live
    Plugin 'itchyny/lightline.vim'         " The pretty statusline
    Plugin 'jiangmiao/auto-pairs'          " Manage quotes, parens, etc in pair
    Plugin 'junegunn/fzf.vim'              " Fuzzy file finder
    Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plugin 'justinmk/vim-sneak'            " The missing vim motion
    Plugin 'mhinz/vim-signify'             " Show added/modified/removed lines
    Plugin 'neoclide/coc.nvim', {'branch': 'release'}  " Conquer of Completion
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
    call vundle#end()
endif
filetype plugin indent on



" Plugin Configs

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
