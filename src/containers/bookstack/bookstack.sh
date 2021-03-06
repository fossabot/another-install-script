#!/usr/bin/env bash

# @file bookstack.sh
# @brief to install docker bookstack

# @description create docker bookstack
# link
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_bookstack() {

    docker-compose -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/docker-compose.yml" up -d

    echo "ctrl+click to open in browser"
    echo "$(get_current_ip):6875"

    return 0
}

# @description remove docker bookstack
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_docker_bookstack() {
    echo "not implemented"
    return 0
}
