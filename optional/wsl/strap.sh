#!/bin/bash
#/ Usage: bin/strap.sh [--debug]
#/ Install development dependencies on Linux.
#/ Based on strap for macOS from Mike McQuaid
set -e

[[ "$1" = "--debug" || -o xtrace ]] && STRAP_DEBUG="1"
STRAP_SUCCESS=""

sudo_askpass() {
  if [ -n "$SUDO_ASKPASS" ]; then
    sudo --askpass "$@"
  else
    sudo "$@"
  fi
}

cleanup() {
  set +e
  sudo_askpass rm -rf "$CLT_PLACEHOLDER" "$SUDO_ASKPASS" "$SUDO_ASKPASS_DIR"
  sudo --reset-timestamp
  if [ -z "$STRAP_SUCCESS" ]; then
    if [ -n "$STRAP_STEP" ]; then
      echo "!!! $STRAP_STEP FAILED" >&2
    else
      echo "!!! FAILED" >&2
    fi
    if [ -z "$STRAP_DEBUG" ]; then
      echo "!!! Run '$0 --debug' for debugging output." >&2
      echo "!!! If you're stuck: file an issue with debugging output at:" >&2
      echo "!!!   $STRAP_ISSUES_URL" >&2
    fi
  fi
}

trap "cleanup" EXIT

if [ -n "$STRAP_DEBUG" ]; then
  set -x
else
  STRAP_QUIET_FLAG="-q"
  Q="$STRAP_QUIET_FLAG"
fi

STDIN_FILE_DESCRIPTOR="0"
[ -t "$STDIN_FILE_DESCRIPTOR" ] && STRAP_INTERACTIVE="1"

# Check for LSB
if [ ! -x "$(command -v lsb_release)" ]; then
  if [ -x "$(command -v dnf)" ]; then
    sudo_askpass dnf -y install redhat-lsb-core
  elif [ -x "$(command -v pacman)" ]; then
    sudo_askpass pacman -S lsb-release
  fi
fi

# Set by web/app.rb
# STRAP_GIT_NAME=
# STRAP_GIT_EMAIL=
# STRAP_GITHUB_USER=
# STRAP_GITHUB_TOKEN=
# CUSTOM_HOMEBREW_TAP=
# CUSTOM_BREW_COMMAND=
STRAP_ISSUES_URL='https://github.com/maxfierke/strap-linux/issues/new'
STRAP_DISTRO="$(lsb_release -is)"

if [ "$STRAP_DISTRO" == "Ubuntu" ] || [ "$STRAP_DISTRO" == "Debian" ]; then
  STRAP_DISTRO_FAMILY="Debian"
elif [ "$STRAP_DISTRO" == "RedHat" ] || [ "$STRAP_DISTRO" == "RHEL" ] || [ "$STRAP_DISTRO" == "CentOS" ]; then
  STRAP_DISTRO_FAMILY="RHEL"
elif [ "$STRAP_DISTRO" == "Fedora" ]; then
  STRAP_DISTRO_FAMILY="Fedora"
elif [ "$STRAP_DISTRO" == "Arch" ] || [ "$STRAP_DISTRO" == "ManjaroLinux" ]; then
  STRAP_DISTRO_FAMILY="Arch"
else
  STRAP_DISTRO_FAMILY="Unknown"
fi

uname -a | grep -q "WSL" && STRAP_WSL=true

echo "Running in WSL: $STRAP_WSL"

# We want to always prompt for sudo password at least once rather than doing
# root stuff unexpectedly.
sudo --reset-timestamp

# functions for turning off debug for use when handling the user password
clear_debug() {
  set +x
}

reset_debug() {
  if [ -n "$STRAP_DEBUG" ]; then
    set -x
  fi
}

# Initialise (or reinitialise) sudo to save unhelpful prompts later.
sudo_init() {
  if [ -z "$STRAP_INTERACTIVE" ]; then
    return
  fi

  local SUDO_PASSWORD SUDO_PASSWORD_SCRIPT

  if ! sudo --validate --non-interactive &>/dev/null; then
    while true; do
      read -rsp "--> Enter your password (for sudo access):" SUDO_PASSWORD
      echo
      if sudo --validate --stdin 2>/dev/null <<<"$SUDO_PASSWORD"; then
        break
      fi

      unset SUDO_PASSWORD
      echo "!!! Wrong password!" >&2
    done

    clear_debug
    SUDO_PASSWORD_SCRIPT="$(cat <<BASH
#!/bin/bash
echo "$SUDO_PASSWORD"
BASH
)"
    unset SUDO_PASSWORD
    SUDO_ASKPASS_DIR="$(mktemp -d)"
    SUDO_ASKPASS="$(mktemp "$SUDO_ASKPASS_DIR"/strap-askpass-XXXXXXXX)"
    chmod 700 "$SUDO_ASKPASS_DIR" "$SUDO_ASKPASS"
    bash -c "cat > '$SUDO_ASKPASS'" <<<"$SUDO_PASSWORD_SCRIPT"
    unset SUDO_PASSWORD_SCRIPT
    reset_debug

    export SUDO_ASKPASS
  fi
}

