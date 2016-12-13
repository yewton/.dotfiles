# -*- mode: sh; sh-shell: zsh; -*-
HISTFILE=$HOME/.zhistory
HISTSIZE=4096
SAVEHIST=4096

umask 0002

export EDITOR=emacsclient
export VISUAL=emacsclient
export LANG=ja_JP.UTF-8

autoload -U compinit && compinit
autoload -U colors && colors

setopt transient_rprompt
setopt ignore_eof

ls -G . &>/dev/null && alias ls='ls -G'
alias fixcomp="compaudit 2>&1 | grep -v 'There are insecure directories:' | xargs chmod go-w"

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "lib/theme-and-appearance", from:oh-my-zsh
zplug "lib/clipboard", from:oh-my-zsh
zplug "lib/directories", from:oh-my-zsh
zplug "lib/completion", from:oh-my-zsh

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/rails", from:oh-my-zsh
zplug "plugins/rbenv", from:oh-my-zsh
zplug "plugins/pyenv", from:oh-my-zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "jreese/zsh-titles"

zplug "themes/gallois", from:oh-my-zsh

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
