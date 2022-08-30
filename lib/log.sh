# shellcheck disable=SC2034

# public variables

LOG_VERBOSE="${LOG_VERBOSE:=1}" # Verbose counter (aka -vvv counter is 3)

escape="\033["
reset=""

# Text color
tc_default="39"
tc_black="30"
tc_red="31"
tc_green="32"
tc_yellow="33"
tc_blue="34"
tc_purple="35"
tc_cyan="36"
tc_white="37"
tc_bright_red="91"
tc_bright_green="92"
tc_bright_yellow="93"
tc_bright_blue="94"
tc_bright_purple="95"
tc_bright_cyan="96"
tc_bright_white="97"

# Text background color
bg_default="49"
bg_black="40"
bg_red="41"
bg_green="42"
bg_yellow="43"
bg_blue="44"
bg_purple="45"
bg_cyan="46"
bg_white="47"
bg_bright_black="100"
bg_bright_red="101"
bg_bright_green="102"
bg_bright_yellow="103"
bg_bright_blue="104"
bg_bright_purple="105"
bg_bright_cyan="106"
bg_bright_white="107"

# Emphasis
emphasis_default="0"
emphasis_bold="1"
emphasis_dimming="2"
emphasis_italics="3"
emphasis_underline="4"
emphasis_blink="5"
emphasis_reverse="7"

# Solve var indirect expansion in a portable way
function __expand() {
  local ref="$1_$2"
  if [ "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=2296
    printf "%q" "${(P)ref}"
  else
    printf "%q" "${!ref}"
  fi
}
function __caller_func() {
  currentShell=$(ps -p $$ | awk "NR==2" | awk '{ print $4 }' | tr -d '-')
  if [[ ${currentShell##*/} == 'zsh' ]]; then
    printf "%s" "${funcstack[3]}"
  fi
  if [[ ${currentShell##*/} == 'bash' ]]; then
    printf "%s" "${FUNCNAME[2]}"
  fi
  # try shomething so script fails if unset is active
    printf "%s" "${FUNCNAME[2]}"
}

# log [message] [-biuln] [-c color] [-k background-color]
# options
#   -o        text is normal
#   -d        text is dimming
#   -b        text is bold
#   -i        text is italic
#   -u        text is underlined
#   -l        text blinks
#   -r          reverse formatting
#   -n        do NOT add new line ("\n") after message
#   -c  color
#         format text with specified named color. See below for available colors.
#   -k  background-color
#         format text with background-color of specified name. See below for available colors.
function _log() {
  local output=""
  typeset -a codes=()
  typeset -a formatting=()

  # check if message
  test -n "$1" || {
    echo
    return
  }
  # Extract message
  message=$1
  shift
  # parse options
  color=""
  background_color=""
  line_break="\n"

  while getopts ":c:k:obdiunlr" option; do
    case $option in
    c)
      color="${OPTARG}"
      ;;
    k)
      background_color="${OPTARG}"
      ;;
    o)
      formatting+=("default")
      ;;
    b)
      formatting+=("bold")
      ;;
    d)
      formatting+=("dimming")
      ;;
    i)
      formatting+=("italics")
      ;;
    u)
      formatting+=("underline")
      ;;
    l)
      formatting+=("blink")
      ;;
    r)
      formatting+=("reverse")
      ;;
    n)
      line_break=""
      ;;
    *)
      exit 1
      ;;
    esac
  done
  # build output
  for format in "${formatting[@]}"; do
    codes+=("$(__expand "emphasis" "$format")")
  done

  if [[ "$color" != "" ]]; then
    codes+=("$(__expand "tc" "$color")")
  fi
  if [[ "$background_color" != "" ]]; then
    codes+=("$(__expand "bg" "$background_color")")
  fi
  if [[ "${#codes[@]}" -gt "0" ]]; then
    reset="${escape}0m"
    for i in "${codes[@]}"; do
      output="${output}${i};"
    done
    # Remove last ';' and add 'm'
    output="${escape}${output%";"}m"
  fi
  # return format
  printf "${output}%s${reset}${line_break}" "$message"
}
# Usage: banner "my title" "my_color" "*"
function banner {
  local msge="${3} ${1} ${3}"
  local edge=""
  # shellcheck disable=SC2001
  edge=$(echo "${msge}" | sed "s/./${3}/g")
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "$edge" -c "$2"
    _log "$msge" -c "$2"
    _log "$edge" -c "$2"
  fi
}
# Usage header "my header" "my_color"
function header {
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "$1" -c "$2" -u
  fi
}
function debug() {   # output when -vvv is expressed
  if [[ ${LOG_VERBOSE} -gt 2 ]]; then
    _log "🐛 $*" -d
  fi
}
function info() {   # output on every run when -vv is expressed
  if [[ ${LOG_VERBOSE} -gt 1 ]]; then
    _log "➜ $*" -d
  fi
}
function success() {
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "✔ $*" -c green -d
  fi
}
function warning() {  # &#9758; or &#9755;
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "☞ $*" -c yellow -d
  fi
}
function error() {    # &#9747;
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "✖ $*" -c red -d
  fi
  return 1
}
function fatal() {  # Skull: &#9760;  # Star: &starf; &#9733; U+02606  # Toxic: &#9762;
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    _log "☢ $*" -c red -b
  fi
  return 1
}
function abort() {
   # Function: Exit with error.
  if [[ ${LOG_VERBOSE} -gt 0 ]]; then
    fatal "${*:-"Exiting abnormally"}"
  fi
  exit 1
}
function not_yet_implemented() {
  abort "$(__caller_func "Not yet implemented")"
}
function assert_equal() {
  [[ $# -eq 2 ]]    || abort "$(__caller_func "2 Args expected")"
  [[ "$1" = "$2" ]] || abort "$(__caller_func "\'$1\' Differs from \'$2\'")"
}
function assert_not_empty() {
  [[ $# -eq 1 ]]    || abort "$(__caller_func "Missing or empty arg")"
}
function assert_function_exists() {
  [[ $(declare -f -F "$1" >/dev/null) ]] || abort "$1 function is undefined"
}
