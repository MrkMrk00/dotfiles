#!/usr/bin/env zsh

WORKDIR=~/workspace/frontend
FIREFOX_BIN='/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox'

kitty @ launch --type=tab --tab-title 'nvim' --cwd "$WORKDIR" zsh -ilc 'nvim .; exec zsh'
kitty @ launch --type=tab --tab-title 'dev' --cwd "$WORKDIR" zsh -ilc 'pnpm dev; exec zsh'
kitty @ launch --type=window --cwd "$WORKDIR" zsh -il

nohup bash -c "'$FIREFOX_BIN' --new-tab 'https://local.herohero.co:3000/'" >/dev/null 2>&1 &

kitten @ focus-tab --match='title:nvim'
kitty @ close-tab --self

