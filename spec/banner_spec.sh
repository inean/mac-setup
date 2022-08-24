#shellcheck disable=SC2154,SC2276

Describe 'banner.sh'
  Include "lib/banner.sh"

  Describe '_log()'
    Parameters
      "Color is Default" ""        "*" ""
      "Color is Cyan"    "cyan"    "*" "36"
      "Color is Yellow"  "yellow"  "*" "33"
    End

    __banner() {
      local start=1
      local end=${1:-80}
      local str="${3:-=}"

      local result=""
      for _ in $(seq $start "$((end + 4))"); do
        result="${result}${str}";
      done
      __print "$result" "$2"
    }
    __print() {
      if [[ "$2" == "" ]]; then
        %= "$1"
      fi
      if [[ "$2" != "" ]] && [[ "$3" != "" ]]; then
        %= "${SHELLSPEC_ESC}[${2};${3}m${1}${SHELLSPEC_ESC}[0m"
      fi
      if [[ "$2" != "" ]] || [[ "$3" != "" ]]; then
        local color="${2:$3}"
        %= "${SHELLSPEC_ESC}[${color}m${1}${SHELLSPEC_ESC}[0m"
      fi
    }

    It 'Show a banner'
      When call banner "$1" "$2" "$3"
      The lines of stdout should eq 3
      The line 1 of stdout should eq "$(__banner "${#1}" "$4" "$3")"
    End
    It 'Show a header'
      When call header "$1" "$2"
      The lines of stdout should eq 1
      The line 1 of stdout should eq "$(__print "$1" "$4")"
    End
  End
End
