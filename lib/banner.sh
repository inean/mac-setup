#!/usr/bin/env bash

# how to use it
# printf "${BOLD}%s${RESET}\n" 'BOLD'
# printf "${UNDERLINE}%s${RESET}\n" 'UNDERLINE'
# printf "${ITALIC}%s${RESET}\n" 'ITALIC'
# printf "${UNDERLINE}${ITALIC}%s${RESET}\n" 'Underline ITALIC'

# shellcheck disable=SC2034
ESC=$(printf '\033')
RESET="${ESC}[0m"

BOLD="${ESC}[1m"
FAINT="${ESC}[2m"
ITALIC="${ESC}[3m"
UNDERLINE="${ESC}[4m"
BLINK="${ESC}[5m"
FAST_BLINK="${ESC}[6m"
REVERSE="${ESC}[7m"
CONCEAL="${ESC}[8m"
STRIKE="${ESC}[9m"

GOTHIC="${ESC}[20m"
DOUBLE_UNDERLINE="${ESC}[21m"
NORMAL="${ESC}[22m"
NO_ITALIC="${ESC}[23m"
NO_UNDERLINE="${ESC}[24m"
NO_BLINK="${ESC}[25m"
NO_REVERSE="${ESC}[27m"
NO_CONCEAL="${ESC}[28m"
NO_STRIKE="${ESC}[29m"

BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"
DEFAULT="${ESC}[39m"

BG_BLACK="${ESC}[40m"
BG_RED="${ESC}[41m"
BG_GREEN="${ESC}[42m"
BG_YELLOW="${ESC}[43m"
BG_BLUE="${ESC}[44m"
BG_MAGENTA="${ESC}[45m"
BG_CYAN="${ESC}[46m"
BG_WHITE="${ESC}[47m"
BG_DEFAULT="${ESC}[49m"

# Usage _parse_color "<color_name>"
function _parse_color() {
    case ${2} in
    black)
        color=0
        ;;
    red)
        color=1
        ;;
    green)
        color=2
        ;;
    yellow)
        color=3
        ;;
    blue)
        color=4
        ;;
    magenta)
        color=5
        ;;
    cyan)
        color=6
        ;;
    white)
        color=7
        ;;
    *)
        echo "color is not set"
        exit 1
        ;;
    esac
}

# Usage: banner "my title" "my_color" "*"
function banner {
    local msg="${3} ${1} ${3}"
    local edge; edge=$(echo "${msg}" | sed "s/./${3}/g")
    local color; color=$(_parse_color "${2}")

    tput setaf ${color}
    tput bold
    echo "${edge}"
    echo "${msg}"
    echo "${edge}"
}
# Usage header "my header" "my_color"
function header {
    local color; color=$(_parse_color "${2}")
    tput setaf ${color}
    tput bold
    echo "${1}"
}
