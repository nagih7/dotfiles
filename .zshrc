# ==============================================================================
# === ZSH MODERN SHELL CONFIGURATION (Ubuntu Native) ==========================
# ==============================================================================

# === PATH ENHANCEMENTS ===
typeset -U PATH path  # Remove duplicates from PATH
export PATH="$HOME/.local/bin:$PATH"

# Set up Bat alternative name on Ubuntu (Ubuntu installs it as batcat)
if command -v batcat &> /dev/null; then
    alias bat="batcat"
fi

# === OH-MY-ZSH INTEGRATION ===
export ZSH="$HOME/.oh-my-zsh"

# Theme setup (Mặc định là robbyrussell, bạn có thể đổi thành theme bạn muốn)
ZSH_THEME="robbyrussell"

# Core Oh-My-Zsh Plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    systemd
    ssh-agent
    gpg-agent
    fzf
    z
    web-search
    node
    npm
    python
    rust
    golang
    colored-man-pages
    command-not-found
    history-substring-search
    extract
    copyfile
    copypath
    sudo
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# === HIGH-PERFORMANCE EXTERNAL PLUGINS ===
# Source trực tiếp từ APT packages của Ubuntu để tối ưu tốc độ load shell
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# === HISTORY OPTIMIZATION ===
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

setopt SHARE_HISTORY          # Share history between all zsh sessions
setopt HIST_IGNORE_DUPS       # Ignore duplicate entries
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when trimming history
setopt HIST_FIND_NO_DUPS      # Don't show duplicates in history search
setopt HIST_REDUCE_BLANKS     # Remove unnecessary blanks from history
setopt HIST_VERIFY            # Show command before executing from history
setopt INC_APPEND_HISTORY     # Immediately append to history

# === MODERN ZSH OPTIONS ===
setopt AUTO_CD                # cd to directory by typing name
setopt AUTO_PUSHD             # automatically push directories to stack
setopt PUSHD_IGNORE_DUPS      # ignore duplicate directories in stack
setopt PUSHD_SILENT           # don't print directory stack
setopt CORRECT                # command auto-correction
setopt CORRECT_ALL            # argument auto-correction
setopt GLOB_DOTS              # include dotfiles in globbing
setopt EXTENDED_GLOB          # extended globbing features
setopt NUMERIC_GLOB_SORT      # sort globs numerically

# === COMPLETION ENHANCEMENTS ===
setopt COMPLETE_IN_WORD       # complete from both ends of word
setopt AUTO_MENU              # show completion menu on tab
setopt AUTO_LIST              # automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH       # add slash after directory names
unsetopt FLOW_CONTROL         # disable flow control (Ctrl+S/Ctrl+Q)

zstyle ':completion:*' menu no

# === KEY BINDINGS (Emacs-style) ===
bindkey '^A' beginning-of-line      # Ctrl+A: beginning of line
bindkey '^E' end-of-line            # Ctrl+E: end of line
bindkey '^R' history-incremental-search-backward  # Ctrl+R: reverse search

# Bindkey cho history-substring-search (Tương thích tốt với các loại Terminal Emulator)
bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow

# === ADVANCED SHELL ALIASES ===
# File Operations (Enhanced via eza)
alias ll="eza -la --icons --git --header"
alias la="eza -a --icons"
alias lt="eza -la --icons --git --tree --level=2"
alias lg="eza -la --icons --git --git-ignore"

# Modern CLI Replacements
alias ls="eza --icons --group-directories-first"
alias grep="rg --color=auto --smart-case"
alias find="fd --color=auto"
alias du="dust"
alias df="duf"
alias ps="procs"
alias top="htop"

# Git Workflow
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v"
alias gcm="git commit -m"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gds="git diff --staged"
alias gf="git fetch"
alias gl="git log --oneline --graph --decorate"
alias gp="git push"
alias gpl="git pull"
alias gs="git status --short"
alias gst="git status"
alias gcaa="git add . && git commit --amend --no-edit"

# Tmux Workflow
alias tm="tmux"
alias tma="tmux attach-session -t"
alias tmn="tmux new-session -s"
alias tml="tmux list-sessions"
alias tmk="tmux kill-session -t"
alias tmd="tmux detach"
alias tmcls="rm -rf ~/.tmux/resurrect/*"

# NPM Workflow
alias npm-list-global="npm list -g --depth=0"
alias npm-outdated-global="npm outdated -g"
alias npm-update-global="npm update -g"

# Quick Utilities
alias h="history"
alias hg="history | grep"
alias weather="curl wttr.in"
alias ip="curl ifconfig.me"
alias localip="ip route get 1 | awk '{print \$7}'"
alias ports="netstat -tulanp"

# Directory Operations
alias md="mkdir -pv"
alias rd="rmdir"

# File Viewing and Editing
alias v="nvim"
alias e="$EDITOR"

# Clipboard Operations (X11 / Wayland detection)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    alias copy="wl-copy"
    alias paste="wl-paste"
else
    alias copy="xclip -sel clip"
    alias paste="xclip -sel clip -o"
fi

# System Info
alias sysinfo="neofetch"
alias diskinfo="df -h"
alias meminfo="free -h"
alias cat="bat --paging=never"

# DevOps
alias tf="terraform"

# === FZF INTEGRATION ===
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="
      --height 40% 
      --layout=reverse 
      --border 
      --preview 'bat --color=always --style=numbers --line-range=:500 {}'
      --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
      --color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc
      --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8"
    
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d . --strip-cwd-prefix --hidden --follow --exclude .git'
    fi
    
    # Load native fzf completion and key-bindings on Ubuntu
    if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi
    if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
fi

# === MODERN DIRECTORY NAVIGATION ===
# Auto ls after cd
chpwd() {
    emulate -L zsh
    if command -v eza &> /dev/null; then
        eza --icons --group-directories-first
    else
        ls --color=auto
    fi
}

# === MODERN CLI TOOL PREFERENCES ===
export EZA_COLORS="da=36:di=34:fi=0:ln=35:pi=33:so=32:bd=33:cd=33:or=31:mi=31:ex=32"
eval "$(direnv hook zsh)"
# BEGIN ANSIBLE MANAGED — devbox role
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
# END ANSIBLE MANAGED — devbox role
