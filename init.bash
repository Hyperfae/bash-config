zdust() {
    nix --extra-experimental-features 'flakes nix-command' run nixpkgs#dust -- -Cr "$@" | less -R --chop-long-lines
}
get-nix-path() {
    store_path="$(nix eval --raw "$@")"
    if ! [ -f "$store_path" ]; then
        nix shell "$@" -c true
    fi
    printf '%s' "$store_path"
}

path-add() {
    local IFS=":"
    local -a path_arr=($PATH)
    path_arr+=( "$@" )

    PATH="${path_arr[0]}"
    local -i i
    local -i size=${#path_arr[@]}
    for ((i = 1; i < size; i++ )); do
        PATH+=":${path_arr[i]}"
    done
    export PATH
}

path-add ~/.local/bin/

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.config/bash/gm-restool.bash
