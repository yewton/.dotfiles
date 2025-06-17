# -*- mode: sh; sh-shell: zsh; -*-
# export ZPROF=1
# メモ: zsh -ixv -c exit 2>&1 | ts -s '%.s' > tmp/zsh.log
[ -n "${ZPROF}" ] && zmodload zsh/zprof && zprof

source_iff() {
    local file_path=$1
    if [[ -f $file_path ]]; then
        source $file_path
    fi
}

typeset -U path PATH

if [[ `uname` = "Darwin" ]]; then
    setopt no_global_rcs # Homebrew の PATH を優先したい
    export PATH="/opt/homebrew/bin:$PATH" # Homebrew 自体へ PATH を通す
    if [ -x /usr/libexec/path_helper ]; then
	    eval `/usr/libexec/path_helper -s`
    fi
    if which brew 2>&1 >/dev/null; then eval "$(brew shellenv)"; fi
fi

export PATH="$HOME/bin:$PATH"

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

MISE_EXEC=$HOME/.local/bin/mise
if [[ -f $MISE_EXEC ]]; then
  eval "$($MISE_EXEC activate zsh)"
fi
source_iff $HOME/.nix-profile/etc/profile.d/nix.sh
source_iff $HOME/.cargo/env

export DENO_INSTALL="${HOME}/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

if which direnv 2>&1 >/dev/null; then eval "$(direnv hook zsh)"; fi

export PATH="${HOME}/.local/bin:$PATH"

source_iff $HOME/.zshenv.local
source_iff $HOME/.local/bin/env
