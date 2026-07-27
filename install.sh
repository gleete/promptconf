#!/bin/sh
# promptconf installer
#
#   curl -fsSL https://raw.githubusercontent.com/gleete/promptconf/main/install.sh | zsh
#
# Clones (or updates) promptconf and adds one line to your .zshrc. Safe to run
# again - it updates in place and will not add the line twice.
#
# Override with environment variables:
#   PROMPTCONF_HOME=~/somewhere   where to install
#   PROMPTCONF_NO_MODIFY_RC=1     install only, leave .zshrc alone
set -eu

REPO=${PROMPTCONF_REPO:-https://github.com/gleete/promptconf}
DEST=${PROMPTCONF_HOME:-$HOME/.promptconf}
ZSHRC=${ZDOTDIR:-$HOME}/.zshrc

say()  { printf '  %s\n' "$*"; }
fail() { printf '\n  error: %s\n\n' "$*" >&2; exit 1; }

printf '\n  promptconf\n\n'

# --- fetch -------------------------------------------------------------------
if [ -d "$DEST/.git" ]; then
  say "updating $DEST"
  git -C "$DEST" pull --ff-only --quiet || fail "could not update $DEST"
elif [ -e "$DEST" ]; then
  fail "$DEST already exists and is not a git checkout - move it, or set PROMPTCONF_HOME"
elif command -v git >/dev/null 2>&1; then
  say "cloning into $DEST"
  git clone --quiet --depth 1 "$REPO" "$DEST" || fail "could not clone $REPO"
else
  # No git: the tool is one file, so fetching just that file is enough. It
  # cannot self-update afterwards, which is why git is preferred.
  say "git not found - downloading promptconf.zsh into $DEST"
  mkdir -p "$DEST"
  curl -fsSL "${REPO}/raw/main/promptconf.zsh" -o "$DEST/promptconf.zsh" \
    || fail "could not download promptconf.zsh"
fi

[ -r "$DEST/promptconf.zsh" ] || fail "$DEST/promptconf.zsh is missing"

# --- wire it in --------------------------------------------------------------
# ~ rather than the expanded path, so the line survives being copied between
# machines - but only when it really is under $HOME.
case "$DEST" in
  "$HOME"/*) SRC="~${DEST#"$HOME"}/promptconf.zsh" ;;
  *)         SRC="$DEST/promptconf.zsh" ;;
esac
LINE="source $SRC"

if [ "${PROMPTCONF_NO_MODIFY_RC:-0}" = "1" ]; then
  say "leaving $ZSHRC alone - add this yourself:"
  say ""
  say "    $LINE"
elif [ -e "$ZSHRC" ] && grep -q 'promptconf\.zsh' "$ZSHRC" 2>/dev/null; then
  say "$ZSHRC already sources promptconf"
else
  printf '\n# promptconf - https://github.com/gleete/promptconf\n%s\n' "$LINE" >> "$ZSHRC"
  say "added to $ZSHRC:  $LINE"
fi

# --- things that will bite otherwise -----------------------------------------
if [ -e "$ZSHRC" ] && grep -Eq '^[[:space:]]*ZSH_THEME=["'"'"']?[^"'"'"'[:space:]]' "$ZSHRC"; then
  printf '\n'
  say "note: $ZSHRC sets ZSH_THEME, which will compete for PROMPT."
  say "      set ZSH_THEME=\"\" and make sure promptconf is sourced after oh-my-zsh.sh."
fi

printf '\n  done. open a new shell, or:\n\n'
printf '      source %s\n' "$ZSHRC"
printf '      promptconf wizard\n\n'
printf '  needs a Powerline-patched font for the separator and branch glyphs.\n'
printf '  run "promptconf doctor" if anything looks wrong.\n\n'
