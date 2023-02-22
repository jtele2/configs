# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout?newreg=741ab675789d4b1ba96862d40c2bb2d7

# Add istio to path
path=('/home/ubuntu/istio-1.17.0/bin' $path)

# Source my pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export PATH