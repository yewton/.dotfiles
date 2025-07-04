# -*- mode: sh; sh-shell: zsh; -*-
HISTFILE=$HOME/.zhistory
HISTSIZE=4096
SAVEHIST=4096
setopt extended_history
setopt append_history
setopt share_history
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
export SUDO_EDITOR=$(which emacsclient)
export LANG=ja_JP.UTF-8

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

ZNAP_DIR=$HOME/.znap
if [[ ! -f $ZNAP_DIR/zsh-snap/znap.zsh ]]; then
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $ZNAP_DIR/zsh-snap
fi

zstyle ':znap:*' repos-dir $ZNAP_DIR
source $ZNAP_DIR/zsh-snap/znap.zsh

znap prompt denysdovhan/spaceship-prompt

znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-autosuggestions
znap source jreese/zsh-titles
znap source zpm-zsh/ls
znap source zshzoo/cd-ls
znap source ohmyzsh/ohmyzsh lib/{key-bindings,completion}

znap clone zsh-users/zsh-completions
fpath=( ~[zsh-users/zsh-completions]/src $fpath ) 

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

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# fdr - cd to selected parent directory
fdr() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
  cd "$DIR"
}

# cdf - cd into the directory of the selected file
cdf() {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# https://unix.stackexchange.com/a/159254
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))"'

alias history="history -E 0"
alias l='ls -lah'
alias ll='ls -lh'

unalias rg &>/dev/null || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local || true

if [ -n "${ZPROF}" ] && (which zprof > /dev/null); then
  zprof | less
fi

if [[ -f /usr/local/bin/terraform ]]; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /usr/local/bin/terraform terraform
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then . $HOME/google-cloud-sdk/path.zsh.inc; fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then . $HOME/google-cloud-sdk/completion.zsh.inc; fi

if (command -v aws-vault > /dev/null); then
  eval "$(aws-vault --completion-script-zsh)"
fi

if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi

vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

vterm_prompt_end() {
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

# https://github.com/doomemacs/doomemacs/issues/2578#issuecomment-593797300
if [[ "$TERM" == "dumb" ]]; then
  unset zle_bracketed_paste
  unset zle
  PS1='$ '
  return
fi

if (command -v zoxide > /dev/null); then
  eval "$(zoxide init zsh --cmd cd)"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
