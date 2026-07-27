# Contributing

Schemes and segments are the two things most worth contributing, and both are
small — a scheme is about a dozen lines, a segment usually fewer.

## Contributing a scheme

Build it live rather than writing it blind. Tune colours until you like them,
then have promptconf write the code for you:

```zsh
promptconf keys                 # every slot, with a swatch
promptconf colors               # the 256-colour cube, to find a number
promptconf set dir_bg 25        # change one, see it immediately
promptconf export midnight      # print it as a scheme function
```

`export` emits exactly the shape the built-ins take. Paste it into
`promptconf.zsh` beside the others, add the name to `PROMPTCONF_SCHEMES`, and
give it a one-line comment saying what it is for.

```zsh
promptconf_scheme_midnight() {  # deep blues, low contrast, for dark rooms
  local -A S=(${(kv)PROMPTCONF_SOL}) T=(${(kv)PROMPTCONF_TINT})
  PROMPTCONF=(
    status_bg $S[base02]  status_fg ''
    ...
  )
}
```

Prefer `$S[...]` and `$T[...]` over bare numbers. `PROMPTCONF_SOL` maps
solarized names onto ANSI slots 0–15, so those follow whatever palette the
terminal has loaded and your scheme adapts to it. `PROMPTCONF_TINT` holds fixed
256-colour tones for hues those sixteen slots cannot reach; use it when you
want a specific colour regardless of the terminal. Reach for a raw number only
when neither fits, and say why in a comment.

Two things to check before opening a pull request:

**Contrast.** Text needs roughly 4.5:1 against its background to stay
comfortable, and a segment nobody can read is worse than one that is a bit
plain. Several colours that seem obvious do not survive: solarized amber
`#a57706` manages only 1.8:1 on steel blue, and the terminal's default
foreground on agnoster's blue is about 1.2:1, which is essentially invisible.

**Every state.** Run `promptconf schemes` to see yours beside the others, and
check it with something failing, a dirty repo, and the optional segments on.
The wizard's first step renders all of that at once.

## Contributing a segment

A segment is any function that calls `promptconf_segment <bg> <fg> <content>`.
Return early to render nothing — that is how `git` disappears outside a
repository.

```zsh
promptconf_kube() {
  (( $+commands[kubectl] )) || return
  local ctx=$(kubectl config current-context 2>/dev/null) || return
  promptconf_segment "${PROMPTCONF[kube_bg]:-$PROMPTCONF_TINT[slate]}" \
                     "${PROMPTCONF[kube_fg]:-$PROMPTCONF_SOL[base3]}" "⎈ ${ctx:gs/%/%%}"
}
```

To ship it as a built-in, add the name to `PROMPTCONF_AVAILABLE` and a
description to `PROMPTCONF_ABOUT`. Leave it out of `PROMPTCONF_SEGMENTS` —
optional segments stay off until someone turns them on.

Four rules that are easy to miss:

- **Escape `%` in anything dynamic** with `:gs/%/%%`. A branch called `100%`
  will otherwise be read as a prompt escape and mangle the line.
- **Fall back on the colour lookup** — `${PROMPTCONF[kube_bg]:-...}` — so
  existing schemes keep working without naming your slot.
- **Fail quietly.** Redirect stderr and return; a prompt that prints errors is
  unusable.
- **Watch the cost.** Everything here runs on every keystroke of every prompt.
  Prefer one command over three: the git segment gets the branch, divergence,
  stash count and file states from a single `git status --porcelain=v2` call
  rather than five separate invocations.

## Style

Namespace everything `promptconf_`, or `_promptconf_` for internals. The
segment functions especially — agnoster defines `prompt_git` and `prompt_dir`,
and colliding with a theme people may also have loaded is the one bug that
looks impossible to diagnose.

Quote colour lookups: `"$PROMPTCONF[ctx_fg]"`. An empty value means "terminal
default" and has to survive as an empty argument rather than collapsing and
shifting the arguments after it.

Use `local name=value`, never a bare `local name`. zsh *prints* a parameter
when `typeset` is given a name with no assignment, so a bare declaration inside
a loop scatters `name=value` debris across the screen.

No dependencies beyond zsh and, for the powerline glyphs, a patched font. It is
one file on purpose.

## Testing

```sh
zsh -n promptconf.zsh                      # parses
zsh -f -c 'source ./promptconf.zsh; promptconf_build'   # works with no framework
```

The framework-free check matters: promptconf has to work under a bare zsh, not
only alongside oh-my-zsh. `promptconf doctor` covers the environment side —
colour support, font glyphs, and whether something else owns `PROMPT`.

Worth exercising by hand: a failing command, a dirty repository, a detached
head, and a directory that is not a repository at all.
