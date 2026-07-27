################################################################################
# promptconf — a configurable two-line powerline prompt for zsh.
#
#   promptconf                     what you can do
#   promptconf schemes             preview every scheme, rendered
#   promptconf scheme ember        switch colors, remembered
#   promptconf layout              which segments are on, in order
#   promptconf add venv            turn a segment on
#   promptconf set dir_bg 25       change one color live
#   promptconf save mine           keep the current colors as a scheme
#
# Self-contained: needs zsh and a Powerline-patched font, nothing else.
################################################################################
setopt prompt_subst

typeset -g  PROMPTCONF_DIR=${PROMPTCONF_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/promptconf}
typeset -gA PROMPTCONF          # active colors, read by the segments
typeset -ga PROMPTCONF_SEGMENTS # what renders, in order
typeset -ga PROMPTCONF_AVAILABLE
typeset -ga PROMPTCONF_SCHEMES
typeset -g  PROMPTCONF_SCHEME

# --- Palettes -----------------------------------------------------------------
# Solarized by ANSI slot rather than absolute color, so the terminal's own
# scheme supplies the hues. Comments show what solarizedDark resolves to.
typeset -gA PROMPTCONF_SOL=(
  base03  8     # #001e27   darkest, the terminal background
  base02  0     # #002831   segment background
  base01  10    # #475b62
  base00  11    # #536870
  base0   12    # #708284   body text
  base1   14    # #819090
  base2   7     # #eae3cb
  base3   15    # #fcf4dc   brightest cream
  yellow  3     # #a57706   amber
  orange  9     # #bd3613
  red     1     # #d11c24
  magenta 5     # #c61c6f
  violet  13    # #5956ba
  blue    4     # #2176c7   agnoster's own directory blue
  cyan    6     # #259286   teal
  green   2     # #738a05   olive
)

# Fixed 256-cube tints for tones solarized's sixteen slots don't reach. These
# stay put when the terminal scheme changes - that is the point of them.
typeset -gA PROMPTCONF_TINT=(
  slate   24    # #005f87   steel blue
  steel   67    # #5f87af
  sky     74    # #5fafd7
  azure   32    # #0087d7
  vivid   33    # #0087ff
  deep    25    # #005faf
  teal    30    # #008787
  ice     116   # #87d7d7
  gold    214   # #ffaf00   bright, for use on a dark background only
  mustard 179   # #d7af5f
  wheat   180   # #d7af87
  bronze  137   # #af875f
  ember   130   # #af5f00
  rust    166   # #d75f00
  moss    64    # #5f8700
  ash     238   # #444444
  smoke   244   # #808080
  fog     250   # #bcbcbc
  ink     232   # #080808
)

# --- Schemes ------------------------------------------------------------------
# A scheme fills PROMPTCONF. S and T are local shorthand for the palettes, so
# adding a scheme means copying a block, renaming it, and listing it below.
PROMPTCONF_SCHEMES=(agnoster tonal ember ice mono vivid light)

# The default. Directory and git segments are agnoster's own pairings -
# AGNOSTER_DIR_BG=blue over CURRENT_FG=black. The date sits on the dark
# background rather than a tint of its own, which leaves solarized's amber
# room to breathe at ~3.9:1 without the glare a brighter gold would bring.
promptconf_scheme_agnoster() {  # the stock theme's colors, faithfully
  local -A S=(${(kv)PROMPTCONF_SOL})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg ''
    ctx_bg    $S[base02]  ctx_fg    ''
    time_bg   $S[base02]  time_fg   $S[yellow]
    dir_bg    $S[blue]    dir_fg    $S[base02]
    clean_bg  $S[green]   clean_fg  $S[base02]
    dirty_bg  $S[yellow]  dirty_fg  $S[base02]
    err $S[red]  root $S[yellow]  job $S[cyan]  mark $S[blue]
  )
}

promptconf_scheme_tonal() {     # one dark run, color carried by the text
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg $S[base1]
    ctx_bg    $S[base02]  ctx_fg    $S[cyan]
    time_bg   $S[base02]  time_fg   $T[gold]
    dir_bg    $S[base02]  dir_fg    $T[sky]
    clean_bg  $S[base02]  clean_fg  $S[green]
    dirty_bg  $S[base02]  dirty_fg  $S[yellow]
    err $S[red]  root $S[yellow]  job $S[cyan]  mark $T[sky]
  )
}

promptconf_scheme_ember() {     # warm: bronze through burnt orange
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg $T[wheat]
    ctx_bg    $S[base02]  ctx_fg    $T[wheat]
    time_bg   $T[bronze]  time_fg   $S[base03]
    dir_bg    $T[ember]   dir_fg    $S[base3]
    clean_bg  $T[moss]    clean_fg  $S[base3]
    dirty_bg  $T[rust]    dirty_fg  $S[base3]
    err $S[red]  root $T[gold]  job $T[wheat]  mark $T[rust]
  )
}

promptconf_scheme_ice() {       # cool: deep teal into pale cyan
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg $T[ice]
    ctx_bg    $S[base02]  ctx_fg    $T[ice]
    time_bg   $T[teal]    time_fg   $S[base3]
    dir_bg    $T[sky]     dir_fg    $S[base03]
    clean_bg  $T[moss]    clean_fg  $S[base03]
    dirty_bg  $T[gold]    dirty_fg  $S[base03]
    err $S[red]  root $T[gold]  job $T[ice]  mark $T[ice]
  )
}

promptconf_scheme_mono() {      # no hue at all, pure grayscale
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $T[ash]     status_fg $T[fog]
    ctx_bg    $T[ash]     ctx_fg    $T[fog]
    time_bg   $T[smoke]   time_fg   $T[ink]
    dir_bg    $T[fog]     dir_fg    $T[ink]
    clean_bg  $T[smoke]   clean_fg  $T[ink]
    dirty_bg  $T[ash]     dirty_fg  $T[fog]
    err $S[red]  root $T[fog]  job $T[fog]  mark $T[fog]
  )
}

