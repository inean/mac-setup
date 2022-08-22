#shellcheck shell=sh
# shellcheck disable=SC2154

Describe 'banner.sh'

  Include lib/banner.sh

  Describe 'Check message function. Color testing is mocked'
  # Stub to prevent banner to use colors
  tput() { :; }

  Before 'prepare'
  prepare() {
    msg='Hello World'
    color='red'
    decorator='*'
  }
  repeat() {
    # Spaces used by banner test
    local spacers=4

    local start=1
    local end=${1:-80}
    local str="${2:-=}"
    for _ in $(seq $start "$((end + spacers))"); do echo "${str}\c"; done
  }
    It 'Show a banner'
      When call banner "$msg" "$color" "$decorator"
      The lines of stdout should eq 3
      The line 1 of output should eq "$(repeat "${#msg}" "$decorator")"
    End
    It 'Show a simple banner with no decorators (A header)'
      When call header "$msg" "$color" "$decorator"
      The lines of stdout should eq 1
      The line 1 of output should eq "$msg"
    End
  End
End
