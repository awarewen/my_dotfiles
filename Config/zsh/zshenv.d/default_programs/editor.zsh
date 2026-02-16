# Editor is the shell program that edits text files.
#
# Example choices:
#
#   * vi
#   * vim
#   * nvim
#   * emacs -nw --color=no
#   * emacsclient --alternate-editor="" -c "$@"
#   * nano
#   * pico
#
(( ${+EDITOR} )) || export EDITOR=$( command -v nvim || command -v vim || command -v vi || "" )
(( ${+ALTERNATE_EDITOR} )) || export ALTERNATE_EDITOR=$(command -v nvim || command -v vim || command -v vi || "" )
(( ${+VISUAL} )) || export VISUAL=$( command -v nvim || command -v vim || command -v vi || "" )
