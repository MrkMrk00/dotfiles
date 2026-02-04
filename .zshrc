if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    exec sway
fi

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward
bindkey -M viins '^y' autosuggest-accept

zvm_after_init_commands+=(			  \
  "bindkey -M viins '^p' history-search-backward" \
  "bindkey -M viins '^n' history-search-forward"  \
)

zinit_async() {
    zinit ice lucid wait'0';
    zinit light $@
}

# cannot be loaded asynchronously
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-autosuggestions

zinit_async Aloxaf/fzf-tab
zinit_async zsh-users/zsh-syntax-highlighting
zinit_async zsh-users/zsh-completions
zinit_async joshskidmore/zsh-fzf-history-search

function -aws-profile() {
    if [[ -z "${AWS_PROFILE}" ]]; then
        return
    fi

    local yellow='%F{214}%'
    echo "%{${yellow}}(${AWS_PROFILE})%f "
}

function -kube-context() {
    if ! type kubectl 2>&1 > /dev/null; then
        return
    fi

    local dark_blue='%F{21}%'
    local current_context=$(kubectl config current-context 2>/dev/null || echo 'default')

    if [[ "${current_context}" == 'default' ]]; then
        return
    fi

    echo "%{${dark_blue}}(${current_context})%f "
}

function use-profile() {
    local profile_name="$1"

    if [[ "${profile_name}" == 'local' || "${profile_name}" == 'default' ]]; then
        unset AWS_PROFILE
        kubectl config use-context default

        return
    fi

    export AWS_PROFILE="apify-${profile_name}"
    kubectl config use-context "apify-${profile_name}" || \
        kubectl config use-context default
}

autoload -Uz compinit && compinit

zinit cdreplay -q

alias gs='git status'
alias ls='ls --color'
alias ll='ls -lah'
alias k='kubectl'

mkcd() {
  mkdir -p "$1" && cd "$1"
}

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt completealiases # autocomplete commands, even if they are aliased
setopt promptsubst     # PS1 substitutions

PS1='$(-aws-profile)$(-kube-context)%1~ %F{green}λ%f '

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

type fzf    2>&1 > /dev/null && eval "$(fzf --zsh)"
type zoxide 2>&1 > /dev/null && eval "$(zoxide init --cmd cd zsh)"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export VISUAL=vim
export EDITOR="$VISUAL"

export GOPATH="$HOME/go"
export GOBIN="${GOPATH}/bin"
export COREPACK_ENABLE_AUTO_PIN=0
export COMPOSER_BIN="${HOME}/.config/composer/vendor/bin"
export GPG_TTY=$(tty)

PATH="${PATH}:${HOME}/bin:${GOBIN}:${COMPOSER_BIN}:${HOME}/.ghcup/bin:${HOME}/opt/nvim/bin"

[[ -f "/usr/share/nvm/init-nvm.sh" ]] && source /usr/share/nvm/init-nvm.sh

