######################################################################
# Oh My Zsh
######################################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# ZSH_THEME="custom"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Ignore false positive security risks with completions
# export ZSH_DISABLE_COMPFIX=true

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# The history file
HISTFILE="$HOME/.zsh_history"

# The number of lines of history to keep.
# If `HIST_EXPIRE_DUPS_FIRST` is enabled then `HISTSIZE - SAVEHIST` duplicates
# are buffered before being deleted.
HISTSIZE=11000
SAVEHIST=10000

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$HOME/.dot/zsh-custom"

plugins=(
    colored-man-pages
    zsh-autosuggestions
)

[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

######################################################################
# Zsh
######################################################################

# Always jump to the end if a completion is made
setopt ALWAYS_TO_END

# Fix nice error
setopt NO_BG_NICE

# Disable prompt to fix typos in commands
setopt NO_CORRECT

# Delete duplicate history items before unique ones
setopt HIST_EXPIRE_DUPS_FIRST

# Don't add commands to history if they have a leading space
setopt HIST_IGNORE_SPACE

# Remove superfluous blanks in commands before adding to history
setopt HIST_REDUCE_BLANKS

# Add commands to history when they're run instead of at shell exit
setopt INC_APPEND_HISTORY

# Wait for commands to finish to add to history for accurate command duration reporting
setopt INC_APPEND_HISTORY_TIME

# Allow `''` in a single-quoted string to signify one single quote
setopt RC_QUOTES

# Vim mode
bindkey -v

# See this gist for a list of commands:
# https://gist.github.com/ssebastianj/dd4a42da5eee3304751712dc8aa1dc62
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line

# Change what characters are considered a word
my-backward-delete-word () {
    local WORDCHARS='&*|'
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;'
ZLE_SPACE_SUFFIX_CHARS=$'&|'

######################################################################
# User configuration
######################################################################

# Starship
if (( $+commands[starship] )); then
    if [[ -z $NO_STARSHIP ]]; then
        export SPACESHIP_PROMPT_ADD_NEWLINE=false
        eval "$(starship init zsh)"
    fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Homebrew
alias axbrew='arch -x86_64 /usr/local/homebrew/bin/brew'

# FZF
source "$HOME/.dot/components/fzf/shell/key-bindings.zsh"
source "$HOME/.dot/components/fzf/shell/completion.zsh"

# awscli completions
[[ -d /opt/aws-cli ]] && source /opt/aws-cli/bin/aws_zsh_completer.sh

# Create vim undodir if it doesn't exist
[[ ! -d ~/.vim/undodir ]] && mkdir -p ~/.vim/undodir

# User config files
for f in .aliases .functions; do
    f="$HOME/.dot/files/$f"
    [[ -f "$f" ]] && source "$f"
done
unset f

true
