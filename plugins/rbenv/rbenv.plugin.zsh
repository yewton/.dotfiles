# https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/rbenv/rbenv.plugin.zsh が
# 主に brew --prefix rbenv の影響で 0.5 秒近くかかってしまうので、決め打ちでやってしまうように改変した。
FOUND_RBENV=0
rbenvdir="$HOME/.rbenv"

# cf. https://github.com/robbyrussell/oh-my-zsh/issues/4998
if [ -d $rbenvdir/shims -a $FOUND_RBENV -eq 0 ] ; then
    FOUND_RBENV=1
    if [[ $RBENV_ROOT = '' ]]; then
        RBENV_ROOT=$rbenvdir
    fi
    export RBENV_ROOT
    export PATH=${rbenvdir}/bin:$PATH
    eval "$(rbenv init --no-rehash - zsh)"

    alias rubies="rbenv versions"
    alias gemsets="rbenv gemset list"

    function current_ruby() {
        echo "$(rbenv version-name)"
    }

    function current_gemset() {
        echo "$(rbenv gemset active 2&>/dev/null | sed -e ":a" -e '$ s/\n/+/gp;N;b a' | head -n1)"
    }

    function gems {
        local rbenv_path=$(rbenv prefix)
        gem list $@ | sed -E \
                          -e "s/\([0-9a-z, \.]+( .+)?\)/$fg[blue]&$reset_color/g" \
                          -e "s|$(echo $rbenv_path)|$fg[magenta]\$rbenv_path$reset_color|g" \
                          -e "s/$current_ruby@global/$fg[yellow]&$reset_color/g" \
                          -e "s/$current_ruby$current_gemset$/$fg[green]&$reset_color/g"
    }

    function _rbenv_prompt_info() {
        if [[ -n $(current_gemset) ]] ; then
            echo "$(current_ruby)@$(current_gemset)"
        else
            echo "$(current_ruby)"
        fi
    }
fi

unset rbenvdir

if [ $FOUND_RBENV -eq 0 ] ; then
  alias rubies='ruby -v'
  function gemsets() { echo 'not supported' }
  function _rbenv_prompt_info() { echo "system: $(ruby -v | cut -f-2 -d ' ')" }
fi

function rbenv_prompt_info() {
    echo "${ZSH_THEME_RVM_PROMPT_PREFIX:=(}$(_rbenv_prompt_info)${ZSH_THEME_RVM_PROMPT_SUFFIX:=)}"
}
