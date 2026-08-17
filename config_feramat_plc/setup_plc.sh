#!/bin/bash

# =============================================================================
# FERAMAT PLC setup script
# =============================================================================
#
# Repository:
#   https://github.com/PokornyPavel/ConfigFiles
#
# Purpose:
#   Initial setup of a new FERAMAT PLC running Debian.
#
# Current version:
#   1.3.1
#
# Version history:
#
#   1.0.0
#     - initial PLC setup script
#     - apt update / upgrade
#     - package installation
#     - SSH public key embedded directly in the script
#     - .bashrc modified directly
#
#   1.1.0
#     - stopped modifying existing .bashrc lines with sed
#     - introduced a managed Bash configuration block
#
#   1.2.0
#     - moved aliases and prompt configuration to ~/.bash_aliases
#     - setup script no longer modifies ~/.bashrc
#
#   1.3.0
#     - moved SSH public key to standalone pokorny.pub
#     - PLC name is now a required script argument
#     - PLC name stored locally in ~/.plc_name
#     - prompt reads PLC name dynamically from ~/.plc_name
#     - added --help and --version
#
#   1.3.1
#     - changed raw GitHub URL to /refs/heads/main
#     - all downloaded files are first stored in temporary files
#     - downloaded files are checked for non-zero size
#     - existing configuration is replaced only after successful validation
#     - added basic SSH public-key format validation
#
# Full version history:
#   See CHANGELOG.md in the repository.
#
# =============================================================================

set -euo pipefail


# =============================================================================
# Script information
# =============================================================================

SCRIPT_VERSION="1.3.1"
SCRIPT_DATE="2026-08-17"

SCRIPT_DESCRIPTION="Initial configuration of a FERAMAT Debian PLC."

REPO_RAW="https://raw.githubusercontent.com/PokornyPavel/ConfigFiles/refs/heads/main"
PLC_CONFIG_RAW="$REPO_RAW/config_feramat_plc"


# =============================================================================
# Functions
# =============================================================================

show_version() {
    echo "FERAMAT PLC setup v$SCRIPT_VERSION ($SCRIPT_DATE)"
    echo "$SCRIPT_DESCRIPTION"
}


show_help() {
    show_version

    echo
    echo "Usage:"
    echo
    echo "    $0 PLC_NAME"
    echo
    echo "Options:"
    echo
    echo "    --help       Show this help"
    echo "    --version    Show script version"
    echo
    echo "Example:"
    echo
    echo "    $0 JABLONEC_PLC"
    echo
    echo "PLC name is used in the Bash prompt."
    echo
    echo "Allowed characters:"
    echo
    echo "    A-Z a-z 0-9 _ - ."
}


download_file() {
    local url="$1"
    local destination="$2"
    local description="$3"

    local tmp_file

    tmp_file="$(mktemp)"

    echo "      Downloading $description..."

    if ! curl -fsSL "$url" -o "$tmp_file"; then
        echo
        echo "ERROR: Failed to download:"
        echo
        echo "    $url"
        echo
        rm -f "$tmp_file"
        exit 1
    fi

    if [ ! -s "$tmp_file" ]; then
        echo
        echo "ERROR: Downloaded file is empty:"
        echo
        echo "    $url"
        echo
        echo "Existing file was NOT modified:"
        echo
        echo "    $destination"
        echo
        rm -f "$tmp_file"
        exit 1
    fi

    mv "$tmp_file" "$destination"

    echo "      Installed: $destination"
}


# =============================================================================
# Command-line arguments
# =============================================================================

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
    exit 0
fi

if [ "${1:-}" = "--version" ] || [ "${1:-}" = "-v" ]; then
    show_version
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo
    echo "ERROR: PLC name is required."
    echo
    show_help
    exit 1
fi

PLC_NAME="$1"


# =============================================================================
# Validate PLC name
# =============================================================================

