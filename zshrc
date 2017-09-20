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

source $(brew --prefix antigen)/share/antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
  git
  npm
  encode64
  colorize
  github
  osx
  ruby
  rails
  rbenv
  bundler
  pyenv
  heroku
  pip
  command-not-found
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  b4b4r07/enhancd
  jreese/zsh-titles
  supercrabtree/k
  rupa/z
  andrewferrier/fzf-z
EOBUNDLES

antigen theme gallois

antigen apply

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

urlencode() {
    echo $1 | perl -nle 's/([^\w ])/"%".unpack("H2",$1)/eg; s/ /\+/g; print'
}

urldecode() {
    echo $1 | perl -MURI::Escape -nle 'print uri_unescape($_)'
}

eval "$(fasd --init auto)"

alias git=hub
alias history="history -E 0"
unalias rg &>/dev/null || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local || true
