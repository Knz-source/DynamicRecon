#!/usr/bin/env bash
#==================
#~~~~~~COLORS~~~~~~
#==================
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

#======= ARGS ========
SCRIPT=$0
targetlist=$1
#=====================
__Banner__(){
    echo
    echo -e "${YELLOW}################################################################################"
    echo -e "${YELLOW}#                                                                              #"
    echo -e "${YELLOW}#                         Created by kuro & knz                                #"
    echo -e "${YELLOW}#                             Dynamic Recon                                    #"
    echo -e "${YELLOW}#                                  V0.1                                        #"
    echo -e "${YELLOW}#                           Usage: ./script.sh                                 #"
    echo -e "${YELLOW}################################################################################"
    echo
    echo -e "${GREEN}#You're able to load list using ./script list here (absolute or relative path) :D"
}

__PrintUsage__(){
    printf "usage: ${GREEN}%s${RESET} ${BLUE}[${RESET}target list file${BLUE}]${RESET}\n" "$SCRIPT"
    printf "or stdin a target or a list of targets\nexample: cat targetlist | %s\n" "$SCRIPT" 
}
__GetTargets__(){
    # read all lines from stdin
    if [ -p /dev/stdin ]; then read -d '' TARGET; return; fi

    # checks if no args were given, then prompt for a target
    if [ -z "$targetlist" ]; then printf "${RESET}${BOLD}Type your target: "; read TARGET; return; fi
    
    # checks if filename exists, then loads it into TARGET
    if [ -f "$targetlist" ]; then
        read -d '' TARGET < "$targetlist"
    else
        printf "${RED}%s file not found.${RESET}\n" "$targetlist"
        __PrintUsage__
        exit 1
    fi
    
    # if there's no input then exits the script
    if [ -z "$TARGET" ]; then printf "${YELLOW}${BOLD}No target given.\n${RESET}"; __PrintUsage__; exit; fi
}

__ZoneTranser__(){
    # get available nameservers
    local RESULT=$(host -t ns "$1" | while read i; do echo $i; sleep 0.8; done)

    # if not found then exits the script *WIP
    if (echo "${RESULT[@]}" | grep -q 'NXDOMAIN')
    then
        printf "${RED}${BOLD}Target not found.\n"
        return
    fi
    
    # set internal field separator to <newline>
    IFS=$'\n'

    # prints zone transfer outputs
    for ns in ${RESULT[@]}
    do
        nameserver=$(echo ${ns##* } | sed 's/\.$//g')
        printf "${RESET}${BOLD}::::::::::::::: TRYING DNS ZONE TRANSFER ON %s :::::::::::::::\n${RESET}" "$1"
        printf "${GREEN}${BOLD}======= %s START =======${RESET}\n" "$nameserver"
        host -l -a $1 $nameserver
	sleep 0.8
        printf "${YELLOW}${BOLD}======= %s  END  =======${RESET}\n\n" "$nameserver"
    done
}

__RunList__()  {
    # run fisrt argument for each other argument, e.g. an array
    for i in ${@:2}; do $1 $i; done
}
__Banner__
__GetTargets__
__RunList__ __ZoneTranser__ ${TARGET[@]}

