#!/usr/bin/env bash

# @file glances.sh
# @brief to install docker glances

# @description create docker glances
# not implemented yet
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_glances() {
    docker-compose -f "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/docker-compose.yml" up -d

    return 0
}

# @description remove docker glances
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_docker_glances() {
    echo "not implemented"
    return 0
}