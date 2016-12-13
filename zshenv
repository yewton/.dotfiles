# -*- mode: sh; sh-shell: zsh; -*-
if which rbenv 2>&1 >/dev/null; then eval "$(rbenv init -)"; fi

if which pyenv 2>&1 >/dev/null; then eval "$(pyenv init -)"; fi
# cf. https://github.com/yyuu/pyenv/issues/106#issuecomment-94921352
if which pyenv 2>&1 >/dev/null; then alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"; fi
if which direnv 2>&1 >/dev/null; then eval "$(direnv hook zsh)"; fi

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
