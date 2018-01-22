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

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
