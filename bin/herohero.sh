#!/bin/bash

WORKDIR=~/workspace/frontend

kitty @ launch --type=tab --tab-title "nvim" --cwd "$WORKDIR" zsh -ilc "nvim .; exec zsh"
kitty @ launch --type=tab --tab-title "dev" --cwd "$WORKDIR" zsh -ilc "pnpm dev; exec zsh"
kitty @ launch --type=window --cwd "$WORKDIR" zsh -il
kitten @ focus-tab --match="title:nvim"
kitty @ close-tab --self

