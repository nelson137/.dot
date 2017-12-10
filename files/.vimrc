" General
    set whichwrap+=<,>,h,l,[,]  " EOL wrapping
    set backspace=indent,eol,start
    set autoread  " auto read when changes are made to file from outside
    set noswapfile



" Graphics
    syntax on
    colorscheme default
    set number
    set laststatus=2  " status bar always visible
    set statusline=%t  " file name in status bar
    set ruler  " bar with cursor positions



" Indentation
    set expandtab      " tabs to spaces
    set tabstop=4      " tab width = 4
    set shiftwidth=4   " indentation size = 4
    set smartindent    " auto-indent
    set autoindent     " fix indentation
    set softtabstop=4  " backspace deletes 4 spaces



" Key bindings
    let mapleader="."
    
    " .n toggles line numbers
    nnoremap <leader>n :set number!<CR>
    
    " H goes to beginning of line
    nnoremap H 0

    " J goes to bottom of file
    nnoremap J G

    " K goes to top of file
    nnoremap K gg

    " L goes to end of line
    nnoremap L $



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
