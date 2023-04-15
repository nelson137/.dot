######################################################################
# Oh My Zsh
######################################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="custom"

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

# Ignore false positive security risks with completions
export ZSH_DISABLE_COMPFIX=true

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$HOME/.dot/zsh-custom"

plugins=(
    colored-man-pages
    extract
    git
    git-prompt
    web-search
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# zsh-syntax-highlighting config
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

source "$ZSH/oh-my-zsh.sh"

######################################################################
# Zsh
######################################################################

# Delete duplicate history items before unique ones
setopt HIST_EXPIRE_DUPS_FIRST

# Don't add commands to history if they have a leading space
setopt HIST_IGNORE_SPACE

# Fix nice error
setopt NO_BG_NICE

# Allow `''` in a single-quoted string to signify one single quote
setopt RC_QUOTES

# Change what characters are considered a word
my-backward-delete-word () {
    local WORDCHARS='&*|'
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

######################################################################
# User configuration
######################################################################

# FZF
source "$HOME/.dot/components/fzf/shell/key-bindings.zsh"
[[ $- == *i* ]] &&
    source "$HOME/.dot/components/fzf/shell/completion.zsh" 2>/dev/null

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
