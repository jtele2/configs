# Fix Github Co-pilot self-signed cert problem
# See: https://github.com/orgs/community/discussions/8866#discussioncomment-3517831
# The script is modified to handle .vscode-server too (in WSL2)
fix_github_copilot() {
    patch_ext() {
        _VSCODEDIR=$1
        _EXTENSIONSPATH="$HOME/${_VSCODEDIR}/extensions"
        _RE=$2
        _NAME=$3
        _COPILOTDIR=$(ls "${_EXTENSIONSPATH}" | grep -E "${_RE}" | sort -V | tail -n1)
        _EXTENSIONFILEPATH="${_EXTENSIONSPATH}/${_COPILOTDIR}/dist/extension.js"

        if [[ -f "$_EXTENSIONFILEPATH" ]]; then
            # echo "Found $_NAME extension, applying 'rejectUnauthorized' patches to '$_EXTENSIONFILEPATH'"
            perl -pi -e 's/,rejectUnauthorized:[a-z]}(?!})/,rejectUnauthorized:false}/g' ${_EXTENSIONFILEPATH}
            sed -i.bak 's/d={...l,/d={...l,rejectUnauthorized:false,/g' ${_EXTENSIONFILEPATH}
        fi
    }

    do_fix() {
        if [[ -d "$HOME/$1" ]]; then
            patch_ext "$1" "github.copilot-[0-9].*" "Copilot"
            patch_ext "$1" "github.copilot-nightly-[0-9].*" "Copilot Nightly"
            patch_ext "$1" "github.copilot-labs-[0-9].*" "Copilot Labs"
            patch_ext "$1" "github.copilot-chat-[0-9].*" "Copilot Chat"
        fi
    }

    do_fix ".vscode"
    do_fix ".vscode-server"
    do_fix ".vscode-server-insiders"

    unset -f do_fix
    unset -f patch_ext
}

# My custom functions all start with `,`

,tfp() {
    terraform plan -out tf.plan
    terraform show  tf.plan > tfplan.ansi
    less -RN tfplan.ansi
}