promptconf_scheme_vivid() {     # maximum saturation, the loud one
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg $S[base3]
    ctx_bg    $S[base02]  ctx_fg    $T[ice]
    time_bg   $T[deep]    time_fg   $T[gold]
    dir_bg    $T[vivid]   dir_fg    $S[base3]
    clean_bg  $S[green]   clean_fg  $S[base3]
    dirty_bg  $T[rust]    dirty_fg  $S[base3]
    err $S[red]  root $T[gold]  job $T[ice]  mark $T[vivid]
  )
}

promptconf_scheme_light() {     # for a solarized *light* terminal background
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base2]   status_fg $S[base01]
    ctx_bg    $S[base2]   ctx_fg    $S[base01]
    time_bg   $T[sky]     time_fg   $S[base03]
    dir_bg    $S[blue]    dir_fg    $S[base3]
    clean_bg  $S[green]   clean_fg  $S[base3]
    dirty_bg  $S[yellow]  dirty_fg  $S[base03]
    err $S[red]  root $S[orange]  job $S[cyan]  mark $S[blue]
  )
}

# --- Engine -------------------------------------------------------------------
# Re-sourcing should pick up new defaults without clobbering anything you set
# yourself. A plain ${VAR-default} cannot tell "the user chose this" from "we
# set it last time we were sourced", so upgrading mid-session would keep
# serving the old default. Track what we defaulted so those can be refreshed.
typeset -ga _promptconf_defaulted
_promptconf_default() {   # <var> <value>
  if [[ ! -v $1 ]] || (( ${_promptconf_defaulted[(I)$1]} )); then
    typeset -g $1="$2"
    (( ${_promptconf_defaulted[(I)$1]} )) || _promptconf_defaulted+=($1)
  fi
}

# Two lines keeps a long path from crowding what you type; one line is more
# compact. Either way the marker is the last thing before the cursor.
_promptconf_default PROMPTCONF_LINES 2
_promptconf_default PROMPTCONF_MARKER '❯'

# \u escapes are converted using the current character set, so under LC_ALL=C
# - common on servers, in containers and in CI - zsh fails to parse them at all
# and nothing below this point loads. Force a UTF-8 ctype just for these two.
() {
  local LC_ALL='' LC_CTYPE='en_US.UTF-8'
  _promptconf_default PROMPTCONF_SEPARATOR $'\ue0b0'
# Drawn between segments that share a background. It also keeps columns
# aligned: without it those boundaries are a one-character gutter while
# colour-change boundaries are three, so segments start at different
# columns from one scheme to the next. Set it to ' ' to keep the
# alignment without a glyph, or '' for a plain single space.
  _promptconf_default PROMPTCONF_SEPARATOR_THIN $'\ue0b1'
}
typeset -g _promptconf_bg='NONE'

# What the git segment appends after the branch. The segment colour already
# says clean or dirty, so the file-state glyphs would only repeat it - only
# divergence, which colour cannot express, is on by default.
# Any of: staged unstaged untracked conflict stashed ahead behind
(( ${+PROMPTCONF_GIT_MARKS} )) || typeset -ga PROMPTCONF_GIT_MARKS=(ahead behind)

# Only the first three need a Powerline-patched font; the rest are ordinary
# Unicode and render in any reasonable font. Override any of them.
typeset -gA PROMPTCONF_GLYPH=(
  branch    $''   #   powerline
  detached  '➦'
  tag       '◈'
  staged    '✚'
  unstaged  '●'
  untracked '…'
  conflict  '✖'
  stashed   '✭'
  ahead     '⇡'
  behind    '⇣'
)

promptconf_segment() {  # <bg> <fg> <content>
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $_promptconf_bg == 'NONE' ]]; then
    echo -n "%{$bg%}%{$fg%} "
  elif [[ $1 != $_promptconf_bg ]]; then
    echo -n " %{$bg%F{$_promptconf_bg}%}$PROMPTCONF_SEPARATOR%{$fg%} "
  elif [[ -n $PROMPTCONF_SEPARATOR_THIN ]]; then
    # Same background: a hairline divides them without a colour break.
    echo -n " %{%F{${PROMPTCONF[thin]:-$PROMPTCONF_SOL[base01]}}%}$PROMPTCONF_SEPARATOR_THIN%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  _promptconf_bg=$1
  [[ -n $3 ]] && echo -n $3
}

promptconf_end() {
  if [[ -n $_promptconf_bg ]]; then
    echo -n " %{%k%F{$_promptconf_bg}%}$PROMPTCONF_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  _promptconf_bg=''
}

promptconf_build() {
  RETVAL=$?             # must be first - the status segment reads it
  _promptconf_bg='NONE' # so this is safe to call directly, not only via $( )
  local s; for s in "${PROMPTCONF_SEGMENTS[@]}"; do "$s"; done
  promptconf_end
}

# --- Segments -----------------------------------------------------------------
# Quote the colour lookups: an empty value means "terminal default" and has to
# survive as an empty argument rather than collapsing and shifting the rest.
# Optional segments fall back to a tint, so a scheme only names what it wants.
promptconf_status() {   # ✘ nonzero exit, ⚡ root, ⚙ background jobs
  local -a symbols
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$PROMPTCONF[err]}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{$PROMPTCONF[root]}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$PROMPTCONF[job]}%}⚙"
  [[ -n $symbols ]] && promptconf_segment "$PROMPTCONF[status_bg]" "$PROMPTCONF[status_fg]" "$symbols"
}

promptconf_context() { promptconf_segment "$PROMPTCONF[ctx_bg]" "$PROMPTCONF[ctx_fg]" '%n@%m' }

promptconf_time() { promptconf_segment "$PROMPTCONF[time_bg]" "$PROMPTCONF[time_fg]" '%D{%H:%M:%S} %D{%a %d %b}' }

promptconf_dir() { promptconf_segment "$PROMPTCONF[dir_bg]" "$PROMPTCONF[dir_fg]" '%~' }

