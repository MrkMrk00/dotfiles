if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
    exec sway
fi

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
ZINIT_VERSION='5c0c0454deeb9eac95e08ef214b5d7ba6859db14' # v3.14.0

if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" \
        --depth=1 \
        --revision="$ZINIT_VERSION"
fi

source "$ZINIT_HOME/zinit.zsh"

bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward
bindkey -M viins '^y' autosuggest-accept

zvm_after_init_commands+=(                          \
    "bindkey -M viins '^p' history-search-backward" \
    "bindkey -M viins '^n' history-search-forward"  \
)

zinit_async() {
    local package_name="$1"
    local package_version="$2"

    zinit ice                 \
        ver"$package_version" \
        depth'1'              \
        lucid                 \
        wait'0'

    zinit light "$package_name"
}

# cannot be loaded asynchronously
zinit ice depth'1' ver'80f78d9a3cc06843c776f60e4535b20bb857b1d4'; zinit light jeffreytse/zsh-vi-mode
zinit ice depth'1' ver'f8907cf32b1aefc6868c4f0d1fb77286d1a0f9b3'; zinit light zsh-users/zsh-autosuggestions

zinit_async Aloxaf/fzf-tab 'c7fb028ec0bbc1056c51508602dbd61b0f475ac3'
zinit_async zsh-users/zsh-syntax-highlighting '1d85c692615a25fe2293bdd44b34c217d5d2bf04'
zinit_async zsh-users/zsh-completions '67921bc12502c1e7b0f156533fbac2cb51f6943d'
zinit_async joshskidmore/zsh-fzf-history-search '35df458f7d9478fa88c74af762dcd296cdfd485d'

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
type fnm    2>&1 > /dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export VISUAL=vim
export EDITOR="$VISUAL"

export GOPATH="$HOME/go"
export GOBIN="${GOPATH}/bin"
export COREPACK_ENABLE_AUTO_PIN=0
export COMPOSER_BIN="${HOME}/.config/composer/vendor/bin"
export GPG_TTY=$(tty)

PATH="${PATH}:${HOME}/bin:${GOBIN}:${COMPOSER_BIN}:${HOME}/.ghcup/bin:${HOME}/opt/nvim/bin:${HOME}/opt/lima/bin"