if [[ ! "$PLC_NAME" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo
    echo "ERROR: Invalid PLC name:"
    echo
    echo "    $PLC_NAME"
    echo
    echo "Allowed characters:"
    echo
    echo "    A-Z a-z 0-9 _ - ."
    echo
    echo "Example:"
    echo
    echo "    $0 JABLONEC_PLC"
    echo
    exit 1
fi


# =============================================================================
# Start
# =============================================================================

echo
echo "=============================================="
echo " FERAMAT PLC setup v$SCRIPT_VERSION"
echo "=============================================="
echo
echo "PLC name:"
echo "    $PLC_NAME"
echo


# =============================================================================
# 1. System update
# =============================================================================

echo "[1/8] Updating system..."

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y


# =============================================================================
# 2. Install packages
# =============================================================================

echo
echo "[2/8] Installing packages..."

sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    vim \
    tcpdump \
    nmap \
    tmux \
    curl


# =============================================================================
# 3. Vim configuration
# =============================================================================

echo
echo "[3/8] Installing Vim configuration..."

download_file \
    "$REPO_RAW/.vimrc" \
    "$HOME/.vimrc" \
    ".vimrc"


# =============================================================================
# 4. Bash aliases and prompt
# =============================================================================

echo
echo "[4/8] Installing Bash configuration..."

download_file \
    "$PLC_CONFIG_RAW/.bash_aliases" \
    "$HOME/.bash_aliases" \
    ".bash_aliases"


# =============================================================================
# 5. PLC name
# =============================================================================

echo
echo "[5/8] Configuring PLC name..."

cat > "$HOME/.plc_name" <<EOF
# Generated by setup_plc.sh
PLC_NAME='$PLC_NAME'
EOF

chmod 600 "$HOME/.plc_name"

echo "      PLC_NAME=$PLC_NAME"


# Verify that ~/.bashrc loads ~/.bash_aliases.
# Do not modify ~/.bashrc automatically.

if grep -q '\.bash_aliases' "$HOME/.bashrc"; then
    echo "      ~/.bashrc loads ~/.bash_aliases"
else
    echo
    echo "WARNING:"
    echo "    ~/.bashrc does not appear to load ~/.bash_aliases."
    echo
    echo "The setup script intentionally did NOT modify ~/.bashrc."
    echo
    echo "Add this manually if required:"
    echo
    echo '    if [ -f ~/.bash_aliases ]; then'
    echo '        . ~/.bash_aliases'
    echo '    fi'
    echo
fi


# =============================================================================
# 6. tmux configuration
# =============================================================================

echo
echo "[6/8] Installing tmux configuration..."

download_file \
    "$REPO_RAW/.tmux.conf" \
    "$HOME/.tmux.conf" \
    ".tmux.conf"


# =============================================================================
# 7. MOTD
# =============================================================================

echo
echo "[7/8] Installing MOTD..."

sudo tee /etc/motd > /dev/null <<'EOF'
  _____ _____ ____      _    __  __    _  _____
 |  ___| ____|  _ \    / \  |  \/  |  / \|_   _|
 | |_  |  _| | |_) |  / _ \ | |\/| | / _ \ | |
 |  _| | |___|  _ <  / ___ \| |  | |/ ___ \| |
 |_|   |_____|_| \_\/_/   \_\_|  |_/_/   \_\_|

   ___ _ __   ___ _ __ __ _(_) ___  ___
  / _ \ '_ \ / _ \ '__/ _` | |/ _ \/ __|
 |  __/ | | |  __/ | | (_| | |  __/\__ \
  \___|_| |_|\___|_|  \__, |_|\___||___/
                      |___/
EOF


# =============================================================================
# 8. SSH public key
# =============================================================================

echo
echo "[8/8] Installing SSH public key..."

TMP_KEY="$(mktemp)"

cleanup() {
    rm -f "$TMP_KEY"
}

trap cleanup EXIT


if ! curl -fsSL \
    "$PLC_CONFIG_RAW/pokorny.pub" \
    -o "$TMP_KEY"; then

    echo
    echo "ERROR: Failed to download SSH public key:"
    echo
    echo "    $PLC_CONFIG_RAW/pokorny.pub"
    echo
    exit 1
fi


if [ ! -s "$TMP_KEY" ]; then
    echo
    echo "ERROR: Downloaded SSH public key is empty."
    echo
    exit 1
fi


# Basic public-key validation

if ! grep -qE '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-)' "$TMP_KEY"; then
    echo
    echo "ERROR: Downloaded pokorny.pub does not look like a valid SSH public key."
    echo
    echo "File was downloaded from:"
    echo
    echo "    $REPO_RAW/pokorny.pub"
    echo
    exit 1
fi


# Public key must contain exactly one non-empty line.

NONEMPTY_LINES="$(grep -cve '^[[:space:]]*$' "$TMP_KEY")"

if [ "$NONEMPTY_LINES" -ne 1 ]; then
    echo
    echo "ERROR: pokorny.pub should contain exactly one SSH public key."
    echo
    echo "Non-empty lines found:"
    echo
    echo "    $NONEMPTY_LINES"
    echo
    exit 1
fi


mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

SSH_KEY="$(cat "$TMP_KEY")"

if grep -qxF "$SSH_KEY" "$HOME/.ssh/authorized_keys"; then
    echo "      SSH key already installed."
else
    echo "$SSH_KEY" >> "$HOME/.ssh/authorized_keys"
    echo "      SSH key installed."
fi


# =============================================================================
# Finished
# =============================================================================

echo
echo "=============================================="
echo " PLC setup finished"
echo "=============================================="
echo
echo "PLC:"
echo "    $PLC_NAME"
echo
echo "Setup version:"
echo "    $SCRIPT_VERSION"
echo
echo "Installed configuration:"
echo
echo "    ~/.vimrc"
echo "    ~/.bash_aliases"
echo "    ~/.plc_name"
echo "    ~/.tmux.conf"
echo "    ~/.ssh/authorized_keys"
echo "    /etc/motd"
echo
echo "Activate the new Bash configuration with:"
echo
echo "    source ~/.bashrc"
echo
echo "or reconnect via SSH."
echo