sudo_refresh() {
  clear_debug
  if [ -n "$SUDO_ASKPASS" ]; then
    sudo --askpass --validate
  else
    sudo_init
  fi
  reset_debug
}

abort() { STRAP_STEP="";   echo "!!! $*" >&2; exit 1; }
log()   { STRAP_STEP="$*"; sudo_refresh; echo "--> $*"; }
logn()  { STRAP_STEP="$*"; sudo_refresh; printf -- "--> %s " "$*"; }
logk()  { STRAP_STEP="";   echo "OK"; }
escape() {
  printf '%s' "${1//\'/\'}"
}

# Given a list of scripts in the dotfiles repo, run the first one that exists
run_dotfile_scripts() {
  if [ -d ~/.dotfiles ]; then
    (
      cd ~/.dotfiles
      for i in "$@"; do
        if [ -f "$i" ] && [ -x "$i" ]; then
          log "Running dotfiles $i:"
          if [ -z "$STRAP_DEBUG" ]; then
            "$i" 2>/dev/null
          else
            "$i"
          fi
          break
        fi
      done
    )
  fi
}

check_if_line_exists()
{
  log "Checking for: $LINE_TO_ADD"
  # grep wont care if one or both files dont exist.
  grep -qsFx "$LINE_TO_ADD" ~/.profile ~/.bash_profile ~/.bashrc
}

add_line_to_profile()
{
  profile=~/.bashrc
  [ -w "$profile" ] || profile=~/.profile
  [ -w "$profile" ] || profile=~/.bash_profile
  log "Adding $LINE_TO_ADD to $profiles" 
  printf "%s\n" "$LINE_TO_ADD" >> "$profile"
  source $profile
}

[ "$USER" = "root" ] && abort "Run Strap as yourself, not root."

if [ -z "$STRAP_CI" ]; then
  if [ "$STRAP_DISTRO_FAMILY" == "Debian" ]; then
    STRAP_SUDOER_GROUP="sudo"
  elif [ "$STRAP_DISTRO_FAMILY" == "RHEL" ] || [ "$STRAP_DISTRO_FAMILY" == "Fedora" ] || [ "$STRAP_DISTRO_FAMILY" == "Arch" ]; then
    STRAP_SUDOER_GROUP="wheel"
  else
    logn "Unknown distro, assuming 'wheel' is the sudoers group."
    STRAP_SUDOER_GROUP="wheel"
  fi

  groups | grep $Q -E "\b($STRAP_SUDOER_GROUP)\b" || abort "Add $USER to the $STRAP_SUDOER_GROUP group."
fi

# Prevent sleeping during script execution, as long as the machine is on AC power
# TODO: Install caffeine
# TODO: Rewrite the following in terms of caffeine
# caffeinate -s -w $$ &

# Install the development tools
if [ "$STRAP_DISTRO_FAMILY" == "Debian" ]; then
  log "Installing build-essential and other development tools:"
  sudo_askpass apt-get -y install build-essential curl file git zlib1g-dev \
    libssl-dev libbz2-dev libreadline-dev xz-utils libffi-dev liblzma-dev
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "RHEL" ]; then
  log "Installing Development Tools group and other development dependencies"
  sudo_askpass yum -y groupinstall 'Development Tools'
  sudo_askpass yum -y install curl file git zlib-devel xz-devel bzip2-devel \
    readline-devel sqlite-devel openssl-devel libffi-devel
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "Fedora" ]; then
  log "Installing Development Tools group and other development dependencies"
  sudo_askpass dnf -y group install 'Development Tools'
  sudo_askpass dnf -y install curl file git libxcrypt-compat zlib-devel xz-devel \
    bzip2-devel readline-devel sqlite-devel openssl-devel libffi-devel libxml2-devel
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "Arch" ]; then
  log "Installing base-devel and other development tools:"
  sudo_askpass pacman -Sy --noconfirm --needed base-devel bzip2 curl file git \
    libffi libxcrypt-compat openssl readline xz zlib
  logk
else
  logn "Using unsupported distro. Can't install development tools"
  logn "Continuing onwards, but this may fail if required tools are missing."
fi

# Setup Git configuration.
logn "Configuring Git:"
if [ -n "$STRAP_GIT_NAME" ] && ! git config user.name >/dev/null; then
  git config --global user.name "$STRAP_GIT_NAME"
fi

if [ -n "$STRAP_GIT_EMAIL" ] && ! git config user.email >/dev/null; then
  git config --global user.email "$STRAP_GIT_EMAIL"
