# clone a plugin, identify its init file, source it, and add it to your fpath
function plugin-load {
  local repo plugdir initfile
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      local -a initfiles=($plugdir/*.plugin.{z,}sh(N) $plugdir/*.{z,}sh{-theme,}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf "${initfiles[1]}" "$initfile"
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# OMZ expects a list named 'plugins' so we can't use that variable name for repos,
# it can only contain the names of actual OMZ plugins
plugins=(
  git
  copydir
  extract
  magic-enter
)

# since we're using OMZ, we can even use one of its themes!
ZSH_THEME=avit

# NOW, here's the trick - let's use the name 'repos' for our plugin-load function instead of 'plugins'.
# that will let OMZ exist with our 3rd party plugins
repos=(
  ohmyzsh/ohmyzsh
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zdharma-continuum/fast-syntax-highlighting
)
plugin-load $repos
