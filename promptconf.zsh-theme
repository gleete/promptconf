# oh-my-zsh theme shim.
#
# Lets promptconf be selected the ordinary oh-my-zsh way. Symlink or copy the
# repo to $ZSH_CUSTOM/themes/promptconf and set ZSH_THEME="promptconf".
# The real implementation is promptconf.zsh next to this file.
#
# oh-my-zsh sources the theme itself, so nothing else competes for PROMPT.
source "${0:A:h}/promptconf.zsh"
