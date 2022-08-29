#shellcheck disable=SC2154,SC2276,SC2288,SC2120
Describe 'os.sh'
  Include "lib/os.sh"

  assert() { :; }
  assert_not_empty() { :; }

  note() { :; }
  header() { :; }
  brew() {
    case "${1:-}" in
      update)
        %= "${1:-}"
        ;;
      shellenv)
        %= "echo ${1:-}"
        ;;
      *)
        command brew "$@"
        ;;
      esac
  }
  curl() {
    case "${2:-}" in
      *Homebrew*)
      ;;
      ifconfig.me)
        %= '8.8.8.8'
      ;;
    *)
      command curl "$@"
      ;;
    esac
  }
  osascript() {
     case "${2:-}" in
      *IPv4*)
        %= '10.10.10.10'
      ;;
      *)
      command osascript "$@"
      ;;
    esac
  }

  Describe '_os_is_mac()'
    not_in_a_mac() { [[ "$(uname)" != "Darwin" ]]; }
    Skip if "Not in a Mac" not_in_a_mac

    Example 'Find if sistem is a Mac'
      BeforeRun
        #shellcheck disable=SC2034
        OS_KERNEL="$(uname)"
      When call _os_is_mac
      The status should eq 0
      The variable OS_KERNEL should eq "Darwin"
      The variable OS_TYPE should eq "macOS"
      The variable OS_PACKAGE_MANAGER should eq "brew"
      The variable OS_INTERNAL_IP should eq "10.10.10.10"
    End
  End

  Describe '_os_is_windows()'
    not_in_windows() { [[ "$(uname)" != "Windows" ]]; }
    Skip if "Not in Windows" not_in_windows

    Example 'Find if sistem is a Windows Machine'
      BeforeRun
        #shellcheck disable=SC2034
        OS_KERNEL="$(uname)"
      When call _os_is_window
      The status should eq 0
      The variable OS_KERNEL should eq "Windows"
      The variable OS_TYPE should eq "Windows"
      The variable OS_PACKAGE_MANAGER should eq "choco"
    End
  End

  Describe '_os_is_linux()'
    not_in_linux() { [[ "$(uname)" != "Linux" ]]; }
    Skip if "Not in Linux" not_in_linux

    Example 'Find if sistem is a Linux Machine'
      BeforeRun
        #shellcheck disable=SC2034
        OS_KERNEL="$(uname)"
      When call _os_is_window
      The status should eq 0
      The variable OS_KERNEL should eq "Linux"
      The variable OS_TYPE should eq "Linux"
    End
  End

  Describe 'os_get_info()'
    hostname() { %= 'hostname'; }
    Example 'Get machine details'
      BeforeRun
        #shellcheck disable=SC2034
        OS_KERNEL="$(uname)"
      When call os_get_info
      The status should eq 0
      The variable OS_HOSTNAME should equal 'hostname'
      The variable OS_PUBLIC_IP should equal '8.8.8.8'
      The variable OS_PACKAGE_MANAGER should equal 'brew'
    End
  End

 Describe 'os_install_package_manager()'
    Example 'Install Package Manager on target machine'
      BeforeRun
        #shellcheck disable=SC2034
        OS_KERNEL="$(uname)"
        os_get_info
      When run os_install_package_manager
      The word 1 of stdout should equal update
      The word 2 of stdout should equal shellenv
      The status should eq 0
    End
  End
End
