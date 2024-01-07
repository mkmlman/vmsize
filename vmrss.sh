#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <pid>"
    exit 1
fi

function print_vmrss() {
    local pid=$1
    local total=0

    while [ -d "/proc/$pid" ]; do
        mem=$(grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} VmRSS /proc/$pid/status | grep --color=auto -o '[0-9]\+' | awk '{print $1/1024}')
        total=$(echo "$mem + $total" | bc)
        name=$(ps -p $pid -o comm=)

        printf "%${space}s%s($pid): %.2f MB\n" '' "$name" "$mem"

        children=$(pgrep -P $pid)

        for child in $children; do
            arr+=("$child" $((space + 2)))
        done
    done

    printf "Total: %.2f MB\n" "$total"
}

if [ ! -z "$VMRSS_MONITOR" ]; then
    while ps -p $1 > /dev/null; do
        print_vmrss $1
        sleep 0.5
    done
fi

print_vmrss $1
