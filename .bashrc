case $- in
    *i*) ;;
      *) return ;;
esac

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && shopt -q login_shell; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
    export MOZ_ENABLE_WAYLAND=1

    logger -t sway <<< "starting sway at $(date -u +'%Y-%m-%d %H:%M')"
    exec dbus-run-session sway 2>&1 | logger -t sway
fi

HISTSIZE=100000
HISTFILESIZE=100000
HISTFILE="$HOME/.bash_history"
# ignoreboth = skip lines starting with a space and duplicates of the previous
# line; erasedups drops older copies of a repeated command.
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
HISTIGNORE='ls:ll:gs:cd:clear:exit'

shopt -s histappend
shopt -s cmdhist

shopt -s globstar
shopt -s no_empty_cmd_completion

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

type kubectl > /dev/null 2>&1 && source <(kubectl completion bash)
complete -o default -F __start_kubectl k 2>/dev/null


_prompt_color() {
    printf '\001\033[%sm\002%s\001\033[0m\002' "$1" "$2"
}

_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        return
    fi

    _prompt_color '38;5;214' "($AWS_PROFILE) "
}

_kube_context() {
    if ! type kubectl > /dev/null 2>&1; then
        return
    fi

    local current_context
    current_context=$(kubectl config current-context 2>/dev/null || echo 'default')

    if [ "$current_context" = 'default' ]; then
        return
    fi

    _prompt_color '38;5;21' "($current_context) "
}

_ssh_hostname() {
    if [ -n "$SSH_TTY" ]; then
        echo "$USER@$(hostname) "
    fi
}

PS1='$(_ssh_hostname)$(_aws_profile)$(_kube_context)\W \[\033[32m\]λ\[\033[0m\] '

use-profile() {
    local profile_name="$1"

    if [ "$profile_name" = 'local' ] || [ "$profile_name" = 'default' ]; then
        unset AWS_PROFILE
        kubectl config use-context default

        return
    fi

    export AWS_PROFILE="apify-${profile_name}"
    kubectl config use-context "apify-${profile_name}" || \
        kubectl config use-context default
}

alias gs='git status'
alias ls='ls --color'
alias ll='ls -lah'
alias k='kubectl'
alias grep='grep --color=auto'

alias sudo='sudo '
alias watch='watch '

export XDG_DATA_DIRS="/var/lib/flatpak/exports/bin:$XDG_DATA_DIRS"
[ -z "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export VISUAL=vim
export EDITOR="$VISUAL"

export GOPATH="$HOME/go"
export GOBIN="${GOPATH}/bin"
export COREPACK_ENABLE_AUTO_PIN=0
export COMPOSER_BIN="${HOME}/.config/composer/vendor/bin"

export GPG_TTY=$(tty)
if [ -n "$SSH_TTY" ]; then
    export GPG_AGENT_INFO="/run/user/$(id -u)/gnupg/S.gpg-agent:0:1"
fi

export PATH="${PATH}:${HOME}/.local/bin:${GOBIN}:${COMPOSER_BIN}:${HOME}/.ghcup/bin:${HOME}/opt/lima/bin:${HOME}/.cargo/bin:/usr/sbin:/sbin:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin"

type fzf    > /dev/null 2>&1 && eval "$(fzf --bash)"
type zoxide > /dev/null 2>&1 && eval "$(zoxide init --cmd cd bash)"
type fnm    > /dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell bash)"

export FZF_CTRL_R_OPTS="--reverse --height 60% --preview 'echo {2..}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_CTRL_T_OPTS="--reverse --height 60% --preview 'head -100 {}'"
export FZF_ALT_C_OPTS="--reverse --height 60% --preview 'ls --color {}'"
