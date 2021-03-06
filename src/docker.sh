#!/usr/bin/env bash
#
# @file docker.sh
# @brief to install docker docker compose on ubuntu18.04

# import

# shellcheck source=config.sh
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/config.sh"
# shellcheck source=utils.sh
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/utils.sh"

# @description install the docker
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_docker() {
    echo "Install Docker"
    print_line
    # exec_root curl -sSL https://get.docker.com/ | CHANNEL=stable sh > /dev/null
    aptremove docker
    aptremove docker-engine
    aptremove docker.io
    aptremove containerd
    aptremove runc
    aptinstall apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | exec_root apt-key add -
    exec_root apt-key fingerprint 0EBFCD88
    if [[ "$(lsb_release -cs)" == "eoan" ]]; then
        if [[ "$UID" -gt 0 ]]; then
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable" >/dev/null
        else
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable" >/dev/null
        fi
    else
        if [[ "$UID" -gt 0 ]]; then
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null
        else
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null
        fi
    fi

    aptupdate
    aptinstall docker-ce docker-ce-cli containerd.io
    aptclean

    print_line
    return 0
}

# @description install the docker compose
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_docker_compose() {
    echo "Install Docker Compose"
    print_line

    exec_root curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    exec_root chmod +x /usr/local/bin/docker-compose
    #ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    print_line
    return 0
}

# @description install the docker extra utils dry
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_docker_extra() {
    echo "Install Docker Extra"
    print_line

    curl -sSf https://moncho.github.io/dry/dryup.sh | exec_root sh
    exec_root "chmod 755 /usr/local/bin/dry"
    print_line

    return 0
}

# @description prune all the volumes and images
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
prune_containers_volumes_all() {
    echo "Prune all Docker Images and Volumes"
    print_line

    docker image prune -a
    docker system prune

    print_line
    return 0
}

# @description stop all container
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
stop_containers_all() {
    echo "Stop all Docker Containers"
    print_line

    docker container stop "$(docker ps --filter "label=AIS.name" -aq)"

    print_line
    return 0
}

# @description stop all container
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
remove_containers_all() {
    echo "Remove all Docker Containers"
    print_line

    docker rm "$(docker ps --filter "label=AIS.name" -aq)"

    print_line
    return 0
}

# @description this  creates the volumes, services and backup directories. It then assisgns the current user to the ACL to give full read write access
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
udocker_create_default_dir() {
    echo "Create Folder for Docker User"
    print_line

    [ -d /home/udocker/config ] || udocker_create_dir /home/udocker/config
    [ -d /home/udocker/services ] || udocker_create_dir /home/udocker/services
    [ -d /home/udocker/volumes ] || udocker_create_dir /home/udocker/volumes
    [ -d /home/udocker/backups ] || udocker_create_dir /home/udocker/backups
    [ -d /home/udocker/downloads ] || udocker_create_dir /home/udocker/downloads
    [ -d /home/udocker/tvshows ] || udocker_create_dir /home/udocker/tv
    [ -d /home/udocker/movies ] || udocker_create_dir /home/udocker/movies
    [ -d /home/udocker/media ] || udocker_create_dir /home/udocker/media
    [ -d /home/udocker/audio ] || udocker_create_dir /home/udocker/audio
    [ -d /home/udocker/music ] || udocker_create_dir /home/udocker/audio

    print_line
    return 0
}

# @description create docker user and current user in the group and create dir
#
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_user() {
    echo "Create Docker User"
    print_line

    if id -u udocker >/dev/null 2>&1; then
        echo "The user udocker already exist"
    else
        exec_root "adduser --disabled-password --gecos '' udocker"
        read_config_yml udocker_password | exec_root passwd udocker --stdin
        exec_root usermod -aG docker udocker
        add_sudo "udocker"
        udocker_create_default_dir
        echo "export UDOCKER_USERID=\"$(id -u udocker)\"" | tee -a /home/udocker/.bashrc
        echo "export UDOCKER_GROUPID=\"$(id -g udocker)\"" | tee -a /home/udocker/.bashrc
        echo "export TZ=\"$(cat /etc/timezone)\"" | tee -a /home/udocker/.bashrc
        echo "export UDOCKER_ROOT=\"/home/udocker/volumes\"" | tee -a /home/udocker/.bashrc
    fi

    grep -qxF "UDOCKER_USERID=\"$(id -u udocker)\"" /etc/environment || echo "UDOCKER_USERID=\"$(id -u udocker)\"" >>/etc/environment
    grep -qxF "UDOCKER_GROUPID=\"$(id -g udocker)\"" /etc/environment || echo "UDOCKER_GROUPID=\"$(id -g udocker)\"" >>/etc/environment
    grep -qxF "TZ=\"$(cat /etc/timezone)\"" /etc/environment || echo "TZ=\"$(cat /etc/timezone)\"" >>/etc/environment
    grep -qxF "UDOCKER_ROOT=\"/home/udocker/volumes\"" /etc/environment || echo "UDOCKER_ROOT=\"/home/udocker/volumes\"" >>/etc/environment

    print_line
    return 0
}

# @description do as the docker user
#
# @args $1 command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
do_as_udocker_user() {
    if typeset -f "$1" >/dev/null; then
        FUNC="$(declare -f "$1")"
        echo "sudo -u udocker bash -c '$FUNC; $1'"
        sudo -u udocker bash -c "$FUNC; $1"
    else
        local command="$*"
        echo "sudo -u udocker $command"
        sudo -u udocker "$command"
    fi
    return 0
}

# @description create udocker dir
#
# @args $1 directory path
# @exitcode 0 If successfull.
# @exitcode 1 On failure
udocker_create_dir() {
    exec_root mkdir -p "$1"
    exec_root chmod 755 "$1"
    exec_root chown udocker:udocker "$1"
}

# @description check if the port is used
#
# @args $# the backup of all the container names
# @exitcode 0 If successfull.
# @exitcode 1 On failure
create_docker_backup_all() {
    while [[ -n $1 ]]; do
        create_docker_name_backup "$1"
        shift # shift all parameters;
    done
    return 0
}