# One `git status --porcelain=v2` call yields the branch, ahead/behind, stash
# count and every file state, so the segment costs a single fork.
promptconf_git() {
  (( $+commands[git] )) || return
  local line ab branch='' oid=''
  integer ahead=0 behind=0 stash=0 staged=0 unstaged=0 untracked=0 conflict=0
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#\# branch.head } ;;
      '# branch.oid '*)  oid=${line#\# branch.oid } ;;
      '# branch.ab '*)   ab=${line#\# branch.ab }
                         ahead=${${ab%% *}#+} behind=${${ab##* }#-} ;;
      '# stash '*)       stash=${line#\# stash } ;;
      ('1 '*|'2 '*)      [[ ${line[3]} != '.' ]] && (( staged++ ))
                         [[ ${line[4]} != '.' ]] && (( unstaged++ )) ;;
      'u '*)             (( conflict++ )) ;;
      '? '*)             (( untracked++ )) ;;
    esac
  done < <(command git status --porcelain=v2 --branch --show-stash \
             --ignore-submodules 2>/dev/null)
  [[ -n $branch ]] || return   # not a repo, or git too old for porcelain v2

  local -A G=(${(kv)PROMPTCONF_GLYPH}) ref
  if [[ $branch == '(detached)' ]]; then
    ref=$(command git describe --exact-match --tags HEAD 2>/dev/null) \
      && ref="$G[tag] $ref" || ref="$G[detached] ${oid[1,7]}"
  else
    ref="$G[branch] $branch"
  fi

  local marks='' m
  for m in $PROMPTCONF_GIT_MARKS; do
    case $m in
      staged)    (( staged ))    && marks+=" $G[staged]" ;;
      unstaged)  (( unstaged ))  && marks+=" $G[unstaged]" ;;
      untracked) (( untracked )) && marks+=" $G[untracked]" ;;
      conflict)  (( conflict ))  && marks+=" $G[conflict]" ;;
      stashed)   (( stash ))     && marks+=" $G[stashed]$stash" ;;
      ahead)     (( ahead ))     && marks+=" $G[ahead]$ahead" ;;
      behind)    (( behind ))    && marks+=" $G[behind]$behind" ;;
    esac
  done

  if (( staged || unstaged || untracked || conflict )); then
    promptconf_segment "$PROMPTCONF[dirty_bg]" "$PROMPTCONF[dirty_fg]" "${ref:gs/%/%%}${marks}"
  else
    promptconf_segment "$PROMPTCONF[clean_bg]" "$PROMPTCONF[clean_fg]" "${ref:gs/%/%%}${marks}"
  fi
}

promptconf_venv() {     # active python virtualenv
  [[ -n $VIRTUAL_ENV ]] || return
  promptconf_segment "${PROMPTCONF[venv_bg]:-$PROMPTCONF_TINT[moss]}" \
                     "${PROMPTCONF[venv_fg]:-$PROMPTCONF_SOL[base3]}" "⬢ ${VIRTUAL_ENV:t}"
}

promptconf_node() {     # node version, only inside a node project
  [[ -f package.json || -f .nvmrc ]] || return
  (( $+commands[node] )) || return
  promptconf_segment "${PROMPTCONF[node_bg]:-$PROMPTCONF_TINT[moss]}" \
                     "${PROMPTCONF[node_fg]:-$PROMPTCONF_SOL[base3]}" "⬡ ${$(node -v 2>/dev/null)#v}"
}

# 1.4s / 12s / 2m05s / 1h20m - precision where it matters, brevity where it
# does not. Nobody needs tenths on a command that ran for an hour.
_promptconf_duration_fmt() {   # <seconds, may be fractional>
  local -F f=$1
  local -i t=${f%%.*}          # truncate; int() would need zsh/mathfunc
  if   (( f < 10 ));   then printf '%.1fs' $f
  elif (( t < 60 ));   then printf '%ds' $t
  elif (( t < 3600 )); then printf '%dm%02ds' $(( t / 60 )) $(( t % 60 ))
  else                      printf '%dh%02dm' $(( t / 3600 )) $(( t % 3600 / 60 ))
  fi
}

promptconf_duration() { # runtime of the last command, once worth mentioning
  (( ${_promptconf_elapsed:-0} >= ${PROMPTCONF_DURATION_MIN:-3} )) || return
  promptconf_segment "${PROMPTCONF[dur_bg]:-$PROMPTCONF_TINT[bronze]}" \
                     "${PROMPTCONF[dur_fg]:-$PROMPTCONF_SOL[base03]}" \
                     "$(_promptconf_duration_fmt $_promptconf_elapsed)"
}

promptconf_exit() {     # the numeric exit code, when ✘ alone isn't enough
  (( RETVAL != 0 )) || return
  promptconf_segment "${PROMPTCONF[exit_bg]:-$PROMPTCONF_SOL[red]}" \
                     "${PROMPTCONF[exit_fg]:-$PROMPTCONF_SOL[base3]}" "$RETVAL"
}

zmodload -F zsh/datetime p:EPOCHSECONDS p:EPOCHREALTIME 2>/dev/null
autoload -Uz add-zsh-hook
_promptconf_timer_start() { _promptconf_started=$EPOCHREALTIME }
_promptconf_timer_stop() {
  if (( ${_promptconf_started:-0} )); then
    _promptconf_elapsed=$(( EPOCHREALTIME - _promptconf_started )); _promptconf_started=0
  else
    _promptconf_elapsed=0
  fi
}
add-zsh-hook preexec _promptconf_timer_start
add-zsh-hook precmd  _promptconf_timer_stop

PROMPTCONF_SEGMENTS=(promptconf_status promptconf_context promptconf_time promptconf_dir promptconf_git)
PROMPTCONF_AVAILABLE=(
  promptconf_status promptconf_context promptconf_time promptconf_dir promptconf_git
  promptconf_venv promptconf_node promptconf_duration promptconf_exit
)

# --- State --------------------------------------------------------------------
_promptconf_state_save() {
  mkdir -p $PROMPTCONF_DIR
  print -r -- $PROMPTCONF_SCHEME >! $PROMPTCONF_DIR/scheme
  print -r -- "$PROMPTCONF_SEGMENTS" >! $PROMPTCONF_DIR/layout
  print -r -- $PROMPTCONF_LINES >! $PROMPTCONF_DIR/lines
}

