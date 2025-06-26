if [[ -f "~/.xinitrc" && "$XDG_SESSION_TYPE" == "tty" && "$TTY" == "/dev/tty1" ]]; then
  startx
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

zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

zinit_async Aloxaf/fzf-tab
zinit_async zsh-users/zsh-syntax-highlighting
zinit_async zsh-users/zsh-completions
zinit_async zsh-users/zsh-autosuggestions
zinit_async joshskidmore/zsh-fzf-history-search

PS1="%1~ > "

autoload -Uz compinit && compinit

zinit cdreplay -q

alias ls='ls --color'
alias ll='ls -lah'
alias vim='nvim'
alias k="kubectl"
alias g="git"

alias gs='git status'
alias gf='git fetch && git pull'
alias gam='git commit --amend --no-edit'

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

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

export VISUAL=nvim
export EDITOR="$VISUAL"

export GOPATH="$HOME/go"
export GOBIN="${GOPATH}/bin"
export COREPACK_ENABLE_AUTO_PIN=0
export COMPOSER_BIN="${HOME}/.config/composer/vendor/bin"

PATH="${PATH}:${HOME}/bin:${GOBIN}:${COMPOSER_BIN}"

# pnpm
export PNPM_HOME="/Users/marek/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#

eval "$(fnm env --use-on-cd --corepack-enabled)"
source "$HOME/.cargo/env"
