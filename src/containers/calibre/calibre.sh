#!/usr/bin/env bash

# @file calibre.sh
# @brief to install docker calibre


# @description create docker calibre
# link
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_calibre(){

     docker-compose -f "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/docker-compose.yml" up -d

     echo "ctrl+click to open in browser"
     echo "$(get_current_ip):8001"
     return 0
}

# @description remove docker calibre
#
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_docker_calibre() {
    echo "not implemented"
    return 0
}