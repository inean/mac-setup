# shellcheck disable=SC2034

# Obtain and show information about the operating system in use to define which package manager to use
# See https://wilsonmar.github.io/mac-setup/#OSDetect

# public variables

LOG_VERBOSE="${LOG_VERBOSE:=1}" # Verbose counter (aka -vvv counter is 3)

OS_KERNEL="$(uname)"
OS_TYPE=""
OS_ARCH=""
OS_DETAILS=""
OS_PACKAGE_MANAGER=""
OS_HOSTNAME=""
OS_PUBLIC_IP=""
OS_INTERNAL_IP=""

# it's on a Mac
function _os_is_mac() {
  if [[ "${OS_KERNEL}" = "Darwin" ]]; then
    OS_TYPE="macOS"
    OS_PACKAGE_MANAGER="brew"
    OS_ARCH="$(uname -m)"
    OS_INTERNAL_IP=$(osascript -e "IPv4 address of (system info)")
    note "Apple macOS sw_vers = $(sw_vers -productVersion) / uname -r = $(uname -r)"  # example: 10.15.1 / 21.4.0
    return 0
  fi
  return 1
}
# It's windows
function _os_is_windows() {
    # TODO: Chocolatey or https://github.com/lukesampson/scoop
  if [[ "${OS_KERNEL}" = "Windows" ]]; then
    OS_TYPE="Windows"   # replace value!
    OS_PACKAGE_MANAGER="choco"
    OS_INTERNAL_IP=$(ipconfig getifaddr en0)
    return 0
  fi
  return 1
}
# It's Linux
function _os_is_linux() {
  not_yet_implemented
}

# Install installers (brew, apt-get), depending on operating system
function _os_macos_install_devtools() {
  assert_function_exists "header"
  if [[ ! $(xcode-select -p 1>/dev/null) ]]; then
    # TODO: Specify install of CommandLineTools or Xcode.app:
    header "Installing Apple's xcode CommandLineTools (this takes a while) ..."
    xcode-select --install
  fi
  # Verify:
  # Ensure cc, gcc, make, and Ruby Development Headers are available:
  header "Confirming xcrun utility is installed ..."
  if [[ ! $(command -v xcrun 1>/dev/null) ]]; then  # installed:
    abort "xcrun command not available!"
  fi
  assert_function_exists "note"
  note "$( gcc --version )"  #  note "$(  cc --version )"
  note "$( xcode-select --version )"  # Example output: xcode-select version 2395 (as of 23APR2022).
}

_os_macos_install_brew() {

  assert "$OS_TYPE" "macOS"
  local brew_head="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

   # brew not found:
  if ! [[ $(command -v brew) ]]; then
    # Download from git and install
    eval "$(curl -fsSL $brew_head)"
  fi
  assert_not_empty "$(command -v brew)"

  header "Updating brew itself ..."
  brew update

  eval "$(brew shellenv)"
  note "Brew \'$(brew --version)\' found at $(brew --prefix)"
  }

os_get_info() {
  [[ -n ${OS_TYPE} ]] || _os_is_mac
  [[ -n ${OS_TYPE} ]] || _os_is_windows
  [[ -n ${OS_TYPE} ]] || _os_is_linux

  assert_not_empty "${OS_INTERNAL_IP}"
  note "OS_TYPE=$OS_TYPE using $OS_PACKAGE_MANAGER"

  OS_HOSTNAME="$(hostname)"
  OS_PUBLIC_IP=$(curl -s ifconfig.me)
  note "on hostname=$OS_HOSTNAME at PUBLIC_IP=$OS_PUBLIC_IP, internal $OS_INTERNAL_IP"
}
function os_install_package_manager() {
  assert_not_empty $OS_PACKAGE_MANAGER

  note "OS_TYPE=$OS_TYPE OS_ARCH=$OS_ARCH"
  if [ "${OS_PACKAGE_MANAGER}" = "brew" ]; then
    _os_macos_install_brew
    return 0
  fi
  # Add support to other package managers
  not_yet_implemented
}