# Accept 'git' as well as the full 'promptconf_git'.
_promptconf_resolve() {
  (( $+functions[$1] )) && { print -r -- $1; return }
  (( $+functions[promptconf_$1] )) && { print -r -- promptconf_$1; return }
  return 1
}
_promptconf_short() { print -r -- ${1#promptconf_} }

# --- Commands -----------------------------------------------------------------
_promptconf_help() {
  print -r -- "
  promptconf - configure the prompt

    wizard                walk through it step by step

  colors
    schemes [name]        preview every scheme, or switch to one
    scheme [name]         show the active scheme, or switch to it
    keys                  every color slot, with a swatch
    colors                the 256-color cube, to find a number
    set <key> <color>     change one slot live ('' means terminal default)
    save <name>           keep the current colors as a reusable scheme
    reset                 discard live edits

  layout
    segments              what every segment looks like
    lines [1|2]           one-line or two-line prompt
    layout                which segments are on, in order
    add <seg> [after <seg>|first]
    remove <seg>
    move <seg> <where>    up, down, first, last, a number, or before/after <seg>
    order <seg>...        set the whole order at once

  doctor                  check fonts, colour support, oh-my-zsh conflicts

  schemes:  $PROMPTCONF_SCHEMES
  segments: ${${PROMPTCONF_AVAILABLE[@]#promptconf_}}
"
}

_promptconf_scheme() {
  local name=$1
  [[ -z $name ]] && { print -r -- $PROMPTCONF_SCHEME; return }
  if (( ! ${PROMPTCONF_SCHEMES[(I)$name]} )); then
    print -u2 "promptconf: unknown scheme '$name'"
    print -u2 "available: $PROMPTCONF_SCHEMES"
    return 1
  fi
  PROMPTCONF_SCHEME=$name
  promptconf_scheme_$name
  _promptconf_state_save
}

_promptconf_schemes() {
  [[ -n $1 ]] && { _promptconf_scheme "$1"; return }   # 'schemes ember' switches
  local current=$PROMPTCONF_SCHEME s line
  print
  for s in $PROMPTCONF_SCHEMES; do
    promptconf_scheme_$s
    false                       # force a non-zero exit so the status shows
    line=$(promptconf_build)
    # Name first, in a fixed-width column. Trailing labels cannot line up:
    # schemes whose segments share a background draw no separator, so their
    # rendered width differs and the eye reads it as broken alignment.
    print -Pn "  %F{$PROMPTCONF_SOL[base01]}${(r:9:)s}%f"
    print -P "$line"
  done
  promptconf_scheme_$current
  print "\n  promptconf scheme <name> to switch and remember.\n"
}

_promptconf_keys() {
  local k v
  print
  for k in ${(ko)PROMPTCONF}; do
    v=$PROMPTCONF[$k]
    if [[ $k == *_bg ]]; then
      print -Pn "  %K{${v:-0}}        %k"
    else
      print -Pn "  %F{${v:-default}}  ██████  %f"
    fi
    printf '  %-11s %s\n' $k "${v:-(terminal default)}"
  done
  print "\n  promptconf set <key> <color>\n"
}

_promptconf_set() {
  local key=$1
  [[ -z $key ]] && { _promptconf_keys; return }
  if [[ -z ${PROMPTCONF[$key]+x} ]]; then
    print -u2 "promptconf: unknown key '$key'"
    print -u2 "keys: ${(ko)PROMPTCONF}"
    return 1
  fi
  PROMPTCONF[$key]=$2
}

_promptconf_colors() {
  local i fg
  for i in {0..255}; do
    (( i < 16 || i > 244 || (i > 20 && i < 25) )) && fg=15 || fg=0
    print -Pn "%K{$i}%F{$fg}$(printf ' %3d ' $i)%k%f"
    (( (i + 1) % 12 )) || print
  done
  print "\n"
}

# The active colours as a scheme function - the same text save writes to disk
# and the same shape the built-ins take, so it can be pasted straight into a
# pull request.
_promptconf_scheme_body() {   # <name>
  local k
  print "promptconf_scheme_$1() {"
  print "  PROMPTCONF=("
  # (q-) already renders an empty value as '' - a :- fallback here would emit
  # escaped quotes, and the scheme would load them as literal characters.
  for k in ${(ko)PROMPTCONF}; do printf '    %-11s %s\n' $k ${(q-)PROMPTCONF[$k]}; done
  print "  )"
  print "}"
}

_promptconf_export() {
  print
  _promptconf_scheme_body ${1:-mine}
  print
}

_promptconf_save() {
  local name=$1
  [[ -z $name ]] && { print -u2 "usage: promptconf save <name>"; return 1 }
  mkdir -p $PROMPTCONF_DIR/schemes
  local f=$PROMPTCONF_DIR/schemes/$name.zsh
  {
    print "# written by promptconf save"
    _promptconf_scheme_body $name
  } > $f
  (( ${PROMPTCONF_SCHEMES[(I)$name]} )) || PROMPTCONF_SCHEMES+=($name)
  PROMPTCONF_SCHEME=$name
  _promptconf_state_save
  print "saved $f"
}

_promptconf_layout() {
  local s
  print "\n  on:"
  for s in $PROMPTCONF_SEGMENTS; do print "    $(_promptconf_short $s)"; done
  print "\n  off:"
  for s in $PROMPTCONF_AVAILABLE; do
    (( ${PROMPTCONF_SEGMENTS[(I)$s]} )) || print "    $(_promptconf_short $s)"
  done
  print "\n  promptconf add <segment> [after <segment>|first]\n  promptconf remove <segment>\n"
}

_promptconf_add() {
  local seg
  [[ -z $1 ]] && { _promptconf_layout; return }
  seg=$(_promptconf_resolve $1) || { print -u2 "promptconf: no such segment '$1'"; return 1 }
  (( ${PROMPTCONF_SEGMENTS[(I)$seg]} )) && { print -u2 "promptconf: '$1' is already on"; return 1 }
  case $2 in
    first) PROMPTCONF_SEGMENTS=($seg $PROMPTCONF_SEGMENTS) ;;
    after) local target=$(_promptconf_resolve $3) i
           i=${PROMPTCONF_SEGMENTS[(I)$target]}
           (( i )) || { print -u2 "promptconf: '$3' is not in the layout"; return 1 }
           PROMPTCONF_SEGMENTS[i]=("${PROMPTCONF_SEGMENTS[i]}" $seg) ;;
    *)     PROMPTCONF_SEGMENTS+=($seg) ;;
  esac
  (( ${PROMPTCONF_AVAILABLE[(I)$seg]} )) || PROMPTCONF_AVAILABLE+=($seg)
  _promptconf_state_save
}

_promptconf_remove() {
  local seg i
  seg=$(_promptconf_resolve $1) || { print -u2 "promptconf: no such segment '$1'"; return 1 }
  i=${PROMPTCONF_SEGMENTS[(I)$seg]}
  (( i )) || { print -u2 "promptconf: '$1' is not in the layout"; return 1 }
  PROMPTCONF_SEGMENTS[i]=()
  _promptconf_state_save
}

_promptconf_move() {   # <segment> up|down|first|last|before <seg>|after <seg>|<n>
  local seg target where=$2 i j
  seg=$(_promptconf_resolve $1) || { print -u2 "promptconf: no such segment '$1'"; return 1 }
  i=${PROMPTCONF_SEGMENTS[(I)$seg]}
  (( i )) || { print -u2 "promptconf: '$1' is not in the layout"; return 1 }

  # Positions are computed against the list with the segment already pulled
  # out, so "move it to 3" means "end up third", not "insert before whatever
  # is third right now" - which differ whenever moving something rightwards.
  local -a rest=(${PROMPTCONF_SEGMENTS:#$seg})
  local -i n=$(( $#rest + 1 ))
  case $where in
    up|u)             (( j = i > 1 ? i - 1 : 1 )) ;;
    down|d)           (( j = i < n ? i + 1 : n )) ;;
    first|top|start)  j=1 ;;
    last|bottom|end)  j=$n ;;
    before|after)
            target=$(_promptconf_resolve $3) \
              || { print -u2 "promptconf: no such segment '$3'"; return 1 }
            j=${rest[(I)$target]}
            (( j )) || { print -u2 "promptconf: '$3' is not in the layout"; return 1 }
            [[ $where == after ]] && (( j++ )) ;;
    <->)    (( j = where < 1 ? 1 : (where > n ? n : where) )) ;;
    *)      print -u2 "promptconf move: don't understand '$where'"
            print -u2 "  try: up  down  first  last  <position>  before <seg>  after <seg>"
            return 1 ;;
  esac
  PROMPTCONF_SEGMENTS=(${rest[1,j-1]} $seg ${rest[j,-1]})
  _promptconf_state_save
}

