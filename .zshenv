# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout?newreg=741ab675789d4b1ba96862d40c2bb2d7

# fpath is the zsh search path only for function definitions and autoloaded functions
fpath=(~/configs/completions $fpath)

# path is the zsh equivalent of PATH
path=(
    /usr/local/cuda-12.1/bin 
    $path
)

# Add path
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"