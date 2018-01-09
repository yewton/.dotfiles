# -*- mode: sh; sh-shell: zsh; -*-
# export ZPROF=1
# メモ: zsh -ixv -c exit 2>&1 | ts -s '%.s' > tmp/zsh.log
[[ -v ZPROF ]] && zmodload zsh/zprof && zprof

typeset -U path PATH

if [[ `uname` = "Darwin" ]]; then
    setopt no_global_rcs
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

if which rbenv 2>&1 >/dev/null; then eval "$(rbenv init -)"; fi
if which pyenv 2>&1 >/dev/null; then eval "$(pyenv init -)"; fi
# cf. https://github.com/yyuu/pyenv/issues/106#issuecomment-94921352
if which pyenv 2>&1 >/dev/null; then alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"; fi
if which direnv 2>&1 >/dev/null; then eval "$(direnv hook zsh)"; fi

[[ -s "/Users/yewton/.gvm/scripts/gvm" ]] && source "/Users/yewton/.gvm/scripts/gvm"

# cf. https://dance.computer.dance/posts/2015/02/making-chruby-and-binstubs-play-nice.html
# Remove the need for bundle exec ... or ./bin/...
# by adding ./bin to path if the current project is trusted

function set_local_bin_path() {
  # Replace any existing local bin paths with our new one
  export PATH="${1:-""}`echo "$PATH"|sed -e 's,[^:]*\.git/[^:]*bin:,,g'`"
}

function add_trusted_local_bin_to_path() {
  if [[ -d "$PWD/.git/safe" ]]; then
    # We're in a trusted project directory so update our local bin path
    set_local_bin_path "$PWD/.git/safe/../../bin:"
  fi
}

# Make sure add_trusted_local_bin_to_path runs after chruby so we
# prepend the default chruby gem paths
if [[ -n "$ZSH_VERSION" ]]; then
  if [[ ! "$preexec_functions" == *add_trusted_local_bin_to_path* ]]; then
    preexec_functions+=("add_trusted_local_bin_to_path")
  fi
fi

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