_promptconf_order() {
  (( $# )) || { _promptconf_layout; return }
  local s r out=()
  for s in "$@"; do
    r=$(_promptconf_resolve $s) || { print -u2 "promptconf: no such segment '$s'"; return 1 }
    out+=($r)
  done
  PROMPTCONF_SEGMENTS=($out)
  _promptconf_state_save
}

# Register a segment of your own so promptconf add can find it.
_promptconf_lines() {   # promptconf lines [1|2]
  if [[ -z $1 ]]; then print -r -- $PROMPTCONF_LINES; return; fi
  if [[ $1 != (1|2) ]]; then
    print -u2 "promptconf lines: expected 1 or 2"; return 1
  fi
  PROMPTCONF_LINES=$1
  promptconf_prompt
  _promptconf_state_save
}

promptconf_register() {
  (( ${PROMPTCONF_AVAILABLE[(I)$1]} )) || PROMPTCONF_AVAILABLE+=($1)
}

# --- Diagnostics --------------------------------------------------------------
# promptconf is standalone but coexists with oh-my-zsh. The one thing that
# actually breaks is another theme also owning PROMPT, so check for that.
_promptconf_doctor() {
  local ok="%F{$PROMPTCONF_SOL[green]}ok%f" warn="%F{$PROMPTCONF_SOL[yellow]}warn%f"
  print
  if (( ${ZSH_VERSION%%.*} >= 5 )); then
    print -P "  zsh $ZSH_VERSION  $ok"
  else
    print -P "  zsh $ZSH_VERSION  $warn - 5.0 or newer expected"
  fi

  if [[ $TERM == *256color* || $TERM == *direct* ]]; then
    print -P "  TERM=$TERM  $ok"
  else
    print -P "  TERM=$TERM  $warn - want a 256-colour TERM such as xterm-256color"
  fi

  if [[ $COLORTERM == (truecolor|24bit) ]]; then
    print -P "  24-bit colour  $ok - hex values like '#005f87' work"
  else
    print -P "  24-bit colour  not advertised - use 0-255, hex may not render"
  fi

  if [[ -n $ZSH && -n $ZSH_THEME ]]; then
    print -P "  oh-my-zsh  $warn - ZSH_THEME=\"$ZSH_THEME\" also sets PROMPT"
    print    "    set ZSH_THEME=\"\" and source promptconf after oh-my-zsh.sh"
  elif [[ -n $ZSH ]]; then
    print -P "  oh-my-zsh  $ok - present, no theme competing"
  fi

  if mkdir -p $PROMPTCONF_DIR 2>/dev/null && [[ -w $PROMPTCONF_DIR ]]; then
    print -P "  state $PROMPTCONF_DIR  $ok"
  else
    print -P "  state $PROMPTCONF_DIR  $warn - not writable, nothing persists"
  fi

  (( $+commands[git] )) \
    && print -P "  git  $ok" \
    || print -P "  git  $warn - the git segment will stay hidden"

  # Literal glyphs, not $'..' - that form is not interpreted inside double
  # quotes, and the separators may have been overridden to something else.
  print -P "\n  powerline glyphs: [] [] []"
  print    "    boxes or blanks here mean you need a Powerline-patched font"
  print    "    https://github.com/powerline/fonts"
  print -P "  plain unicode: [$PROMPTCONF_GLYPH[staged]] [$PROMPTCONF_GLYPH[unstaged]] [$PROMPTCONF_GLYPH[untracked]] [$PROMPTCONF_GLYPH[conflict]] [$PROMPTCONF_GLYPH[stashed]] [$PROMPTCONF_GLYPH[ahead]] [$PROMPTCONF_GLYPH[behind]] [$PROMPTCONF_GLYPH[detached]] [$PROMPTCONF_GLYPH[tag]]"
  print    "    these need no special font\n"
}

# --- Segment reference --------------------------------------------------------
typeset -gA PROMPTCONF_ABOUT=(
  promptconf_status   'exit code, root and background jobs - hidden when all is well'
  promptconf_context  'user@host'
  promptconf_time     'clock and date'
  promptconf_dir      'working directory'
  promptconf_git      'branch, dirty state, divergence - hidden outside a repo'
  promptconf_venv     'python virtualenv - hidden unless one is active'
  promptconf_node     'node version - hidden unless package.json or .nvmrc is present'
  promptconf_duration 'how long the last command took - hidden under 3s'
  promptconf_exit     'the exit code as a number - hidden on success'
)

# Most segments hide themselves unless something is wrong or present, so a
# useful preview has to fake the conditions: a failed command, an active
# virtualenv, a slow command, and a scratch directory holding a package.json
# so the node segment has something to detect.
# Lives under $HOME so the dir segment renders as a short ~/... path rather
# than a long temp path that would wrap the preview. A staged file makes the
# git segment show its dirty colour, which is otherwise hard to preview.
_promptconf_demo_dir() {
  # mktemp, not $$: two calls in one shell would otherwise return the same path
  # and their cleanups would delete each other's directory.
  local d=$(mktemp -d "$HOME/.promptconf-demo.XXXXXX")
  print '{"name":"demo"}' > $d/package.json
  if (( $+commands[git] )); then
    git -C $d init -q 2>/dev/null
    git -C $d add -A 2>/dev/null
  fi
  print -r -- $d
}

# A whole prompt with every segment showing, for judging a scheme's palette.
_promptconf_demo_prompt() {   # <scratch-dir> [segment...]
  local dir=$1; shift
  local -a segs=(${@:-$PROMPTCONF_AVAILABLE})
  (
    cd $dir
    _promptconf_bg='NONE'
    RETVAL=127
    VIRTUAL_ENV=/opt/venvs/api
    _promptconf_elapsed=42
    local seg
    for seg in $segs; do $seg; done
    promptconf_end
  ) | {
    # %~ is expanded by the caller's print -P, not in the subshell above, so
    # cd cannot shorten it. Swap it for a stand-in to keep the row from wrapping.
    local out stand_in='~/demo'   # via a variable: an inline ~ would expand
    IFS= read -r out
    print -r -- ${out//\%\~/$stand_in}
  }
}

_promptconf_demo() {   # <segment> <scratch-dir> - its rendered output
  (
    [[ $1 == promptconf_node ]] && cd $2
    _promptconf_bg='NONE'
    RETVAL=127
    VIRTUAL_ENV=/opt/venvs/api
    _promptconf_elapsed=42
    $1
    promptconf_end
  )
}

# One line per segment: on/off, name, and what it actually renders.
_promptconf_demo_line() {   # <segment> <index-or-empty> <scratch-dir>
  local s=$1 i=$2 tmp=$3 out dim=$PROMPTCONF_SOL[base01]
  [[ -n $i ]] && print -Pn "   %F{$dim}$(printf '%2d' $i)%f " || print -Pn "  "
  (( ${PROMPTCONF_SEGMENTS[(I)$s]} )) \
    && print -Pn " %F{$PROMPTCONF_SOL[green]}on %f " \
    || print -Pn " %F{$dim}off%f "
  print -Pn "%F{$dim}${(r:10:)${s#promptconf_}}%f"
  out=$(_promptconf_demo $s $tmp)
  [[ -n $out ]] && print -P "$out" || print -P "%F{$dim}(nothing here)%f"
}

_promptconf_segments() {
  local s tmp=$(_promptconf_demo_dir) dim=$PROMPTCONF_SOL[base01]
  print
  for s in $PROMPTCONF_AVAILABLE; do
    _promptconf_demo_line $s '' $tmp
    print -P "                %F{$dim}$PROMPTCONF_ABOUT[$s]%f"
  done
  rm -rf $tmp
  print -P "  %F{$dim}shown with a failing command, a virtualenv and a slow command,%f"
  print -P "  %F{$dim}so segments that normally stay hidden are visible here.%f\n"
}

# --- Wizard -------------------------------------------------------------------
# Everything here is reachable through the individual commands; this just walks
# you through them in order and shows the effect of each choice before the next.
_promptconf_wizard() {
  [[ -o interactive ]] || { print -u2 "promptconf wizard: needs an interactive shell"; return 1 }

  local reply s i cyan=$PROMPTCONF_SOL[cyan] dim=$PROMPTCONF_SOL[base01]
  local tmp=$(_promptconf_demo_dir) row= tmp2= seg= keys= k= bad=
  tmp2=$tmp                       # one scratch dir serves every step
  local was_scheme=$PROMPTCONF_SCHEME was_lines=$PROMPTCONF_LINES
  local -a was_segments=($PROMPTCONF_SEGMENTS)
  local -a chosen=($PROMPTCONF_SEGMENTS)
  _promptconf_abort() {
    PROMPTCONF_SCHEME=$was_scheme; promptconf_scheme_$was_scheme
    PROMPTCONF_SEGMENTS=($was_segments)
    PROMPTCONF_LINES=$was_lines; promptconf_prompt
    print "\n  cancelled, nothing changed\n"
  }

  print -P "\n  %Bpromptconf%b   Enter keeps what you have, q quits\n"

  # 1 - colour scheme, each rendered with your real directory and git state
  print -P "  %F{$cyan}1/5  colour scheme%f\n"
  row=
  i=1
  for s in $PROMPTCONF_SCHEMES; do
    promptconf_scheme_$s
    row=$(_promptconf_demo_prompt $tmp)   # every segment, so the whole palette shows
    print -Pn "   %F{$dim}$(printf '%2d' $i)  ${(r:9:)s}%f"
    print -P "$row"
    (( i++ ))
  done
  promptconf_scheme_$PROMPTCONF_SCHEME
  print -n "
  number [Enter = $PROMPTCONF_SCHEME]: "
  if ! read -r reply; then _promptconf_abort; return 1; fi
  case $reply in
    q|Q) _promptconf_abort; return 1 ;;
    '')  ;;
    <->) if (( reply >= 1 && reply <= $#PROMPTCONF_SCHEMES )); then
           PROMPTCONF_SCHEME=$PROMPTCONF_SCHEMES[reply]
           promptconf_scheme_$PROMPTCONF_SCHEME
         else
           print "  out of range - keeping $PROMPTCONF_SCHEME"
         fi ;;
    *)   print "  not a number - keeping $PROMPTCONF_SCHEME" ;;
  esac

  # 2 - segments, toggled by number until you press Enter. Each is rendered so
  # the choice is visual; ? adds a line of description to every one.
  local detail=0
  _promptconf_abort() {
    rm -rf $tmp
    PROMPTCONF_SCHEME=$was_scheme; promptconf_scheme_$was_scheme
    PROMPTCONF_SEGMENTS=($was_segments)
    PROMPTCONF_LINES=$was_lines; promptconf_prompt
    print "\n  cancelled, nothing changed\n"
  }
  while true; do
    print -P "\n  %F{$cyan}2/5  segments%f   toggle by number, ? for detail, Enter when done\n"
    i=1
    local saved=($PROMPTCONF_SEGMENTS)
    PROMPTCONF_SEGMENTS=($chosen)        # so on/off reflects your pending choices
    for s in $PROMPTCONF_AVAILABLE; do
      _promptconf_demo_line $s $i $tmp
      (( detail )) && print -P "                %F{$dim}$PROMPTCONF_ABOUT[$s]%f"
      (( i++ ))
    done
    PROMPTCONF_SEGMENTS=($saved)
    print -n "
  numbers [Enter = done]: "
    if ! read -r reply; then _promptconf_abort; return 1; fi
    [[ $reply == (q|Q) ]] && { _promptconf_abort; return 1 }
    [[ $reply == '?' ]] && { detail=1; continue }
    [[ -z $reply ]] && break
    for i in ${=reply}; do
      if [[ $i != <-> ]] || (( i < 1 || i > $#PROMPTCONF_AVAILABLE )); then
        print "  ignoring '$i'"; continue
      fi
      s=$PROMPTCONF_AVAILABLE[i]
      if (( ${chosen[(I)$s]} )); then
        chosen[${chosen[(I)$s]}]=()
      else
        chosen+=($s)   # appended in the order you switch them on
      fi
    done
  done
  PROMPTCONF_SEGMENTS=($chosen)

  # 3 - confirm
  # 3 - order
  _promptconf_abort() {
    rm -rf $tmp $tmp2
    PROMPTCONF_SCHEME=$was_scheme; promptconf_scheme_$was_scheme
    PROMPTCONF_SEGMENTS=($was_segments)
    PROMPTCONF_LINES=$was_lines; promptconf_prompt
    print "\n  cancelled, nothing changed\n"
  }
  # Show the assembled prompt on one line - that is the thing being arranged -
  # with a numbered key beneath it. Shifting is left/right, the direction the
  # prompt actually runs; a vertical list made up/down look right and it never was.
  _promptconf_order_view() {   # <selected-segment-or-empty>
    local s i=1 key=''
    print -P "    $(_promptconf_demo_prompt $tmp $PROMPTCONF_SEGMENTS)"
    for s in $PROMPTCONF_SEGMENTS; do
      if [[ $s == $1 ]]; then
        key+="  %F{$PROMPTCONF_SOL[green]}[${s#promptconf_}]%f"
      else
        key+="  %F{$dim}$i ${s#promptconf_}%f"
      fi
      (( i++ ))
    done
    print -P "  $key"
  }

  while true; do
    print -P "\n  %F{$cyan}3/5  order%f\n"
    _promptconf_order_view ''
    print -n "
  pick a number [Enter = done]: "
    if ! read -r reply; then _promptconf_abort; return 1; fi
    [[ $reply == (q|Q) ]] && { _promptconf_abort; return 1 }
    [[ -z $reply ]] && break

    # Assignment form: bare "local x" re-declares an already-set name and zsh
    # prints it, which is how x=... debris ended up on screen.
    seg=
    if [[ $reply == <-> ]] && (( reply >= 1 && reply <= $#PROMPTCONF_SEGMENTS )); then
      seg=$PROMPTCONF_SEGMENTS[reply]
    elif ! seg=$(_promptconf_resolve $reply) || (( ! ${PROMPTCONF_SEGMENTS[(I)$seg]} )); then
      print "  '$reply' is not one of the numbers above"; continue
    fi

    while true; do
      print -P "\n  %F{$cyan}moving ${seg#promptconf_}%f\n"
      _promptconf_order_view $seg
      print -n "
  l/r to shift, b/e for the ends, Enter drops: "
      # A plain line read, not single-keypress: read -k leaves terminal echo on,
      # so arrow escapes were painting ^[[C across the screen, and it needs raw
      # mode this does not. Arrows still work - they arrive as escape sequences
      # and get folded into l/r below.
      if ! read -r keys; then _promptconf_abort; return 1; fi
      keys=${keys//$'\e[D'/l}; keys=${keys//$'\eOD'/l}
      keys=${keys//$'\e[C'/r}; keys=${keys//$'\eOC'/r}
      keys=${(L)keys//[[:space:]]/}
      [[ -z $keys ]] && break
      [[ $keys == q ]] && { _promptconf_abort; return 1 }

      bad=
      for k in ${(s::)keys}; do
        case $k in
          l) _promptconf_move ${seg#promptconf_} up ;;     # left  = earlier
          r) _promptconf_move ${seg#promptconf_} down ;;   # right = later
          b) _promptconf_move ${seg#promptconf_} first ;;
          e) _promptconf_move ${seg#promptconf_} last ;;
          *) bad+=$k ;;
        esac
      done
      [[ -n $bad ]] && print "  ignored: $bad   (l, r, b, e or Enter)"
    done
    print
  done
  # 4 - one line or two
  while true; do
    print -P "\n  %F{$cyan}4/5  shape%f\n"
    print -P "    %F{$dim}1%f  one line   $(_promptconf_demo_prompt $tmp $PROMPTCONF_SEGMENTS) ${PROMPTCONF_MARKER}"
    print -P "    %F{$dim}2%f  two lines  $(_promptconf_demo_prompt $tmp $PROMPTCONF_SEGMENTS)"
    print -P "                  ${PROMPTCONF_MARKER}"
    print -n "
  1 or 2 [Enter = $PROMPTCONF_LINES]: "
    if ! read -r reply; then _promptconf_abort; return 1; fi
    [[ $reply == (q|Q) ]] && { _promptconf_abort; return 1 }
    [[ -z $reply ]] && break
    if [[ $reply == (1|2) ]]; then
      PROMPTCONF_LINES=$reply; promptconf_prompt; break
    fi
    print "  expected 1 or 2"
  done

  print -P "\n  %F{$cyan}5/5  result%f\n"
  print -Pn "   "; false; print -P "$(promptconf_build)"
  (( PROMPTCONF_LINES == 2 )) && print -P "   ${PROMPTCONF_MARKER}"
  print -Pn "   "; print -P "$(promptconf_build)"
  (( PROMPTCONF_LINES == 2 )) && print -P "   ${PROMPTCONF_MARKER}"
  print "
  order: ${${PROMPTCONF_SEGMENTS[@]#promptconf_}}"
  print -n "
  keep this? [Y/n]: "
  if ! read -r reply; then _promptconf_abort; return 1; fi
  case $reply in
    n|N|q|Q) _promptconf_abort; return 1 ;;
  esac
  rm -rf $tmp
  _promptconf_state_save
  print "\n  saved. promptconf help shows everything else.\n"
}

promptconf() {
  local cmd=${1:-help}
  (( $# )) && shift
  case $cmd in
    wizard)         _promptconf_wizard ;;
    segments)       _promptconf_segments ;;
    doctor)         _promptconf_doctor ;;
    schemes)        _promptconf_schemes "$@" ;;
    scheme)         _promptconf_scheme "$@" ;;
    keys)           _promptconf_keys ;;
    colors)         _promptconf_colors ;;
    set)            _promptconf_set "$@" ;;
    save)           _promptconf_save "$@" ;;
    export)         _promptconf_export "$@" ;;
    reset)          promptconf_scheme_$PROMPTCONF_SCHEME ;;
    layout)         _promptconf_layout ;;
    lines)          _promptconf_lines "$@" ;;
    add)            _promptconf_add "$@" ;;
    remove|rm)      _promptconf_remove "$@" ;;
    order)          _promptconf_order "$@" ;;
    move)           _promptconf_move "$@" ;;
    help|-h|--help) _promptconf_help ;;
    *) print -u2 "promptconf: unknown command '$cmd'"; _promptconf_help; return 1 ;;
  esac
}

