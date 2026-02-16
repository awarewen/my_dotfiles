
# Background processes run full speed
unsetopt BGNICE

# Don't chase directory dots because they exist for a reason.
unsetopt CHASE_DOTS

# Report the status of background and suspended jobs before exiting a shell.
setopt CHECK_JOBS

# Don't correct mistakes.
unsetopt CORRECT
unsetopt CORRECT_ALL

# When a command runs, hash the directory containing it and parents.
setopt HASH_DIRS

# Skip command line in the history list if it duplicates the previous line.
setopt HIST_IGNORE_DUPS

# Restart running processes on exit.
setopt HUP

# Enable variable substitution in the prompt.
setopt PROMPT_SUBST
