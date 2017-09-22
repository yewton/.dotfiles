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

# cf. https://carlosbecker.com/posts/speeding-up-zsh/
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
    compinit
else
    compinit -C
fi

setopt transient_rprompt
setopt ignore_eof

ls -G . &>/dev/null && alias ls='ls -G'
alias fixcomp="compaudit 2>&1 | grep -v 'There are insecure directories:' | xargs chmod go-w"

alias tmux-pbcopy="tmux showb | pbcopy"

export ZGEN_RESET_ON_CHANGE=($(readlink ~/.zshrc))
[[ -f ~/.zshrc.local ]] && export ZGEN_RESET_ON_CHANGE=($ZGEN_RESET_ON_CHANGE ~/.zshrc.local)

[[ -f ~/.zgen/zgen.zsh ]] || git clone https://github.com/tarjoilija/zgen.git ~/.zgen
source ~/.zgen/zgen.zsh

# if the init scipt doesn't exist
if ! zgen saved; then
  # specify plugins here
  zgen oh-my-zsh

  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/npm
  zgen oh-my-zsh plugins/encode64
  zgen oh-my-zsh plugins/colorize
  zgen oh-my-zsh plugins/github
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/ruby
  zgen oh-my-zsh plugins/rails
  zgen oh-my-zsh plugins/bundler
  zgen oh-my-zsh plugins/heroku
  zgen oh-my-zsh plugins/pip
  # cf. https://github.com/robbyrussell/oh-my-zsh/pull/6165
  zgen load cyphus/oh-my-zsh plugins/pyenv pyenv-plugin-refactor

  # 以下は遅くなるので読み込まない
  # zgen oh-my-zsh plugins/rbenv
  # 改造版を読み込む
  zgen load ~/.dotfiles/plugins/rbenv
  # zgen oh-my-zsh plugins/command-not-found

  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-completions src
  zgen load zsh-users/zsh-autosuggestions
  zgen load b4b4r07/enhancd
  zgen load jreese/zsh-titles
  zgen load supercrabtree/k

  zgen oh-my-zsh themes/gallois

  # generate the init script from plugins above
  zgen save
fi

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

if [[ -v ZPROF ]] && (which zprof > /dev/null) ;then
  zprof | less
fi