# --- Completion ---------------------------------------------------------------
# zsh completes filenames and commands out of the box, but the programmable
# system that compdef belongs to only exists once compinit has run. Frameworks
# do that for you; a bare zsh does not. Rather than silently offering no
# completion, start it - set PROMPTCONF_COMPINIT=0 to leave it alone.
_promptconf_completion() {
  if (( ! $+functions[compdef] )); then
    (( ${PROMPTCONF_COMPINIT:-1} )) || return
    autoload -Uz compinit
    # -i skips insecure directories rather than prompting about them, which
    # would otherwise stall an interactive shell on startup.
    compinit -i
  fi
  (( $+functions[compdef] )) || return
  compdef '_arguments \
    "1:command:(wizard schemes scheme segments keys colors set save export reset lines layout add remove move order doctor help)" \
    "*::arg:->rest"' promptconf
}

if (( $+functions[compdef] )); then
  _promptconf_completion
else
  # Defer to the first prompt. By then the rest of .zshrc has run, so $fpath is
  # complete and anything that runs compinit itself has already had its turn -
  # calling it here would freeze fpath before those additions landed.
  _promptconf_completion_once() {
    add-zsh-hook -d precmd _promptconf_completion_once
    _promptconf_completion
  }
  add-zsh-hook precmd _promptconf_completion_once
