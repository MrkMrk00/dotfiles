if [[ -f "~/.xinitrc" && "$XDG_SESSION_TYPE" == "tty" && "$TTY" == "/dev/tty1" ]]; then
  startx
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward
bindkey -M viins '^y' autosuggest-accept

zvm_after_init_commands+=(			  \
  "bindkey -M viins '^p' history-search-backward" \
  "bindkey -M viins '^n' history-search-forward"  \
)

zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -Uz compinit && compinit

zinit cdreplay -q

alias ls='ls --color'
alias ll='ls -lah --group-directories-first'
alias vim='nvim'
alias k="kubectl"

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

mkcd() {
  mkdir -p "$1" && cd "$1"
}

export VISUAL=nvim
export EDITOR="$VISUAL"

export GOPATH=/home/marek/go
export GOBIN="${GOPATH}/bin"


mount_drives() {
  if [[ "$1" == "-u" ]]; then
    systemctl --user stop rclone@onedrive && echo "unmounted onedrive"
    systemctl --user stop rclone@google_drive && echo "unmouned google_drive"

    return 0
  fi

  systemctl --user start rclone@onedrive && echo "mounted onedrive"
  systemctl --user start rclone@google_drive && echo "mounted google_drive"
}

PATH="${PATH}:/home/marek/bin:${GOBIN}"
