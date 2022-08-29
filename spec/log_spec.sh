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
    __missing_method() {
      not_yet_implemented
      return $?
    }
  Describe '_log()'
    Parameters
      "Default"              ""           ""
      "Default without line" "-n"         ""
      "Color is Yellow"      "-c yellow"  "33"
      "Color is Green"       "-c green"   "32"
      "Background is Yellow" "-k yellow"  "43"
      "Background is Green"  "-k green"   "42"
      "Format is underline"  "-u"         "4"
      "Format is Blink"      "-l"         "5"
    End
    It 'Call _log() with basic arguments'
      #shellcheck disable=SC2086
      When call _log "${1}" ${2}
      The stdout should eq "$(__log "$1" "$3")"
    End
  End
  Describe '_log()'
    # log function format is emphasis, foreground color, background color
    Parameters
      "Color 'red', Bg 'Black', 'No Emphasis'."  "-c red -k black"     "31;40"
      "Color 'red', Bg 'Black', 'Italic'."       "-c red -k black -i"  "3;31;40"
      "Bg 'Green', 'Underlined'."                "-k green -u"         "4;42"
    End
    It 'Call _log() with variable arguments'
      #shellcheck disable=SC2086
      When call _log "${1}" ${2}
      The stdout should eq "$(__log "$1" "$3")"
    End
  End
  Describe 'banner()'
    Parameters
      "Color is Yellow" "yellow" "*" "33"
    End
    It 'Shows a banner'
      When call banner "$1" "$2" "$3"
      The lines of stdout should eq 3
      The line 1 of stdout should eq "$(__banner "${#1}" "$4" "$3")"
    End
  End
  Describe 'header()'
    Parameters
      "Color is Yellow" "yellow" "*" "4;33"
    End
    It 'Shows a header'
      When call header "$1" "$2"
      The lines of stdout should eq 1
      The stdout should eq "$(__log "$1" "$4")"
    End
  End
  Describe 'info()'
    It 'Shows an info message'
      BeforeRun 'LOG_VERBOSE=2'
      When run info "this is an info message"
      The line 1 of stdout should eq "$(__log "➜ this is an info message" "2")"
    End
    It 'Dont show anything if verbose is set to Quiet LOG_VERBOSE=0'
      When call info "this is an info message"
      The variable LOG_VERBOSE should equal 1
      The stdout should equal ""
    End
  End
  Describe 'error()'
    It 'Dont show anything if verbose is set to Quiet LOG_VERBOSE=0'
      BeforeRun 'LOG_VERBOSE=0'
      When run error "this is an error message"
      The status should be failure
    End
    It 'Shows an error'
      When run error "this is an error message"
      The line 1 of stdout should eq "$(__log "✖ this is an error message" "2;31")"
      The variable LOG_VERBOSE should equal 1
      The status should be failure
    End
  End
  Describe "Developer errors"
    It 'Not yet implemented'
      When run __missing_method
      The line 1 of stdout should eq "$(__log "☢ __missing_method" "1;31")"
      The status should eq 1
    End
  End
End