fi

if [ -n "$STRAP_GITHUB_USER" ] && [ "$(git config github.user)" != "$STRAP_GITHUB_USER" ]; then
  git config --global github.user "$STRAP_GITHUB_USER"
fi

# Squelch git 2.x warning message when pushing
if ! git config push.default >/dev/null; then
  git config --global push.default simple
fi
logk

# Setup Homebrew directory and permissions.
logn "Installing Homebrew:"
HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
[ -n "$HOMEBREW_PREFIX" ] || HOMEBREW_PREFIX="/usr/local/linuxbrew"
[ -d "$HOMEBREW_PREFIX" ] || sudo_askpass mkdir -p "$HOMEBREW_PREFIX"
(
  cd "$HOMEBREW_PREFIX"
  sudo_askpass mkdir -p               Cellar Frameworks bin etc include lib opt sbin share var
  sudo_askpass chown -R "$USER:$STRAP_SUDOER_GROUP" Cellar Frameworks bin etc include lib opt sbin share var
)

HOMEBREW_REPOSITORY="$(brew --repository 2>/dev/null || true)"
[ -n "$HOMEBREW_REPOSITORY" ] || HOMEBREW_REPOSITORY="/usr/local/linuxbrew/Homebrew"
[ -d "$HOMEBREW_REPOSITORY" ] || sudo_askpass mkdir -p "$HOMEBREW_REPOSITORY"
sudo_askpass chown -R "$USER:$STRAP_SUDOER_GROUP" "$HOMEBREW_REPOSITORY"

if [ "$HOMEBREW_PREFIX" != "$HOMEBREW_REPOSITORY" ]
then
  ln -sf "$HOMEBREW_REPOSITORY/bin/brew" "$HOMEBREW_PREFIX/bin/brew"
fi

# Download Homebrew.
export GIT_DIR="$HOMEBREW_REPOSITORY/.git" GIT_WORK_TREE="$HOMEBREW_REPOSITORY"
git init $Q
git config remote.origin.url "https://github.com/Homebrew/brew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch $Q --tags --force
git reset $Q --hard origin/master
unset GIT_DIR GIT_WORK_TREE
logk

# Update Homebrew.
export PATH=$PATH:${HOMEBREW_PREFIX}/bin
LINE_TO_ADD="export PATH=\$PATH:${HOMEBREW_PREFIX}/bin"
check_if_line_exists || add_line_to_profile

log "Updating Homebrew:"
brew update $Q
logk

# Check and install any remaining software updates.
logn "Checking for software updates:"

if [ -n "$STRAP_CI" ]; then
  echo "Skipping software updates for CI"
elif [ "$STRAP_DISTRO_FAMILY" == "Debian" ]; then
  sudo_askpass apt-get update

  log "Installing software updates:"
  sudo_askpass apt-get dist-upgrade -y
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "RHEL" ]; then
  sudo_askpass yum check-update || [ $? -eq 100 ]

  log "Installing software updates:"
  sudo_askpass yum update -y
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "Fedora" ]; then
  sudo_askpass dnf check-update || [ $? -eq 100 ]

  log "Installing software updates:"
  sudo_askpass dnf update -y
  logk
elif [ "$STRAP_DISTRO_FAMILY" == "Arch" ]; then
  log "Installing software updates:"
  sudo_askpass pacman -Syu --noconfirm
  logk
else
  log "Unknown distro, can't check for updates. Skipping."
fi

if [ "$STRAP_DISTRO_FAMILY" == "Debian" ]; then

  if [ $STRAP_WSL ]; then
    echo "Skipping configuring AppArmor in WSL"
  elif [ -n "$STRAP_CI" ]; then
    echo "Skipping configuring AppArmor in CI"
  else
    # Setup AppArmor and auditd
    sudo_askpass apt-get install -y apparmor-profiles apparmor-utils

    log "Configuring apparmor:"
    sudo_askpass aa-enforce /etc/apparmor.d/usr.bin.evince
    sudo_askpass aa-enforce /etc/apparmor.d/usr.bin.firefox
    sudo_askpass aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
    sudo_askpass aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
    sudo_askpass aa-enforce /etc/apparmor.d/bin.ping
    sudo_askpass aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd

    [ -f "/etc/apparmor.d/usr.bin.chromium-browser" ] && sudo_askpass aa-enforce /etc/apparmor.d/usr.bin.chromium-browser

    logk
  fi

  # Setup auto-updates for APT
  logn "Configuring automatic updates:"
  EXISTS=$(grep "APT::Periodic::Update-Package-Lists \"1\"" /etc/apt/apt.conf.d/20auto-upgrades || true)
  if [ -z "$EXISTS" ]; then
    echo "APT::Periodic::Update-Package-Lists \"1\";" | sudo_askpass tee /etc/apt/apt.conf.d/20auto-upgrades
  fi

  EXISTS=$(grep "APT::Periodic::Unattended-Upgrade \"1\"" /etc/apt/apt.conf.d/20auto-upgrades || true)
  if [ -z "$EXISTS" ]; then
    echo "APT::Periodic::Unattended-Upgrade \"1\";" | sudo_askpass tee /etc/apt/apt.conf.d/20auto-upgrades
  fi

  EXISTS=$(grep "APT::Periodic::AutocleanInterval \"7\"" /etc/apt/apt.conf.d/10periodic || true)
  if [ -z "$EXISTS" ]; then
    echo "APT::Periodic::AutocleanInterval \"7\";" | sudo_askpass tee /etc/apt/apt.conf.d/10periodic
  fi
  sudo_askpass chmod 644 /etc/apt/apt.conf.d/20auto-upgrades
  sudo_askpass chmod 644 /etc/apt/apt.conf.d/10periodic
  logk

  if [ -n "$STRAP_CI" ]; then
    echo "Skipping configuring firewall (ufw) in CI"
  else
    # Setting up firewall without any rules.
    log "Enabling firewall (ufw):"
    sudo_askpass apt-get -y install ufw
    sudo_askpass ufw enable
    logk
  fi
