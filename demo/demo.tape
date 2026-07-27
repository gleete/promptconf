# Regenerate with:  vhs demo/demo.tape   (needs ~/demo to be a small git repo)
# Produces demo/promptconf.gif
#
# The theme is this repo's solarizedDark iTerm preset, so the recording shows
# the colours a solarized terminal would.

Output demo/promptconf.gif

Set Shell zsh
Set FontSize 20
Set Width 1280
Set Height 620
Set Padding 20
Set TypingSpeed 55ms
Set Theme { "name": "solarized-dark", "background": "#001e27", "foreground": "#708284", "cursor": "#708284", "selection": "#002831", "black": "#002831", "red": "#d11c24", "green": "#738a05", "yellow": "#a57706", "blue": "#2176c7", "magenta": "#c61c6f", "cyan": "#259286", "white": "#eae3cb", "brightBlack": "#001e27", "brightRed": "#bd3613", "brightGreen": "#475b62", "brightYellow": "#536870", "brightBlue": "#708284", "brightMagenta": "#5956ba", "brightCyan": "#819090", "brightWhite": "#fcf4dc" }

# Clean slate in a short directory - a long $PWD wraps every row.
Hide
Type "PC=$PWD; export PROMPTCONF_DIR=$(mktemp -d); cd ~/demo" Enter
Type "source $PC/promptconf.zsh" Enter
Type "clear" Enter
Show

Sleep 800ms

Type "promptconf schemes"          Sleep 400ms  Enter  Sleep 3.2s
Type "clear"                       Enter        Sleep 300ms
Type "promptconf scheme ember"     Sleep 400ms  Enter  Sleep 1.8s
Type "promptconf add duration"     Sleep 400ms  Enter  Sleep 1.2s
# Actually run something slow - the segment stays hidden below 3s, so without
# this the demo looks like the command did nothing.
Type "sleep 4"                     Sleep 400ms  Enter  Sleep 5s
Type "promptconf segments"         Sleep 400ms  Enter  Sleep 3.5s
Type "clear"                       Enter        Sleep 300ms
Type "promptconf scheme agnoster"  Sleep 400ms  Enter  Sleep 1.6s
Type "false"                       Sleep 300ms  Enter  Sleep 2.5s
