#!/usr/bin/env bash
#
# @file config.sh
# @brief file containing the utils  for the project and other

# @description Read YML file from Bash script
# https://gist.github.com/pkuczynski/8665367
# @noargsW
# @exitcode 0 If successfull.
# @exitcode 1 On failure
parse_yml() {
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @ | tr @ '\034')
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
        awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
    }'
}

# @description get value for yml
#
# @args $1 variable path name
# @exitcode 0 If successfull.
# @exitcode 1 On failure
read_config_yml() {
    parse_yml "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/config.yml" | grep "$1" | cut -d '=' -f 2-
    return 0
}

# @description read config file
# https://unix.stackexchange.com/questions/175648/use-config-file-for-my-shell-script
# @arg $1 the config fiel path
# @exitcode 0 If successfull.
# @exitcode 1 On failure
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2-
    return 0
}

# @description get config var from a spefic file
# https://unix.stackexchange.com/questions/175648/use-config-file-for-my-shell-script
# @arg $1 the config file path
# @arg $2 the config file var
# @exitcode 0 If successfull.
# @exitcode 1 On failure
config_get() {
    # shellcheck disable=SC2086
    val="$(config_read_file ${1} ${2})"
    if [ "${val}" = "__UNDEFINED__" ]; then
        # shellcheck disable=SC2086
        val="$(config_read_file config.cfg.defaults ${2})"
    fi
    printf -- "%s" "${val}"
    return 0
}

# @description get config var array into a list ports
# @arg $1 the config file var array
# @exitcode 0 If successfull.
# @exitcode 1 On failure
parse_yml_array_ports() {
    local ARRAY="$(read_config_yml "$1""_ports")"
    local NEW_ARRAY="${ARRAY//\"/}"
    if [[ "$NEW_ARRAY" == *"["*"]"* ]]; then
        local VALUES="$(echo "$NEW_ARRAY" | jq -c '.[]')"
        printf -- "%s\n" "${VALUES}"
        return 0
    else
        return 1
    fi
}

# @description get config var array into a list web
# @arg $1 the config file var array
# @exitcode 0 If successfull.
# @exitcode 1 On failure
parse_yml_array_web() {
    local ARRAY="$(read_config_yml "$1""_web")"
    local NEW_ARRAY="${ARRAY:1:${#ARRAY}-2}"
    local NEW_ARRAY="${NEW_ARRAY:1:${#NEW_ARRAY}-2}"
    local NEW_ARRAY="$(echo "$NEW_ARRAY" | sed -e $'s/,/\\\n/g')"
    local VALUES="$NEW_ARRAY"
    printf -- "%s\n" "${VALUES}"
    return 0
}

# @description generate the container url on the server
# @arg $1 container name
# @exitcode 0 If successfull.
# @exitcode 1 On failure
containers_url() {
    local webport="$(parse_yml_array_web "$1")"
    local domain="$(read_config_yml "domain")"
    printf "${domain//\"/}${webport//\"/}\n"
    return 0
}