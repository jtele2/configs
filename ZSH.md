# Zsh Quick Reference

## Startup Files

```bash
/etc/zshenv     # Always run (global)
~/.zshenv       # Always run (user) - unless NO_RCS set
/etc/zprofile   # Login shells (global)
~/.zprofile     # Login shells (user)
/etc/zshrc      # Interactive shells (global)
~/.zshrc        # Interactive shells (user)
/etc/zlogin     # Login shells after zshrc (global)
~/.zlogin       # Login shells after zshrc (user)
~/.zlogout      # Logout from login shells
```

**Login shell:** Terminal app, SSH session  
**Interactive shell:** Any shell you start manually

## Options

```bash
setopt OPTION_NAME    # Enable option
unsetopt OPTION_NAME  # Disable option
set -o                # List all options
```

Options are case-insensitive with flexible underscores: `NO_RCS` = `norcs` = `__NoRcS___`

## Parameters & Arrays

```bash
# Variables
foo='value'           # Set variable
print -- "$foo"       # Print with expansion
print -- '$foo'       # Print literal

# Arrays (1-indexed!)
arr=(one two three)
print ${arr[2]}       # Prints: two
```

## Functions

```bash
# Define function
fn() { 
    print "Args: $@"
    print "Name: $0"  # Function name
}

# Autoload from $fpath
autoload -Uz function_name
```

## Prompts

```bash
# Common prompt escapes
%m    # Hostname
%n    # Username
%~    # Current directory (with ~ for home)
%#    # % for user, # for root
%t    # Time (12-hour)
%T    # Time (24-hour)

# Test prompts
print -P '%n@%m:%~%# '

# Truncate paths
%10<...<%~    # Limit to 10 chars with ... 
```

Key variables:

- `$PS1` / `$PROMPT` - Main prompt
- `$RPS1` - Right-side prompt
- `$PS2` - Continuation prompt
- `$PS4` - Debug trace prefix

## Path Management

```bash
# Array form (preferred in Zsh)
path=(/usr/local/bin $path)

# Traditional form (for compatibility)
export PATH="/usr/local/bin:$PATH"

# Completion paths
fpath=(~/.zsh/completions $fpath)
```

## Useful Commands

```bash
whence -v command    # Show command type/location
which command        # Simpler version
type command         # Another alternative

compinit            # Initialize completions
rehash              # Rebuild command hash table
```

## Tips

- Use `[[` for conditions (more features than `[`)
- `$VISUAL` for full-screen editors, `$EDITOR` for line editors
- `--` in commands means "no more options"
- `print -P` to test prompt strings
- `stty -a` to show terminal shortcuts
