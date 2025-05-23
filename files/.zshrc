######################################################################
# Oh My Zsh
######################################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# ZSH_THEME="custom"

ZSH_COMPDUMP="$ZSH/cache/zcompdump-$HOST"

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

# Don't import commands added to history file
setopt NO_SHARE_HISTORY

# Delete duplicate history items before unique ones
setopt HIST_EXPIRE_DUPS_FIRST

# Don't add commands to history if they have a leading space
setopt HIST_IGNORE_SPACE

# Remove superfluous blanks in commands before adding to history
setopt HIST_REDUCE_BLANKS

# Allow `''` in a single-quoted string to signify one single quote
setopt RC_QUOTES

bindkey -e
bindkey '^[' vi-cmd-mode

# Change what characters are considered a word
export WORDCHARS='&|'

ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;'
ZLE_SPACE_SUFFIX_CHARS=$'&|'

autoload -U promptinit
promptinit
prompt adam1

######################################################################
# User configuration
######################################################################

#region FZF
if command -v fzf &>/dev/null; then

eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude=.cache --exclude=.npm --exclude=.gem --exclude=.vim/undodir"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_G_COMMAND="git status --porcelain=v1 --untracked-files=all | awk '{print \$NF}'"
fzf-git-file-widget() {
    LBUFFER="${LBUFFER}$(FZF_CTRL_T_COMMAND="$FZF_CTRL_G_COMMAND" __fzf_select)"
    local ret=$?
    zle reset-prompt
    return $ret
}
zle     -N            fzf-git-file-widget
bindkey -M emacs '^G' fzf-git-file-widget
bindkey -M vicmd '^G' fzf-git-file-widget
bindkey -M viins '^G' fzf-git-file-widget

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#switching-between-ripgrep-mode-and-fzf-mode
fzf-rg-file-widget() {
    local rg_prefix="rg --trim --no-heading --line-number --color=always --smart-case"
    local fzf_base_opts="--disabled --ansi --delimiter=:"
    local fzf_mode_opts="\
        --bind='start:reload($rg_prefix {q})+unbind(ctrl-r)' \
        --bind='change:reload:sleep 0.1; $rg_prefix {q} || true' --prompt='rg> ' \
        --bind='ctrl-f:unbind(change,ctrl-f)+change-prompt(fzf> )+enable-search+transform-query(echo {q} >/tmp/fzf-query-r; cat /tmp/fzf-query-f)+rebind(ctrl-r)' \
        --bind='ctrl-r:unbind(ctrl-r)+change-prompt(rg> )+disable-search+reload($rg_prefix {q} || true)+transform-query(echo {q} >/tmp/fzf-query-f; cat /tmp/fzf-query-r)+rebind(change,ctrl-f)'"
    local fzf_output_opts="--bind='enter:become(printf \"%s\n\" {+} | cut -d: -f1)'"
    local fzf_preview_opts="--preview='bat --color=always {1} --highlight-line {2}' --preview-window='up,60%,border-bottom,+{2}+3/3,~3'"
    local fzf_opts="$fzf_base_opts $fzf_mode_opts $fzf_output_opts $fzf_preview_opts"
    LBUFFER="${LBUFFER}$(FZF_CTRL_T_COMMAND=":" FZF_DEFAULT_OPTS="$fzf_opts" __fzf_select)"
    local ret=$?
    zle reset-prompt
    return $ret
}
zle     -N            fzf-rg-file-widget
bindkey -M emacs '^F' fzf-rg-file-widget
bindkey -M vicmd '^F' fzf-rg-file-widget
bindkey -M viins '^F' fzf-rg-file-widget

fi
#endregion FZF

# Homebrew
# Must be in zshrc for macOS.
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
if (( $+commands[brew] )) && [[ $(arch) == arm64 ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

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
