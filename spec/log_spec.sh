#shellcheck disable=SC2154,SC2276,SC2288
Describe 'log.sh'
  Include "lib/log.sh"

  __banner() {
      local start=1
      local end=${1:-80}
      local str="${3:-=}"

      local result=""
      for _ in $(seq $start "$((end + 4))"); do
        result="${result}${str}";
      done
      __log "$result" "$2"
    }
    __log() {
      if [[ "$2" == "" ]]; then
        %= "$1"
        return
      fi
      %= "${SHELLSPEC_ESC}[${2}m${1}${SHELLSPEC_ESC}[0m"
    }
    __pending_method() {
        not_yet_implemented
      return $?
    }
  Describe '_log()'
    Parameters
      "message"                        ""           ""
      "message without return line"    "-n"         ""
      "message yellow"                 "-c yellow"  "33"
      "message green"                  "-c green"   "32"
      "bessage with background yellow" "-k yellow"  "43"
      "message with background green"  "-k green"   "42"
      "message underlined"             "-u"         "4"
      "message blinking"               "-l"         "5"
    End
    Example "Show log ${1}"
      #shellcheck disable=SC2086
      When call _log "${1}" ${2}
      The stdout should eq "$(__log "$1" "$3")"
    End
  End
  Describe '_log()'
    # log function format is emphasis, foreground color, background color
    Parameters
      "message in red and black bacground"            "-c red -k black"     "31;40"
      "message in red, background black and italic"   "-c red -k black -i"  "3;31;40"
      "messsage with background green and underlined" "-k green -u"         "4;42"
    End
    Example "Show log $1"
      #shellcheck disable=SC2086
      When call _log "${1}" ${2}
      The stdout should eq "$(__log "$1" "$3")"
    End
  End
  Describe 'banner()'
    Parameters
      "Color is Yellow" "yellow" "*" "33"
    End
    Example 'Show banner "Color is Yellow" in yellow color'
      When call banner "$1" "$2" "$3"
      The lines of stdout should eq 3
      The line 1 of stdout should eq "$(__banner "${#1}" "$4" "$3")"
    End
  End
  Describe 'header()'
    Parameters
      "Color is Yellow" "yellow" "*" "4;33"
    End
    Example 'Show header "Color is Yellow" in yellow color'
      When call header "$1" "$2"
      The lines of stdout should eq 1
      The stdout should eq "$(__log "$1" "$4")"
    End
  End
  Describe 'info()'
    Example 'Show info message "This is an info message"'
      BeforeRun 'LOG_VERBOSE=2'
      When run info "This is an info message"
      The line 1 of stdout should eq "$(__log "➜ This is an info message" "2")"
    End
    It 'Dont show anything if verbose is set to Quiet LOG_VERBOSE=0'
      When call info "this is an info message"
      The variable LOG_VERBOSE should equal 1
      The stdout should equal ""
    End
  End
  Describe 'error()'
    Example 'Show error message "This is an error message"'
      When run error "This is an error message"
      The line 1 of stdout should eq "$(__log "✖ This is an error message" "2;31")"
      The variable LOG_VERBOSE should equal 1
      The status should be failure
    End
    It 'Dont show anything if verbose is set to Quiet LOG_VERBOSE=0'
      BeforeRun 'LOG_VERBOSE=0'
      When run error "this is an error message"
      The status should be failure
    End
  End
  Describe "not_yet_implemented()"
    Example 'Embed "not_yet_implemented" inside a function'
      When run __pending_method
      The line 1 of stdout should eq "$(__log "☢ __pending_method" "1;31")"
      The status should eq 1
    End
  End
End