fi

# --- Restore ------------------------------------------------------------------
for _pf in $PROMPTCONF_DIR/schemes/*.zsh(N); do
  source $_pf
  (( ${PROMPTCONF_SCHEMES[(I)${_pf:t:r}]} )) || PROMPTCONF_SCHEMES+=(${_pf:t:r})
done
unset _pf

PROMPTCONF_SCHEME=agnoster
[[ -r $PROMPTCONF_DIR/scheme ]] && read -r PROMPTCONF_SCHEME < $PROMPTCONF_DIR/scheme
(( ${PROMPTCONF_SCHEMES[(I)$PROMPTCONF_SCHEME]} )) || PROMPTCONF_SCHEME=agnoster
promptconf_scheme_$PROMPTCONF_SCHEME

# read, not $(<file): zsh evaluates $(<...) even under -n, so a syntax check
# would try to open the file and complain about it.
if [[ -r $PROMPTCONF_DIR/lines ]]; then
  read -r _promptconf_line < $PROMPTCONF_DIR/lines
  [[ $_promptconf_line == (1|2) ]] && PROMPTCONF_LINES=$_promptconf_line
fi

if [[ -r $PROMPTCONF_DIR/layout ]]; then
  read -r _promptconf_line < $PROMPTCONF_DIR/layout \
    && PROMPTCONF_SEGMENTS=(${=_promptconf_line})
  unset _promptconf_line
fi

# Single-quoted so $(promptconf_build) and ${PROMPTCONF[mark]} stay unexpanded
# for prompt_subst to evaluate on every redraw; only the marker glyph is
# substituted now.
promptconf_prompt() {
  local mark='%{%F{${PROMPTCONF[mark]}}%}'${PROMPTCONF_MARKER}'%{%f%} '
  if (( PROMPTCONF_LINES == 1 )); then
    PROMPT='%{%f%b%k%}$(promptconf_build) '$mark
  else
    PROMPT='%{%f%b%k%}$(promptconf_build)'$'\n'$mark
  fi
}
promptconf_prompt
