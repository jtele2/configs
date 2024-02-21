# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout?newreg=741ab675789d4b1ba96862d40c2bb2d7

# fpath is the zsh search path only for function definitions and autoloaded functions
fpath=(~/configs/completions $fpath)