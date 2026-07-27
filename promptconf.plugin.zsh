# oh-my-zsh compatibility shim.
#
# promptconf is a standalone file - this only exists so it can also be dropped
# into $ZSH_CUSTOM/plugins/promptconf and listed in plugins=(...). The real
# implementation is promptconf.zsh next to this file.
#
# Remember to set ZSH_THEME="" so no oh-my-zsh theme competes for PROMPT.
source "${0:A:h}/promptconf.zsh"
