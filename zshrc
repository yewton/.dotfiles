# -*- mode: sh; sh-shell: zsh; -*-
HISTFILE=$HOME/.zhistory
HISTSIZE=4096
SAVEHIST=4096
setopt extended_history
setopt hist_ignore_dups
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

if grep -qs Microsoft /proc/version; then
  export SHELL=$(which zsh)
  export DISPLAY=localhost:0.0
  export TERM=xterm-256color
  unsetopt BG_NICE
fi

umask 0002

export EDITOR=emacsclient
export VISUAL=emacsclient
export LANG=ja_JP.UTF-8

# ls colors
autoload -U colors && colors

# Enable ls colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"

# TODO organise this chaotic logic

if [[ "$DISABLE_LS_COLORS" != "true" ]]; then
  # Find the option for using colors in ls, depending on the version
  if [[ "$OSTYPE" == netbsd* ]]; then
    # On NetBSD, test if "gls" (GNU ls) is installed (this one supports colors);
    # otherwise, leave ls as is, because NetBSD's ls doesn't support -G
    gls --color -d . &>/dev/null && alias ls='gls --color=tty'
  elif [[ "$OSTYPE" == openbsd* ]]; then
    # On OpenBSD, "gls" (ls from GNU coreutils) and "colorls" (ls from base,
    # with color and multibyte support) are available from ports.  "colorls"
    # will be installed on purpose and can't be pulled in by installing
    # coreutils, so prefer it to "gls".
    gls --color -d . &>/dev/null && alias ls='gls --color=tty'
    colorls -G -d . &>/dev/null && alias ls='colorls -G'
  elif [[ "$OSTYPE" == darwin* ]]; then
    # this is a good alias, it works by default just using $LSCOLORS
    ls -G . &>/dev/null && alias ls='ls -G'

    # only use coreutils ls if there is a dircolors customization present ($LS_COLORS or .dircolors file)
    # otherwise, gls will use the default color scheme which is ugly af
    [[ -n "$LS_COLORS" || -f "$HOME/.dircolors" ]] && gls --color -d . &>/dev/null && alias ls='gls --color=tty'
  else
    # For GNU ls, we use the default ls color theme. They can later be overwritten by themes.
    if [[ -z "$LS_COLORS" ]]; then
      (( $+commands[dircolors] )) && eval "$(dircolors -b)"
    fi

    ls --color -d . &>/dev/null && alias ls='ls --color=tty' || { ls -G . &>/dev/null && alias ls='ls -G' }

    # Take advantage of $LS_COLORS for completion as well.
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  fi
fi

setopt auto_cd
setopt multios
setopt prompt_subst

[[ -n "$WINDOW" ]] && SCREEN_NO="%B$WINDOW%b " || SCREEN_NO=""

setopt transient_rprompt
setopt ignore_eof

alias fixcomp="compaudit 2>&1 | grep -v 'There are insecure directories:' | xargs chmod go-w"

alias tmux-pbcopy="tmux showb | pbcopy"

export SPACESHIP_BATTERY_SHOW=false
export SPACESHIP_DIR_TRUNC=0
export SPACESHIP_EXIT_CODE_SHOW=true
export SPACESHIP_NODE_SHOW=false
export SPACESHIP_DIR_TRUNC_REPO=false

if [[ -d ~/.zplug ]]; then
  export ZPLUG_HOME=~/.zplug
else
  export ZPLUG_HOME=/usr/local/opt/zplug
fi
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "b4b4r07/enhancd", use:init.sh
zplug "jreese/zsh-titles"
zplug "supercrabtree/k"
zplug "denysdovhan/spaceship-zsh-theme", as:theme
zplug "lib/completion", from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

bindkey '^[[Z' reverse-menu-complete

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

# https://unix.stackexchange.com/a/159254
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))"'

eval "$(fasd --init auto)"

alias history="history -E 0"
alias l='ls -lah'
alias ll='ls -lh'

unalias rg &>/dev/null || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -f /usr/local/opt/asdf/asdf.sh ]]; then
  . /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
fi
if [[ -f $HOME/.asdf/asdf.sh ]]; then
  . $HOME/.asdf/completions/asdf.bash
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local || true

if [ -n "${ZPROF}" ] && (which zprof > /dev/null); then
  zprof | less
fi
