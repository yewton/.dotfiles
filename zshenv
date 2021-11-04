# -*- mode: sh; sh-shell: zsh; -*-
# export ZPROF=1
# メモ: zsh -ixv -c exit 2>&1 | ts -s '%.s' > tmp/zsh.log
[ -n "${ZPROF}" ] && zmodload zsh/zprof && zprof

typeset -U path PATH

if [[ `uname` = "Darwin" ]]; then
    setopt no_global_rcs
    export PATH="/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:$PATH"
    export PATH="/opt/homebrew/opt/texinfo/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

if [[ -f /usr/local/opt/asdf/asdf.sh ]]; then
  . /usr/local/opt/asdf/asdf.sh
fi
if [[ -f /opt/homebrew/opt/asdf/asdf.sh ]]; then
  . /opt/homebrew/opt/asdf/asdf.sh
fi
if [[ -f /home/linuxbrew/.linuxbrew/opt/asdf/asdf.sh ]]; then
  . /home/linuxbrew/.linuxbrew/opt/asdf/asdf.sh
fi
if [[ -f $HOME/.asdf/asdf.sh ]]; then
  . $HOME/.asdf/asdf.sh
fi
if [[ -f $HOME/.nix-profile/etc/profile.d/nix.sh ]]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

if which direnv 2>&1 >/dev/null; then eval "$(direnv hook zsh)"; fi

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
