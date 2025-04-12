# Zsh

## Chapter 1

- Builtins and functions always run in the shell itself

- In `alias %=' '`, the space above indicates that any following aliases should be expanded
- You can ref options in upper or lower case with as many or as few underscores as you like

## Chapter 2

- When you startup the shell, there is actually 2x shells - the interactive one and the non-interactive one that is waiting to finish running the script
- There are times when you are going to make some radical changes to the shell's settings temporarily, and the easiest thing to do is to start another shell, do what you want to do, and exit back to the original, unaltered, shell
- That second shell will not be a login shell
- Any zsh you start yourself will not be a login shell
- The -o tells the shell to test an option, here login
- `[[` is treated specially, which allows the shell to do some extra checks and allows more natural syntax

Startup Scripts

```shell
# Always run for every zsh
# If NO_RCS (zsh -f) set, nothing else ran
/etc/zshenv

# Usually run for every zsh (see below)
~/.zshenv

# Run for login shells
/etc/zprofile

# Run for login shells
~/.zprofile

# Run for interactive shells
/etc/zshrc

# Run for interactive shells
~/.zshrc

# Run for login shells
/etc/zlogin

# Run for login shells
~/.zlogin

# Run on logout (only login shells)
~/.zlogout

# Run on logout (only login shells)
/etc/zlogout
```

- If the option NO_RCS is set (or, equivalently, the RCS option is unset: I'll talk about options shortly, since they are important in startup files), none of the others are run

### Options

- All Boolean
- NO_RCE, norcs, __NoRcS___ mean same thing!
- "no” in front of the option means off

```shell
# To set and unset options

# Set with no -o sets positional params

# set -o == setopt

setopt/unsetopt
```

- `$VISUAL`: full-screen editor
- `$EDITOR`: line editor

### Parameters/Variables

`foo='This is a param'`

- Space before: name of command
- Space after: assign empty string to param foo
- Single quotes: nuclear option of quotes - everything up to another single quote is a simple string

```shell
foo='This is a param
This is the same param'
foo=this_also_works
```

#### Expansion/Substitution

```shell
foo=bar
print -- '$foo is "'$foo'"'
# >>> $foo is "bar"
```

- The `--` indicates no more options

#### Arrays

```shell
foo=(this is an array)
print -- ${foo[4]}
# >>> array
# Note its 1-indexed!
```

### Functions

```shell
# Note nothing ever in `()`
# $0 is fn name
# $0 outside a function is shell/script name
fn() { print My name is $0; }
fn
# >>> My name is fn
```

- You can put all functions in `autoload fn` and the function will only be loaded when you run it by typing its name
- Shell uses `$fpath` to know where fn is stored

### Prompts

- 2x ways of getting info into prompts like $PS1 which determins the usual prompt at start of a new command line
    1. Using percent escapes: `%` followed by another character, maybe w/ a number between the two (`%m%#`).
        - First `%` escape turns into name of host computer
        - Second `%` escape turns into a `%` or `#` for user/root
    2. Other way is to put parameters into prompt to be substituded
        - Set `$PROMPT_SUBST`
        - Assign `PS1='${PWD}% '`
        - Note single quotes, so this happens when prompt is shown, not when assigned. Otherwise it wouldn't change to reflect the dir you were in.
        - Prompts with PROMPT_SUBST are expanded pretty much the same as a string inside double quotes every time the prompt is displayed
- Main prompt is in param `$PS1` or `$PROMPT` or `$prompt`
  - `$RPS1` is right side
  - `$PS2` is when shell waiting for more input
  - `$PS3` is showin with loop by shell's `select`
  - `$PS4` usefull in debugging - there is `XTRACE` option which caues the shell to print out lines about to be executed preceded by `$PS4`
  - `print -P` try out prompt alterations (expands strings just as they are in prompts)
- Prompts or parts of prompts, not just bits showing the directory, can be truncated to any length you choose. To truncate a path on the left, use something like `%10<...<%~`
  - `%<<` is the basic form for truncation
  - The 10 after the `%' says that anything following is limited to 10 characters
  - The characters `...' are to be displayed whenever the prompt would otherwise be longer than that