fi

if [ -x "$HOMEBREW_PREFIX/bin/gcc" ]; then
  logn "Unlink Homebrew's gcc (it's quite old, and supported distros will have newer): "
  brew unlink gcc
  logk
fi

# Setup dotfiles
if [ -n "$STRAP_GITHUB_USER" ]; then
  DOTFILES_URL="git+ssh://git@github.com/$STRAP_GITHUB_USER/dotfiles"
  if ! git ls-remote "$DOTFILES_URL" &>/dev/null; then
    DOTFILES_URL="https://github.com/$STRAP_GITHUB_USER/dotfiles"
  fi

  if git ls-remote "$DOTFILES_URL" &>/dev/null; then
    log "Fetching $STRAP_GITHUB_USER/dotfiles from GitHub:"
    if [ ! -d "$HOME/.dotfiles" ]; then
      log "Cloning to ~/.dotfiles:"
      git clone $Q "$DOTFILES_URL" ~/.dotfiles
    else
      (
        cd ~/.dotfiles
        git pull $Q --rebase --autostash
      )
    fi
    run_dotfile_scripts script/setup script/bootstrap
    logk
  fi
fi

# Setup Brewfile
if [ -n "$STRAP_GITHUB_USER" ] && { [ ! -f "$HOME/.Brewfile" ] || [ "$HOME/.Brewfile" -ef "$HOME/.homebrew-brewfile/Brewfile" ]; }; then
  HOMEBREW_BREWFILE_URL="git+ssh://git@github.com/$STRAP_GITHUB_USER/homebrew-brewfile"
  if ! git ls-remote "$HOMEBREW_BREWFILE_URL" &>/dev/null; then
    HOMEBREW_BREWFILE_URL="https://github.com/$STRAP_GITHUB_USER/homebrew-brewfile"
  fi

  if git ls-remote "$HOMEBREW_BREWFILE_URL" &>/dev/null; then
    log "Fetching $STRAP_GITHUB_USER/homebrew-brewfile from GitHub:"
    if [ ! -d "$HOME/.homebrew-brewfile" ]; then
      log "Cloning to ~/.homebrew-brewfile:"
      git clone $Q "$HOMEBREW_BREWFILE_URL" ~/.homebrew-brewfile
      logk
    else
      (
        cd ~/.homebrew-brewfile
        git pull $Q
      )
    fi
    ln -sf ~/.homebrew-brewfile/Brewfile ~/.Brewfile
    logk
  fi
fi

# Install from local Brewfile
if [ -f "$HOME/.Brewfile" ]; then
  log "Installing from user Brewfile on GitHub:"
  brew bundle check --global || brew bundle --global
  logk
fi

# Tap a custom Homebrew tap
if [ -n "$CUSTOM_HOMEBREW_TAP" ]; then
  read -ra CUSTOM_HOMEBREW_TAP <<< "$CUSTOM_HOMEBREW_TAP"
  log "Running 'brew tap ${CUSTOM_HOMEBREW_TAP[*]}':"
  brew tap "${CUSTOM_HOMEBREW_TAP[@]}"
  logk
fi

# Run a custom `brew` command
if [ -n "$CUSTOM_BREW_COMMAND" ]; then
  log "Executing 'brew $CUSTOM_BREW_COMMAND':"
  # shellcheck disable=SC2086
  brew $CUSTOM_BREW_COMMAND
  logk
fi

# Run post-install dotfiles script
run_dotfile_scripts script/strap-after-setup

STRAP_SUCCESS="1"
log "Your system is now Strap'd!"