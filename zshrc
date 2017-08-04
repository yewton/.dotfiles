# -*- mode: sh; sh-shell: zsh; -*-
HISTFILE=$HOME/.zhistory
HISTSIZE=4096
SAVEHIST=4096
setopt extended_history
setopt hist_ignore_dups

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

alias tmux-pbcopy="tmux showb | pbcopy"

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
zplug "b4b4r07/enhancd", use:init.sh
zplug "jreese/zsh-titles"
zplug "supercrabtree/k"
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf, use:"*darwin*amd64*"
zplug "junegunn/fzf", use:shell/key-bindings.zsh

zplug "themes/gallois", from:oh-my-zsh

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

export ENHANCD_FILTER=fzf

export FZF_DEFAULT_OPTS='--height 40% --reverse --border --bind ctrl-v:page-down,alt-v:page-up'

bindkey '^x^d' fzf-cd-widget
bindkey '^x^f' fzf-file-widget

fzf-z-widget() {
    local ret=$(z | sort -rn | cut -c 12- | fzf +s --query "$*")
    if [[ -z "$ret" ]]; then
        zle redisplay
        return 0
    fi
    BUFFER+="cd $ret"
    zle accept-line
}
zle -N fzf-z-widget
bindkey '^x^r' fzf-z-widget

fco() {
    local tags branches target
    tags=$(
        git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    branches=$(
        git branch --all | grep -v HEAD             |
            sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
            sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    target=$(
        (echo "$tags"; echo "$branches") |
            fzf --no-hscroll --ansi +m -d "\t" -n 2) || return
    git checkout $(echo "$target" | awk '{print $2}')
}

eval "$(fasd --init auto)"

alias git=hub
unalias rg

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local || true
