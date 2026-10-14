gm-restool() {
    local IFS= LC_ALL="C"
    if [[ -z "$GM_RESTOOL_REPL_COPROC" ]] && [[ $1 = "exit" ]]; then
        echo "ResourceTool isn't running, so no need to exit."
        return 1
    fi
    gm-restool::ensure-resourcetool-repl
    printf "\"%s\" " "$@" 1>&"${GM_RESTOOL_REPL_COPROC[1]}"
    # printf "$@" 1>&"${GM_RESTOOL_REPL_COPROC[1]}"
    echo 1>&"${GM_RESTOOL_REPL_COPROC[1]}"
    local _unused=""
    read -u "${GM_RESTOOL_REPL_COPROC[0]}" _unused
    gm-restool::read-output
}

gm-restool::read-output() {
    local IFS= LC_ALL="C"
    local finished_str=$'|> '
    local finised_prog=0
    # cat <&"${GM_RESTOOL_REPL_COPROC[0]}"
    while read -r -d '' -n 1 -u "${GM_RESTOOL_REPL_COPROC[0]}" char; do
        if [[ "${char}" == "${finished_str:${finised_prog}:1}" ]]; then
            finised_prog+=1
            if (( finised_prog + 1 >= ${#finished_str} )); then
                break
            fi
        else
            if (( finised_prog > 0 )); then
                printf "%s" "${finished_str:0:${finised_prog}}"
                finised_prog=0
            fi
            printf "%s" "${char}"
        fi
    done
}

gm-restool::ensure-resourcetool-repl() {
    local IFS= LC_ALL="C"
    if ! [[ -z "$GM_RESTOOL_REPL_COPROC" ]]; then
        return 0;
    fi
    echo "Starting ResourceTool..."
    coproc GM_RESTOOL_REPL_COPROC { gm-cli resourcetool repl; }
    # coproc GM_RESTOOL_REPL_COPROC { qalc; }
    gm-restool::read-output; #>/dev/null
}

gm-restool-unload() {
    local IFS= LC_ALL="C"
    if ! [[ -z "$GM_RESTOOL_REPL_COPROC_PID" ]]; then
        local pid=${GM_RESTOOL_REPL_COPROC_PID}
        kill -15 $pid
        wait $pid
    fi
    unset -f gm-restool::ensure-resourcetool-repl
    unset -f gm-restool::read-output
    unset -f gm-restool
    unset -f gm-restool-unload
    return 0
}

# Executing this on it's own is meaningless
if ! ( return 0 &>/dev/null ); then
    echo "gm-restool: not a standalone program, must be sourced!" 1>&2
    exit 1
fi
